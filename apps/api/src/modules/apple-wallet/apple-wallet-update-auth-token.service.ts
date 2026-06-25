import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac, timingSafeEqual } from 'crypto';

const tokenPrefix = 'waflo_apple_update_v1';
const tokenVersion = 1;
const tokenPattern =
  /^waflo_apple_update_v1\.(\d+)\.(\d{13})\.([A-Za-z0-9_-]{43})\.([A-Za-z0-9_-]{43})$/;

export type AppleUpdateAuthTokenPassFields = {
  id: string;
  businessId: string;
  membershipId: string;
  appleUpdateAuthTokenHash: string | null;
  appleUpdateAuthTokenVersion: number | null;
  appleUpdateAuthTokenIssuedAt: Date | null;
  appleUpdateAuthTokenLast4: string | null;
};

export type AppleUpdateAuthTokenMetadata = {
  rawToken: string;
  tokenHash: string;
  tokenVersion: number;
  tokenIssuedAt: Date;
  tokenLast4: string;
};

@Injectable()
export class AppleWalletUpdateAuthTokenService {
  readonly currentVersion = tokenVersion;

  constructor(private readonly configService: ConfigService) {}

  buildMetadataForPass(
    pass: AppleUpdateAuthTokenPassFields,
    issuedAt = pass.appleUpdateAuthTokenIssuedAt ?? new Date(),
    version = pass.appleUpdateAuthTokenVersion ?? this.currentVersion
  ): AppleUpdateAuthTokenMetadata {
    const rawToken = this.buildRawToken({
      id: pass.id,
      businessId: pass.businessId,
      membershipId: pass.membershipId,
      issuedAt,
      version
    });

    return {
      rawToken,
      tokenHash: this.hashToken(rawToken),
      tokenVersion: version,
      tokenIssuedAt: issuedAt,
      tokenLast4: rawToken.slice(-4)
    };
  }

  hashToken(token: string) {
    return this.hmacHex('lookup', token.trim());
  }

  hashDeviceLibraryIdentifier(identifier: string) {
    return this.hmacHex('device', identifier.trim());
  }

  verifyForPass(token: string, pass: AppleUpdateAuthTokenPassFields) {
    const normalized = token.trim();
    const match = tokenPattern.exec(normalized);

    if (
      !match ||
      !pass.appleUpdateAuthTokenHash ||
      !pass.appleUpdateAuthTokenVersion ||
      !pass.appleUpdateAuthTokenIssuedAt
    ) {
      return false;
    }

    const version = Number(match[1]);
    const issuedAtMs = Number(match[2]);

    if (
      version !== pass.appleUpdateAuthTokenVersion ||
      issuedAtMs !== pass.appleUpdateAuthTokenIssuedAt.getTime() ||
      !this.safeEqual(this.hashToken(normalized), pass.appleUpdateAuthTokenHash)
    ) {
      return false;
    }

    const expected = this.buildMetadataForPass(
      pass,
      pass.appleUpdateAuthTokenIssuedAt,
      pass.appleUpdateAuthTokenVersion
    ).rawToken;

    return this.safeEqual(normalized, expected);
  }

  private buildRawToken(input: {
    id: string;
    businessId: string;
    membershipId: string;
    issuedAt: Date;
    version: number;
  }) {
    const issuedAtMs = input.issuedAt.getTime();
    const opaque = this.hmacBase64Url(
      'body',
      [
        input.id,
        input.businessId,
        input.membershipId,
        input.version,
        issuedAtMs
      ].join(':')
    );
    const signature = this.hmacBase64Url(
      'signature',
      `${input.version}.${issuedAtMs}.${opaque}`
    );

    return `${tokenPrefix}.${input.version}.${issuedAtMs}.${opaque}.${signature}`;
  }

  private hmacBase64Url(purpose: string, value: string) {
    return createHmac('sha256', this.getSecret())
      .update(`apple-wallet-update:${purpose}:${value}`)
      .digest('base64url');
  }

  private hmacHex(purpose: string, value: string) {
    return createHmac('sha256', this.getSecret())
      .update(`apple-wallet-update:${purpose}:${value}`)
      .digest('hex');
  }

  private safeEqual(left: string, right: string) {
    const leftBuffer = Buffer.from(left);
    const rightBuffer = Buffer.from(right);

    return (
      leftBuffer.length === rightBuffer.length &&
      timingSafeEqual(leftBuffer, rightBuffer)
    );
  }

  private getSecret() {
    const secret =
      this.configService
        .get<string>('APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET')
        ?.trim() ?? '';

    if (secret.length < 32) {
      throw new Error(
        'APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET must be at least 32 characters'
      );
    }

    return secret;
  }
}

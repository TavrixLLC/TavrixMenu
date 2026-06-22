import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac, timingSafeEqual } from 'crypto';

const tokenPrefix = 'waflo_scan_v1';
const tokenVersion = 1;
const tokenPattern =
  /^waflo_scan_v1\.(\d+)\.(\d{13})\.([A-Za-z0-9_-]{43})\.([A-Za-z0-9_-]{43})$/;

export type WalletScanTokenPassFields = {
  id: string;
  businessId: string;
  membershipId: string;
  scanTokenHash: string | null;
  scanTokenVersion: number | null;
  scanTokenIssuedAt: Date | null;
  scanTokenLast4: string | null;
};

export type WalletScanTokenMetadata = {
  rawToken: string;
  scanTokenHash: string;
  scanTokenVersion: number;
  scanTokenIssuedAt: Date;
  scanTokenLast4: string;
};

type ParsedWalletScanToken = {
  token: string;
  version: number;
  issuedAtMs: number;
};

@Injectable()
export class WalletScanTokenService {
  readonly currentVersion = tokenVersion;

  constructor(private readonly configService: ConfigService) {}

  buildMetadataForPass(
    pass: WalletScanTokenPassFields,
    issuedAt: Date = pass.scanTokenIssuedAt ?? new Date(),
    version = pass.scanTokenVersion ?? this.currentVersion
  ): WalletScanTokenMetadata {
    const rawToken = this.buildRawToken({
      id: pass.id,
      businessId: pass.businessId,
      membershipId: pass.membershipId,
      version,
      issuedAt
    });

    return {
      rawToken,
      scanTokenHash: this.hashToken(rawToken),
      scanTokenVersion: version,
      scanTokenIssuedAt: issuedAt,
      scanTokenLast4: rawToken.slice(-4)
    };
  }

  hashToken(token: string) {
    return this.hmacHex('wallet-scan-lookup', this.normalizeToken(token));
  }

  parse(token: string): ParsedWalletScanToken | null {
    const normalized = this.normalizeToken(token);

    if (normalized.length > 256) {
      return null;
    }

    const match = tokenPattern.exec(normalized);

    if (!match) {
      return null;
    }

    const version = Number(match[1]);
    const issuedAtMs = Number(match[2]);

    if (
      !Number.isSafeInteger(version) ||
      version <= 0 ||
      !Number.isSafeInteger(issuedAtMs)
    ) {
      return null;
    }

    return {
      token: normalized,
      version,
      issuedAtMs
    };
  }

  verifyForPass(token: string, pass: WalletScanTokenPassFields) {
    const parsed = this.parse(token);

    if (
      !parsed ||
      !pass.scanTokenHash ||
      !pass.scanTokenVersion ||
      !pass.scanTokenIssuedAt
    ) {
      return false;
    }

    if (
      parsed.version !== pass.scanTokenVersion ||
      parsed.issuedAtMs !== pass.scanTokenIssuedAt.getTime()
    ) {
      return false;
    }

    if (!this.safeEqual(this.hashToken(parsed.token), pass.scanTokenHash)) {
      return false;
    }

    const expectedToken = this.buildMetadataForPass(
      pass,
      pass.scanTokenIssuedAt,
      pass.scanTokenVersion
    ).rawToken;

    return this.safeEqual(parsed.token, expectedToken);
  }

  private buildRawToken(input: {
    id: string;
    businessId: string;
    membershipId: string;
    version: number;
    issuedAt: Date;
  }) {
    const issuedAtMs = input.issuedAt.getTime();
    const bodyInput = [
      input.id,
      input.businessId,
      input.membershipId,
      input.version,
      issuedAtMs
    ].join(':');
    const opaque = this.hmacBase64Url('wallet-scan-body', bodyInput);
    const signature = this.hmacBase64Url(
      'wallet-scan-signature',
      `${input.version}.${issuedAtMs}.${opaque}`
    );

    return `${tokenPrefix}.${input.version}.${issuedAtMs}.${opaque}.${signature}`;
  }

  private normalizeToken(token: string) {
    return token.trim();
  }

  private hmacBase64Url(purpose: string, value: string) {
    return createHmac('sha256', this.getSecret())
      .update(`${purpose}:${value}`)
      .digest('base64url');
  }

  private hmacHex(purpose: string, value: string) {
    return createHmac('sha256', this.getSecret())
      .update(`${purpose}:${value}`)
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
      this.configService.get<string>('WALLET_SCAN_TOKEN_SECRET')?.trim() ?? '';

    if (secret.length < 32) {
      throw new Error('WALLET_SCAN_TOKEN_SECRET must be at least 32 characters');
    }

    return secret;
  }
}

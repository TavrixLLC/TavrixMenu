import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  createPublicKey,
  JsonWebKey,
  verify as verifyCryptoSignature
} from 'node:crypto';
import { ClerkVerifiedUser } from './interfaces/clerk-verified-user.interface';

type JwtHeader = {
  alg?: string;
  kid?: string;
};

type ClerkJwtClaims = {
  sub?: string;
  iss?: string;
  exp?: number;
  nbf?: number;
  email?: string;
  primary_email_address?: string;
  name?: string;
  full_name?: string;
  phone?: string;
  phone_number?: string;
};

type JwksResponse = {
  keys?: JsonWebKey[];
};

@Injectable()
export class ClerkTokenVerifierService {
  private readonly jwksCacheTtlMs = 5 * 60 * 1000;
  private jwksCache?: { fetchedAt: number; keys: JsonWebKey[] };

  constructor(private readonly configService: ConfigService) {}

  async verifyToken(token: string): Promise<ClerkVerifiedUser> {
    if (token.startsWith('dev:')) {
      return this.verifyDevelopmentToken(token);
    }

    return this.verifyClerkJwt(token);
  }

  private verifyDevelopmentToken(token: string): ClerkVerifiedUser {
    const nodeEnv = this.configService.get<string>('NODE_ENV', 'development');

    if (nodeEnv !== 'development') {
      throw new UnauthorizedException(
        'Development auth tokens are blocked outside development'
      );
    }

    const rawToken = token.slice('dev:'.length).trim();
    const [clerkUserId, ...metadataParts] = rawToken.split(';');

    if (!clerkUserId) {
      throw new UnauthorizedException('Invalid development auth token');
    }

    const metadata = metadataParts.reduce<Record<string, string>>(
      (accumulator, part) => {
        const separatorIndex = part.indexOf('=');

        if (separatorIndex === -1) {
          return accumulator;
        }

        const key = part.slice(0, separatorIndex);
        const value = part.slice(separatorIndex + 1);

        if (key) {
          accumulator[key] = this.decodeDevelopmentTokenValue(value);
        }

        return accumulator;
      },
      {}
    );

    return {
      clerkUserId,
      email: metadata.email,
      name: metadata.name,
      phone: metadata.phone
    };
  }

  private async verifyClerkJwt(token: string): Promise<ClerkVerifiedUser> {
    const issuer = this.configService.get<string>('CLERK_JWT_ISSUER');

    if (!issuer) {
      // TODO: Configure CLERK_JWT_ISSUER from the Clerk instance before using
      // real Clerk JWTs in staging or production.
      throw new UnauthorizedException(
        'Clerk JWT verification is not configured'
      );
    }

    const [encodedHeader, encodedPayload, encodedSignature] = token.split('.');

    if (!encodedHeader || !encodedPayload || !encodedSignature) {
      throw new UnauthorizedException('Invalid bearer token');
    }

    const header = this.decodeJwtPart<JwtHeader>(encodedHeader);
    const claims = this.decodeJwtPart<ClerkJwtClaims>(encodedPayload);

    if (header.alg !== 'RS256' || !header.kid) {
      throw new UnauthorizedException('Unsupported Clerk token');
    }

    const normalizedIssuer = this.normalizeIssuer(issuer);

    if (claims.iss !== normalizedIssuer) {
      throw new UnauthorizedException('Invalid Clerk token issuer');
    }

    const nowInSeconds = Math.floor(Date.now() / 1000);

    if (typeof claims.exp !== 'number' || claims.exp <= nowInSeconds) {
      throw new UnauthorizedException('Expired Clerk token');
    }

    if (typeof claims.nbf === 'number' && claims.nbf > nowInSeconds) {
      throw new UnauthorizedException('Clerk token is not active yet');
    }

    if (!claims.sub) {
      throw new UnauthorizedException('Clerk token is missing a subject');
    }

    const signingKey = await this.getSigningKey(header.kid);
    const publicKey = createPublicKey({ key: signingKey, format: 'jwk' });
    const signingInput = `${encodedHeader}.${encodedPayload}`;
    const signature = this.decodeBase64Url(encodedSignature);
    const isValid = verifyCryptoSignature(
      'RSA-SHA256',
      Buffer.from(signingInput),
      publicKey,
      signature
    );

    if (!isValid) {
      throw new UnauthorizedException('Invalid Clerk token signature');
    }

    return {
      clerkUserId: claims.sub,
      email: claims.email ?? claims.primary_email_address,
      name: claims.name ?? claims.full_name,
      phone: claims.phone ?? claims.phone_number
    };
  }

  private async getSigningKey(kid: string): Promise<JsonWebKey> {
    const cachedKeys = await this.getJwks(false);
    const cachedKey = cachedKeys.find((key) => key.kid === kid);

    if (cachedKey) {
      return cachedKey;
    }

    const refreshedKeys = await this.getJwks(true);
    const refreshedKey = refreshedKeys.find((key) => key.kid === kid);

    if (!refreshedKey) {
      throw new UnauthorizedException('Clerk signing key was not found');
    }

    return refreshedKey;
  }

  private async getJwks(forceRefresh: boolean): Promise<JsonWebKey[]> {
    const now = Date.now();

    if (
      !forceRefresh &&
      this.jwksCache &&
      now - this.jwksCache.fetchedAt < this.jwksCacheTtlMs
    ) {
      return this.jwksCache.keys;
    }

    const issuer = this.configService.get<string>('CLERK_JWT_ISSUER');

    if (!issuer) {
      throw new UnauthorizedException(
        'Clerk JWT verification is not configured'
      );
    }

    const jwksUrl =
      this.configService.get<string>('CLERK_JWKS_URL') ??
      `${this.normalizeIssuer(issuer)}/.well-known/jwks.json`;
    const response = await fetch(jwksUrl);

    if (!response.ok) {
      throw new UnauthorizedException('Unable to fetch Clerk signing keys');
    }

    const jwks = (await response.json()) as JwksResponse;

    if (!Array.isArray(jwks.keys)) {
      throw new UnauthorizedException('Invalid Clerk JWKS response');
    }

    this.jwksCache = {
      fetchedAt: now,
      keys: jwks.keys
    };

    return jwks.keys;
  }

  private decodeJwtPart<T>(encodedValue: string): T {
    try {
      return JSON.parse(this.decodeBase64Url(encodedValue).toString('utf8')) as T;
    } catch {
      throw new UnauthorizedException('Invalid bearer token');
    }
  }

  private decodeBase64Url(encodedValue: string): Buffer {
    const normalizedValue = encodedValue.replace(/-/g, '+').replace(/_/g, '/');
    const paddingLength = (4 - (normalizedValue.length % 4)) % 4;
    const paddedValue = `${normalizedValue}${'='.repeat(paddingLength)}`;

    return Buffer.from(paddedValue, 'base64');
  }

  private decodeDevelopmentTokenValue(value: string): string {
    try {
      return decodeURIComponent(value);
    } catch {
      return value;
    }
  }

  private normalizeIssuer(issuer: string): string {
    return issuer.replace(/\/+$/, '');
  }
}

import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import { createHash } from 'crypto';
import {
  WalletPassPlatform,
  WalletPassStatus
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { PublicLoyaltyService } from '../loyalty/public-loyalty.service';
import { resolveAppleWalletPassTheme } from './apple-wallet-pass-theme';
import { AppleWalletService } from './apple-wallet.service';
import {
  AppleUpdateAuthTokenMetadata,
  AppleWalletUpdateAuthTokenService
} from './apple-wallet-update-auth-token.service';

export const APPLE_WALLET_PASS_CONTENT_TYPE =
  'application/vnd.apple.pkpass';
export const APPLE_WALLET_PASS_FILE_NAME = 'waflo-loyalty.pkpass';

export type PublicAppleWalletErrorCode =
  | 'APPLE_WALLET_DISABLED'
  | 'APPLE_WALLET_NOT_CONFIGURED'
  | 'PUBLIC_LOYALTY_CARD_NOT_FOUND'
  | 'APPLE_WALLET_SIGNING_FAILED';

export type PublicAppleWalletPassFile = {
  pass: Buffer;
  fileName: typeof APPLE_WALLET_PASS_FILE_NAME;
};

@Injectable()
export class PublicAppleWalletPassService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly publicLoyaltyService: PublicLoyaltyService,
    private readonly appleWalletService: AppleWalletService,
    private readonly updateAuthTokenService: AppleWalletUpdateAuthTokenService
  ) {}

  async generatePublicPass(token: string): Promise<PublicAppleWalletPassFile> {
    const readiness = this.appleWalletService.getReadiness();

    if (readiness === 'DISABLED') {
      throw this.safeError(
        HttpStatus.SERVICE_UNAVAILABLE,
        'APPLE_WALLET_DISABLED'
      );
    }

    if (readiness !== 'READY') {
      throw this.safeError(
        HttpStatus.SERVICE_UNAVAILABLE,
        'APPLE_WALLET_NOT_CONFIGURED'
      );
    }

    const membership = await this.resolveMembership(token);
    const walletPass = await this.prisma.walletPass.upsert({
      where: {
        membershipId_platform: {
          membershipId: membership.id,
          platform: WalletPassPlatform.APPLE_WALLET
        }
      },
      create: {
        businessId: membership.businessId,
        membershipId: membership.id,
        platform: WalletPassPlatform.APPLE_WALLET,
        status: WalletPassStatus.PENDING,
        syncError: null
      },
      update: {
        businessId: membership.businessId,
        status: WalletPassStatus.PENDING,
        syncError: null
      }
    });

    try {
      const updateToken = this.buildUpdateToken(walletPass);
      const generated = await this.appleWalletService.generatePass({
        serialNumber: this.buildSerialNumber(walletPass.id),
        businessName: membership.business.name,
        programName: membership.loyaltyProgram.name,
        programDescription:
          membership.loyaltyProgram.description ?? undefined,
        stampCount: membership.stampCount,
        stampGoal: membership.loyaltyProgram.stampGoal,
        rewardName: membership.loyaltyProgram.rewardName,
        rewardDescription:
          membership.loyaltyProgram.rewardDescription ??
          membership.loyaltyProgram.rewardName,
        terms: membership.loyaltyProgram.terms ?? undefined,
        theme: resolveAppleWalletPassTheme(membership.loyaltyProgram),
        updateAuthenticationToken: updateToken?.rawToken,
        scanTokenPass: {
          id: walletPass.id,
          businessId: walletPass.businessId,
          membershipId: walletPass.membershipId,
          scanTokenHash: null,
          scanTokenVersion: null,
          scanTokenIssuedAt: null,
          scanTokenLast4: null
        }
      });
      const lastSyncedAt = new Date();

      await this.prisma.walletPass.update({
        where: {
          id: walletPass.id
        },
        data: {
          scanTokenHash: generated.scanTokenMetadata.scanTokenHash,
          scanTokenVersion: generated.scanTokenMetadata.scanTokenVersion,
          scanTokenIssuedAt: generated.scanTokenMetadata.scanTokenIssuedAt,
          scanTokenLast4: generated.scanTokenMetadata.scanTokenLast4,
          applePassTypeIdentifier: generated.metadata.passTypeIdentifier,
          appleSerialNumber: generated.metadata.serialNumber,
          applePassUpdatedAt: lastSyncedAt,
          ...this.updateTokenFields(updateToken),
          status: WalletPassStatus.ACTIVE,
          lastSyncedAt,
          syncError: null
        }
      });

      return {
        pass: generated.pass,
        fileName: APPLE_WALLET_PASS_FILE_NAME
      };
    } catch {
      await this.markSigningFailure(walletPass.id);
      throw this.safeError(
        HttpStatus.BAD_GATEWAY,
        'APPLE_WALLET_SIGNING_FAILED'
      );
    }
  }

  private buildUpdateToken(walletPass: {
    id: string;
    businessId: string;
    membershipId: string;
    appleUpdateAuthTokenHash: string | null;
    appleUpdateAuthTokenVersion: number | null;
    appleUpdateAuthTokenIssuedAt: Date | null;
    appleUpdateAuthTokenLast4: string | null;
  }) {
    if (this.appleWalletService.getUpdateWebServiceReadiness() !== 'READY') {
      return null;
    }

    return this.updateAuthTokenService.buildMetadataForPass(walletPass);
  }

  private updateTokenFields(metadata: AppleUpdateAuthTokenMetadata | null) {
    if (!metadata) {
      return {};
    }

    return {
      appleUpdateAuthTokenHash: metadata.tokenHash,
      appleUpdateAuthTokenVersion: metadata.tokenVersion,
      appleUpdateAuthTokenIssuedAt: metadata.tokenIssuedAt,
      appleUpdateAuthTokenLast4: metadata.tokenLast4
    };
  }

  private async resolveMembership(token: string) {
    try {
      return await this.publicLoyaltyService.findMembershipByPublicCardToken(
        token
      );
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof BadRequestException
      ) {
        throw this.safeError(
          HttpStatus.NOT_FOUND,
          'PUBLIC_LOYALTY_CARD_NOT_FOUND'
        );
      }

      throw error;
    }
  }

  private async markSigningFailure(walletPassId: string) {
    try {
      await this.prisma.walletPass.update({
        where: {
          id: walletPassId
        },
        data: {
          status: WalletPassStatus.ERROR,
          lastSyncedAt: new Date(),
          syncError: 'APPLE_WALLET_SIGNING_FAILED'
        }
      });
    } catch {
      // Preserve the public-safe signing error even if status persistence fails.
    }
  }

  private buildSerialNumber(walletPassId: string) {
    const opaqueId = createHash('sha256')
      .update(walletPassId)
      .digest('hex')
      .slice(0, 24);

    return `waflo-apple-${opaqueId}`;
  }

  private safeError(status: HttpStatus, code: PublicAppleWalletErrorCode) {
    const messages: Record<PublicAppleWalletErrorCode, string> = {
      APPLE_WALLET_DISABLED: 'Apple Wallet is unavailable',
      APPLE_WALLET_NOT_CONFIGURED: 'Apple Wallet is unavailable',
      PUBLIC_LOYALTY_CARD_NOT_FOUND: 'Loyalty card not found',
      APPLE_WALLET_SIGNING_FAILED: 'Apple Wallet pass generation failed'
    };

    return new HttpException(
      {
        statusCode: status,
        code,
        message: messages[code]
      },
      status
    );
  }
}

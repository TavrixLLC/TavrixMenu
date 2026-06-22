import {
  BadGatewayException,
  BadRequestException,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import { createHash } from 'crypto';
import {
  BusinessStatus,
  BusinessUserRole,
  LoyaltyMembershipStatus,
  Prisma,
  WalletPass,
  WalletPassPlatform,
  WalletPassStatus
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessAccessService } from '../businesses/business-access.service';
import { StampImageStorageService } from '../loyalty/stamp-image-storage.service';
import {
  resolveWalletPassVisual,
  resolveWalletPassVisualTheme,
  WalletPassVisualModel
} from '../loyalty/wallet-pass-visual.resolver';
import { GoogleWalletApiError } from './google-wallet-api.client';
import { GoogleWalletService } from './google-wallet.service';
import {
  WalletScanTokenMetadata,
  WalletScanTokenService
} from './wallet-scan-token.service';

export type WalletMembership = Prisma.LoyaltyMembershipGetPayload<{
  include: {
    business: true;
    customer: true;
    loyaltyProgram: {
      include: {
        stampStyle: true;
      };
    };
  };
}>;

export type GoogleWalletPassResponse = {
  platform: WalletPassPlatform;
  membershipId: string;
  googleClassId: string;
  googleObjectId: string;
  saveUrl: string;
  status: WalletPassStatus;
  lastSyncedAt: Date;
};

export type GoogleWalletPassRefreshResult =
  | {
      status: 'SKIPPED_DISABLED' | 'SKIPPED_NO_PASS';
    }
  | {
      status: 'REFRESHED';
      platform: WalletPassPlatform;
      membershipId: string;
      googleObjectId: string;
      lastSyncedAt: Date;
    }
  | {
      status: 'FAILED';
      platform: WalletPassPlatform;
      membershipId: string;
      error: string;
    };

@Injectable()
export class WalletPassService {
  private readonly staffRoles = [
    BusinessUserRole.OWNER,
    BusinessUserRole.MANAGER,
    BusinessUserRole.STAFF
  ];

  constructor(
    private readonly prisma: PrismaService,
    private readonly businessAccessService: BusinessAccessService,
    private readonly googleWalletService: GoogleWalletService,
    private readonly walletScanTokenService: WalletScanTokenService,
    private readonly stampImageStorageService: StampImageStorageService
  ) {}

  async syncGoogleWalletPass(
    currentUser: AuthenticatedUser,
    businessId: string,
    membershipId: string
  ): Promise<GoogleWalletPassResponse> {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const membership = await this.findMembership(businessId, membershipId);

    return this.syncResolvedGoogleWalletPass(membership);
  }

  async syncResolvedGoogleWalletPass(
    membership: WalletMembership
  ): Promise<GoogleWalletPassResponse> {
    this.assertSyncableMembership(membership);

    let pass = await this.createOrReusePendingPass(membership);

    try {
      const barcodeToken = await this.ensureScanToken(pass);
      pass = barcodeToken.pass;

      const visual = this.resolveVisual(membership);
      const heroImageUrl = await this.renderHeroImage(membership, visual);
      const classSuffix = this.buildClassSuffix(membership);
      const objectSuffix = this.buildObjectSuffix(membership);
      const classPayload = this.googleWalletService.buildLoyaltyClassPayload({
        classSuffix,
        issuerName: visual.businessName,
        programName: visual.programName,
        logoUrl: visual.logoUrl ?? undefined,
        rewardDescription:
          membership.loyaltyProgram.rewardDescription ??
          membership.loyaltyProgram.rewardName,
        hexBackgroundColor: visual.theme.walletBackgroundColor
      });
      const objectPayload = this.googleWalletService.buildLoyaltyObjectPayload({
        classSuffix,
        objectSuffix,
        accountName: this.buildAccountName(membership),
        accountId: this.buildAccountId(pass),
        stampCount: visual.stampCount,
        stampGoal: visual.stampGoal,
        rewardName: visual.rewardName,
        barcodeValue: barcodeToken.metadata.rawToken,
        barcodeAlternateText: this.buildBarcodeAlternateText(
          barcodeToken.metadata.scanTokenLast4
        ),
        heroImageUrl,
        heroImageDescription: `${visual.programName} stamp progress`
      });

      await this.googleWalletService.upsertLoyaltyClass(classPayload);
      await this.googleWalletService.upsertLoyaltyObject(objectPayload);

      const saveUrl = this.googleWalletService.generateSaveUrl({
        loyaltyObject: objectPayload
      });
      const lastSyncedAt = new Date();

      pass = await this.prisma.walletPass.update({
        where: {
          id: pass.id
        },
        data: {
          googleClassId: classPayload.id,
          googleObjectId: objectPayload.id,
          saveUrl,
          heroImageUrl,
          status: WalletPassStatus.ACTIVE,
          lastSyncedAt,
          syncError: null
        }
      });

      return {
        platform: pass.platform,
        membershipId: pass.membershipId,
        googleClassId: classPayload.id,
        googleObjectId: objectPayload.id,
        saveUrl,
        status: pass.status,
        lastSyncedAt: pass.lastSyncedAt ?? lastSyncedAt
      };
    } catch (error) {
      await this.prisma.walletPass.update({
        where: {
          id: pass.id
        },
        data: {
          status: WalletPassStatus.ERROR,
          syncError: this.sanitizeSyncError(error),
          lastSyncedAt: new Date()
        }
      });

      throw new BadGatewayException('Google Wallet sync failed');
    }
  }

  async refreshGoogleWalletPassForMembership(
    membershipId: string
  ): Promise<GoogleWalletPassRefreshResult> {
    if (!this.googleWalletService.isEnabled()) {
      return {
        status: 'SKIPPED_DISABLED'
      };
    }

    let pass = await this.prisma.walletPass.findFirst({
      where: {
        membershipId,
        platform: WalletPassPlatform.GOOGLE_WALLET
      }
    });

    if (!pass) {
      return {
        status: 'SKIPPED_NO_PASS'
      };
    }

    try {
      const membership = await this.findMembershipById(membershipId);

      this.assertSyncableMembership(membership);

      const barcodeToken = await this.ensureScanToken(pass);
      pass = barcodeToken.pass;

      const visual = this.resolveVisual(membership);
      const heroImageUrl = await this.renderHeroImage(membership, visual);
      const classSuffix = this.buildClassSuffix(membership);
      const objectSuffix = this.buildObjectSuffix(membership);
      const objectPayload = this.googleWalletService.buildLoyaltyObjectPayload({
        classSuffix,
        objectSuffix,
        accountName: this.buildAccountName(membership),
        accountId: this.buildAccountId(pass),
        stampCount: visual.stampCount,
        stampGoal: visual.stampGoal,
        rewardName: visual.rewardName,
        barcodeValue: barcodeToken.metadata.rawToken,
        barcodeAlternateText: this.buildBarcodeAlternateText(
          barcodeToken.metadata.scanTokenLast4
        ),
        heroImageUrl,
        heroImageDescription: `${visual.programName} stamp progress`
      });

      await this.googleWalletService.upsertLoyaltyObject(objectPayload);

      const lastSyncedAt = new Date();
      const updatedPass = await this.prisma.walletPass.update({
        where: {
          id: pass.id
        },
        data: {
          googleObjectId: objectPayload.id,
          heroImageUrl,
          status: WalletPassStatus.ACTIVE,
          lastSyncedAt,
          syncError: null
        }
      });

      return {
        status: 'REFRESHED',
        platform: updatedPass.platform,
        membershipId: updatedPass.membershipId,
        googleObjectId: objectPayload.id,
        lastSyncedAt: updatedPass.lastSyncedAt ?? lastSyncedAt
      };
    } catch (error) {
      const syncError = this.sanitizeSyncError(error);

      await this.prisma.walletPass.update({
        where: {
          id: pass.id
        },
        data: {
          status: WalletPassStatus.ERROR,
          syncError,
          lastSyncedAt: new Date()
        }
      });

      return {
        status: 'FAILED',
        platform: pass.platform,
        membershipId: pass.membershipId,
        error: syncError
      };
    }
  }

  private assertSyncableMembership(membership: WalletMembership) {
    if (membership.business.status !== BusinessStatus.ACTIVE) {
      throw new BadRequestException('Business is inactive');
    }

    if (membership.status !== LoyaltyMembershipStatus.ACTIVE) {
      throw new BadRequestException('Loyalty membership is inactive');
    }

    if (!membership.loyaltyProgram.isActive) {
      throw new BadRequestException('Loyalty program is inactive');
    }
  }

  private async findMembership(
    businessId: string,
    membershipId: string
  ): Promise<WalletMembership> {
    const membership = await this.prisma.loyaltyMembership.findFirst({
      where: {
        id: membershipId,
        businessId
      },
      include: {
        business: true,
        customer: true,
        loyaltyProgram: {
          include: {
            stampStyle: true
          }
        }
      }
    });

    if (!membership) {
      throw new NotFoundException('Loyalty membership not found');
    }

    return membership;
  }

  private async findMembershipById(membershipId: string): Promise<WalletMembership> {
    const membership = await this.prisma.loyaltyMembership.findUnique({
      where: {
        id: membershipId
      },
      include: {
        business: true,
        customer: true,
        loyaltyProgram: {
          include: {
            stampStyle: true
          }
        }
      }
    });

    if (!membership) {
      throw new NotFoundException('Loyalty membership not found');
    }

    return membership;
  }

  private async createOrReusePendingPass(membership: WalletMembership) {
    return this.prisma.walletPass.upsert({
      where: {
        membershipId_platform: {
          membershipId: membership.id,
          platform: WalletPassPlatform.GOOGLE_WALLET
        }
      },
      create: {
        businessId: membership.businessId,
        membershipId: membership.id,
        platform: WalletPassPlatform.GOOGLE_WALLET,
        status: WalletPassStatus.PENDING,
        syncError: null
      },
      update: {
        businessId: membership.businessId,
        status: WalletPassStatus.PENDING,
        syncError: null
      }
    });
  }

  private async ensureScanToken(pass: WalletPass): Promise<{
    pass: WalletPass;
    metadata: WalletScanTokenMetadata;
  }> {
    const metadata = this.walletScanTokenService.buildMetadataForPass(pass);
    const tokenFieldsMatch =
      pass.scanTokenHash === metadata.scanTokenHash &&
      pass.scanTokenVersion === metadata.scanTokenVersion &&
      pass.scanTokenIssuedAt?.getTime() === metadata.scanTokenIssuedAt.getTime() &&
      pass.scanTokenLast4 === metadata.scanTokenLast4;

    if (tokenFieldsMatch) {
      return {
        pass,
        metadata
      };
    }

    const updatedPass = await this.prisma.walletPass.update({
      where: {
        id: pass.id
      },
      data: {
        scanTokenHash: metadata.scanTokenHash,
        scanTokenVersion: metadata.scanTokenVersion,
        scanTokenIssuedAt: metadata.scanTokenIssuedAt,
        scanTokenLast4: metadata.scanTokenLast4
      }
    });

    return {
      pass: updatedPass,
      metadata
    };
  }

  private async renderHeroImage(
    membership: WalletMembership,
    visual: WalletPassVisualModel
  ) {
    const storedImage = await this.stampImageStorageService.renderAndStore({
      membershipId: this.buildObjectSuffix(membership),
      businessName: visual.businessName,
      programName: visual.programName,
      rewardName: visual.rewardName,
      stampCount: visual.stampCount,
      stampGoal: visual.stampGoal,
      ...visual.theme
    });

    return this.stampImageStorageService.requirePublicUrl(storedImage);
  }

  private resolveVisual(membership: WalletMembership) {
    return resolveWalletPassVisual({
      businessName: membership.business.name,
      programName: membership.loyaltyProgram.name,
      rewardName: membership.loyaltyProgram.rewardName,
      logoUrl:
        membership.loyaltyProgram.logoUrl ?? membership.business.logoUrl,
      stampCount: membership.stampCount,
      stampGoal: membership.loyaltyProgram.stampGoal,
      theme: resolveWalletPassVisualTheme(membership.loyaltyProgram)
    });
  }

  private buildClassSuffix(membership: WalletMembership) {
    return `business_${this.stableOpaqueSegment(
      membership.businessId,
      membership.loyaltyProgramId
    )}`;
  }

  private buildObjectSuffix(membership: WalletMembership) {
    return `membership_${this.stableOpaqueSegment(membership.id)}`;
  }

  private buildAccountName(membership: WalletMembership) {
    return membership.customer.name?.trim() || 'Waflo Member';
  }

  private buildAccountId(pass: WalletPass) {
    const suffix = this.stableOpaqueSegment(pass.id).slice(0, 10);

    return `WAFLO-${suffix.toUpperCase()}`;
  }

  private buildBarcodeAlternateText(last4: string) {
    return `Scan code ending ${last4.toUpperCase()}`;
  }

  private stableOpaqueSegment(...values: string[]) {
    return createHash('sha256').update(values.join(':')).digest('hex').slice(0, 24);
  }

  private sanitizeSyncError(error: unknown) {
    if (error instanceof GoogleWalletApiError) {
      return `Google Wallet API request failed with status ${error.status}`;
    }

    if (!(error instanceof Error)) {
      return 'Google Wallet sync failed';
    }

    const message = error.message.trim();

    if (!message) {
      return 'Google Wallet sync failed';
    }

    const unsafePatterns = [
      /private[_ -]?key/i,
      /client[_ -]?email/i,
      /waflo_scan_v1/i,
      /scan[_ -]?token/i,
      /[A-Za-z]:\\/,
      /\/(?:home|users|var|tmp|etc)\//i
    ];

    if (unsafePatterns.some((pattern) => pattern.test(message))) {
      return 'Google Wallet sync failed';
    }

    return message.slice(0, 500);
  }
}

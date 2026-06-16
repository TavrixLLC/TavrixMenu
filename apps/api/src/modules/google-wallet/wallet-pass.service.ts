import {
  BadGatewayException,
  BadRequestException,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import {
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
import { DEFAULT_LOYALTY_STAMP_STYLE } from '../loyalty/loyalty-stamp-style.constants';
import { StampImageStorageService } from '../loyalty/stamp-image-storage.service';
import { GoogleWalletApiError } from './google-wallet-api.client';
import { GoogleWalletService } from './google-wallet.service';

type WalletMembership = Prisma.LoyaltyMembershipGetPayload<{
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

    if (membership.status !== LoyaltyMembershipStatus.ACTIVE) {
      throw new BadRequestException('Loyalty membership is inactive');
    }

    if (!membership.loyaltyProgram.isActive) {
      throw new BadRequestException('Loyalty program is inactive');
    }

    let pass = await this.createOrReusePendingPass(membership);

    try {
      const heroImageUrl = await this.renderHeroImage(membership);
      const classSuffix = this.buildClassSuffix(membership);
      const objectSuffix = this.buildObjectSuffix(membership);
      const classPayload = this.googleWalletService.buildLoyaltyClassPayload({
        classSuffix,
        issuerName: membership.business.name,
        programName: membership.loyaltyProgram.name,
        logoUrl: this.httpsUrlOrUndefined(
          membership.loyaltyProgram.logoUrl ?? membership.business.logoUrl
        ),
        rewardDescription:
          membership.loyaltyProgram.rewardDescription ??
          membership.loyaltyProgram.rewardName,
        hexBackgroundColor: this.resolveStampStyle(membership).walletBackgroundColor
      });
      const objectPayload = this.googleWalletService.buildLoyaltyObjectPayload({
        classSuffix,
        objectSuffix,
        accountName: this.buildAccountName(membership),
        accountId: this.buildAccountId(pass),
        stampCount: membership.stampCount,
        stampGoal: membership.loyaltyProgram.stampGoal,
        rewardName: membership.loyaltyProgram.rewardName,
        includeBarcode: false,
        heroImageUrl,
        heroImageDescription: `${membership.loyaltyProgram.name} stamp progress`,
        progressText: `${Math.min(
          membership.stampCount,
          membership.loyaltyProgram.stampGoal
        )} of ${membership.loyaltyProgram.stampGoal} stamps collected`
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

  private async renderHeroImage(membership: WalletMembership) {
    const style = this.resolveStampStyle(membership);
    const storedImage = await this.stampImageStorageService.renderAndStore({
      membershipId: membership.id,
      businessName: membership.business.name,
      programName: membership.loyaltyProgram.name,
      rewardName: membership.loyaltyProgram.rewardName,
      stampCount: membership.stampCount,
      stampGoal: membership.loyaltyProgram.stampGoal,
      presetKey: style.presetKey,
      backgroundColor: style.backgroundColor,
      accentColor: style.accentColor,
      textColor: style.textColor,
      imageBackgroundColor: style.imageBackgroundColor,
      imageSurfaceColor: style.imageSurfaceColor,
      imageAccentColor: style.imageAccentColor,
      imageTextColor: style.imageTextColor,
      stampFilledColor: style.stampFilledColor,
      stampEmptyColor: style.stampEmptyColor,
      rewardBannerColor: style.rewardBannerColor,
      themePreset: style.themePreset,
      layoutVariant: style.layoutVariant
    });

    return this.stampImageStorageService.requirePublicUrl(storedImage);
  }

  private resolveStampStyle(membership: WalletMembership) {
    return membership.loyaltyProgram.stampStyle ?? DEFAULT_LOYALTY_STAMP_STYLE;
  }

  private buildClassSuffix(membership: WalletMembership) {
    return `business_${this.safeResourceSegment(
      membership.businessId
    )}_loyalty_${this.safeResourceSegment(membership.loyaltyProgramId)}`;
  }

  private buildObjectSuffix(membership: WalletMembership) {
    return `membership_${this.safeResourceSegment(membership.id)}`;
  }

  private buildAccountName(membership: WalletMembership) {
    return membership.customer.name?.trim() || 'Waflo Member';
  }

  private buildAccountId(pass: WalletPass) {
    const suffix = pass.id.replace(/[^A-Za-z0-9]/g, '').slice(0, 10);

    return `WAFLO-${suffix.toUpperCase()}`;
  }

  private safeResourceSegment(value: string) {
    return value.replace(/[^A-Za-z0-9._-]/g, '_');
  }

  private httpsUrlOrUndefined(value: string | null) {
    if (!value) {
      return undefined;
    }

    try {
      const parsed = new URL(value);

      return parsed.protocol === 'https:' ? parsed.toString() : undefined;
    } catch {
      return undefined;
    }
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
      /[A-Za-z]:\\/,
      /\/(?:home|users|var|tmp|etc)\//i
    ];

    if (unsafePatterns.some((pattern) => pattern.test(message))) {
      return 'Google Wallet sync failed';
    }

    return message.slice(0, 500);
  }
}

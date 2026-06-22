import { Injectable, NotFoundException } from '@nestjs/common';
import {
  BusinessUserRole,
  LoyaltyProgram,
  LoyaltyStampStyle
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessAccessService } from '../businesses/business-access.service';
import { UpdateLoyaltyStampStyleDto } from './dto/update-loyalty-stamp-style.dto';
import {
  DEFAULT_LOYALTY_STAMP_STYLE,
  LOYALTY_STAMP_PRESETS,
  LOYALTY_WALLET_COLOR_MODES,
  LOYALTY_WALLET_THEME_PRESET_CATALOG,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue,
  LoyaltyStampStyleTypeValue,
  LoyaltyWalletColorModeValue,
  LoyaltyWalletThemePresetValue
} from './loyalty-stamp-style.constants';
import { resolveLoyaltyVisualStyle } from './loyalty-visual-style';

type ProgramWithStampStyle = LoyaltyProgram & {
  stampStyle: LoyaltyStampStyle | null;
};

type LoyaltyStampStyleResponse = {
  id: string | null;
  loyaltyProgramId: string;
  styleType: LoyaltyStampStyleTypeValue;
  presetKey: LoyaltyStampPresetKeyValue;
  backgroundColor: string;
  accentColor: string;
  textColor: string;
  walletBackgroundColor: string;
  imageBackgroundColor: string;
  imageSurfaceColor: string;
  imageAccentColor: string;
  imageTextColor: string;
  stampFilledColor: string;
  stampEmptyColor: string;
  rewardBannerColor: string;
  themePreset: LoyaltyWalletThemePresetValue;
  colorMode: LoyaltyWalletColorModeValue;
  layoutVariant: LoyaltyStampLayoutVariantValue;
  isDefault: boolean;
  createdAt: Date | null;
  updatedAt: Date | null;
};

@Injectable()
export class LoyaltyStampStyleService {
  private readonly configRoles = [
    BusinessUserRole.OWNER,
    BusinessUserRole.MANAGER
  ];
  private readonly staffRoles = [
    BusinessUserRole.OWNER,
    BusinessUserRole.MANAGER,
    BusinessUserRole.STAFF
  ];

  constructor(
    private readonly prisma: PrismaService,
    private readonly businessAccessService: BusinessAccessService
  ) {}

  getStampPresets() {
    return {
      presets: LOYALTY_STAMP_PRESETS,
      stampPresets: LOYALTY_STAMP_PRESETS,
      themePresets: LOYALTY_WALLET_THEME_PRESET_CATALOG,
      styleTypes: ['PRESET'],
      colorModes: LOYALTY_WALLET_COLOR_MODES,
      layoutVariants: ['MODERN', 'COMPACT']
    };
  }

  async getStampStyle(currentUser: AuthenticatedUser, businessId: string) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const program = await this.findActiveProgramWithStampStyle(businessId);

    return this.mapStampStyle(program);
  }

  async updateStampStyle(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: UpdateLoyaltyStampStyleDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.configRoles
    );

    const program = await this.findActiveProgramWithStampStyle(businessId);
    const currentStyle = this.mapStampStyle(program);
    const data = {
      styleType: dto.styleType ?? currentStyle.styleType,
      presetKey: dto.presetKey ?? currentStyle.presetKey,
      backgroundColor: dto.backgroundColor ?? currentStyle.backgroundColor,
      accentColor: dto.accentColor ?? currentStyle.accentColor,
      textColor: dto.textColor ?? currentStyle.textColor,
      walletBackgroundColor:
        dto.walletBackgroundColor ?? currentStyle.walletBackgroundColor,
      imageBackgroundColor:
        dto.imageBackgroundColor ?? currentStyle.imageBackgroundColor,
      imageSurfaceColor: dto.imageSurfaceColor ?? currentStyle.imageSurfaceColor,
      imageAccentColor: dto.imageAccentColor ?? currentStyle.imageAccentColor,
      imageTextColor: dto.imageTextColor ?? currentStyle.imageTextColor,
      stampFilledColor: dto.stampFilledColor ?? currentStyle.stampFilledColor,
      stampEmptyColor: dto.stampEmptyColor ?? currentStyle.stampEmptyColor,
      rewardBannerColor: dto.rewardBannerColor ?? currentStyle.rewardBannerColor,
      themePreset: dto.themePreset ?? currentStyle.themePreset,
      colorMode: dto.colorMode ?? currentStyle.colorMode,
      layoutVariant: dto.layoutVariant ?? currentStyle.layoutVariant
    };

    // TODO: Add WCAG contrast validation before exposing custom palettes in admin UI.
    const style = await this.prisma.loyaltyStampStyle.upsert({
      where: {
        loyaltyProgramId: program.id
      },
      create: {
        loyaltyProgramId: program.id,
        ...data
      },
      update: data
    });

    return this.mapPersistedStyle(style);
  }

  private async findActiveProgramWithStampStyle(
    businessId: string
  ): Promise<ProgramWithStampStyle> {
    const program = await this.prisma.loyaltyProgram.findFirst({
      where: {
        businessId,
        isActive: true
      },
      include: {
        stampStyle: true
      },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }]
    });

    if (!program) {
      throw new NotFoundException('No active loyalty program found');
    }

    return program;
  }

  private mapStampStyle(
    program: ProgramWithStampStyle
  ): LoyaltyStampStyleResponse {
    if (program.stampStyle) {
      return this.mapPersistedStyle(program.stampStyle);
    }

    const visualStyle = resolveLoyaltyVisualStyle(program);

    return {
      id: null,
      loyaltyProgramId: program.id,
      styleType: DEFAULT_LOYALTY_STAMP_STYLE.styleType,
      ...visualStyle,
      isDefault: true,
      createdAt: null,
      updatedAt: null
    };
  }

  private mapPersistedStyle(style: LoyaltyStampStyle): LoyaltyStampStyleResponse {
    return {
      id: style.id,
      loyaltyProgramId: style.loyaltyProgramId,
      styleType: style.styleType,
      presetKey: style.presetKey,
      backgroundColor: style.backgroundColor,
      accentColor: style.accentColor,
      textColor: style.textColor,
      walletBackgroundColor: style.walletBackgroundColor,
      imageBackgroundColor: style.imageBackgroundColor,
      imageSurfaceColor: style.imageSurfaceColor,
      imageAccentColor: style.imageAccentColor,
      imageTextColor: style.imageTextColor,
      stampFilledColor: style.stampFilledColor,
      stampEmptyColor: style.stampEmptyColor,
      rewardBannerColor: style.rewardBannerColor,
      themePreset: style.themePreset,
      colorMode: style.colorMode,
      layoutVariant: style.layoutVariant,
      isDefault: false,
      createdAt: style.createdAt,
      updatedAt: style.updatedAt
    };
  }
}

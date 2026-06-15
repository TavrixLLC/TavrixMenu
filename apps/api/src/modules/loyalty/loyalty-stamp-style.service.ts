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
  HEX_COLOR_PATTERN,
  LOYALTY_STAMP_PRESETS,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue,
  LoyaltyStampStyleTypeValue
} from './loyalty-stamp-style.constants';

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
      styleTypes: ['PRESET'],
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
      layoutVariant: dto.layoutVariant ?? currentStyle.layoutVariant
    };

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

    return {
      id: null,
      loyaltyProgramId: program.id,
      styleType: DEFAULT_LOYALTY_STAMP_STYLE.styleType,
      presetKey: DEFAULT_LOYALTY_STAMP_STYLE.presetKey,
      backgroundColor: this.normalizeColorOrDefault(
        program.cardColor,
        DEFAULT_LOYALTY_STAMP_STYLE.backgroundColor
      ),
      accentColor: this.normalizeColorOrDefault(
        program.accentColor,
        DEFAULT_LOYALTY_STAMP_STYLE.accentColor
      ),
      textColor: DEFAULT_LOYALTY_STAMP_STYLE.textColor,
      layoutVariant: DEFAULT_LOYALTY_STAMP_STYLE.layoutVariant,
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
      layoutVariant: style.layoutVariant,
      isDefault: false,
      createdAt: style.createdAt,
      updatedAt: style.updatedAt
    };
  }

  private normalizeColorOrDefault(value: string | null, fallback: string) {
    const normalized = value?.trim();

    return normalized && HEX_COLOR_PATTERN.test(normalized)
      ? normalized
      : fallback;
  }
}

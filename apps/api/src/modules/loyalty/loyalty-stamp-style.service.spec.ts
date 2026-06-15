import { ForbiddenException } from '@nestjs/common';
import { strict as assert } from 'assert';
import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { describe, it } from 'node:test';
import { BusinessUserRole } from '../../generated/prisma';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { UpdateLoyaltyStampStyleDto } from './dto/update-loyalty-stamp-style.dto';
import {
  LOYALTY_STAMP_PRESET_KEYS,
  LOYALTY_WALLET_THEME_PRESETS,
  LoyaltyStampPresetKeyValue,
  LoyaltyWalletColorModeValue,
  LoyaltyWalletThemePresetValue
} from './loyalty-stamp-style.constants';
import { LoyaltyStampStyleService } from './loyalty-stamp-style.service';

describe('LoyaltyStampStyleService', () => {
  it('returns the preset catalog', () => {
    const service = createService({
      activeProgram: buildProgram()
    }).service;

    const catalog = service.getStampPresets();

    assert.deepEqual(
      catalog.presets.map((preset) => preset.key),
      [...LOYALTY_STAMP_PRESET_KEYS]
    );
    assert.deepEqual(catalog.styleTypes, ['PRESET']);
    assert.deepEqual(
      catalog.themePresets.map((preset) => preset.key),
      [...LOYALTY_WALLET_THEME_PRESETS]
    );
    assert.equal(
      catalog.themePresets[0]?.recommendedPalette.walletBackgroundColor,
      '#2563eb'
    );
    assert.deepEqual(catalog.colorModes, ['PRESET', 'CUSTOM']);
    assert.deepEqual(catalog.layoutVariants, ['MODERN', 'COMPACT']);
  });

  it('returns a default style when no explicit style exists', async () => {
    const { service, businessAccess } = createService({
      activeProgram: buildProgram({
        cardColor: '#123abc',
        accentColor: null,
        stampStyle: null
      })
    });

    const response = await service.getStampStyle(user('staff'), 'business_1');

    assert.deepEqual(businessAccess.calls[0], {
      businessId: 'business_1',
      userId: 'staff',
      roles: [
        BusinessUserRole.OWNER,
        BusinessUserRole.MANAGER,
        BusinessUserRole.STAFF
      ]
    });
    assert.equal(response.id, null);
    assert.equal(response.loyaltyProgramId, 'program_1');
    assert.equal(response.styleType, 'PRESET');
    assert.equal(response.presetKey, 'STAR');
    assert.equal(response.backgroundColor, '#123abc');
    assert.equal(response.accentColor, '#f59e0b');
    assert.equal(response.textColor, '#ffffff');
    assert.equal(response.walletBackgroundColor, '#123abc');
    assert.equal(response.imageBackgroundColor, '#123abc');
    assert.equal(response.imageSurfaceColor, '#92400e');
    assert.equal(response.imageAccentColor, '#f59e0b');
    assert.equal(response.imageTextColor, '#ffffff');
    assert.equal(response.stampFilledColor, '#f59e0b');
    assert.equal(response.stampEmptyColor, '#d6d3d1');
    assert.equal(response.rewardBannerColor, '#a16207');
    assert.equal(response.themePreset, 'DEFAULT');
    assert.equal(response.colorMode, 'PRESET');
    assert.equal(response.layoutVariant, 'MODERN');
    assert.equal(response.isDefault, true);
  });

  it('creates or updates style via PATCH', async () => {
    const program = buildProgram({
      stampStyle: null
    });
    const persistedStyle = buildStampStyle({
      loyaltyProgramId: program.id,
      presetKey: 'COFFEE',
      backgroundColor: '#222222',
      accentColor: '#ffcc00',
      textColor: '#ffffff',
      walletBackgroundColor: '#1d4ed8',
      imageBackgroundColor: '#111827',
      imageSurfaceColor: '#1f2937',
      imageAccentColor: '#22c55e',
      imageTextColor: '#f9fafb',
      stampFilledColor: '#22c55e',
      stampEmptyColor: '#9ca3af',
      rewardBannerColor: '#14532d',
      themePreset: 'MINIMAL',
      colorMode: 'CUSTOM',
      layoutVariant: 'COMPACT'
    });
    const { service, prisma } = createService({
      activeProgram: program,
      upsertResult: persistedStyle
    });

    const response = await service.updateStampStyle(user('owner'), 'business_1', {
      presetKey: 'COFFEE',
      backgroundColor: '#222222',
      accentColor: '#ffcc00',
      textColor: '#ffffff',
      walletBackgroundColor: '#1d4ed8',
      imageBackgroundColor: '#111827',
      imageSurfaceColor: '#1f2937',
      imageAccentColor: '#22c55e',
      imageTextColor: '#f9fafb',
      stampFilledColor: '#22c55e',
      stampEmptyColor: '#9ca3af',
      rewardBannerColor: '#14532d',
      themePreset: 'MINIMAL',
      colorMode: 'CUSTOM',
      layoutVariant: 'COMPACT'
    });

    assert.equal(response.isDefault, false);
    assert.equal(response.presetKey, 'COFFEE');
    assert.equal(response.walletBackgroundColor, '#1d4ed8');
    assert.equal(response.themePreset, 'MINIMAL');
    assert.equal(response.colorMode, 'CUSTOM');
    assert.equal(response.layoutVariant, 'COMPACT');
    assert.deepEqual(prisma.upsertArgs?.where, {
      loyaltyProgramId: 'program_1'
    });
    assert.deepEqual(prisma.upsertArgs?.create, {
      loyaltyProgramId: 'program_1',
      styleType: 'PRESET',
      presetKey: 'COFFEE',
      backgroundColor: '#222222',
      accentColor: '#ffcc00',
      textColor: '#ffffff',
      walletBackgroundColor: '#1d4ed8',
      imageBackgroundColor: '#111827',
      imageSurfaceColor: '#1f2937',
      imageAccentColor: '#22c55e',
      imageTextColor: '#f9fafb',
      stampFilledColor: '#22c55e',
      stampEmptyColor: '#9ca3af',
      rewardBannerColor: '#14532d',
      themePreset: 'MINIMAL',
      colorMode: 'CUSTOM',
      layoutVariant: 'COMPACT'
    });
  });

  it('forbids STAFF updates', async () => {
    const { service, prisma } = createService({
      activeProgram: buildProgram()
    });

    await assert.rejects(
      () =>
        service.updateStampStyle(user('staff'), 'business_1', {
          presetKey: 'HEART'
        }),
      ForbiddenException
    );
    assert.equal(prisma.findFirstCalls.length, 0);
    assert.equal(prisma.upsertArgs, undefined);
  });

  it('allows OWNER and MANAGER updates', async () => {
    for (const userId of ['owner', 'manager']) {
      const { service, prisma } = createService({
        activeProgram: buildProgram({
          stampStyle: null
        })
      });

      await service.updateStampStyle(user(userId), 'business_1', {
        presetKey: 'PIZZA'
      });

      assert.equal(prisma.upsertArgs?.create.presetKey, 'PIZZA');
    }
  });

  it('rejects invalid preset, colors, and layout variant at DTO validation', () => {
    assertValidationError({ presetKey: 'MOON' }, 'presetKey');
    assertValidationError({ backgroundColor: 'blue' }, 'backgroundColor');
    assertValidationError({ accentColor: '#12345z' }, 'accentColor');
    assertValidationError({ textColor: 'ffffff' }, 'textColor');
    assertValidationError(
      { walletBackgroundColor: 'blue' },
      'walletBackgroundColor'
    );
    assertValidationError({ imageBackgroundColor: '#12345z' }, 'imageBackgroundColor');
    assertValidationError({ stampFilledColor: 'gold' }, 'stampFilledColor');
    assertValidationError({ rewardBannerColor: '#12' }, 'rewardBannerColor');
    assertValidationError({ themePreset: 'NEON' }, 'themePreset');
    assertValidationError({ colorMode: 'AUTO' }, 'colorMode');
    assertValidationError({ layoutVariant: 'CLASSIC' }, 'layoutVariant');
    assertValidationError({ styleType: 'CUSTOM' }, 'styleType');
  });
});

function createService(input: {
  activeProgram: ReturnType<typeof buildProgram>;
  upsertResult?: ReturnType<typeof buildStampStyle>;
}) {
  const prisma = {
    findFirstCalls: [] as unknown[],
    upsertArgs: undefined as
      | {
          where: { loyaltyProgramId: string };
          create: Record<string, unknown>;
          update: Record<string, unknown>;
        }
      | undefined,
    loyaltyProgram: {
      findFirst: async (args: unknown) => {
        prisma.findFirstCalls.push(args);
        return input.activeProgram;
      }
    },
    loyaltyStampStyle: {
      upsert: async (args: {
        where: { loyaltyProgramId: string };
        create: Record<string, unknown>;
        update: Record<string, unknown>;
      }) => {
        prisma.upsertArgs = args;

        return input.upsertResult ?? buildStampStyle(args.create);
      }
    }
  };
  const businessAccess = {
    calls: [] as Array<{
      businessId: string;
      userId: string;
      roles: BusinessUserRole[];
    }>,
    assertRole: async (
      businessId: string,
      userId: string,
      roles: BusinessUserRole[]
    ) => {
      businessAccess.calls.push({
        businessId,
        userId,
        roles
      });

      if (userId === 'staff' && !roles.includes(BusinessUserRole.STAFF)) {
        throw new ForbiddenException('Insufficient business role');
      }
    }
  };

  return {
    service: new LoyaltyStampStyleService(prisma as any, businessAccess as any),
    prisma,
    businessAccess
  };
}

function assertValidationError(input: object, property: string) {
  const errors = validateSync(plainToInstance(UpdateLoyaltyStampStyleDto, input));

  assert.ok(
    errors.some((error) => error.property === property),
    `Expected validation error for ${property}`
  );
}

function user(id: string): AuthenticatedUser {
  const now = new Date('2026-06-15T00:00:00.000Z');

  return {
    id,
    clerkUserId: id,
    name: id,
    email: `${id}@example.test`,
    phone: null,
    status: 'ACTIVE',
    createdAt: now,
    updatedAt: now
  } as AuthenticatedUser;
}

function buildProgram(
  overrides: Partial<{
    cardColor: string | null;
    accentColor: string | null;
    stampStyle: ReturnType<typeof buildStampStyle> | null;
  }> = {}
) {
  const now = new Date('2026-06-15T00:00:00.000Z');

  return {
    id: 'program_1',
    businessId: 'business_1',
    name: 'Tavrix Cafe Stamp Card',
    description: 'Collect stamps.',
    stampGoal: 5,
    rewardName: 'Free coffee',
    rewardDescription: 'One free coffee after 5 stamps.',
    isActive: true,
    cardColor: '#111827',
    accentColor: '#f59e0b',
    logoUrl: null,
    terms: null,
    createdAt: now,
    updatedAt: now,
    stampStyle: overrides.stampStyle ?? null,
    ...overrides
  };
}

function buildStampStyle(
  overrides: Partial<{
    id: string;
    loyaltyProgramId: string;
    styleType: 'PRESET';
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
    layoutVariant: 'MODERN' | 'COMPACT';
    createdAt: Date;
    updatedAt: Date;
  }> = {}
) {
  const now = new Date('2026-06-15T00:00:00.000Z');

  return {
    id: 'stamp_style_1',
    loyaltyProgramId: 'program_1',
    styleType: 'PRESET' as const,
    presetKey: 'STAR' as LoyaltyStampPresetKeyValue,
    backgroundColor: '#111827',
    accentColor: '#f59e0b',
    textColor: '#ffffff',
    walletBackgroundColor: '#111827',
    imageBackgroundColor: '#111827',
    imageSurfaceColor: '#1f2937',
    imageAccentColor: '#f59e0b',
    imageTextColor: '#ffffff',
    stampFilledColor: '#f59e0b',
    stampEmptyColor: '#d6d3d1',
    rewardBannerColor: '#92400e',
    themePreset: 'DEFAULT' as LoyaltyWalletThemePresetValue,
    colorMode: 'PRESET' as LoyaltyWalletColorModeValue,
    layoutVariant: 'MODERN' as const,
    createdAt: now,
    updatedAt: now,
    ...overrides
  };
}

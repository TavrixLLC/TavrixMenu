import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { strict as assert } from 'assert';
import { validate } from 'class-validator';
import { describe, it } from 'node:test';
import { UpdateMenuAppearanceDto } from './dto/update-menu-appearance.dto';
import { MENU_TEMPLATE_IDS } from './menu-appearance.constants';
import { BusinessesService } from './businesses.service';

describe('BusinessesService menu appearance contract', () => {
  it('reads the selected template and exposes the effective template', async () => {
    const setup = createService({
      business: {
        id: 'business_1',
        menuTemplateId: 'coffeehouse-premium',
        menuThemeOverrides: null
      }
    });

    const appearance = await setup.service.getMenuAppearance(user(), 'business_1');

    assert.deepEqual(appearance, {
      businessId: 'business_1',
      menuTemplateId: 'coffeehouse-premium',
      menuThemeOverrides: null,
      effectiveTemplateId: 'coffeehouse-premium',
      fallbackApplied: false,
      defaultTemplateId: 'waflo-warm'
    });
  });

  it('falls back to waflo-warm when an existing business has no template', async () => {
    const setup = createService({
      business: {
        id: 'business_1',
        menuTemplateId: null,
        menuThemeOverrides: null
      }
    });

    const appearance = await setup.service.getMenuAppearance(user(), 'business_1');

    assert.equal(appearance.menuTemplateId, 'waflo-warm');
    assert.equal(appearance.effectiveTemplateId, 'waflo-warm');
    assert.equal(appearance.fallbackApplied, true);
  });

  it('lets an owner update the business template and writes a safe audit action', async () => {
    const setup = createService({
      business: {
        id: 'business_1',
        menuTemplateId: 'waflo-warm',
        menuThemeOverrides: null
      }
    });

    const appearance = await setup.service.updateMenuAppearance(user(), 'business_1', {
      menuTemplateId: 'street-bites'
    });

    assert.equal(appearance.menuTemplateId, 'street-bites');
    assert.equal(setup.updates.length, 1);
    assert.equal(setup.updates[0].data.menuTemplateId, 'street-bites');
    assert.deepEqual(setup.auditLogs, [
      {
        businessId: 'business_1',
        userId: 'user_1',
        action: 'MENU_APPEARANCE_UPDATED',
        metadataJson: {
          menuTemplateId: 'street-bites'
        }
      }
    ]);
  });

  it('rejects staff updates before changing appearance', async () => {
    const setup = createService({
      ownerError: new ForbiddenException('Insufficient business role')
    });

    await assert.rejects(
      setup.service.updateMenuAppearance(user(), 'business_1', {
        menuTemplateId: 'minimal-modern'
      }),
      ForbiddenException
    );
    assert.equal(setup.updates.length, 0);
  });

  it('rejects an unsupported template id', async () => {
    const setup = createService();

    await assert.rejects(
      setup.service.updateMenuAppearance(user(), 'business_1', {
        menuTemplateId: 'merchant-uploaded-css'
      } as any),
      BadRequestException
    );
    assert.equal(setup.updates.length, 0);
  });

  it('rejects non-null merchant theme overrides until they are safely supported', async () => {
    const setup = createService();

    await assert.rejects(
      setup.service.updateMenuAppearance(user(), 'business_1', {
        menuThemeOverrides: {
          unsafeCss: 'body{}'
        }
      }),
      BadRequestException
    );
    assert.equal(setup.updates.length, 0);
  });

  it('keeps DTO validation scoped to the enabled Waflo-managed template IDs', async () => {
    assert.deepEqual(MENU_TEMPLATE_IDS, [
      'waflo-warm',
      'coffeehouse-premium',
      'street-bites',
      'minimal-modern'
    ]);

    for (const menuTemplateId of MENU_TEMPLATE_IDS) {
      const dto = new UpdateMenuAppearanceDto();
      dto.menuTemplateId = menuTemplateId;

      assert.deepEqual(await validate(dto), []);
    }

    const invalid = new UpdateMenuAppearanceDto();
    invalid.menuTemplateId = 'luxury-dining' as never;

    const errors = await validate(invalid);

    assert.equal(errors.length, 1);
    assert.ok(errors[0]?.constraints?.isIn);
  });
});

function createService({
  business = {
    id: 'business_1',
    menuTemplateId: 'waflo-warm',
    menuThemeOverrides: null
  },
  ownerError
}: {
  business?: {
    id: string;
    menuTemplateId: string | null;
    menuThemeOverrides: Record<string, unknown> | null;
  };
  ownerError?: Error;
} = {}) {
  const updates: Array<{ where: Record<string, unknown>; data: Record<string, unknown> }> = [];
  const auditLogs: Array<Record<string, unknown>> = [];
  let currentBusiness = { ...business };
  const transaction = {
    business: {
      update: async (args: { where: Record<string, unknown>; data: Record<string, unknown> }) => {
        updates.push(args);
        currentBusiness = {
          ...currentBusiness,
          menuTemplateId: (args.data.menuTemplateId as string | undefined) ?? currentBusiness.menuTemplateId,
          menuThemeOverrides:
            (args.data.menuThemeOverrides as Record<string, unknown> | null | undefined) ??
            currentBusiness.menuThemeOverrides
        };

        return currentBusiness;
      }
    },
    auditLog: {
      create: async (args: { data: Record<string, unknown> }) => {
        auditLogs.push(args.data);
        return args.data;
      }
    }
  };
  const prisma = {
    business: {
      findUnique: async () => currentBusiness
    },
    $transaction: async <T>(callback: (client: typeof transaction) => Promise<T>) => callback(transaction)
  };
  const businessAccess = {
    appContextRoles: ['OWNER', 'MANAGER', 'STAFF'],
    assertRole: async () => undefined,
    assertOwner: async () => {
      if (ownerError) {
        throw ownerError;
      }
    },
    getPermissions: () => ({
      canManageBusiness: true,
      canManageMenu: true,
      canManageMembers: true,
      canViewMembers: true,
      canViewPublicLink: true,
      canManageAppearance: true
    })
  };
  const configService = {
    get: (_key: string, fallback: string) => fallback
  };

  return {
    service: new BusinessesService(prisma as any, businessAccess as any, configService as any),
    updates,
    auditLogs
  };
}

function user() {
  return {
    id: 'user_1'
  } as any;
}

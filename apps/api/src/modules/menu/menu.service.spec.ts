import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { MenuService } from './menu.service';

describe('MenuService public menu appearance contract', () => {
  it('returns the selected and effective template on public menu data', async () => {
    const service = new MenuService(prismaWithBusiness(publicBusiness({
      menuTemplateId: 'minimal-modern'
    })) as any, {} as any);

    const menu = await service.getPublicMenu('sample-cafe');

    assert.equal(menu.business.menuTemplateId, 'minimal-modern');
    assert.deepEqual(menu.appearance, {
      menuTemplateId: 'minimal-modern',
      effectiveTemplateId: 'minimal-modern',
      fallbackApplied: false,
      menuThemeOverrides: null
    });
  });

  it('falls back to waflo-warm for an existing public menu without a template', async () => {
    const service = new MenuService(prismaWithBusiness(publicBusiness({
      menuTemplateId: null
    })) as any, {} as any);

    const menu = await service.getPublicMenu('sample-cafe');

    assert.equal(menu.business.menuTemplateId, 'waflo-warm');
    assert.equal(menu.appearance.effectiveTemplateId, 'waflo-warm');
    assert.equal(menu.appearance.fallbackApplied, true);
  });
});

function publicBusiness(overrides: { menuTemplateId: string | null }) {
  return {
    id: 'business_1',
    name: 'Sample Cafe',
    slug: 'sample-cafe',
    type: 'cafe',
    logoUrl: null,
    coverUrl: null,
    currency: 'IQD',
    language: 'en',
    city: 'Baghdad',
    menuTemplateId: overrides.menuTemplateId,
    menuThemeOverrides: null,
    menuCategories: [
      {
        id: 'category_1',
        nameAr: 'Coffee',
        nameEn: 'Coffee',
        sortOrder: 0,
        items: [
          {
            id: 'item_1',
            nameAr: 'Espresso',
            nameEn: 'Espresso',
            descriptionAr: null,
            descriptionEn: null,
            price: {
              toString: () => '3000'
            },
            imageUrl: null,
            isAvailable: true,
            sortOrder: 0
          }
        ]
      }
    ]
  };
}

function prismaWithBusiness(business: ReturnType<typeof publicBusiness>) {
  return {
    business: {
      findFirst: async () => business
    }
  };
}

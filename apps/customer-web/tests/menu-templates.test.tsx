import { strict as assert } from 'assert';
import { readFileSync } from 'fs';
import { join } from 'path';
import { describe, it } from 'node:test';
import { renderToStaticMarkup } from 'react-dom/server';
import { PublicMenuTemplateView } from '../app/components/PublicMenuTemplateView';
import {
  DetailState,
  ITEM_NOT_AVAILABLE_MESSAGE,
  ITEM_UNAVAILABLE_MESSAGE,
  MENU_UNAVAILABLE_MESSAGE,
  MenuState
} from '../app/components/PublicMenuStates';
import { demoLoyalty, demoMenu } from '../app/dev/menu-templates/preview-data';
import MenuTemplatePreviewPage from '../app/dev/menu-templates/page';
import { getPublicMenuTemplate, publicMenuTemplates } from '../app/lib/menu-templates';
import { fetchPublicItem, fetchPublicMenu } from '../app/lib/public-menu';

describe('customer-web public menu templates', () => {
  it('keeps the mobile logo visible in the public menu CSS', () => {
    const cssFiles = [
      'app/styles/public-menu-contract.css',
      'app/styles/menu-templates/waflo-warm.css',
      'app/styles/menu-templates/coffeehouse-premium.css',
      'app/styles/menu-templates/street-bites.css',
      'app/styles/menu-templates/minimal-modern.css',
      'app/styles/menu-templates/luxury-dining.css',
      'app/styles/menu-templates/artisan-cafe.css',
      'app/styles/menu-templates/quick-serve-bold.css'
    ];

    for (const cssFile of cssFiles) {
      const css = readFileSync(join(process.cwd(), cssFile), 'utf8');

      assert.equal(/waflo-menu__logo\s*\{[^}]*display:\s*none/i.test(css), false, cssFile);
    }
  });

  it('/dev/menu-templates page renders every template preview frame', () => {
    const html = renderToStaticMarkup(<MenuTemplatePreviewPage />);

    assert.equal(publicMenuTemplates.length, 7);

    for (const template of publicMenuTemplates) {
      assert.match(html, new RegExp(template.id));
      assert.match(html, new RegExp(`/dev/menu-templates/${template.id}`));
      assert.match(html, new RegExp(template.displayName));
    }
  });

  it('renders the selected public menu template from backend appearance data', () => {
    const template = getPublicMenuTemplate('coffeehouse-premium');
    const html = renderToStaticMarkup(
      <PublicMenuTemplateView
        menu={{
          ...demoMenu,
          appearance: {
            ...demoMenu.appearance,
            menuTemplateId: 'coffeehouse-premium',
            effectiveTemplateId: 'coffeehouse-premium'
          }
        }}
        template={template}
        loyaltyContext={demoLoyalty}
      />
    );

    assert.match(html, /data-template="coffeehouse-premium"/);
    assert.match(html, /waflo-template-coffeehouse-premium/);
  });

  it('renders an intentional no-cover fallback when the business has no cover image', () => {
    const html = renderToStaticMarkup(
      <PublicMenuTemplateView menu={demoMenu} template={getPublicMenuTemplate('waflo-warm')} loyaltyContext={demoLoyalty} />
    );

    assert.match(html, /data-slot="merchant-cover-fallback"/);
    assert.match(html, /Fresh menu/);
    assert.match(html, /Happy Birthday 2/);
    assert.match(html, /data-has-image="false"/);
  });

  it('falls back safely when a template id is invalid', () => {
    assert.equal(getPublicMenuTemplate('unknown-template').id, 'waflo-warm');
    assert.equal(getPublicMenuTemplate('luxury-dining').id, 'luxury-dining');
    assert.equal(getPublicMenuTemplate('artisan-cafe').id, 'artisan-cafe');
    assert.equal(getPublicMenuTemplate('quick-serve-bold').id, 'quick-serve-bold');
  });

  it('renders a web preview template without mutating the saved appearance', () => {
    const savedAppearance = {
      ...demoMenu.appearance,
      menuTemplateId: 'waflo-warm',
      effectiveTemplateId: 'waflo-warm'
    };
    const menu = {
      ...demoMenu,
      appearance: savedAppearance
    };
    const html = renderToStaticMarkup(
      <PublicMenuTemplateView
        menu={menu}
        template={getPublicMenuTemplate('coffeehouse-premium')}
        loyaltyContext={demoLoyalty}
      />
    );

    assert.match(html, /data-template="coffeehouse-premium"/);
    assert.equal(menu.appearance.effectiveTemplateId, 'waflo-warm');
    assert.equal(savedAppearance.effectiveTemplateId, 'waflo-warm');
  });

  it('renders item photo, name, and price in the public menu card contract', () => {
    const menuWithImage = {
      ...demoMenu,
      categories: demoMenu.categories.map((category, categoryIndex) => ({
        ...category,
        items: category.items.map((item, itemIndex) => ({
          ...item,
          imageUrl: categoryIndex === 0 && itemIndex === 0 ? '/sample-food.jpg' : item.imageUrl
        }))
      }))
    };
    const html = renderToStaticMarkup(
      <PublicMenuTemplateView menu={menuWithImage} template={getPublicMenuTemplate('waflo-warm')} loyaltyContext={demoLoyalty} />
    );

    assert.match(html, /data-slot="item-image"/);
    assert.match(html, /src="\/sample-food\.jpg"/);
    assert.match(html, /Strawberry Cake/);
    assert.match(html, /5,500\s*IQD/);
  });

  it('marks the first category as current for mobile orientation', () => {
    const html = renderToStaticMarkup(
      <PublicMenuTemplateView menu={demoMenu} template={getPublicMenuTemplate('waflo-warm')} loyaltyContext={demoLoyalty} />
    );

    assert.match(html, /data-component="category-navigation"/);
    assert.match(html, /data-state="current"/);
    assert.match(html, /aria-current="location"/);
  });

  it('renders sold-out items as unavailable instead of hiding them', () => {
    const html = renderToStaticMarkup(
      <PublicMenuTemplateView menu={demoMenu} template={getPublicMenuTemplate('waflo-warm')} loyaltyContext={demoLoyalty} />
    );

    assert.match(html, /Mint Lemonade/);
    assert.match(html, /data-state="sold-out"/);
    assert.match(html, /Sold out/);
  });

  it('keeps sold-out items from the public menu response for customer clarity', async () => {
    const originalFetch = globalThis.fetch;

    globalThis.fetch = (async () =>
      new Response(JSON.stringify(demoMenu), {
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        }
      })) as typeof fetch;

    try {
      const result = await fetchPublicMenu('happy-birthday-2');

      assert.equal(result.status, 'ok');

      if (result.status === 'ok') {
        const soldOutItem = result.data.categories
          .flatMap((category) => category.items)
          .find((item) => item.id === 'mint-lemonade');

        assert.equal(soldOutItem?.isAvailable, false);
      }
    } finally {
      globalThis.fetch = originalFetch;
    }
  });

  it('keeps sold-out item details available for the unavailable state', async () => {
    const originalFetch = globalThis.fetch;
    const drinks = demoMenu.categories.find((category) => category.id === 'drinks');
    const soldOutItem = drinks?.items.find((item) => item.id === 'mint-lemonade');

    assert.ok(drinks);
    assert.ok(soldOutItem);

    globalThis.fetch = (async () =>
      new Response(
        JSON.stringify({
          business: demoMenu.business,
          category: {
            id: drinks.id,
            nameAr: drinks.nameAr,
            nameEn: drinks.nameEn,
            sortOrder: drinks.sortOrder
          },
          item: soldOutItem
        }),
        {
          status: 200,
          headers: {
            'Content-Type': 'application/json'
          }
        }
      )) as typeof fetch;

    try {
      const result = await fetchPublicItem('happy-birthday-2', 'mint-lemonade');

      assert.equal(result.status, 'ok');

      if (result.status === 'ok') {
        assert.equal(result.data.item.id, 'mint-lemonade');
        assert.equal(result.data.item.isAvailable, false);
      }
    } finally {
      globalThis.fetch = originalFetch;
    }
  });

  it('uses customer-friendly public menu and item error copy', () => {
    const menuHtml = renderToStaticMarkup(
      <MenuState slug="sample-cafe" title="Menu unavailable" message={MENU_UNAVAILABLE_MESSAGE} state="error" />
    );
    const itemMissingHtml = renderToStaticMarkup(
      <DetailState slug="sample-cafe" title="Item not found" message={ITEM_NOT_AVAILABLE_MESSAGE} />
    );
    const itemErrorHtml = renderToStaticMarkup(
      <DetailState slug="sample-cafe" title="Menu unavailable" message={ITEM_UNAVAILABLE_MESSAGE} />
    );
    const html = `${menuHtml}${itemMissingHtml}${itemErrorHtml}`;

    assert.match(html, /We could not load this menu right now/);
    assert.match(html, /This item is not available on the menu right now/);
    assert.equal(/public API|API returned|apiUrl|Unable to reach/i.test(html), false);
  });

  it('keeps the same semantic DOM contract across templates', () => {
    const requiredSlots = [
      'merchant-hero',
      'category-navigation',
      'menu-body',
      'category-section',
      'menu-item',
      'item-price',
      'footer-branding'
    ];

    for (const template of publicMenuTemplates) {
      const html = renderToStaticMarkup(
        <PublicMenuTemplateView menu={demoMenu} template={template} loyaltyContext={demoLoyalty} />
      );

      for (const slot of requiredSlots) {
        assert.match(html, new RegExp(`data-slot="${slot}"|data-component="${slot}"`));
      }
    }
  });
});

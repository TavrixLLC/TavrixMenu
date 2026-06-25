import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { renderToStaticMarkup } from 'react-dom/server';
import { PublicMenuTemplateView } from '../app/components/PublicMenuTemplateView';
import { demoLoyalty, demoMenu } from '../app/dev/menu-templates/preview-data';
import MenuTemplatePreviewPage from '../app/dev/menu-templates/page';
import { getPublicMenuTemplate, publicMenuTemplates } from '../app/lib/menu-templates';

describe('customer-web public menu templates', () => {
  it('/dev/menu-templates page renders every template preview frame', () => {
    const html = renderToStaticMarkup(<MenuTemplatePreviewPage />);

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

  it('falls back safely when a template id is invalid', () => {
    assert.equal(getPublicMenuTemplate('unknown-template').id, 'waflo-warm');
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

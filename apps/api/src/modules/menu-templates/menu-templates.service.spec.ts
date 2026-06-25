import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import { MenuTemplatesService } from './menu-templates.service';

describe('MenuTemplatesService', () => {
  it('returns enabled Waflo-managed template catalog metadata', () => {
    const service = new MenuTemplatesService();
    const catalog = service.getCatalog();

    assert.deepEqual(
      catalog.templates.map((template) => template.id),
      ['waflo-warm', 'coffeehouse-premium', 'street-bites', 'minimal-modern']
    );
    assert.ok(catalog.templates.every((template) => template.enabled));
    assert.ok(catalog.templates.every((template) => template.status === 'enabled'));
    assert.ok(catalog.templates.some((template) => template.isDefault && template.id === 'waflo-warm'));
    assert.ok(catalog.templates.every((template) => Array.isArray(template.preview.previewColors)));
    assert.ok(catalog.templates.every((template) => typeof template.preview.previewLayout === 'string'));
    assert.equal(Object.hasOwn(catalog.templates[0] as object, 'cssFile'), false);
    assert.equal(Object.hasOwn(catalog.templates[0] as object, 'cssClass'), false);
  });
});

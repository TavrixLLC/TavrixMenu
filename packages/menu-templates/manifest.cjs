const DEFAULT_MENU_TEMPLATE_ID = 'waflo-warm';

const sharedFeatures = Object.freeze({
  rtl: true,
  loyaltyBlock: true,
  itemImages: true,
  soldOutState: true,
  aiRecommendations: false,
  responsiveLayouts: true
});

const menuTemplates = Object.freeze([
  Object.freeze({
    id: 'waflo-warm',
    displayName: 'Waflo Warm',
    description: 'Warm coral, cream, and green CSS template for most restaurant and cafe menus.',
    bestFor: 'General restaurants, cafes, bakeries, and casual dining',
    cssClass: 'waflo-template-waflo-warm',
    cssFile: 'waflo-warm.css',
    version: '1.0.0',
    status: 'enabled',
    isDefault: true,
    preview: Object.freeze({
      previewColors: Object.freeze(['#FF6B4A', '#FFF8F2', '#43A047']),
      previewLayout: 'warm-card-list',
      thumbnailUrl: null,
      mobilePreviewUrl: '/dev/menu-templates/waflo-warm',
      desktopPreviewUrl: '/dev/menu-templates/waflo-warm'
    }),
    supportedFeatures: sharedFeatures
  }),
  Object.freeze({
    id: 'coffeehouse-premium',
    displayName: 'Coffeehouse Premium',
    description: 'Dark green, gold, and cream CSS template for premium cafe and dessert menus.',
    bestFor: 'Specialty coffee, dessert shops, premium bakeries, and boutique cafes',
    cssClass: 'waflo-template-coffeehouse-premium',
    cssFile: 'coffeehouse-premium.css',
    version: '1.0.0',
    status: 'enabled',
    isDefault: false,
    preview: Object.freeze({
      previewColors: Object.freeze(['#12392F', '#F59E0B', '#F8F1E7']),
      previewLayout: 'editorial-cafe',
      thumbnailUrl: null,
      mobilePreviewUrl: '/dev/menu-templates/coffeehouse-premium',
      desktopPreviewUrl: '/dev/menu-templates/coffeehouse-premium'
    }),
    supportedFeatures: sharedFeatures
  }),
  Object.freeze({
    id: 'street-bites',
    displayName: 'Street Bites',
    description: 'Bold coral, orange, and red-accented CSS template for fast-food browsing.',
    bestFor: 'Burgers, shawarma, fried chicken, food trucks, and street-food brands',
    cssClass: 'waflo-template-street-bites',
    cssFile: 'street-bites.css',
    version: '1.0.0',
    status: 'enabled',
    isDefault: false,
    preview: Object.freeze({
      previewColors: Object.freeze(['#FF6B4A', '#FFB020', '#FFF3EC']),
      previewLayout: 'bold-quick-service',
      thumbnailUrl: null,
      mobilePreviewUrl: '/dev/menu-templates/street-bites',
      desktopPreviewUrl: '/dev/menu-templates/street-bites'
    }),
    supportedFeatures: sharedFeatures
  }),
  Object.freeze({
    id: 'minimal-modern',
    displayName: 'Minimal Modern',
    description: 'Clean white and neutral CSS template with subtle coral accents.',
    bestFor: 'Fine casual restaurants, modern cafes, simple menus, and premium dining',
    cssClass: 'waflo-template-minimal-modern',
    cssFile: 'minimal-modern.css',
    version: '1.0.0',
    status: 'enabled',
    isDefault: false,
    preview: Object.freeze({
      previewColors: Object.freeze(['#FFFFFF', '#FF6B4A', '#E5E7EB']),
      previewLayout: 'minimal-list',
      thumbnailUrl: null,
      mobilePreviewUrl: '/dev/menu-templates/minimal-modern',
      desktopPreviewUrl: '/dev/menu-templates/minimal-modern'
    }),
    supportedFeatures: sharedFeatures
  })
]);

const MENU_TEMPLATE_IDS = Object.freeze(menuTemplates.map((template) => template.id));
const menuTemplateIdSet = new Set(MENU_TEMPLATE_IDS);

function isMenuTemplateId(value) {
  return typeof value === 'string' && menuTemplateIdSet.has(value);
}

function resolveMenuTemplateId(value) {
  return isMenuTemplateId(value) ? value : DEFAULT_MENU_TEMPLATE_ID;
}

function getMenuTemplate(value) {
  const id = resolveMenuTemplateId(value);
  return menuTemplates.find((template) => template.id === id && template.status === 'enabled') || menuTemplates[0];
}

function getEnabledMenuTemplates() {
  return menuTemplates.filter((template) => template.status === 'enabled');
}

function toPublicMenuTemplateCatalogItem(template) {
  return {
    id: template.id,
    displayName: template.displayName,
    description: template.description,
    bestFor: template.bestFor,
    version: template.version,
    status: template.status,
    enabled: template.status === 'enabled',
    isDefault: template.isDefault,
    preview: {
      previewColors: [...template.preview.previewColors],
      previewLayout: template.preview.previewLayout,
      thumbnailUrl: template.preview.thumbnailUrl,
      mobilePreviewUrl: template.preview.mobilePreviewUrl,
      desktopPreviewUrl: template.preview.desktopPreviewUrl
    },
    supportedFeatures: { ...template.supportedFeatures }
  };
}

function getMenuTemplateCatalog() {
  return getEnabledMenuTemplates().map(toPublicMenuTemplateCatalogItem);
}

module.exports = {
  DEFAULT_MENU_TEMPLATE_ID,
  MENU_TEMPLATE_IDS,
  menuTemplates,
  isMenuTemplateId,
  resolveMenuTemplateId,
  getMenuTemplate,
  getEnabledMenuTemplates,
  getMenuTemplateCatalog,
  toPublicMenuTemplateCatalogItem
};

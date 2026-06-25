export type MenuTemplateId =
  | 'waflo-warm'
  | 'coffeehouse-premium'
  | 'street-bites'
  | 'minimal-modern';

export type MenuTemplateStatus = 'enabled' | 'disabled';

export type MenuTemplateSupportedFeatures = {
  rtl: boolean;
  loyaltyBlock: boolean;
  itemImages: boolean;
  soldOutState: boolean;
  aiRecommendations: boolean;
  responsiveLayouts: boolean;
};

export type MenuTemplatePreviewMetadata = {
  previewColors: readonly string[];
  previewLayout: string;
  thumbnailUrl: string | null;
  mobilePreviewUrl: string | null;
  desktopPreviewUrl: string | null;
};

export type MenuTemplateDefinition = {
  id: MenuTemplateId;
  displayName: string;
  description: string;
  bestFor: string;
  cssClass: `waflo-template-${MenuTemplateId}`;
  cssFile: string;
  version: string;
  status: MenuTemplateStatus;
  isDefault: boolean;
  preview: MenuTemplatePreviewMetadata;
  supportedFeatures: MenuTemplateSupportedFeatures;
};

export type MenuTemplateCatalogItem = Omit<MenuTemplateDefinition, 'cssClass' | 'cssFile'> & {
  enabled: boolean;
};

export const DEFAULT_MENU_TEMPLATE_ID: MenuTemplateId;
export const MENU_TEMPLATE_IDS: readonly MenuTemplateId[];
export const menuTemplates: readonly MenuTemplateDefinition[];

export function isMenuTemplateId(value: string): value is MenuTemplateId;
export function resolveMenuTemplateId(value: string | null | undefined): MenuTemplateId;
export function getMenuTemplate(value: string | null | undefined): MenuTemplateDefinition;
export function getEnabledMenuTemplates(): MenuTemplateDefinition[];
export function getMenuTemplateCatalog(): MenuTemplateCatalogItem[];
export function toPublicMenuTemplateCatalogItem(template: MenuTemplateDefinition): MenuTemplateCatalogItem;

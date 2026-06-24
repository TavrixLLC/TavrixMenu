export const DEFAULT_MENU_TEMPLATE_ID = 'waflo-warm';

export const MENU_TEMPLATE_IDS = [
  'waflo-warm',
  'coffeehouse-premium',
  'street-bites',
  'minimal-modern'
] as const;

export type MenuTemplateId = (typeof MENU_TEMPLATE_IDS)[number];

const menuTemplateIds = new Set<string>(MENU_TEMPLATE_IDS);

export function isMenuTemplateId(value: string): value is MenuTemplateId {
  return menuTemplateIds.has(value);
}

export function resolveMenuTemplateId(value: string | null | undefined) {
  return value && isMenuTemplateId(value) ? value : DEFAULT_MENU_TEMPLATE_ID;
}

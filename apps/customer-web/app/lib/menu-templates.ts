import {
  DEFAULT_MENU_TEMPLATE_ID,
  MENU_TEMPLATE_IDS,
  getMenuTemplate,
  isMenuTemplateId,
  menuTemplates,
  resolveMenuTemplateId,
  type MenuTemplateDefinition,
  type MenuTemplateId
} from '@tavrix-menu/menu-templates';

export const DEFAULT_PUBLIC_MENU_TEMPLATE_ID = DEFAULT_MENU_TEMPLATE_ID;
export const publicMenuTemplateIds = MENU_TEMPLATE_IDS;
export const publicMenuTemplates = menuTemplates;

export type PublicMenuTemplateId = MenuTemplateId;
export type PublicMenuTemplateDefinition = MenuTemplateDefinition;

export { isMenuTemplateId as isPublicMenuTemplateId };
export { resolveMenuTemplateId as resolvePublicMenuTemplateId };

export function getPublicMenuTemplate(value: string | null | undefined) {
  return getMenuTemplate(value);
}

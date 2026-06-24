export const adminMenuTemplates = [
  {
    id: 'waflo-warm',
    displayName: 'Waflo Warm',
    description: 'Warm coral, cream, and green menu style with rounded food cards.',
    bestFor: 'General restaurants, cafes, bakeries, and casual dining',
    preview: {
      label: 'Cream canvas with coral CTA',
      swatches: ['#FF6B4A', '#FFF8F2', '#43A047']
    }
  },
  {
    id: 'coffeehouse-premium',
    displayName: 'Coffeehouse Premium',
    description: 'Dark green, gold, and cream editorial style for premium cafe and dessert menus.',
    bestFor: 'Specialty coffee, desserts, boutique cafes, and premium bakeries',
    preview: {
      label: 'Dark green editorial header',
      swatches: ['#12392F', '#F59E0B', '#F8F1E7']
    }
  },
  {
    id: 'street-bites',
    displayName: 'Street Bites',
    description: 'Bold coral and warm accent style with punchy rows and prominent prices.',
    bestFor: 'Burgers, shawarma, fried chicken, food trucks, and street-food brands',
    preview: {
      label: 'Bold prices and tabs',
      swatches: ['#FF6B4A', '#FFB020', '#FFF3EC']
    }
  },
  {
    id: 'minimal-modern',
    displayName: 'Minimal Modern',
    description: 'Clean white and neutral list style with subtle coral accents.',
    bestFor: 'Premium dining, modern cafes, and simple focused menus',
    preview: {
      label: 'Clean white list',
      swatches: ['#FFFFFF', '#FF6B4A', '#E5E7EB']
    }
  }
] as const;

export type AdminMenuTemplateId = (typeof adminMenuTemplates)[number]['id'];

export function isAdminMenuTemplateId(value: string): value is AdminMenuTemplateId {
  return adminMenuTemplates.some((template) => template.id === value);
}

export function getAdminMenuTemplate(value: string) {
  return adminMenuTemplates.find((template) => template.id === value) ?? adminMenuTemplates[0];
}

import { wafloPalette } from './waflo-design';

export const DEFAULT_PUBLIC_MENU_TEMPLATE_ID = 'waflo-warm';

export const publicMenuTemplateIds = [
  'waflo-warm',
  'coffeehouse-premium',
  'street-bites',
  'minimal-modern'
] as const;

export type PublicMenuTemplateId = (typeof publicMenuTemplateIds)[number];

export type PublicMenuTemplateDefinition = {
  id: PublicMenuTemplateId;
  displayName: string;
  description: string;
  bestFor: string;
  cssClass: `waflo-template-${PublicMenuTemplateId}`;
  cssFile: string;
  version: string;
  status: 'enabled' | 'disabled';
  themeTokens: {
    background: string;
    surface: string;
    primary: string;
    primaryDark: string;
    success: string;
    border: string;
    text: string;
    muted: string;
    reward: string;
    danger: string;
  };
  supportedFeatures: {
    rtl: boolean;
    loyaltyBlock: boolean;
    itemImages: boolean;
    soldOutState: boolean;
    aiRecommendations: boolean;
    responsiveLayouts: boolean;
  };
  preview: {
    label: string;
    description: string;
    swatches: string[];
  };
};

const sharedFeatures = {
  rtl: true,
  loyaltyBlock: true,
  itemImages: true,
  soldOutState: true,
  aiRecommendations: false,
  responsiveLayouts: true
} as const;

export const publicMenuTemplates = [
  {
    id: 'waflo-warm',
    displayName: 'Waflo Warm',
    description: 'Warm coral, cream, and green CSS template for most restaurant and cafe menus.',
    bestFor: 'General restaurants, cafes, bakeries, and casual dining',
    cssClass: 'waflo-template-waflo-warm',
    cssFile: 'waflo-warm.css',
    version: '1.0.0',
    status: 'enabled',
    themeTokens: {
      background: wafloPalette.warmCream,
      surface: wafloPalette.surfaceWhite,
      primary: wafloPalette.primaryCoral,
      primaryDark: wafloPalette.primaryCoralDark,
      success: wafloPalette.freshGreen,
      border: wafloPalette.softBorder,
      text: wafloPalette.textDark,
      muted: wafloPalette.mutedText,
      reward: wafloPalette.rewardGold,
      danger: wafloPalette.dangerRed
    },
    supportedFeatures: sharedFeatures,
    preview: {
      label: 'Cream canvas with coral CTA',
      description: 'Rounded cards over a warm public QR-menu background.',
      swatches: [wafloPalette.primaryCoral, wafloPalette.warmCream, wafloPalette.freshGreen]
    }
  },
  {
    id: 'coffeehouse-premium',
    displayName: 'Coffeehouse Premium',
    description: 'Dark green, gold, and cream CSS template for premium cafe and dessert menus.',
    bestFor: 'Specialty coffee, dessert shops, premium bakeries, and boutique cafes',
    cssClass: 'waflo-template-coffeehouse-premium',
    cssFile: 'coffeehouse-premium.css',
    version: '1.0.0',
    status: 'enabled',
    themeTokens: {
      background: '#F8F1E7',
      surface: wafloPalette.surfaceWhite,
      primary: '#12392F',
      primaryDark: '#0B271F',
      success: wafloPalette.freshGreenDark,
      border: '#E7D7C1',
      text: wafloPalette.textDark,
      muted: wafloPalette.mutedText,
      reward: wafloPalette.rewardGold,
      danger: wafloPalette.dangerRed
    },
    supportedFeatures: sharedFeatures,
    preview: {
      label: 'Dark green editorial header',
      description: 'Premium merchant hero, calm cards, and gold reward accents.',
      swatches: ['#12392F', wafloPalette.rewardGold, '#F8F1E7']
    }
  },
  {
    id: 'street-bites',
    displayName: 'Street Bites',
    description: 'Bold coral, orange, and red-accented CSS template for fast-food browsing.',
    bestFor: 'Burgers, shawarma, fried chicken, food trucks, and street-food brands',
    cssClass: 'waflo-template-street-bites',
    cssFile: 'street-bites.css',
    version: '1.0.0',
    status: 'enabled',
    themeTokens: {
      background: '#FFF3EC',
      surface: wafloPalette.surfaceWhite,
      primary: wafloPalette.primaryCoral,
      primaryDark: wafloPalette.primaryCoralDark,
      success: wafloPalette.freshGreen,
      border: '#FFD5C8',
      text: wafloPalette.textDark,
      muted: wafloPalette.mutedText,
      reward: '#FFB020',
      danger: wafloPalette.dangerRed
    },
    supportedFeatures: sharedFeatures,
    preview: {
      label: 'Bold prices and tabs',
      description: 'Energetic rows with strong category and price treatment.',
      swatches: [wafloPalette.primaryCoral, '#FFB020', '#FFF3EC']
    }
  },
  {
    id: 'minimal-modern',
    displayName: 'Minimal Modern',
    description: 'Clean white and neutral CSS template with subtle coral accents.',
    bestFor: 'Fine casual restaurants, modern cafes, simple menus, and premium dining',
    cssClass: 'waflo-template-minimal-modern',
    cssFile: 'minimal-modern.css',
    version: '1.0.0',
    status: 'enabled',
    themeTokens: {
      background: wafloPalette.surfaceWhite,
      surface: wafloPalette.surfaceWhite,
      primary: wafloPalette.primaryCoral,
      primaryDark: wafloPalette.primaryCoralDark,
      success: wafloPalette.freshGreenDark,
      border: '#E5E7EB',
      text: wafloPalette.textDark,
      muted: wafloPalette.mutedText,
      reward: wafloPalette.rewardGold,
      danger: wafloPalette.dangerRed
    },
    supportedFeatures: sharedFeatures,
    preview: {
      label: 'Clean white list',
      description: 'Sparse border-first layout with quiet typography.',
      swatches: [wafloPalette.surfaceWhite, wafloPalette.primaryCoral, '#E5E7EB']
    }
  }
] as const satisfies ReadonlyArray<PublicMenuTemplateDefinition>;

export function isPublicMenuTemplateId(value: string): value is PublicMenuTemplateId {
  return publicMenuTemplateIds.includes(value as PublicMenuTemplateId);
}

export function resolvePublicMenuTemplateId(value: string | null | undefined): PublicMenuTemplateId {
  return value && isPublicMenuTemplateId(value) ? value : DEFAULT_PUBLIC_MENU_TEMPLATE_ID;
}

export function getPublicMenuTemplate(value: string | null | undefined) {
  const id = resolvePublicMenuTemplateId(value);
  return publicMenuTemplates.find((template) => template.id === id && template.status === 'enabled') ?? publicMenuTemplates[0];
}

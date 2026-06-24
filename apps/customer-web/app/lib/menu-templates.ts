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
  };
  layoutVariant: 'warm-cards' | 'editorial-premium' | 'street-rows' | 'minimal-list';
  itemCardStyle: string;
  categoryNavigationStyle: string;
  loyaltyBlockStyle: string;
  stateStyle: string;
  preview: {
    label: string;
    description: string;
    swatches: string[];
  };
};

export const publicMenuTemplates = [
  {
    id: 'waflo-warm',
    displayName: 'Waflo Warm',
    description: 'Warm coral, cream, and green public menu style for most restaurants and cafes.',
    bestFor: 'General restaurants, cafes, bakeries, and casual dining',
    themeTokens: {
      background: wafloPalette.warmCream,
      surface: wafloPalette.surfaceWhite,
      primary: wafloPalette.primaryCoral,
      primaryDark: wafloPalette.primaryCoralDark,
      success: wafloPalette.freshGreen,
      border: wafloPalette.softBorder,
      text: wafloPalette.textDark,
      muted: wafloPalette.mutedText,
      reward: wafloPalette.rewardGold
    },
    layoutVariant: 'warm-cards',
    itemCardStyle: 'Rounded food cards with generous image treatment and coral price emphasis.',
    categoryNavigationStyle: 'Sticky horizontal chips with coral active/focus treatment.',
    loyaltyBlockStyle: 'Warm cream or white loyalty panel with coral join CTA and green progress tone.',
    stateStyle: 'Friendly cream empty/error states with rounded cards and concise retry copy.',
    preview: {
      label: 'Cream canvas with coral CTA',
      description: 'Rounded menu cards over a warm public QR-menu background.',
      swatches: [wafloPalette.primaryCoral, wafloPalette.warmCream, wafloPalette.freshGreen]
    }
  },
  {
    id: 'coffeehouse-premium',
    displayName: 'Coffeehouse Premium',
    description: 'Dark green, gold, and cream style for premium cafe and dessert menus.',
    bestFor: 'Specialty coffee, dessert shops, premium bakeries, and boutique cafes',
    themeTokens: {
      background: '#F8F1E7',
      surface: wafloPalette.surfaceWhite,
      primary: '#12392F',
      primaryDark: '#0B271F',
      success: wafloPalette.freshGreenDark,
      border: '#E7D7C1',
      text: wafloPalette.textDark,
      muted: wafloPalette.mutedText,
      reward: wafloPalette.rewardGold
    },
    layoutVariant: 'editorial-premium',
    itemCardStyle: 'Polished image-led cards with restrained gold reward accents.',
    categoryNavigationStyle: 'Dark green section links with gold active underline.',
    loyaltyBlockStyle: 'Premium reward card with gold milestone details and green progress.',
    stateStyle: 'Quiet premium states with low-motion loading and clear retry action.',
    preview: {
      label: 'Dark green editorial header',
      description: 'Cream body, dark merchant banner, and gold reward highlight.',
      swatches: ['#12392F', wafloPalette.rewardGold, '#F8F1E7']
    }
  },
  {
    id: 'street-bites',
    displayName: 'Street Bites',
    description: 'Bold coral, orange, and red-accented style for energetic fast-food menus.',
    bestFor: 'Burgers, shawarma, fried chicken, food trucks, and street-food brands',
    themeTokens: {
      background: '#FFF3EC',
      surface: wafloPalette.surfaceWhite,
      primary: wafloPalette.primaryCoral,
      primaryDark: wafloPalette.primaryCoralDark,
      success: wafloPalette.freshGreen,
      border: '#FFD5C8',
      text: wafloPalette.textDark,
      muted: wafloPalette.mutedText,
      reward: '#FFB020'
    },
    layoutVariant: 'street-rows',
    itemCardStyle: 'Bold compact rows with prominent price and quick category scanning.',
    categoryNavigationStyle: 'Punchy sticky tabs with strong coral active indicator.',
    loyaltyBlockStyle: 'Direct earn/redeem panel with coral action and green success state.',
    stateStyle: 'High-contrast states, fast skeletons, and direct retry copy.',
    preview: {
      label: 'Bold prices and tabs',
      description: 'Energetic row layout with prominent category and price treatment.',
      swatches: [wafloPalette.primaryCoral, '#FFB020', '#FFF3EC']
    }
  },
  {
    id: 'minimal-modern',
    displayName: 'Minimal Modern',
    description: 'Clean white and neutral style with subtle accents for premium simple menus.',
    bestFor: 'Fine casual restaurants, modern cafes, simple menus, and premium dining',
    themeTokens: {
      background: wafloPalette.surfaceWhite,
      surface: wafloPalette.surfaceWhite,
      primary: wafloPalette.primaryCoral,
      primaryDark: wafloPalette.primaryCoralDark,
      success: wafloPalette.freshGreenDark,
      border: '#E5E7EB',
      text: wafloPalette.textDark,
      muted: wafloPalette.mutedText,
      reward: wafloPalette.rewardGold
    },
    layoutVariant: 'minimal-list',
    itemCardStyle: 'Border-first rows with restrained images and strong text hierarchy.',
    categoryNavigationStyle: 'Simple underlined tabs with subtle coral active state.',
    loyaltyBlockStyle: 'Quiet inline loyalty panel with subtle coral CTA and green progress.',
    stateStyle: 'Minimal empty/loading/error states with unobtrusive borders.',
    preview: {
      label: 'Clean white list',
      description: 'Sparse menu layout with subtle coral action and thin dividers.',
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
  return publicMenuTemplates.find((template) => template.id === id) ?? publicMenuTemplates[0];
}

export const LOYALTY_STAMP_STYLE_TYPES = ['PRESET'] as const;

export const LOYALTY_STAMP_PRESET_KEYS = [
  'STAR',
  'COOKIE',
  'COFFEE',
  'BOWL',
  'BURGER',
  'PIZZA',
  'HEART',
  'CUPCAKE'
] as const;

export const LOYALTY_STAMP_LAYOUT_VARIANTS = ['MODERN', 'COMPACT'] as const;

export type LoyaltyStampStyleTypeValue =
  (typeof LOYALTY_STAMP_STYLE_TYPES)[number];
export type LoyaltyStampPresetKeyValue =
  (typeof LOYALTY_STAMP_PRESET_KEYS)[number];
export type LoyaltyStampLayoutVariantValue =
  (typeof LOYALTY_STAMP_LAYOUT_VARIANTS)[number];

export const DEFAULT_LOYALTY_STAMP_STYLE = {
  styleType: 'PRESET',
  presetKey: 'STAR',
  backgroundColor: '#111827',
  accentColor: '#f59e0b',
  textColor: '#ffffff',
  layoutVariant: 'MODERN'
} as const satisfies {
  styleType: LoyaltyStampStyleTypeValue;
  presetKey: LoyaltyStampPresetKeyValue;
  backgroundColor: string;
  accentColor: string;
  textColor: string;
  layoutVariant: LoyaltyStampLayoutVariantValue;
};

export const LOYALTY_STAMP_PRESETS = [
  { key: 'STAR', label: 'Star' },
  { key: 'COOKIE', label: 'Cookie' },
  { key: 'COFFEE', label: 'Coffee' },
  { key: 'BOWL', label: 'Bowl' },
  { key: 'BURGER', label: 'Burger' },
  { key: 'PIZZA', label: 'Pizza' },
  { key: 'HEART', label: 'Heart' },
  { key: 'CUPCAKE', label: 'Cupcake' }
] satisfies Array<{
  key: LoyaltyStampPresetKeyValue;
  label: string;
}>;

export const HEX_COLOR_PATTERN = /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/;

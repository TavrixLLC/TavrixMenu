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

export const LOYALTY_WALLET_THEME_PRESETS = [
  'DEFAULT',
  'COFFEE',
  'RESTAURANT',
  'DESSERT',
  'MINIMAL',
  'CUSTOM'
] as const;

export const LOYALTY_WALLET_COLOR_MODES = ['PRESET', 'CUSTOM'] as const;

export type LoyaltyStampStyleTypeValue =
  (typeof LOYALTY_STAMP_STYLE_TYPES)[number];
export type LoyaltyStampPresetKeyValue =
  (typeof LOYALTY_STAMP_PRESET_KEYS)[number];
export type LoyaltyStampLayoutVariantValue =
  (typeof LOYALTY_STAMP_LAYOUT_VARIANTS)[number];
export type LoyaltyWalletThemePresetValue =
  (typeof LOYALTY_WALLET_THEME_PRESETS)[number];
export type LoyaltyWalletColorModeValue =
  (typeof LOYALTY_WALLET_COLOR_MODES)[number];

export type LoyaltyWalletThemePalette = {
  walletBackgroundColor: string;
  imageBackgroundColor: string;
  imageSurfaceColor: string;
  imageAccentColor: string;
  imageTextColor: string;
  stampFilledColor: string;
  stampEmptyColor: string;
  rewardBannerColor: string;
};

export type LoyaltyWalletThemePreset = {
  key: LoyaltyWalletThemePresetValue;
  label: string;
  recommendedPalette: LoyaltyWalletThemePalette;
};

export const DEFAULT_LOYALTY_WALLET_THEME_PALETTE = {
  walletBackgroundColor: '#2563eb',
  imageBackgroundColor: '#1d4ed8',
  imageSurfaceColor: '#2563eb',
  imageAccentColor: '#fde047',
  imageTextColor: '#eff6ff',
  stampFilledColor: '#fde047',
  stampEmptyColor: '#bfdbfe',
  rewardBannerColor: '#1e40af'
} as const satisfies LoyaltyWalletThemePalette;

export const DEFAULT_LOYALTY_WALLET_THEME = {
  ...DEFAULT_LOYALTY_WALLET_THEME_PALETTE,
  themePreset: 'DEFAULT',
  colorMode: 'PRESET'
} as const satisfies LoyaltyWalletThemePalette & {
  themePreset: LoyaltyWalletThemePresetValue;
  colorMode: LoyaltyWalletColorModeValue;
};

export const DEFAULT_LOYALTY_STAMP_STYLE = {
  styleType: 'PRESET',
  presetKey: 'STAR',
  backgroundColor: '#111827',
  accentColor: '#f59e0b',
  textColor: '#ffffff',
  layoutVariant: 'MODERN',
  ...DEFAULT_LOYALTY_WALLET_THEME
} as const satisfies {
  styleType: LoyaltyStampStyleTypeValue;
  presetKey: LoyaltyStampPresetKeyValue;
  backgroundColor: string;
  accentColor: string;
  textColor: string;
  layoutVariant: LoyaltyStampLayoutVariantValue;
} & LoyaltyWalletThemePalette & {
  themePreset: LoyaltyWalletThemePresetValue;
  colorMode: LoyaltyWalletColorModeValue;
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

export const LOYALTY_WALLET_THEME_PRESET_CATALOG = [
  {
    key: 'DEFAULT',
    label: 'Default',
    recommendedPalette: DEFAULT_LOYALTY_WALLET_THEME_PALETTE
  },
  {
    key: 'COFFEE',
    label: 'Coffee',
    recommendedPalette: {
      walletBackgroundColor: '#7c2d12',
      imageBackgroundColor: '#7c2d12',
      imageSurfaceColor: '#92400e',
      imageAccentColor: '#facc15',
      imageTextColor: '#ffffff',
      stampFilledColor: '#facc15',
      stampEmptyColor: '#d6d3d1',
      rewardBannerColor: '#a16207'
    }
  },
  {
    key: 'RESTAURANT',
    label: 'Restaurant',
    recommendedPalette: {
      walletBackgroundColor: '#065f46',
      imageBackgroundColor: '#064e3b',
      imageSurfaceColor: '#047857',
      imageAccentColor: '#34d399',
      imageTextColor: '#ecfdf5',
      stampFilledColor: '#34d399',
      stampEmptyColor: '#a7f3d0',
      rewardBannerColor: '#047857'
    }
  },
  {
    key: 'DESSERT',
    label: 'Dessert',
    recommendedPalette: {
      walletBackgroundColor: '#be185d',
      imageBackgroundColor: '#831843',
      imageSurfaceColor: '#9d174d',
      imageAccentColor: '#f9a8d4',
      imageTextColor: '#fff1f2',
      stampFilledColor: '#f9a8d4',
      stampEmptyColor: '#fce7f3',
      rewardBannerColor: '#be185d'
    }
  },
  {
    key: 'MINIMAL',
    label: 'Minimal',
    recommendedPalette: {
      walletBackgroundColor: '#111827',
      imageBackgroundColor: '#111827',
      imageSurfaceColor: '#1f2937',
      imageAccentColor: '#e5e7eb',
      imageTextColor: '#f9fafb',
      stampFilledColor: '#f9fafb',
      stampEmptyColor: '#9ca3af',
      rewardBannerColor: '#374151'
    }
  },
  {
    key: 'CUSTOM',
    label: 'Custom',
    recommendedPalette: DEFAULT_LOYALTY_WALLET_THEME_PALETTE
  }
] as const satisfies ReadonlyArray<LoyaltyWalletThemePreset>;

export const HEX_COLOR_PATTERN = /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/;

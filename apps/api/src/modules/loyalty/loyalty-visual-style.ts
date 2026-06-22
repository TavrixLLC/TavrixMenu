import {
  DEFAULT_LOYALTY_STAMP_STYLE,
  HEX_COLOR_PATTERN,
  LOYALTY_WALLET_THEME_PRESET_CATALOG,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue,
  LoyaltyWalletColorModeValue,
  LoyaltyWalletThemePalette,
  LoyaltyWalletThemePresetValue
} from './loyalty-stamp-style.constants';

type StoredVisualStyle = {
  presetKey: LoyaltyStampPresetKeyValue;
  backgroundColor: string;
  accentColor: string;
  textColor: string;
  walletBackgroundColor: string;
  imageBackgroundColor: string;
  imageSurfaceColor: string;
  imageAccentColor: string;
  imageTextColor: string;
  stampFilledColor: string;
  stampEmptyColor: string;
  rewardBannerColor: string;
  themePreset: LoyaltyWalletThemePresetValue;
  colorMode: LoyaltyWalletColorModeValue;
  layoutVariant: LoyaltyStampLayoutVariantValue;
};

export type LoyaltyProgramVisualInput = {
  cardColor?: string | null;
  accentColor?: string | null;
  stampStyle?: StoredVisualStyle | null;
};

export type ResolvedLoyaltyVisualStyle = {
  presetKey: LoyaltyStampPresetKeyValue;
  backgroundColor: string;
  accentColor: string;
  textColor: string;
  themePreset: LoyaltyWalletThemePresetValue;
  colorMode: LoyaltyWalletColorModeValue;
  layoutVariant: LoyaltyStampLayoutVariantValue;
} & LoyaltyWalletThemePalette;

export function resolveLoyaltyVisualStyle(
  program: LoyaltyProgramVisualInput
): ResolvedLoyaltyVisualStyle {
  const stored = program.stampStyle;

  if (!stored) {
    const walletBackgroundColor = colorOrFallback(
      program.cardColor,
      DEFAULT_LOYALTY_STAMP_STYLE.walletBackgroundColor
    );
    const imageAccentColor = colorOrFallback(
      program.accentColor,
      DEFAULT_LOYALTY_STAMP_STYLE.imageAccentColor
    );

    return {
      presetKey: DEFAULT_LOYALTY_STAMP_STYLE.presetKey,
      backgroundColor: walletBackgroundColor,
      accentColor: imageAccentColor,
      textColor: DEFAULT_LOYALTY_STAMP_STYLE.textColor,
      walletBackgroundColor,
      imageBackgroundColor: walletBackgroundColor,
      imageSurfaceColor: mixHex(walletBackgroundColor, '#ffffff', 0.12),
      imageAccentColor,
      imageTextColor: DEFAULT_LOYALTY_STAMP_STYLE.imageTextColor,
      stampFilledColor: imageAccentColor,
      stampEmptyColor: mixHex(walletBackgroundColor, '#ffffff', 0.58),
      rewardBannerColor: mixHex(walletBackgroundColor, '#000000', 0.22),
      themePreset: DEFAULT_LOYALTY_STAMP_STYLE.themePreset,
      colorMode: DEFAULT_LOYALTY_STAMP_STYLE.colorMode,
      layoutVariant: DEFAULT_LOYALTY_STAMP_STYLE.layoutVariant
    };
  }

  const presetPalette =
    stored.colorMode === 'PRESET'
      ? LOYALTY_WALLET_THEME_PRESET_CATALOG.find(
          (preset) => preset.key === stored.themePreset
        )?.recommendedPalette
      : undefined;
  const palette = presetPalette ?? stored;

  return {
    presetKey: stored.presetKey,
    backgroundColor: colorOrFallback(
      stored.backgroundColor,
      palette.imageBackgroundColor
    ),
    accentColor: colorOrFallback(
      stored.accentColor,
      palette.imageAccentColor
    ),
    textColor: colorOrFallback(stored.textColor, palette.imageTextColor),
    walletBackgroundColor: colorOrFallback(
      palette.walletBackgroundColor,
      DEFAULT_LOYALTY_STAMP_STYLE.walletBackgroundColor
    ),
    imageBackgroundColor: colorOrFallback(
      palette.imageBackgroundColor,
      DEFAULT_LOYALTY_STAMP_STYLE.imageBackgroundColor
    ),
    imageSurfaceColor: colorOrFallback(
      palette.imageSurfaceColor,
      DEFAULT_LOYALTY_STAMP_STYLE.imageSurfaceColor
    ),
    imageAccentColor: colorOrFallback(
      palette.imageAccentColor,
      DEFAULT_LOYALTY_STAMP_STYLE.imageAccentColor
    ),
    imageTextColor: colorOrFallback(
      palette.imageTextColor,
      DEFAULT_LOYALTY_STAMP_STYLE.imageTextColor
    ),
    stampFilledColor: colorOrFallback(
      palette.stampFilledColor,
      DEFAULT_LOYALTY_STAMP_STYLE.stampFilledColor
    ),
    stampEmptyColor: colorOrFallback(
      palette.stampEmptyColor,
      DEFAULT_LOYALTY_STAMP_STYLE.stampEmptyColor
    ),
    rewardBannerColor: colorOrFallback(
      palette.rewardBannerColor,
      DEFAULT_LOYALTY_STAMP_STYLE.rewardBannerColor
    ),
    themePreset: stored.themePreset,
    colorMode: stored.colorMode,
    layoutVariant: stored.layoutVariant
  };
}

function colorOrFallback(value: string | null | undefined, fallback: string) {
  const normalized = value?.trim();

  return normalized && HEX_COLOR_PATTERN.test(normalized)
    ? normalized
    : fallback;
}

function mixHex(first: string, second: string, secondWeight: number) {
  const firstRgb = hexToRgb(first);
  const secondRgb = hexToRgb(second);
  const weight = Math.min(Math.max(secondWeight, 0), 1);

  return rgbToHex(
    firstRgb.map((value, index) =>
      Math.round(value * (1 - weight) + secondRgb[index] * weight)
    ) as [number, number, number]
  );
}

function hexToRgb(value: string): [number, number, number] {
  const normalized =
    value.length === 4
      ? `#${value[1]}${value[1]}${value[2]}${value[2]}${value[3]}${value[3]}`
      : value;

  return [
    Number.parseInt(normalized.slice(1, 3), 16),
    Number.parseInt(normalized.slice(3, 5), 16),
    Number.parseInt(normalized.slice(5, 7), 16)
  ];
}

function rgbToHex([red, green, blue]: [number, number, number]) {
  return `#${[red, green, blue]
    .map((value) => value.toString(16).padStart(2, '0'))
    .join('')}`;
}

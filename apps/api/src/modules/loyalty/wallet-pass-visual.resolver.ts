import {
  DEFAULT_LOYALTY_STAMP_STYLE,
  HEX_COLOR_PATTERN,
  LOYALTY_STAMP_LAYOUT_VARIANTS,
  LOYALTY_STAMP_PRESET_KEYS,
  LOYALTY_WALLET_THEME_PRESETS,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue,
  LoyaltyWalletThemePresetValue
} from './loyalty-stamp-style.constants';

export type WalletPassVisualTheme = {
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
  layoutVariant: LoyaltyStampLayoutVariantValue;
};

export type WalletPassVisualThemeSource = {
  cardColor: string | null;
  accentColor: string | null;
  stampStyle: (Partial<WalletPassVisualTheme> & {
    presetKey?: string;
    themePreset?: string;
    layoutVariant?: string;
  }) | null;
};

export type WalletPassVisualInput = {
  businessName?: string;
  programName?: string;
  rewardName?: string;
  logoUrl?: string | null;
  stampCount: number;
  stampGoal: number;
  theme?: Partial<WalletPassVisualTheme>;
};

export type WalletPassVisualModel = {
  businessName: string;
  programName: string;
  rewardName: string;
  logoUrl: string | null;
  stampCount: number;
  stampGoal: number;
  progressLabel: 'STAMPS';
  progressText: string;
  progressHeadline: string;
  rewardSummary: string;
  theme: WalletPassVisualTheme;
};

const legacyDefaultPalette = {
  walletBackgroundColor: '#2563eb',
  imageBackgroundColor: '#7c2d12',
  imageSurfaceColor: '#92400e',
  imageAccentColor: '#facc15',
  imageTextColor: '#ffffff',
  stampFilledColor: '#facc15',
  stampEmptyColor: '#d6d3d1',
  rewardBannerColor: '#a16207'
};

export function resolveWalletPassVisualTheme(
  program: WalletPassVisualThemeSource
): WalletPassVisualTheme {
  if (program.stampStyle) {
    const style = resolveTheme(program.stampStyle);

    return usesLegacyDefaultPalette(style)
      ? {
          ...style,
          walletBackgroundColor:
            DEFAULT_LOYALTY_STAMP_STYLE.walletBackgroundColor,
          imageBackgroundColor:
            DEFAULT_LOYALTY_STAMP_STYLE.imageBackgroundColor,
          imageSurfaceColor: DEFAULT_LOYALTY_STAMP_STYLE.imageSurfaceColor,
          imageAccentColor: DEFAULT_LOYALTY_STAMP_STYLE.imageAccentColor,
          imageTextColor: DEFAULT_LOYALTY_STAMP_STYLE.imageTextColor,
          stampFilledColor: DEFAULT_LOYALTY_STAMP_STYLE.stampFilledColor,
          stampEmptyColor: DEFAULT_LOYALTY_STAMP_STYLE.stampEmptyColor,
          rewardBannerColor: DEFAULT_LOYALTY_STAMP_STYLE.rewardBannerColor
        }
      : style;
  }

  const background = safeHexColor(
    program.cardColor,
    DEFAULT_LOYALTY_STAMP_STYLE.walletBackgroundColor
  );
  const accent = safeHexColor(
    program.accentColor,
    DEFAULT_LOYALTY_STAMP_STYLE.imageAccentColor
  );
  const text = contrastText(background);

  return {
    presetKey: DEFAULT_LOYALTY_STAMP_STYLE.presetKey,
    backgroundColor: background,
    accentColor: accent,
    textColor: text,
    walletBackgroundColor: background,
    imageBackgroundColor: background,
    imageSurfaceColor: mixForSurface(background),
    imageAccentColor: accent,
    imageTextColor: text,
    stampFilledColor: accent,
    stampEmptyColor: mixColors(background, text, 0.56),
    rewardBannerColor: mixForSurface(background),
    themePreset: DEFAULT_LOYALTY_STAMP_STYLE.themePreset,
    layoutVariant: DEFAULT_LOYALTY_STAMP_STYLE.layoutVariant
  };
}

export function resolveWalletPassVisual(
  input: WalletPassVisualInput
): WalletPassVisualModel {
  if (!Number.isInteger(input.stampGoal) || input.stampGoal < 1) {
    throw new Error('stampGoal must be a positive integer');
  }

  if (!Number.isInteger(input.stampCount) || input.stampCount < 0) {
    throw new Error('stampCount must be a non-negative integer');
  }

  const stampCount = Math.min(input.stampCount, input.stampGoal);
  const remaining = input.stampGoal - stampCount;
  const rewardName = safeText(input.rewardName, 'Reward', 72);

  return {
    businessName: safeText(input.businessName, 'Waflo', 64),
    programName: safeText(input.programName, 'Loyalty Card', 64),
    rewardName,
    logoUrl: safeHttpsUrl(input.logoUrl),
    stampCount,
    stampGoal: input.stampGoal,
    progressLabel: 'STAMPS',
    progressText: `${stampCount} / ${input.stampGoal}`,
    progressHeadline:
      remaining === 0
        ? 'Reward ready'
        : `${remaining} ${remaining === 1 ? 'stamp' : 'stamps'} to reward`,
    rewardSummary: `Reward: ${rewardName}`,
    theme: resolveTheme(input.theme)
  };
}

function resolveTheme(
  input: Partial<WalletPassVisualTheme> = {}
): WalletPassVisualTheme {
  const backgroundColor = safeHexColor(
    input.backgroundColor,
    DEFAULT_LOYALTY_STAMP_STYLE.backgroundColor
  );
  const accentColor = safeHexColor(
    input.accentColor,
    DEFAULT_LOYALTY_STAMP_STYLE.accentColor
  );
  const textColor = safeHexColor(
    input.textColor,
    DEFAULT_LOYALTY_STAMP_STYLE.textColor
  );
  const imageBackgroundColor = safeHexColor(
    input.imageBackgroundColor,
    DEFAULT_LOYALTY_STAMP_STYLE.imageBackgroundColor
  );
  const imageAccentColor = safeHexColor(
    input.imageAccentColor,
    accentColor
  );
  const imageTextColor = safeHexColor(input.imageTextColor, textColor);

  return {
    presetKey: LOYALTY_STAMP_PRESET_KEYS.includes(
      input.presetKey as LoyaltyStampPresetKeyValue
    )
      ? (input.presetKey as LoyaltyStampPresetKeyValue)
      : DEFAULT_LOYALTY_STAMP_STYLE.presetKey,
    backgroundColor,
    accentColor,
    textColor,
    walletBackgroundColor: safeHexColor(
      input.walletBackgroundColor,
      DEFAULT_LOYALTY_STAMP_STYLE.walletBackgroundColor
    ),
    imageBackgroundColor,
    imageSurfaceColor: safeHexColor(
      input.imageSurfaceColor,
      DEFAULT_LOYALTY_STAMP_STYLE.imageSurfaceColor
    ),
    imageAccentColor,
    imageTextColor,
    stampFilledColor: safeHexColor(
      input.stampFilledColor,
      imageAccentColor
    ),
    stampEmptyColor: safeHexColor(
      input.stampEmptyColor,
      DEFAULT_LOYALTY_STAMP_STYLE.stampEmptyColor
    ),
    rewardBannerColor: safeHexColor(
      input.rewardBannerColor,
      DEFAULT_LOYALTY_STAMP_STYLE.rewardBannerColor
    ),
    themePreset: LOYALTY_WALLET_THEME_PRESETS.includes(
      input.themePreset as LoyaltyWalletThemePresetValue
    )
      ? (input.themePreset as LoyaltyWalletThemePresetValue)
      : DEFAULT_LOYALTY_STAMP_STYLE.themePreset,
    layoutVariant: LOYALTY_STAMP_LAYOUT_VARIANTS.includes(
      input.layoutVariant as LoyaltyStampLayoutVariantValue
    )
      ? (input.layoutVariant as LoyaltyStampLayoutVariantValue)
      : DEFAULT_LOYALTY_STAMP_STYLE.layoutVariant
  };
}

function usesLegacyDefaultPalette(theme: WalletPassVisualTheme) {
  return (
    theme.themePreset === 'DEFAULT' &&
    Object.entries(legacyDefaultPalette).every(
      ([key, value]) =>
        theme[key as keyof typeof legacyDefaultPalette].toLowerCase() === value
    )
  );
}

function safeText(value: string | undefined, fallback: string, max: number) {
  const normalized = value
    ?.replace(/[\u0000-\u001f\u007f]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  const characters = Array.from(normalized || fallback);

  return characters.length <= max
    ? characters.join('')
    : `${characters.slice(0, max - 3).join('')}...`;
}

function safeHttpsUrl(value: string | null | undefined) {
  if (!value) {
    return null;
  }

  try {
    const parsed = new URL(value);

    return parsed.protocol === 'https:' ? parsed.toString() : null;
  } catch {
    return null;
  }
}

function safeHexColor(value: string | null | undefined, fallback: string) {
  const normalized = value?.trim();

  if (!normalized || !HEX_COLOR_PATTERN.test(normalized)) {
    return expandHex(fallback);
  }

  return expandHex(normalized);
}

function expandHex(value: string) {
  const normalized = value.toLowerCase();

  return normalized.length === 4
    ? `#${normalized
        .slice(1)
        .split('')
        .map((character) => character.repeat(2))
        .join('')}`
    : normalized;
}

function contrastText(color: string) {
  const [red, green, blue] = hexToRgb(color);
  const luminance = (red * 299 + green * 587 + blue * 114) / 1000;

  return luminance > 165 ? '#111827' : '#ffffff';
}

function mixForSurface(color: string) {
  return contrastText(color) === '#ffffff'
    ? mixColors(color, '#ffffff', 0.12)
    : mixColors(color, '#000000', 0.1);
}

function mixColors(base: string, overlay: string, amount: number) {
  const baseRgb = hexToRgb(base);
  const overlayRgb = hexToRgb(overlay);

  return rgbToHex(
    baseRgb.map((value, index) =>
      Math.round(value * (1 - amount) + overlayRgb[index] * amount)
    ) as [number, number, number]
  );
}

function hexToRgb(value: string): [number, number, number] {
  const hex = expandHex(value).slice(1);

  return [
    Number.parseInt(hex.slice(0, 2), 16),
    Number.parseInt(hex.slice(2, 4), 16),
    Number.parseInt(hex.slice(4, 6), 16)
  ];
}

function rgbToHex([red, green, blue]: [number, number, number]) {
  return `#${[red, green, blue]
    .map((value) => value.toString(16).padStart(2, '0'))
    .join('')}`;
}

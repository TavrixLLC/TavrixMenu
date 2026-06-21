import { DEFAULT_LOYALTY_STAMP_STYLE } from '../loyalty/loyalty-stamp-style.constants';
import { AppleWalletPassTheme } from './apple-wallet.types';

type AppleWalletPassThemeSource = {
  cardColor: string | null;
  accentColor: string | null;
  stampStyle: {
    walletBackgroundColor: string;
    imageBackgroundColor: string;
    imageSurfaceColor: string;
    imageAccentColor: string;
    imageTextColor: string;
    stampFilledColor: string;
    stampEmptyColor: string;
  } | null;
};

export function resolveAppleWalletPassTheme(
  program: AppleWalletPassThemeSource
): AppleWalletPassTheme {
  if (program.stampStyle) {
    return {
      walletBackgroundColor: program.stampStyle.walletBackgroundColor,
      imageBackgroundColor: program.stampStyle.imageBackgroundColor,
      imageSurfaceColor: program.stampStyle.imageSurfaceColor,
      imageAccentColor: program.stampStyle.imageAccentColor,
      imageTextColor: program.stampStyle.imageTextColor,
      stampFilledColor: program.stampStyle.stampFilledColor,
      stampEmptyColor: program.stampStyle.stampEmptyColor
    };
  }

  const background = safeHexColor(
    program.cardColor,
    DEFAULT_LOYALTY_STAMP_STYLE.walletBackgroundColor
  );
  const accent = safeHexColor(
    program.accentColor,
    DEFAULT_LOYALTY_STAMP_STYLE.imageAccentColor
  );

  return {
    walletBackgroundColor: background,
    imageBackgroundColor: background,
    imageSurfaceColor: background,
    imageAccentColor: accent,
    imageTextColor: contrastText(background),
    stampFilledColor: accent,
    stampEmptyColor: DEFAULT_LOYALTY_STAMP_STYLE.stampEmptyColor
  };
}

function safeHexColor(value: string | null, fallback: string) {
  const normalized = value?.trim();
  return normalized && /^#(?:[0-9a-f]{3}|[0-9a-f]{6})$/i.test(normalized)
    ? normalized
    : fallback;
}

function contrastText(color: string) {
  const normalized =
    color.length === 4
      ? color
          .slice(1)
          .split('')
          .map((character) => character.repeat(2))
          .join('')
      : color.slice(1);
  const red = Number.parseInt(normalized.slice(0, 2), 16);
  const green = Number.parseInt(normalized.slice(2, 4), 16);
  const blue = Number.parseInt(normalized.slice(4, 6), 16);
  const luminance = (red * 299 + green * 587 + blue * 114) / 1000;

  return luminance > 165 ? '#111827' : '#ffffff';
}

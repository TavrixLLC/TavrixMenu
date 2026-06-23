import { mkdir, writeFile } from 'fs/promises';
import { join, relative } from 'path';
import {
  LOYALTY_WALLET_THEME_PRESET_CATALOG,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue,
  LoyaltyWalletThemePresetValue
} from '../src/modules/loyalty/loyalty-stamp-style.constants';
import {
  StampImageRendererService,
  StampImageRenderInput
} from '../src/modules/loyalty/stamp-image-renderer.service';
import { AppleWalletPassBuilderService } from '../src/modules/apple-wallet/apple-wallet-pass-builder.service';

type PreviewDefinition = {
  fileName: string;
  platform: 'APPLE' | 'GOOGLE';
  businessName: string;
  programName: string;
  rewardName: string;
  stampCount: number;
  stampGoal: number;
  presetKey: LoyaltyStampPresetKeyValue;
  themePreset: LoyaltyWalletThemePresetValue;
  layoutVariant: LoyaltyStampLayoutVariantValue;
};

const outputRoot = join(
  process.cwd(),
  'public',
  'generated',
  'wallet-previews'
);
const renderer = new StampImageRendererService();
const applePassBuilder = new AppleWalletPassBuilderService(renderer);

const previews: PreviewDefinition[] = [
  {
    fileName: 'apple-5-cookie-coffee.png',
    platform: 'APPLE',
    businessName: 'Waflo Bakery',
    programName: 'Cookie Club',
    rewardName: 'Free cookie box',
    stampCount: 3,
    stampGoal: 5,
    presetKey: 'COOKIE',
    themePreset: 'COFFEE',
    layoutVariant: 'MODERN'
  },
  {
    fileName: 'apple-10-star-blue.png',
    platform: 'APPLE',
    businessName: 'Waflo',
    programName: 'Blue Rewards',
    rewardName: 'Free menu item',
    stampCount: 7,
    stampGoal: 10,
    presetKey: 'STAR',
    themePreset: 'DEFAULT',
    layoutVariant: 'MODERN'
  },
  {
    fileName: 'apple-8-coffee.png',
    platform: 'APPLE',
    businessName: 'Tavrix Cafe',
    programName: 'Coffee Rewards',
    rewardName: 'Free Turkish coffee',
    stampCount: 5,
    stampGoal: 8,
    presetKey: 'COFFEE',
    themePreset: 'COFFEE',
    layoutVariant: 'MODERN'
  },
  {
    fileName: 'apple-12-heart-dark.png',
    platform: 'APPLE',
    businessName: 'Waflo',
    programName: 'After Dark Rewards',
    rewardName: 'VIP dessert',
    stampCount: 9,
    stampGoal: 12,
    presetKey: 'HEART',
    themePreset: 'MINIMAL',
    layoutVariant: 'MODERN'
  },
  {
    fileName: 'google-5-cookie.png',
    platform: 'GOOGLE',
    businessName: 'Waflo Bakery',
    programName: 'Cookie Club',
    rewardName: 'Free cookie box',
    stampCount: 3,
    stampGoal: 5,
    presetKey: 'COOKIE',
    themePreset: 'DESSERT',
    layoutVariant: 'MODERN'
  },
  {
    fileName: 'google-10-coffee.png',
    platform: 'GOOGLE',
    businessName: 'Tavrix Cafe',
    programName: 'Coffee Rewards',
    rewardName: 'Free Turkish coffee',
    stampCount: 6,
    stampGoal: 10,
    presetKey: 'COFFEE',
    themePreset: 'COFFEE',
    layoutVariant: 'MODERN'
  },
  {
    fileName: 'google-10-default-blue.png',
    platform: 'GOOGLE',
    businessName: 'Waflo',
    programName: 'Blue Rewards',
    rewardName: 'Free menu item',
    stampCount: 7,
    stampGoal: 10,
    presetKey: 'STAR',
    themePreset: 'DEFAULT',
    layoutVariant: 'MODERN'
  },
  {
    fileName: 'google-10-dark.png',
    platform: 'GOOGLE',
    businessName: 'Waflo',
    programName: 'After Dark Rewards',
    rewardName: 'VIP dessert',
    stampCount: 8,
    stampGoal: 10,
    presetKey: 'CUPCAKE',
    themePreset: 'MINIMAL',
    layoutVariant: 'MODERN'
  }
];

async function main() {
  await mkdir(outputRoot, {
    recursive: true
  });

  const renderedFiles: string[] = [];

  for (const preview of previews) {
    const input = renderInput(preview);
    const png =
      preview.platform === 'APPLE'
        ? (
            await applePassBuilder.buildAssets({
              passTypeIdentifier: 'pass.app.waflo.preview',
              serialNumber: `preview-${preview.stampGoal}`,
              teamIdentifier: 'PREVIEW0000',
              organizationName: 'Waflo',
              barcodeValue: '<redacted-preview-barcode>',
              businessName: preview.businessName,
              programName: preview.programName,
              rewardName: preview.rewardName,
              stampCount: preview.stampCount,
              stampGoal: preview.stampGoal,
              theme: input
            })
          )['strip@3x.png']
        : await renderer.renderPng(input);
    const outputPath = join(outputRoot, preview.fileName);

    await writeFile(outputPath, png);
    renderedFiles.push(relative(process.cwd(), outputPath));
  }

  console.log(
    JSON.stringify(
      {
        passed: true,
        outputDirectory: relative(process.cwd(), outputRoot),
        files: renderedFiles
      },
      null,
      2
    )
  );
}

function renderInput(preview: PreviewDefinition): StampImageRenderInput {
  const theme = LOYALTY_WALLET_THEME_PRESET_CATALOG.find(
    (candidate) => candidate.key === preview.themePreset
  );

  if (!theme) {
    throw new Error(`Missing preview theme ${preview.themePreset}`);
  }

  return {
    businessName: preview.businessName,
    programName: preview.programName,
    rewardName: preview.rewardName,
    stampCount: preview.stampCount,
    stampGoal: preview.stampGoal,
    presetKey: preview.presetKey,
    backgroundColor: theme.recommendedPalette.imageBackgroundColor,
    accentColor: theme.recommendedPalette.imageAccentColor,
    textColor: theme.recommendedPalette.imageTextColor,
    ...theme.recommendedPalette,
    themePreset: preview.themePreset,
    layoutVariant: preview.layoutVariant
  };
}

main().catch((error) => {
  console.error(
    error instanceof Error ? error.message : 'Wallet preview rendering failed'
  );
  process.exitCode = 1;
});

import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';
import { StampImageRendererService } from '../src/modules/loyalty/stamp-image-renderer.service';
import { StampImageStorageService } from '../src/modules/loyalty/stamp-image-storage.service';

loadEnvFile();

const renderer = new StampImageRendererService();
const storage = new StampImageStorageService(renderer);

const previews = [
  {
    membershipId: 'preview-cookie',
    businessName: 'Waflo Demo Cafe',
    programName: 'Cookie Club',
    rewardName: 'Free cookie box',
    stampCount: 3,
    stampGoal: 10,
    presetKey: 'COOKIE' as const,
    backgroundColor: '#7c2d12',
    accentColor: '#facc15',
    textColor: '#fff7ed',
    imageBackgroundColor: '#7c2d12',
    imageSurfaceColor: '#92400e',
    imageAccentColor: '#facc15',
    imageTextColor: '#ffffff',
    stampFilledColor: '#facc15',
    stampEmptyColor: '#d6d3d1',
    rewardBannerColor: '#a16207',
    themePreset: 'COFFEE' as const,
    layoutVariant: 'MODERN' as const
  },
  {
    membershipId: 'preview-coffee',
    businessName: 'Tavrix Cafe',
    programName: 'Coffee Rewards',
    rewardName: 'Free Turkish coffee',
    stampCount: 5,
    stampGoal: 10,
    presetKey: 'COFFEE' as const,
    backgroundColor: '#111827',
    accentColor: '#f59e0b',
    textColor: '#ffffff',
    imageBackgroundColor: '#111827',
    imageSurfaceColor: '#1f2937',
    imageAccentColor: '#f59e0b',
    imageTextColor: '#ffffff',
    stampFilledColor: '#f59e0b',
    stampEmptyColor: '#d1d5db',
    rewardBannerColor: '#92400e',
    themePreset: 'COFFEE' as const,
    layoutVariant: 'MODERN' as const
  },
  {
    membershipId: 'preview-bowl',
    businessName: 'Baghdad Bowl',
    programName: 'Lunch Stamps',
    rewardName: 'Free lunch bowl',
    stampCount: 2,
    stampGoal: 5,
    presetKey: 'BOWL' as const,
    backgroundColor: '#064e3b',
    accentColor: '#34d399',
    textColor: '#ecfdf5',
    imageBackgroundColor: '#064e3b',
    imageSurfaceColor: '#047857',
    imageAccentColor: '#34d399',
    imageTextColor: '#ecfdf5',
    stampFilledColor: '#34d399',
    stampEmptyColor: '#a7f3d0',
    rewardBannerColor: '#047857',
    themePreset: 'RESTAURANT' as const,
    layoutVariant: 'COMPACT' as const
  },
  {
    membershipId: 'preview-star',
    businessName: 'Waflo Stars',
    programName: 'VIP Rewards',
    rewardName: 'Completed reward',
    stampCount: 10,
    stampGoal: 10,
    presetKey: 'STAR' as const,
    backgroundColor: '#1d4ed8',
    accentColor: '#fde047',
    textColor: '#eff6ff',
    imageBackgroundColor: '#1d4ed8',
    imageSurfaceColor: '#2563eb',
    imageAccentColor: '#fde047',
    imageTextColor: '#eff6ff',
    stampFilledColor: '#fde047',
    stampEmptyColor: '#bfdbfe',
    rewardBannerColor: '#1e40af',
    themePreset: 'DEFAULT' as const,
    layoutVariant: 'MODERN' as const
  }
];

async function main() {
  const files = await Promise.all(
    previews.map((preview) => storage.renderAndStore(preview))
  );

  console.log(
    JSON.stringify(
      {
        passed: true,
        files: files.map((file) => ({
          fileName: file.fileName,
          absolutePath: file.absolutePath,
          publicUrl: file.publicUrl
        }))
      },
      null,
      2
    )
  );
}

function loadEnvFile() {
  const envPath = resolve(__dirname, '..', '.env');

  if (!existsSync(envPath)) {
    return;
  }

  const envFile = readFileSync(envPath, 'utf8');

  for (const rawLine of envFile.split(/\r?\n/)) {
    const line = rawLine.trim();

    if (!line || line.startsWith('#')) {
      continue;
    }

    const separatorIndex = line.indexOf('=');

    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    const rawValue = line.slice(separatorIndex + 1).trim();
    const value = rawValue.replace(/^['"]|['"]$/g, '');

    if (key && process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

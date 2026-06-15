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

'use client';

import { useMemo, useState } from 'react';
import { WalletAppearancePanel } from '../../components/WalletAppearancePanel';
import {
  type AdminLoyaltyStampPresetCatalog,
  type AdminLoyaltyStampStyleInput
} from '../../lib/admin-api';

const mockPresetCatalog: AdminLoyaltyStampPresetCatalog = {
  presets: [
    { key: 'STAR', label: 'Star' },
    { key: 'COOKIE', label: 'Cookie' },
    { key: 'COFFEE', label: 'Coffee' },
    { key: 'BOWL', label: 'Bowl' },
    { key: 'BURGER', label: 'Burger' },
    { key: 'PIZZA', label: 'Pizza' },
    { key: 'HEART', label: 'Heart' },
    { key: 'CUPCAKE', label: 'Cupcake' }
  ],
  stampPresets: [
    { key: 'STAR', label: 'Star' },
    { key: 'COOKIE', label: 'Cookie' },
    { key: 'COFFEE', label: 'Coffee' },
    { key: 'BOWL', label: 'Bowl' },
    { key: 'BURGER', label: 'Burger' },
    { key: 'PIZZA', label: 'Pizza' },
    { key: 'HEART', label: 'Heart' },
    { key: 'CUPCAKE', label: 'Cupcake' }
  ],
  themePresets: [
    {
      key: 'DEFAULT',
      label: 'Default',
      recommendedPalette: {
        walletBackgroundColor: '#2563eb',
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
    }
  ],
  styleTypes: ['PRESET'],
  colorModes: ['PRESET', 'CUSTOM'],
  layoutVariants: ['MODERN', 'COMPACT']
};

const initialDraft: AdminLoyaltyStampStyleInput = {
  themePreset: 'COFFEE',
  colorMode: 'PRESET',
  presetKey: 'COOKIE',
  walletBackgroundColor: '#7c2d12',
  imageBackgroundColor: '#7c2d12',
  imageSurfaceColor: '#92400e',
  imageAccentColor: '#facc15',
  imageTextColor: '#ffffff',
  stampFilledColor: '#facc15',
  stampEmptyColor: '#d6d3d1',
  rewardBannerColor: '#a16207',
  layoutVariant: 'MODERN'
};

export function WalletAppearanceDevPreview() {
  const [draft, setDraft] = useState<AdminLoyaltyStampStyleInput>(initialDraft);
  const [savedDraft, setSavedDraft] = useState<AdminLoyaltyStampStyleInput>(initialDraft);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('Mock OWNER preview. No API calls are made.');
  const isDirty = useMemo(
    () => JSON.stringify(draft) !== JSON.stringify(savedDraft),
    [draft, savedDraft]
  );

  function saveMockDraft() {
    setSaving(true);
    window.setTimeout(() => {
      setSavedDraft(draft);
      setSaving(false);
      setMessage('Mock save complete. Preview state was stored only in this page.');
    }, 300);
  }

  return (
    <main className="min-h-screen bg-[#f6f7f9] p-6">
      <div className="mx-auto grid max-w-7xl gap-5">
        <section className="rounded-lg border border-blue-200 bg-blue-50 p-5">
          <p className="text-sm font-semibold uppercase text-blue-700">Dev-only preview</p>
          <h1 className="mt-2 text-2xl font-bold text-ink">Wallet &amp; Stamp Appearance</h1>
          <p className="mt-2 max-w-3xl text-sm leading-6 text-blue-900">
            This route uses mock business/style data for local visual review when Clerk blocks the authenticated loyalty page.
            It is hidden unless <span className="font-semibold">NEXT_PUBLIC_ENABLE_DEV_PREVIEWS=true</span> and
            <span className="font-semibold"> NODE_ENV</span> is not production.
          </p>
          <div className="mt-4 flex flex-wrap gap-2 text-xs font-semibold">
            <span className="rounded-full bg-white px-2 py-1 text-blue-800 ring-1 ring-blue-200">businessId: dev_business_wallet_preview</span>
            <span className="rounded-full bg-white px-2 py-1 text-blue-800 ring-1 ring-blue-200">role: OWNER</span>
            <span className="rounded-full bg-white px-2 py-1 text-blue-800 ring-1 ring-blue-200">API calls: none</span>
          </div>
        </section>

        <p className="rounded-lg border border-neutral-200 bg-white p-3 text-sm font-semibold text-neutral-700">{message}</p>

        <WalletAppearancePanel
          actionPending={saving}
          canConfigure
          catalog={mockPresetCatalog}
          draft={draft}
          isDirty={isDirty}
          onDraftChange={setDraft}
          onSubmit={saveMockDraft}
        />
      </div>
    </main>
  );
}

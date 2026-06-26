'use client';

import { FormEvent, useMemo, useState } from 'react';
import {
  type AdminLoyaltyStampPreset,
  type AdminLoyaltyStampPresetCatalog,
  type AdminLoyaltyStampStyleInput,
  type AdminStampLayoutVariant,
  type AdminStampPresetKey,
  type AdminWalletColorMode,
  type AdminWalletThemePalette,
  type AdminWalletThemePreset,
  type AdminWalletThemePresetKey
} from '../lib/admin-api';
import { WafloBadge, WafloButton, WafloPanel, WafloToast } from './waflo';

const colorFields = [
  ['walletBackgroundColor', 'Wallet background'],
  ['imageBackgroundColor', 'Image background'],
  ['imageSurfaceColor', 'Image surface'],
  ['imageAccentColor', 'Image accent'],
  ['imageTextColor', 'Image text'],
  ['stampFilledColor', 'Stamp filled'],
  ['stampEmptyColor', 'Stamp empty'],
  ['rewardBannerColor', 'Reward banner']
] as const satisfies ReadonlyArray<[keyof AdminWalletThemePalette, string]>;

const hexColorPattern = /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/;

type WalletAppearancePanelProps = {
  catalog: AdminLoyaltyStampPresetCatalog;
  draft: AdminLoyaltyStampStyleInput;
  canConfigure: boolean;
  actionPending: boolean;
  isDirty: boolean;
  onDraftChange: (draft: AdminLoyaltyStampStyleInput) => void;
  onSubmit: () => void;
};

export function WalletAppearancePanel({
  catalog,
  draft,
  canConfigure,
  actionPending,
  isDirty,
  onDraftChange,
  onSubmit
}: WalletAppearancePanelProps) {
  const [submitted, setSubmitted] = useState(false);
  const validationErrors = useMemo(() => getColorValidationErrors(draft), [draft]);
  const hasValidationErrors = Object.keys(validationErrors).length > 0;
  const colorControlsEnabled = canConfigure && !actionPending && draft.colorMode === 'CUSTOM';

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitted(true);

    if (hasValidationErrors || !canConfigure || actionPending || !isDirty) {
      return;
    }

    onSubmit();
  }

  function applyThemePreset(preset: AdminWalletThemePreset) {
    if (!canConfigure || actionPending) {
      return;
    }

    if (preset.key === 'CUSTOM') {
      onDraftChange({
        ...draft,
        themePreset: 'CUSTOM',
        colorMode: 'CUSTOM'
      });
      return;
    }

    onDraftChange({
      ...draft,
      ...preset.recommendedPalette,
      themePreset: preset.key,
      colorMode: 'PRESET'
    });
    setSubmitted(false);
  }

  function setColorMode(colorMode: AdminWalletColorMode) {
    if (!canConfigure || actionPending) {
      return;
    }

    if (colorMode === 'CUSTOM') {
      onDraftChange({
        ...draft,
        colorMode: 'CUSTOM',
        themePreset: 'CUSTOM'
      });
      return;
    }

    const preset = catalog.themePresets.find((item) => item.key === (draft.themePreset === 'CUSTOM' ? 'DEFAULT' : draft.themePreset));

    onDraftChange({
      ...draft,
      ...(preset?.recommendedPalette ?? {}),
      themePreset: preset?.key ?? 'DEFAULT',
      colorMode: 'PRESET'
    });
  }

  function setColor(field: keyof AdminWalletThemePalette, value: string) {
    onDraftChange({
      ...draft,
      [field]: value,
      colorMode: 'CUSTOM',
      themePreset: 'CUSTOM'
    });
  }

  return (
    <WafloPanel
      eyebrow="Wallet and stamp appearance"
      title="Customize wallet card visuals"
      description="These settings shape the loyalty card artwork used for supported wallet platforms and web previews."
      actions={
        <>
          <WafloBadge tone={draft.colorMode === 'CUSTOM' ? 'gold' : 'neutral'}>{draft.colorMode}</WafloBadge>
          {isDirty ? <WafloBadge tone="gold">Unsaved</WafloBadge> : <WafloBadge tone="green">Saved</WafloBadge>}
        </>
      }
    >

      {!canConfigure ? (
        <div className="mb-4"><WafloToast tone="gold">Staff can preview wallet appearance, but only owners and managers can update it.</WafloToast></div>
      ) : null}

      <form className="grid gap-5" onSubmit={submit}>
        <div className="grid gap-5 xl:grid-cols-[minmax(0,1fr)_420px]">
          <div className="grid gap-5">
            <ControlGroup title="Theme preset">
              <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
                {catalog.themePresets.map((preset) => (
                  <button
                    key={preset.key}
                    type="button"
                    className={`rounded-xl border p-3 text-left transition ${
                      draft.themePreset === preset.key
                        ? 'border-waflo-coral bg-waflo-coralSoft ring-2 ring-waflo-coral/20'
                        : 'border-waflo-border bg-white hover:border-waflo-coral/35'
                    } disabled:cursor-not-allowed disabled:opacity-60`}
                    disabled={!canConfigure || actionPending}
                    onClick={() => applyThemePreset(preset)}
                  >
                    <span className="text-sm font-bold text-waflo-charcoal">{preset.label}</span>
                    <span className="mt-3 flex gap-1">
                      {Object.values(preset.recommendedPalette)
                        .slice(0, 5)
                        .map((color, index) => (
                          <span
                            key={`${preset.key}-${color}-${index}`}
                            className="h-5 w-5 rounded-full border border-white shadow-sm ring-1 ring-neutral-200"
                            style={{ backgroundColor: color }}
                          />
                        ))}
                    </span>
                  </button>
                ))}
              </div>
            </ControlGroup>

            <div className="grid gap-5 lg:grid-cols-2">
              <ControlGroup title="Color mode">
                <div className="grid grid-cols-2 gap-2">
                  {catalog.colorModes.map((mode) => (
                    <button
                      key={mode}
                      type="button"
                      className={`rounded-lg border px-3 py-2 text-sm font-bold ${
                        draft.colorMode === mode ? 'border-waflo-coral bg-waflo-coralSoft text-waflo-coralDark' : 'border-waflo-border text-waflo-muted'
                      } disabled:cursor-not-allowed disabled:opacity-60`}
                      disabled={!canConfigure || actionPending}
                      onClick={() => setColorMode(mode)}
                    >
                      {mode}
                    </button>
                  ))}
                </div>
              </ControlGroup>

              <ControlGroup title="Layout">
                <div className="grid grid-cols-2 gap-2">
                  {catalog.layoutVariants.map((variant) => (
                    <button
                      key={variant}
                      type="button"
                      className={`rounded-lg border px-3 py-2 text-sm font-bold ${
                        draft.layoutVariant === variant ? 'border-waflo-coral bg-waflo-coralSoft text-waflo-coralDark' : 'border-waflo-border text-waflo-muted'
                      } disabled:cursor-not-allowed disabled:opacity-60`}
                      disabled={!canConfigure || actionPending}
                      onClick={() => onDraftChange({ ...draft, layoutVariant: variant })}
                    >
                      {variant}
                    </button>
                  ))}
                </div>
              </ControlGroup>
            </div>

            <ControlGroup title="Stamp shape">
              <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
                {catalog.stampPresets.map((preset) => (
                  <StampPresetButton
                    key={preset.key}
                    disabled={!canConfigure || actionPending}
                    draft={draft}
                    preset={preset}
                    selected={draft.presetKey === preset.key}
                    onSelect={() => onDraftChange({ ...draft, presetKey: preset.key })}
                  />
                ))}
              </div>
            </ControlGroup>

            <ControlGroup title="Colors">
              {draft.colorMode !== 'CUSTOM' ? (
                <p className="rounded-lg border border-waflo-border bg-waflo-cream p-3 text-sm font-semibold text-waflo-muted">
                  Select CUSTOM to tune colors manually. Presets apply their recommended palette.
                </p>
              ) : null}
              <div className="grid gap-3 md:grid-cols-2">
                {colorFields.map(([field, label]) => (
                  <ColorField
                    key={field}
                    disabled={!colorControlsEnabled}
                    error={(submitted || !hexColorPattern.test(draft[field])) ? validationErrors[field] : undefined}
                    label={label}
                    value={draft[field]}
                    onChange={(value) => setColor(field, value)}
                  />
                ))}
              </div>
            </ControlGroup>
          </div>

          <WalletAppearancePreview draft={draft} />
        </div>

        <div className="flex flex-col gap-3 border-t border-waflo-border pt-4 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-sm leading-6 text-waflo-muted">
            Existing saved cards are not refreshed automatically after appearance changes.
          </p>
          {canConfigure ? (
            <WafloButton type="submit" disabled={actionPending || hasValidationErrors || !isDirty}>
              {actionPending ? 'Saving appearance...' : 'Save appearance'}
            </WafloButton>
          ) : null}
        </div>
      </form>
    </WafloPanel>
  );
}

function ControlGroup({ children, title }: Readonly<{ children: React.ReactNode; title: string }>) {
  return (
    <fieldset className="grid gap-3">
      <legend className="text-sm font-bold text-waflo-charcoal">{title}</legend>
      {children}
    </fieldset>
  );
}

function ColorField({
  disabled,
  error,
  label,
  value,
  onChange
}: {
  disabled: boolean;
  error?: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
}) {
  const colorPickerValue = hexColorPattern.test(value) ? normalizeHex(value) : '#000000';

  return (
    <label className="grid gap-2 text-sm font-semibold text-neutral-700">
      {label}
      <span className="grid grid-cols-[44px_minmax(0,1fr)] gap-2">
        <input
          aria-label={`${label} swatch`}
          className="h-10 w-11 rounded-md border border-neutral-200 bg-white p-1 disabled:opacity-60"
          disabled={disabled}
          type="color"
          value={colorPickerValue}
          onChange={(event) => onChange(event.target.value)}
        />
        <input
          aria-invalid={Boolean(error)}
          className="min-w-0 rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
          disabled={disabled}
          value={value}
          onChange={(event) => onChange(event.target.value)}
          placeholder="#2563eb"
        />
      </span>
      {error ? <span className="text-xs font-semibold text-rose-700">{error}</span> : null}
    </label>
  );
}

function StampPresetButton({
  disabled,
  draft,
  preset,
  selected,
  onSelect
}: {
  disabled: boolean;
  draft: AdminLoyaltyStampStyleInput;
  preset: AdminLoyaltyStampPreset;
  selected: boolean;
  onSelect: () => void;
}) {
  return (
    <button
      type="button"
      className={`grid gap-2 rounded-lg border p-3 text-center transition ${
        selected ? 'border-accent bg-[#fff8f2] ring-2 ring-[#ffd9c7]' : 'border-neutral-200 bg-white hover:border-neutral-300'
      } disabled:cursor-not-allowed disabled:opacity-60`}
      disabled={disabled}
      onClick={onSelect}
    >
      <span className="mx-auto flex h-12 w-12 items-center justify-center rounded-md" style={{ backgroundColor: hexToRgba(draft.imageSurfaceColor, 0.35) }}>
        <StampIcon fill={draft.stampFilledColor} presetKey={preset.key} stroke={draft.stampFilledColor} />
      </span>
      <span className="text-xs font-bold text-neutral-700">{preset.label}</span>
    </button>
  );
}

function WalletAppearancePreview({ draft }: { draft: AdminLoyaltyStampStyleInput }) {
  const compact = draft.layoutVariant === 'COMPACT';

  return (
    <aside className="grid content-start gap-4">
      <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-4">
        <p className="text-sm font-bold text-ink">Live preview</p>
        <div className="mt-4 overflow-hidden rounded-lg border border-neutral-200 bg-white shadow-sm">
          <div className="p-4 text-white" style={{ backgroundColor: safeHex(draft.walletBackgroundColor, '#2563eb') }}>
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <p className="text-xs font-semibold uppercase opacity-80">Wallet card</p>
                <h3 className="mt-1 truncate text-lg font-bold">Waflo Rewards</h3>
                <p className="mt-1 text-xs font-semibold opacity-85">Member card</p>
              </div>
              <QrPlaceholder />
            </div>
            <p className="mt-4 text-xs font-semibold opacity-80">Scan in store to earn stamps</p>
          </div>

          <div
            className={`relative overflow-hidden p-5 text-white ${compact ? 'min-h-[190px]' : 'min-h-[280px]'}`}
            style={{
              background: `linear-gradient(135deg, ${safeHex(draft.imageBackgroundColor, '#7c2d12')}, ${mixWithBlack(safeHex(draft.imageBackgroundColor, '#7c2d12'), 0.22)})`
            }}
          >
            <div
              className={`absolute rounded-full ${compact ? 'right-5 top-4 h-20 w-20' : 'right-7 top-6 h-28 w-28'}`}
              style={{ backgroundColor: hexToRgba(draft.imageAccentColor, 0.18) }}
            />
            <div className={`absolute text-center ${compact ? 'right-5 top-8 w-20' : 'right-7 top-12 w-28'}`}>
              <p className="text-xs font-bold" style={{ color: hexToRgba(draft.imageTextColor, 0.78) }}>
                stamps
              </p>
              <p className={`${compact ? 'text-2xl' : 'text-4xl'} font-extrabold`} style={{ color: safeHex(draft.imageTextColor, '#ffffff') }}>
                3 / 10
              </p>
            </div>

            <div className="relative pr-24">
              <p className="text-sm font-bold" style={{ color: hexToRgba(draft.imageTextColor, 0.78) }}>
                Sample Cafe
              </p>
              <h3 className={`${compact ? 'text-2xl' : 'text-3xl'} mt-1 font-extrabold`} style={{ color: safeHex(draft.imageTextColor, '#ffffff') }}>
                Stamp Card
              </h3>
            </div>

            <div className={`relative mx-auto mt-8 grid max-w-[310px] gap-2 ${compact ? 'grid-cols-10' : 'grid-cols-5'}`}>
              {Array.from({ length: 10 }, (_, index) => {
                const filled = index < 3;

                return (
                  <span
                    key={index}
                    className="flex aspect-square min-w-0 items-center justify-center rounded-md border"
                    style={{
                      backgroundColor: filled ? hexToRgba(draft.imageSurfaceColor, 0.92) : hexToRgba(draft.imageSurfaceColor, 0.48),
                      borderColor: filled ? hexToRgba(draft.stampFilledColor, 0.52) : hexToRgba(draft.stampEmptyColor, 0.44)
                    }}
                  >
                    <StampIcon
                      fill={filled ? safeHex(draft.stampFilledColor, '#facc15') : 'none'}
                      presetKey={draft.presetKey}
                      stroke={filled ? safeHex(draft.stampFilledColor, '#facc15') : safeHex(draft.stampEmptyColor, '#d6d3d1')}
                    />
                  </span>
                );
              })}
            </div>

            <div
              className="relative mt-7 rounded-full px-4 py-2 text-sm font-bold"
              style={{
                backgroundColor: hexToRgba(draft.rewardBannerColor, 0.86),
                color: safeHex(draft.imageTextColor, '#ffffff')
              }}
            >
              Reward: Free reward after 10 stamps
            </div>
          </div>
        </div>
      </div>
    </aside>
  );
}

function QrPlaceholder() {
  return (
    <div className="grid h-16 w-16 grid-cols-4 grid-rows-4 gap-1 rounded-md bg-white/95 p-2">
      {Array.from({ length: 16 }, (_, index) => (
        <span key={index} className={index % 3 === 0 || index === 5 || index === 10 ? 'rounded-sm bg-neutral-900' : 'rounded-sm bg-neutral-200'} />
      ))}
    </div>
  );
}

function StampIcon({ fill, presetKey, stroke }: { fill: string; presetKey: AdminStampPresetKey; stroke: string }) {
  const filled = fill !== 'none';
  const common = {
    fill,
    stroke,
    strokeLinecap: 'round' as const,
    strokeLinejoin: 'round' as const,
    strokeWidth: 8
  };

  switch (presetKey) {
    case 'STAR':
      return (
        <svg aria-hidden="true" className="h-7 w-7" viewBox="0 0 100 100">
          <polygon {...common} points="50,8 61,36 91,37 67,56 76,86 50,69 24,86 33,56 9,37 39,36" />
        </svg>
      );
    case 'COOKIE':
      return (
        <svg aria-hidden="true" className="h-7 w-7" viewBox="0 0 100 100">
          <circle {...common} cx="50" cy="50" r="34" />
          {filled ? (
            <>
              <circle cx="38" cy="38" r="4" fill="#6b3f16" stroke="none" />
              <circle cx="58" cy="48" r="4" fill="#6b3f16" stroke="none" />
              <circle cx="46" cy="63" r="4" fill="#6b3f16" stroke="none" />
            </>
          ) : null}
        </svg>
      );
    case 'COFFEE':
      return (
        <svg aria-hidden="true" className="h-7 w-7" viewBox="0 0 100 100">
          <path {...common} d="M25 35h40v32H25z" />
          <path {...common} d="M65 42c20-2 20 24 0 22" fill="none" />
          <path {...common} d="M35 22c0-8 10-8 10-16" fill="none" strokeWidth="6" />
        </svg>
      );
    case 'BOWL':
      return (
        <svg aria-hidden="true" className="h-7 w-7" viewBox="0 0 100 100">
          <path {...common} d="M16 42h68c-8 27-20 38-34 38S24 69 16 42z" />
          <path {...common} d="M28 30c14-11 30-11 44 0" fill="none" strokeWidth="7" />
        </svg>
      );
    case 'BURGER':
      return (
        <svg aria-hidden="true" className="h-7 w-7" viewBox="0 0 100 100">
          <path {...common} d="M20 42c8-23 52-23 60 0z" />
          <path {...common} d="M20 56h60M24 70h52M30 82h40" fill="none" />
        </svg>
      );
    case 'PIZZA':
      return (
        <svg aria-hidden="true" className="h-7 w-7" viewBox="0 0 100 100">
          <path {...common} d="M50 12 84 82H16z" />
          {filled ? (
            <>
              <circle cx="45" cy="48" r="4" fill="#dc2626" stroke="none" />
              <circle cx="58" cy="64" r="4" fill="#dc2626" stroke="none" />
            </>
          ) : null}
        </svg>
      );
    case 'HEART':
      return (
        <svg aria-hidden="true" className="h-7 w-7" viewBox="0 0 100 100">
          <path {...common} d="M50 82C-2 43 25 7 50 31 75 7 102 43 50 82z" />
        </svg>
      );
    case 'CUPCAKE':
      return (
        <svg aria-hidden="true" className="h-7 w-7" viewBox="0 0 100 100">
          <path {...common} d="M24 43c0-25 52-25 52 0" />
          <path {...common} d="M26 50h48l-8 34H34z" />
        </svg>
      );
  }
}

function getColorValidationErrors(draft: AdminLoyaltyStampStyleInput) {
  const errors: Partial<Record<keyof AdminWalletThemePalette, string>> = {};

  for (const [field, label] of colorFields) {
    if (!hexColorPattern.test(draft[field])) {
      errors[field] = `${label} must be a valid hex color.`;
    }
  }

  return errors;
}

function safeHex(value: string, fallback: string) {
  return hexColorPattern.test(value) ? normalizeHex(value) : fallback;
}

function normalizeHex(value: string) {
  if (value.length !== 4) {
    return value;
  }

  return `#${value[1]}${value[1]}${value[2]}${value[2]}${value[3]}${value[3]}`;
}

function hexToRgba(value: string, alpha: number) {
  const hex = safeHex(value, '#111827');
  const [r, g, b] = hexToRgb(hex);

  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function mixWithBlack(value: string, amount: number) {
  const [r, g, b] = hexToRgb(value);

  return `#${[r, g, b]
    .map((channel) => Math.round(channel * (1 - amount)).toString(16).padStart(2, '0'))
    .join('')}`;
}

function hexToRgb(value: string): [number, number, number] {
  const hex = normalizeHex(safeHex(value, '#111827'));

  return [
    Number.parseInt(hex.slice(1, 3), 16),
    Number.parseInt(hex.slice(3, 5), 16),
    Number.parseInt(hex.slice(5, 7), 16)
  ];
}

'use client';

import { FormEvent, useCallback, useEffect, useMemo, useState } from 'react';
import { useAuth } from '@clerk/nextjs';
import {
  addLoyaltyStamps,
  createLoyaltyProgram,
  enrollLoyaltyCustomer,
  fetchAdminMe,
  getActiveLoyaltyProgram,
  getDashboardSummary,
  getLoyaltyMembership,
  getLoyaltyStampPresets,
  getLoyaltyStampStyle,
  listLoyaltyMemberships,
  listLoyaltyTransactions,
  redeemLoyaltyReward,
  updateLoyaltyProgram,
  updateLoyaltyStampStyle,
  type AdminApiResult,
  type AdminDashboardSummary,
  type AdminLoyaltyCardState,
  type AdminLoyaltyMembership,
  type AdminLoyaltyProgram,
  type AdminLoyaltyProgramInput,
  type AdminLoyaltyStampPresetCatalog,
  type AdminLoyaltyStampStyle,
  type AdminLoyaltyStampStyleInput,
  type AdminLoyaltyTransaction,
  type AdminMeResponse
} from '../lib/admin-api';
import { WalletAppearancePanel } from './WalletAppearancePanel';

type LoyaltyPanelProps = {
  apiBaseUrl: string;
};

type LoyaltyState =
  | {
      status: 'idle' | 'loading';
    }
  | {
      status: 'missing-business';
      message: string;
    }
  | {
      status: 'auth-error' | 'forbidden' | 'validation-error' | 'error';
      apiUrl?: string;
      message: string;
    }
  | {
      status: 'ok';
      me: AdminMeResponse;
      businessId: string;
      summary: AdminDashboardSummary;
      program: AdminLoyaltyProgram | null;
      stampPresetCatalog: AdminLoyaltyStampPresetCatalog;
      stampStyle: AdminLoyaltyStampStyle | null;
      memberships: AdminLoyaltyMembership[];
      selectedMembership: AdminLoyaltyMembership | null;
      transactions: AdminLoyaltyTransaction[];
    };

type ActionState =
  | {
      status: 'idle';
    }
  | {
      status: 'pending';
      message: string;
    }
  | {
      status: 'success' | 'error';
      message: string;
    };

type MembershipFilters = {
  search: string;
  status: 'ACTIVE' | 'INACTIVE' | '';
  rewardReady: 'all' | 'ready' | 'not-ready';
};

const emptyProgramDraft: AdminLoyaltyProgramInput = {
  name: '',
  description: '',
  stampGoal: 5,
  rewardName: '',
  rewardDescription: '',
  cardColor: '',
  accentColor: '',
  logoUrl: '',
  terms: '',
  isActive: true
};

const stampStyleColorFields = [
  'walletBackgroundColor',
  'imageBackgroundColor',
  'imageSurfaceColor',
  'imageAccentColor',
  'imageTextColor',
  'stampFilledColor',
  'stampEmptyColor',
  'rewardBannerColor'
] as const satisfies ReadonlyArray<keyof AdminLoyaltyStampStyleInput>;
const hexColorPattern = /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/;

function pickCurrentBusinessId(me: AdminMeResponse) {
  const activeMembership = me.memberships.find((membership) => membership.isActive && membership.business.id);
  const firstMembership = me.memberships.find((membership) => membership.business.id);

  return activeMembership?.business.id || firstMembership?.business.id || me.businesses[0]?.id || null;
}

function canConfigureProgram(summary: AdminDashboardSummary) {
  const role = summary.currentUser.role.toUpperCase();
  return role === 'OWNER' || role === 'MANAGER';
}

function canOperateLoyalty(summary: AdminDashboardSummary) {
  const role = summary.currentUser.role.toUpperCase();
  return role === 'OWNER' || role === 'MANAGER' || role === 'STAFF';
}

function rewardReadyQuery(value: MembershipFilters['rewardReady']) {
  if (value === 'ready') {
    return true;
  }

  if (value === 'not-ready') {
    return false;
  }

  return null;
}

function programToDraft(program: AdminLoyaltyProgram | null): AdminLoyaltyProgramInput {
  if (!program) {
    return emptyProgramDraft;
  }

  return {
    name: program.name,
    description: program.description || '',
    stampGoal: program.stampGoal || 5,
    rewardName: program.rewardName,
    rewardDescription: program.rewardDescription || '',
    cardColor: program.cardColor || '',
    accentColor: program.accentColor || '',
    logoUrl: program.logoUrl || '',
    terms: program.terms || '',
    isActive: program.isActive
  };
}

function stampStyleToDraft(style: AdminLoyaltyStampStyle): AdminLoyaltyStampStyleInput {
  return {
    themePreset: style.themePreset,
    colorMode: style.colorMode,
    presetKey: style.presetKey,
    walletBackgroundColor: style.walletBackgroundColor,
    imageBackgroundColor: style.imageBackgroundColor,
    imageSurfaceColor: style.imageSurfaceColor,
    imageAccentColor: style.imageAccentColor,
    imageTextColor: style.imageTextColor,
    stampFilledColor: style.stampFilledColor,
    stampEmptyColor: style.stampEmptyColor,
    rewardBannerColor: style.rewardBannerColor,
    layoutVariant: style.layoutVariant
  };
}

function stampStyleDraftKey(draft: AdminLoyaltyStampStyleInput | null) {
  return draft ? JSON.stringify(draft) : '';
}

function hasInvalidStampStyleColors(draft: AdminLoyaltyStampStyleInput) {
  return stampStyleColorFields.some((field) => !hexColorPattern.test(draft[field]));
}

function displayCustomer(membership: AdminLoyaltyMembership) {
  const customer = membership.customer;

  return customer?.name || customer?.phone || customer?.email || 'Loyalty customer';
}

function contactLine(membership: AdminLoyaltyMembership) {
  const customer = membership.customer;
  const parts = [customer?.phone, customer?.email].filter((value): value is string => Boolean(value?.trim()));

  return parts.length ? parts.join(' / ') : 'No phone or email returned';
}

function effectiveCardState(membership: AdminLoyaltyMembership): AdminLoyaltyCardState {
  if (membership.cardState) {
    return membership.cardState;
  }

  const stampGoal = membership.program?.stampGoal || 0;
  const progressPercent = stampGoal > 0 ? Math.min(Math.round((membership.stampCount / stampGoal) * 100), 100) : 0;

  return {
    stampCount: membership.stampCount,
    stampGoal,
    rewardReady: membership.rewardReady,
    progressPercent,
    rewardName: membership.program?.rewardName || 'Reward',
    programName: membership.program?.name || 'Loyalty program'
  };
}

function transactionLabel(type: string) {
  switch (type.toUpperCase()) {
    case 'STAMP_ADDED':
      return 'Stamp added';
    case 'REWARD_REDEEMED':
      return 'Reward redeemed';
    case 'ADJUSTMENT':
      return 'Adjustment';
    case 'VOID':
      return 'Void';
    default:
      return type.trim() ? type.replaceAll('_', ' ') : 'Unknown transaction';
  }
}

function formatDate(value: string | null) {
  if (!value) {
    return 'No timestamp';
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat('en', {
    dateStyle: 'medium',
    timeStyle: 'short'
  }).format(date);
}

function StatusPill({
  children,
  tone = 'neutral'
}: Readonly<{
  children: React.ReactNode;
  tone?: 'neutral' | 'success' | 'warning' | 'danger';
}>) {
  const toneClass =
    tone === 'success'
      ? 'bg-emerald-50 text-emerald-700 ring-emerald-200'
      : tone === 'warning'
        ? 'bg-amber-50 text-amber-800 ring-amber-200'
        : tone === 'danger'
          ? 'bg-rose-50 text-rose-700 ring-rose-200'
          : 'bg-neutral-100 text-neutral-700 ring-neutral-200';

  return <span className={`inline-flex rounded-full px-2 py-1 text-xs font-semibold ring-1 ${toneClass}`}>{children}</span>;
}

function ActionBanner({ actionState }: { actionState: ActionState }) {
  if (actionState.status === 'idle') {
    return null;
  }

  const toneClass =
    actionState.status === 'success'
      ? 'border-emerald-200 bg-emerald-50 text-emerald-800'
      : actionState.status === 'error'
        ? 'border-rose-200 bg-rose-50 text-rose-800'
        : 'border-amber-200 bg-amber-50 text-amber-900';

  const message =
    actionState.status === 'error'
      ? 'That loyalty change could not be saved. Please try again or check your permission for this business.'
      : actionState.message;

  return <p className={`rounded-lg border p-3 text-sm font-semibold ${toneClass}`}>{message}</p>;
}

function BlockingState({ state }: { state: Exclude<LoyaltyState, { status: 'ok' }> }) {
  const titleByStatus = {
    'auth-error': 'Sign-in required',
    forbidden: 'Permission denied',
    'validation-error': 'Loyalty information needs attention',
    error: 'Loyalty unavailable'
  };

  switch (state.status) {
    case 'idle':
    case 'loading':
      return (
        <section className="rounded-lg border border-neutral-200 bg-white p-5">
          <p className="text-sm font-semibold uppercase text-accent">Loyalty</p>
          <h2 className="mt-2 text-xl font-bold text-ink">Loading loyalty workspace</h2>
          <p className="mt-2 text-sm leading-6 text-neutral-600">
            Checking your business, loyalty program, and customer memberships.
          </p>
        </section>
      );
    case 'missing-business':
      return (
        <section className="rounded-lg border border-amber-200 bg-amber-50 p-5">
          <p className="text-sm font-semibold uppercase text-amber-700">Missing business context</p>
          <h2 className="mt-2 text-xl font-bold text-ink">No business is available for this account</h2>
          <p className="mt-2 text-sm leading-6 text-amber-900">
            Create or choose a business before managing loyalty.
          </p>
        </section>
      );
    default:
      return (
        <section className="rounded-lg border border-rose-200 bg-rose-50 p-5">
          <p className="text-sm font-semibold uppercase text-rose-700">{titleByStatus[state.status]}</p>
          <h2 className="mt-2 text-xl font-bold text-ink">Could not load loyalty</h2>
          <p className="mt-2 text-sm leading-6 text-rose-900">
            Please refresh the page, sign in again, or ask an owner to confirm your access.
          </p>
        </section>
      );
  }
}

function ProgramPanel({
  program,
  draft,
  canConfigure,
  actionPending,
  onDraftChange,
  onSubmit
}: {
  program: AdminLoyaltyProgram | null;
  draft: AdminLoyaltyProgramInput;
  canConfigure: boolean;
  actionPending: boolean;
  onDraftChange: (draft: AdminLoyaltyProgramInput) => void;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
}) {
  return (
    <section className="rounded-lg border border-neutral-200 bg-white">
      <div className="border-b border-neutral-200 p-4">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase text-accent">Loyalty program</p>
            <h2 className="mt-2 text-xl font-bold text-ink">{program ? program.name : 'No active stamp card yet'}</h2>
            <p className="mt-2 max-w-3xl text-sm leading-6 text-neutral-600">
              Configure one active stamp-card program for owner and staff daily operations.
            </p>
          </div>
          {program ? (
            <StatusPill tone={program.isActive ? 'success' : 'warning'}>{program.isActive ? 'Active' : 'Inactive'}</StatusPill>
          ) : (
            <StatusPill tone="warning">Setup needed</StatusPill>
          )}
        </div>
      </div>

      {!canConfigure ? (
        <div className="border-b border-amber-200 bg-amber-50 p-4 text-sm font-semibold text-amber-900">
          STAFF can view the loyalty program, but only OWNER and MANAGER can create or update it.
        </div>
      ) : null}

      {!program && !canConfigure ? (
        <div className="p-4">
          <p className="text-sm leading-6 text-neutral-600">No active loyalty program exists yet. Ask an owner or manager to set up a stamp card.</p>
        </div>
      ) : null}

      {(program || canConfigure) && (
        <form className="grid gap-4 p-4" onSubmit={onSubmit}>
          <div className="grid gap-4 lg:grid-cols-3">
            <label className="grid gap-2 text-sm font-semibold text-neutral-700">
              Program name
              <input
                className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
                disabled={!canConfigure || actionPending}
                value={draft.name}
                onChange={(event) => onDraftChange({ ...draft, name: event.target.value })}
                placeholder="Tavrix Cafe Stamp Card"
              />
            </label>
            <label className="grid gap-2 text-sm font-semibold text-neutral-700">
              Stamp goal
              <input
                className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
                disabled={!canConfigure || actionPending}
                min={1}
                max={50}
                type="number"
                value={draft.stampGoal}
                onChange={(event) => onDraftChange({ ...draft, stampGoal: Number(event.target.value) })}
              />
            </label>
            <label className="grid gap-2 text-sm font-semibold text-neutral-700">
              Reward name
              <input
                className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
                disabled={!canConfigure || actionPending}
                value={draft.rewardName}
                onChange={(event) => onDraftChange({ ...draft, rewardName: event.target.value })}
                placeholder="Free coffee"
              />
            </label>
          </div>

          <div className="grid gap-4 lg:grid-cols-2">
            <label className="grid gap-2 text-sm font-semibold text-neutral-700">
              Description
              <textarea
                className="min-h-24 rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
                disabled={!canConfigure || actionPending}
                value={draft.description || ''}
                onChange={(event) => onDraftChange({ ...draft, description: event.target.value })}
              />
            </label>
            <label className="grid gap-2 text-sm font-semibold text-neutral-700">
              Reward description
              <textarea
                className="min-h-24 rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
                disabled={!canConfigure || actionPending}
                value={draft.rewardDescription || ''}
                onChange={(event) => onDraftChange({ ...draft, rewardDescription: event.target.value })}
              />
            </label>
          </div>

          <div className="grid gap-4 lg:grid-cols-4">
            <label className="grid gap-2 text-sm font-semibold text-neutral-700">
              Card color
              <input
                className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
                disabled={!canConfigure || actionPending}
                value={draft.cardColor || ''}
                onChange={(event) => onDraftChange({ ...draft, cardColor: event.target.value })}
                placeholder="#111827"
              />
            </label>
            <label className="grid gap-2 text-sm font-semibold text-neutral-700">
              Accent color
              <input
                className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
                disabled={!canConfigure || actionPending}
                value={draft.accentColor || ''}
                onChange={(event) => onDraftChange({ ...draft, accentColor: event.target.value })}
                placeholder="#f59e0b"
              />
            </label>
            <label className="grid gap-2 text-sm font-semibold text-neutral-700 lg:col-span-2">
              Logo URL
              <input
                className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
                disabled={!canConfigure || actionPending}
                value={draft.logoUrl || ''}
                onChange={(event) => onDraftChange({ ...draft, logoUrl: event.target.value })}
                placeholder="https://example.com/logo.png"
              />
            </label>
          </div>

          <label className="grid gap-2 text-sm font-semibold text-neutral-700">
            Terms
            <textarea
              className="min-h-20 rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
              disabled={!canConfigure || actionPending}
              value={draft.terms || ''}
              onChange={(event) => onDraftChange({ ...draft, terms: event.target.value })}
            />
          </label>

          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <label className="inline-flex items-center gap-2 text-sm font-semibold text-neutral-700">
              <input
                checked={draft.isActive}
                disabled={!canConfigure || actionPending}
                type="checkbox"
                onChange={(event) => onDraftChange({ ...draft, isActive: event.target.checked })}
              />
              Active program
            </label>
            {canConfigure ? (
              <button
                type="submit"
                className="rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:bg-neutral-300"
                disabled={actionPending}
              >
                {program ? 'Update program' : 'Create program'}
              </button>
            ) : null}
          </div>
        </form>
      )}
    </section>
  );
}

function EnrollmentPanel({
  disabled,
  actionPending,
  onSubmit
}: {
  disabled: boolean;
  actionPending: boolean;
  onSubmit: (input: { phone: string; email: string; name: string }) => void;
}) {
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [validation, setValidation] = useState<string | null>(null);

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setValidation(null);

    if (!phone.trim() && !email.trim()) {
      setValidation('Enter a phone number or email before enrolling.');
      return;
    }

    onSubmit({ phone, email, name });
    setPhone('');
    setEmail('');
    setName('');
  }

  return (
    <section className="rounded-lg border border-neutral-200 bg-white p-4">
      <p className="text-sm font-semibold uppercase text-accent">Customer enrollment</p>
      <h2 className="mt-2 text-xl font-bold text-ink">Enroll or find existing membership</h2>
      <p className="mt-2 text-sm leading-6 text-neutral-600">Phone or email is required. Existing memberships are returned gracefully.</p>

      <form className="mt-4 grid gap-4" onSubmit={submit}>
        <div className="grid gap-4 lg:grid-cols-3">
          <label className="grid gap-2 text-sm font-semibold text-neutral-700">
            Phone
            <input
              className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
              disabled={disabled || actionPending}
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              placeholder="+9647700000000"
            />
          </label>
          <label className="grid gap-2 text-sm font-semibold text-neutral-700">
            Email
            <input
              className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
              disabled={disabled || actionPending}
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              placeholder="customer@example.com"
            />
          </label>
          <label className="grid gap-2 text-sm font-semibold text-neutral-700">
            Name
            <input
              className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink disabled:bg-neutral-50"
              disabled={disabled || actionPending}
              value={name}
              onChange={(event) => setName(event.target.value)}
              placeholder="Demo Customer"
            />
          </label>
        </div>
        {validation ? <p className="rounded-md border border-rose-200 bg-rose-50 p-3 text-sm font-semibold text-rose-800">{validation}</p> : null}
        <button
          type="submit"
          className="w-fit rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:bg-neutral-300"
          disabled={disabled || actionPending}
        >
          Enroll customer
        </button>
      </form>
    </section>
  );
}

function MembershipListPanel({
  memberships,
  filters,
  selectedMembershipId,
  actionPending,
  onFiltersChange,
  onSearch,
  onSelect
}: {
  memberships: AdminLoyaltyMembership[];
  filters: MembershipFilters;
  selectedMembershipId: string | null;
  actionPending: boolean;
  onFiltersChange: (filters: MembershipFilters) => void;
  onSearch: () => void;
  onSelect: (membershipId: string) => void;
}) {
  return (
    <section className="rounded-lg border border-neutral-200 bg-white">
      <div className="border-b border-neutral-200 p-4">
        <p className="text-sm font-semibold uppercase text-accent">Memberships</p>
        <h2 className="mt-2 text-xl font-bold text-ink">Search stamp-card members</h2>
        <div className="mt-4 grid gap-3 lg:grid-cols-[1fr_auto_auto_auto]">
          <input
            className="rounded-md border border-neutral-200 px-3 py-2 text-sm text-ink"
            value={filters.search}
            onChange={(event) => onFiltersChange({ ...filters, search: event.target.value })}
            placeholder="Search phone, email, or name"
          />
          <select
            className="rounded-md border border-neutral-200 px-3 py-2 text-sm text-ink"
            value={filters.status}
            onChange={(event) => onFiltersChange({ ...filters, status: event.target.value as MembershipFilters['status'] })}
          >
            <option value="">Any status</option>
            <option value="ACTIVE">ACTIVE</option>
            <option value="INACTIVE">INACTIVE</option>
          </select>
          <select
            className="rounded-md border border-neutral-200 px-3 py-2 text-sm text-ink"
            value={filters.rewardReady}
            onChange={(event) => onFiltersChange({ ...filters, rewardReady: event.target.value as MembershipFilters['rewardReady'] })}
          >
            <option value="all">Any reward state</option>
            <option value="ready">Reward ready</option>
            <option value="not-ready">Not ready</option>
          </select>
          <button
            type="button"
            className="rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:bg-neutral-300"
            disabled={actionPending}
            onClick={onSearch}
          >
            Search
          </button>
        </div>
      </div>

      {memberships.length === 0 ? (
        <div className="p-4">
          <p className="text-sm font-semibold text-neutral-700">No memberships found.</p>
          <p className="mt-1 text-sm text-neutral-600">Enroll a customer or try a different search.</p>
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full min-w-[960px] text-left text-sm">
            <thead className="bg-neutral-50 text-neutral-500">
              <tr>
                <th className="px-4 py-3">Customer</th>
                <th className="px-4 py-3">Phone</th>
                <th className="px-4 py-3">Email</th>
                <th className="px-4 py-3">Progress</th>
                <th className="px-4 py-3">Reward</th>
                <th className="px-4 py-3">Totals</th>
              </tr>
            </thead>
            <tbody>
              {memberships.map((membership) => {
                const cardState = effectiveCardState(membership);
                const selected = membership.id === selectedMembershipId;

                return (
                  <tr
                    key={membership.id}
                    className={`cursor-pointer border-t border-neutral-100 ${selected ? 'bg-emerald-50' : 'bg-white hover:bg-neutral-50'}`}
                    onClick={() => onSelect(membership.id)}
                  >
                    <td className="px-4 py-3 font-semibold text-ink">{displayCustomer(membership)}</td>
                    <td className="px-4 py-3 text-neutral-600">{membership.customer?.phone || '-'}</td>
                    <td className="px-4 py-3 text-neutral-600">{membership.customer?.email || '-'}</td>
                    <td className="px-4 py-3 text-neutral-600">
                      {cardState.stampCount}/{cardState.stampGoal} ({cardState.progressPercent}%)
                    </td>
                    <td className="px-4 py-3">
                      <StatusPill tone={cardState.rewardReady ? 'warning' : 'neutral'}>
                        {cardState.rewardReady ? 'Ready' : 'Not ready'}
                      </StatusPill>
                    </td>
                    <td className="px-4 py-3 text-neutral-600">
                      Earned {membership.totalStampsEarned ?? '-'} / Redeemed {membership.totalRewardsRedeemed ?? '-'}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}

function MembershipDetailPanel({
  membership,
  transactions,
  actionPending,
  canOperate,
  onAddStamps,
  onRedeem
}: {
  membership: AdminLoyaltyMembership | null;
  transactions: AdminLoyaltyTransaction[];
  actionPending: boolean;
  canOperate: boolean;
  onAddStamps: (count: number, reason: string) => void;
  onRedeem: (reason: string) => void;
}) {
  const [stampCount, setStampCount] = useState(1);
  const [stampReason, setStampReason] = useState('');
  const [redeemReason, setRedeemReason] = useState('');
  const [validation, setValidation] = useState<string | null>(null);

  if (!membership) {
    return (
      <section className="rounded-lg border border-neutral-200 bg-white p-5">
        <p className="text-sm font-semibold uppercase text-accent">Membership detail</p>
        <h2 className="mt-2 text-xl font-bold text-ink">Select a membership</h2>
        <p className="mt-2 text-sm leading-6 text-neutral-600">Choose a loyalty member to view card state, add stamps, redeem rewards, and inspect transactions.</p>
      </section>
    );
  }

  const selectedMembership = membership;
  const cardState = effectiveCardState(membership);

  function submitStamps(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setValidation(null);

    if (!canOperate) {
      setValidation('This role cannot add loyalty stamps.');
      return;
    }

    if (stampCount < 1 || stampCount > 10) {
      setValidation('Stamp count must be between 1 and 10.');
      return;
    }

    onAddStamps(stampCount, stampReason);
    setStampCount(1);
    setStampReason('');
  }

  function submitRedeem(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!canOperate) {
      return;
    }

    if (!window.confirm(`Redeem ${cardState.rewardName} for ${displayCustomer(selectedMembership)}?`)) {
      return;
    }

    onRedeem(redeemReason);
    setRedeemReason('');
  }

  return (
    <section className="grid gap-4">
      <article className="rounded-lg border border-neutral-200 bg-white p-5">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase text-accent">Membership detail</p>
            <h2 className="mt-2 text-xl font-bold text-ink">{displayCustomer(membership)}</h2>
            <p className="mt-1 text-sm text-neutral-600">{contactLine(membership)}</p>
          </div>
          <StatusPill tone={cardState.rewardReady ? 'warning' : 'success'}>{cardState.rewardReady ? 'Reward ready' : membership.status}</StatusPill>
        </div>

        <div className="mt-5 grid gap-4 lg:grid-cols-4">
          <Metric label="Program" value={cardState.programName} />
          <Metric label="Reward" value={cardState.rewardName} />
          <Metric label="Stamps" value={`${cardState.stampCount}/${cardState.stampGoal}`} />
          <Metric label="Progress" value={`${cardState.progressPercent}%`} />
        </div>
        <div className="mt-5 h-3 overflow-hidden rounded-full bg-neutral-100">
          <div className="h-full rounded-full bg-accent" style={{ width: `${Math.max(0, Math.min(cardState.progressPercent, 100))}%` }} />
        </div>
        {cardState.rewardReady ? (
          <p className="mt-4 rounded-lg border border-amber-200 bg-amber-50 p-3 text-sm font-semibold text-amber-900">
            Reward ready: {cardState.rewardName}. Confirm before redeeming.
          </p>
        ) : null}
      </article>

      <div className="grid gap-4 lg:grid-cols-2">
        <article className="rounded-lg border border-neutral-200 bg-white p-4">
          <p className="text-sm font-semibold uppercase text-accent">Add stamps</p>
          {canOperate ? (
            <form className="mt-4 grid gap-3" onSubmit={submitStamps}>
              <label className="grid gap-2 text-sm font-semibold text-neutral-700">
                Count
                <input
                  className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink"
                  disabled={actionPending}
                  max={10}
                  min={1}
                  type="number"
                  value={stampCount}
                  onChange={(event) => setStampCount(Number(event.target.value))}
                />
              </label>
              <label className="grid gap-2 text-sm font-semibold text-neutral-700">
                Reason
                <input
                  className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink"
                  disabled={actionPending}
                  value={stampReason}
                  onChange={(event) => setStampReason(event.target.value)}
                  placeholder="Coffee purchase"
                />
              </label>
              {validation ? <p className="rounded-md border border-rose-200 bg-rose-50 p-3 text-sm font-semibold text-rose-800">{validation}</p> : null}
              <button
                type="submit"
                className="w-fit rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:bg-neutral-300"
                disabled={actionPending}
              >
                Add stamps
              </button>
            </form>
          ) : (
            <p className="mt-4 rounded-md border border-amber-200 bg-amber-50 p-3 text-sm font-semibold text-amber-900">
              This role can view loyalty activity, but cannot add stamps.
            </p>
          )}
        </article>

        <article className="rounded-lg border border-neutral-200 bg-white p-4">
          <p className="text-sm font-semibold uppercase text-accent">Redeem reward</p>
          {!canOperate ? (
            <p className="mt-4 rounded-md border border-amber-200 bg-amber-50 p-3 text-sm font-semibold text-amber-900">
              This role can view loyalty activity, but cannot redeem rewards.
            </p>
          ) : cardState.rewardReady ? (
            <form className="mt-4 grid gap-3" onSubmit={submitRedeem}>
              <label className="grid gap-2 text-sm font-semibold text-neutral-700">
                Reason
                <input
                  className="rounded-md border border-neutral-200 px-3 py-2 text-sm font-normal text-ink"
                  disabled={actionPending}
                  value={redeemReason}
                  onChange={(event) => setRedeemReason(event.target.value)}
                  placeholder="Reward redeemed"
                />
              </label>
              <button
                type="submit"
                className="w-fit rounded-md bg-rose-600 px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:bg-neutral-300"
                disabled={actionPending}
              >
                Redeem reward
              </button>
            </form>
          ) : (
            <p className="mt-4 text-sm leading-6 text-neutral-600">Redeem appears when rewardReady=true.</p>
          )}
        </article>
      </div>

      <TransactionsPanel transactions={transactions} />
    </section>
  );
}

function Metric({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="rounded-lg bg-neutral-50 p-3">
      <p className="text-xs font-semibold uppercase text-neutral-500">{label}</p>
      <p className="mt-2 text-sm font-bold text-ink">{value}</p>
    </div>
  );
}

function TransactionsPanel({ transactions }: { transactions: AdminLoyaltyTransaction[] }) {
  return (
    <article className="rounded-lg border border-neutral-200 bg-white">
      <div className="border-b border-neutral-200 p-4">
        <p className="text-sm font-semibold uppercase text-accent">Transactions</p>
        <h2 className="mt-2 text-xl font-bold text-ink">Recent loyalty activity</h2>
      </div>
      {transactions.length === 0 ? (
        <div className="p-4">
          <p className="text-sm font-semibold text-neutral-700">No transactions yet.</p>
        </div>
      ) : (
        <div className="divide-y divide-neutral-100">
          {transactions.map((transaction) => (
            <div key={transaction.id} className="grid gap-3 p-4 lg:grid-cols-[1fr_auto] lg:items-start">
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <p className="font-semibold text-ink">{transactionLabel(transaction.type)}</p>
                  <StatusPill tone={transaction.stampsDelta > 0 ? 'success' : transaction.stampsDelta < 0 ? 'warning' : 'neutral'}>
                    {transaction.stampsDelta > 0 ? '+' : ''}
                    {transaction.stampsDelta} stamps
                  </StatusPill>
                </div>
                <p className="mt-1 text-sm text-neutral-600">{transaction.reason || 'No reason provided'}</p>
              </div>
              <p className="text-sm font-semibold text-neutral-500">{formatDate(transaction.createdAt)}</p>
            </div>
          ))}
        </div>
      )}
    </article>
  );
}

export function LoyaltyPanel({ apiBaseUrl }: LoyaltyPanelProps) {
  const { getToken, isLoaded, isSignedIn } = useAuth();
  const [state, setState] = useState<LoyaltyState>({ status: 'idle' });
  const [actionState, setActionState] = useState<ActionState>({ status: 'idle' });
  const [filters, setFilters] = useState<MembershipFilters>({
    search: '',
    status: '',
    rewardReady: 'all'
  });
  const [programDraft, setProgramDraft] = useState<AdminLoyaltyProgramInput>(emptyProgramDraft);
  const [stampStyleDraft, setStampStyleDraft] = useState<AdminLoyaltyStampStyleInput | null>(null);

  const actionPending = actionState.status === 'pending';

  const loadLoyalty = useCallback(
    async (signal?: AbortSignal) => {
      if (!isLoaded || !isSignedIn) {
        return;
      }

      setState({ status: 'loading' });
      setActionState({ status: 'idle' });

      try {
        const token = await getToken();
        const meResult = await fetchAdminMe({
          apiBaseUrl,
          token,
          signal
        });

        if (signal?.aborted) {
          return;
        }

        if (meResult.status !== 'ok') {
          setState({
            status: meResult.status,
            apiUrl: meResult.apiUrl,
            message: meResult.message
          });
          return;
        }

        const businessId = pickCurrentBusinessId(meResult.data);

        if (!businessId) {
          setState({
            status: 'missing-business',
            message: 'No active business is available for this account.'
          });
          return;
        }

        const [summaryResult, programResult, stampPresetsResult] = await Promise.all([
          getDashboardSummary({
            apiBaseUrl,
            token,
            businessId,
            signal
          }),
          getActiveLoyaltyProgram({
            apiBaseUrl,
            token,
            businessId,
            signal
          }),
          getLoyaltyStampPresets({
            apiBaseUrl,
            token,
            signal
          })
        ]);

        if (signal?.aborted) {
          return;
        }

        if (summaryResult.status !== 'ok') {
          setState({
            status: summaryResult.status,
            apiUrl: summaryResult.apiUrl,
            message: summaryResult.message
          });
          return;
        }

        if (programResult.status !== 'ok') {
          setState({
            status: programResult.status,
            apiUrl: programResult.apiUrl,
            message: programResult.message
          });
          return;
        }

        if (stampPresetsResult.status !== 'ok') {
          setState({
            status: stampPresetsResult.status,
            apiUrl: stampPresetsResult.apiUrl,
            message: stampPresetsResult.message
          });
          return;
        }

        const [stampStyleResult, membershipsResult] = programResult.data
          ? await Promise.all([
              getLoyaltyStampStyle({
                apiBaseUrl,
                token,
                businessId,
                signal
              }),
              listLoyaltyMemberships({
                apiBaseUrl,
                token,
                businessId,
                signal
              })
            ])
          : [null, null];

        if (signal?.aborted) {
          return;
        }

        if (stampStyleResult && stampStyleResult.status !== 'ok') {
          setState({
            status: stampStyleResult.status,
            apiUrl: stampStyleResult.apiUrl,
            message: stampStyleResult.message
          });
          return;
        }

        if (membershipsResult && membershipsResult.status !== 'ok') {
          setState({
            status: membershipsResult.status,
            apiUrl: membershipsResult.apiUrl,
            message: membershipsResult.message
          });
          return;
        }

        setProgramDraft(programToDraft(programResult.data));
        setStampStyleDraft(stampStyleResult?.data ? stampStyleToDraft(stampStyleResult.data) : null);
        setState({
          status: 'ok',
          me: meResult.data,
          businessId,
          summary: summaryResult.data,
          program: programResult.data,
          stampPresetCatalog: stampPresetsResult.data,
          stampStyle: stampStyleResult?.data || null,
          memberships: membershipsResult?.data || [],
          selectedMembership: null,
          transactions: []
        });
      } catch (error) {
        if (!signal?.aborted) {
          setState({
            status: 'error',
            message: error instanceof Error ? error.message : 'Unable to load loyalty.'
          });
        }
      }
    },
    [apiBaseUrl, getToken, isLoaded, isSignedIn]
  );

  const refreshMemberships = useCallback(
    async (token: string, businessId: string, nextFilters = filters) => {
      const result = await listLoyaltyMemberships({
        apiBaseUrl,
        token,
        businessId,
        search: nextFilters.search,
        status: nextFilters.status,
        rewardReady: rewardReadyQuery(nextFilters.rewardReady)
      });

      if (result.status === 'ok') {
        setState((current) =>
          current.status === 'ok'
            ? {
                ...current,
                memberships: result.data
              }
            : current
        );
      }

      return result;
    },
    [apiBaseUrl, filters]
  );

  const refreshSelectedMembership = useCallback(
    async (token: string, businessId: string, membershipId: string) => {
      const [membershipResult, transactionsResult] = await Promise.all([
        getLoyaltyMembership({
          apiBaseUrl,
          token,
          businessId,
          membershipId
        }),
        listLoyaltyTransactions({
          apiBaseUrl,
          token,
          businessId,
          membershipId
        })
      ]);

      if (membershipResult.status !== 'ok') {
        return membershipResult;
      }

      if (transactionsResult.status !== 'ok') {
        return transactionsResult;
      }

      setState((current) =>
        current.status === 'ok'
          ? {
              ...current,
              selectedMembership: membershipResult.data,
              transactions: transactionsResult.data
            }
          : current
      );

      return membershipResult;
    },
    [apiBaseUrl]
  );

  useEffect(() => {
    const controller = new AbortController();

    void loadLoyalty(controller.signal);

    return () => {
      controller.abort();
    };
  }, [loadLoyalty]);

  const canConfigure = useMemo(() => (state.status === 'ok' ? canConfigureProgram(state.summary) : false), [state]);
  const canOperate = useMemo(() => (state.status === 'ok' ? canOperateLoyalty(state.summary) : false), [state]);

  async function withToken(action: (token: string, current: Extract<LoyaltyState, { status: 'ok' }>) => Promise<void>) {
    if (state.status !== 'ok') {
      return;
    }

    const token = await getToken();

    if (!token) {
      setActionState({
        status: 'error',
        message: 'Please sign in again before saving changes.'
      });
      return;
    }

    await action(token, state);
  }

  function handleApiResult<T>(result: AdminApiResult<T>, successMessage: string) {
    if (result.status !== 'ok') {
      setActionState({
        status: 'error',
        message: result.message
      });
      return false;
    }

    setActionState({
      status: 'success',
      message: successMessage
    });
    return true;
  }

  async function submitProgram(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!canConfigure) {
      setActionState({
        status: 'error',
        message: 'Only OWNER and MANAGER can configure loyalty programs.'
      });
      return;
    }

    if (!programDraft.name.trim() || !programDraft.rewardName.trim() || programDraft.stampGoal < 1 || programDraft.stampGoal > 50) {
      setActionState({
        status: 'error',
        message: 'Program name, reward name, and stamp goal from 1 to 50 are required.'
      });
      return;
    }

    setActionState({ status: 'pending', message: 'Saving loyalty program...' });

    await withToken(async (token, current) => {
      const result = current.program
        ? await updateLoyaltyProgram({
            apiBaseUrl,
            token,
            businessId: current.businessId,
            programId: current.program.id,
            input: programDraft
          })
        : await createLoyaltyProgram({
            apiBaseUrl,
            token,
            businessId: current.businessId,
            input: programDraft
          });

      if (result.status !== 'ok') {
        handleApiResult(result, current.program ? 'Loyalty program updated.' : 'Loyalty program created.');
        return;
      }

      handleApiResult(result, current.program ? 'Loyalty program updated.' : 'Loyalty program created.');
      setProgramDraft(programToDraft(result.data));
      const styleResult = await getLoyaltyStampStyle({
        apiBaseUrl,
        token,
        businessId: current.businessId
      });
      const nextStampStyle = styleResult.status === 'ok' ? styleResult.data : current.stampStyle;

      if (styleResult.status === 'ok') {
        setStampStyleDraft(stampStyleToDraft(styleResult.data));
      }

      setState((openState) =>
        openState.status === 'ok'
          ? {
              ...openState,
              program: result.data,
              stampStyle: nextStampStyle
            }
          : openState
      );
      await refreshMemberships(token, current.businessId);
    });
  }

  async function submitStampStyle() {
    if (!canConfigure) {
      setActionState({
        status: 'error',
        message: 'Only OWNER and MANAGER can update wallet appearance.'
      });
      return;
    }

    if (!stampStyleDraft) {
      setActionState({
        status: 'error',
        message: 'Wallet appearance is not loaded yet.'
      });
      return;
    }

    if (hasInvalidStampStyleColors(stampStyleDraft)) {
      setActionState({
        status: 'error',
        message: 'Fix invalid hex colors before saving wallet appearance.'
      });
      return;
    }

    setActionState({ status: 'pending', message: 'Saving wallet appearance...' });

    await withToken(async (token, current) => {
      const result = await updateLoyaltyStampStyle({
        apiBaseUrl,
        token,
        businessId: current.businessId,
        input: stampStyleDraft
      });

      if (result.status !== 'ok') {
        handleApiResult(result, 'Wallet appearance saved.');
        return;
      }

      handleApiResult(result, 'Wallet appearance saved.');
      setStampStyleDraft(stampStyleToDraft(result.data));
      setState((openState) =>
        openState.status === 'ok'
          ? {
              ...openState,
              stampStyle: result.data
            }
          : openState
      );
    });
  }

  async function submitEnrollment(input: { phone: string; email: string; name: string }) {
    if (!canOperate) {
      setActionState({ status: 'error', message: 'This role cannot enroll loyalty customers.' });
      return;
    }

    setActionState({ status: 'pending', message: 'Enrolling customer...' });

    await withToken(async (token, current) => {
      const result = await enrollLoyaltyCustomer({
        apiBaseUrl,
        token,
        businessId: current.businessId,
        input: {
          phone: input.phone,
          email: input.email,
          name: input.name,
          programId: current.program?.id
        }
      });

      if (result.status !== 'ok') {
        handleApiResult(result, 'Customer membership is ready.');
        return;
      }

      handleApiResult(result, 'Customer membership is ready.');
      await refreshMemberships(token, current.businessId);
      await refreshSelectedMembership(token, current.businessId, result.data.membership.id);
    });
  }

  async function searchMemberships() {
    setActionState({ status: 'pending', message: 'Searching memberships...' });

    await withToken(async (token, current) => {
      const result = await refreshMemberships(token, current.businessId);
      handleApiResult(result, 'Memberships refreshed.');
    });
  }

  async function selectMembership(membershipId: string) {
    setActionState({ status: 'pending', message: 'Loading membership...' });

    await withToken(async (token, current) => {
      const result = await refreshSelectedMembership(token, current.businessId, membershipId);
      handleApiResult(result, 'Membership loaded.');
    });
  }

  async function submitAddStamps(count: number, reason: string) {
    if (state.status !== 'ok' || !state.selectedMembership) {
      return;
    }

    if (!canOperate) {
      setActionState({ status: 'error', message: 'This role cannot add loyalty stamps.' });
      return;
    }

    setActionState({ status: 'pending', message: 'Adding stamps...' });

    await withToken(async (token, current) => {
      const selectedId = current.selectedMembership?.id;

      if (!selectedId) {
        setActionState({ status: 'error', message: 'Select a membership before adding stamps.' });
        return;
      }

      const result = await addLoyaltyStamps({
        apiBaseUrl,
        token,
        businessId: current.businessId,
        membershipId: selectedId,
        input: {
          count,
          reason
        }
      });

      if (result.status !== 'ok') {
        handleApiResult(result, 'Stamp added.');
        return;
      }

      handleApiResult(result, result.data.cardState.rewardReady ? 'Stamp added. Reward is ready.' : 'Stamp added.');
      await refreshMemberships(token, current.businessId);
      await refreshSelectedMembership(token, current.businessId, selectedId);
    });
  }

  async function submitRedeem(reason: string) {
    if (state.status !== 'ok' || !state.selectedMembership) {
      return;
    }

    if (!canOperate) {
      setActionState({ status: 'error', message: 'This role cannot redeem loyalty rewards.' });
      return;
    }

    setActionState({ status: 'pending', message: 'Redeeming reward...' });

    await withToken(async (token, current) => {
      const selectedId = current.selectedMembership?.id;

      if (!selectedId) {
        setActionState({ status: 'error', message: 'Select a membership before redeeming.' });
        return;
      }

      const result = await redeemLoyaltyReward({
        apiBaseUrl,
        token,
        businessId: current.businessId,
        membershipId: selectedId,
        input: {
          reason
        }
      });

      if (!handleApiResult(result, 'Reward redeemed.')) {
        return;
      }

      await refreshMemberships(token, current.businessId);
      await refreshSelectedMembership(token, current.businessId, selectedId);
    });
  }

  if (state.status !== 'ok') {
    return <BlockingState state={state} />;
  }

  return (
    <div className="grid gap-6">
      <section className="rounded-lg border border-neutral-200 bg-white p-5">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase text-accent">Loyalty workspace</p>
            <h1 className="mt-2 text-2xl font-bold text-ink">{state.summary.business.name}</h1>
            <p className="mt-2 max-w-3xl text-sm leading-6 text-neutral-600">
              Manage the stamp-card program, wallet appearance, and staff cashier operations.
            </p>
          </div>
          <div className="flex flex-wrap gap-2">
            <StatusPill tone="success">{state.summary.currentUser.role}</StatusPill>
            <StatusPill tone={canConfigure ? 'success' : 'neutral'}>{canConfigure ? 'Can configure' : 'View program only'}</StatusPill>
          </div>
        </div>
      </section>

      <ActionBanner actionState={actionState} />

      <ProgramPanel
        actionPending={actionPending}
        canConfigure={canConfigure}
        draft={programDraft}
        program={state.program}
        onDraftChange={setProgramDraft}
        onSubmit={submitProgram}
      />

      {state.program ? (
        <>
          {stampStyleDraft && state.stampStyle ? (
            <WalletAppearancePanel
              actionPending={actionPending}
              canConfigure={canConfigure}
              catalog={state.stampPresetCatalog}
              draft={stampStyleDraft}
              isDirty={stampStyleDraftKey(stampStyleDraft) !== stampStyleDraftKey(stampStyleToDraft(state.stampStyle))}
              onDraftChange={setStampStyleDraft}
              onSubmit={() => void submitStampStyle()}
            />
          ) : (
            <section className="rounded-lg border border-neutral-200 bg-white p-5">
              <p className="text-sm font-semibold uppercase text-accent">Wallet &amp; Stamp Appearance</p>
              <h2 className="mt-2 text-xl font-bold text-ink">Loading appearance settings</h2>
              <p className="mt-2 text-sm leading-6 text-neutral-600">Appearance controls load after the active loyalty program is ready.</p>
            </section>
          )}

          <EnrollmentPanel actionPending={actionPending} disabled={!canOperate} onSubmit={submitEnrollment} />

          <MembershipListPanel
            actionPending={actionPending}
            filters={filters}
            memberships={state.memberships}
            selectedMembershipId={state.selectedMembership?.id || null}
            onFiltersChange={setFilters}
            onSearch={() => void searchMemberships()}
            onSelect={(membershipId) => void selectMembership(membershipId)}
          />

          <MembershipDetailPanel
            actionPending={actionPending}
            canOperate={canOperate}
            membership={state.selectedMembership}
            transactions={state.transactions}
            onAddStamps={(count, reason) => void submitAddStamps(count, reason)}
            onRedeem={(reason) => void submitRedeem(reason)}
          />
        </>
      ) : (
        <section className="rounded-lg border border-amber-200 bg-amber-50 p-5">
          <p className="text-sm font-semibold uppercase text-amber-700">No active loyalty program</p>
          <h2 className="mt-2 text-xl font-bold text-ink">Set up a stamp card before enrolling customers</h2>
          <p className="mt-2 text-sm leading-6 text-amber-900">
            OWNER and MANAGER can create the active program above. STAFF can return here after setup to search, enroll, add stamps,
            and redeem rewards.
          </p>
        </section>
      )}
    </div>
  );
}

'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@clerk/nextjs';
import { fetchAdminMe, type AdminMeFetchResult, type AdminMeResponse } from '../lib/admin-api';
import { WafloBadge, WafloCard, WafloEmptyState, WafloErrorState, WafloLoadingSkeleton, WafloMetricCard, WafloPanel, WafloTable } from './waflo';

type OwnerContextPanelProps = {
  apiBaseUrl: string;
  variant?: 'summary' | 'businesses';
};

type LoadState =
  | {
      status: 'idle' | 'loading';
    }
  | AdminMeFetchResult;

function StatusPill({ children }: Readonly<{ children: React.ReactNode }>) {
  return <WafloBadge tone="neutral">{children}</WafloBadge>;
}

function formatNextStep(value: string | null | undefined) {
  switch (value) {
    case 'CREATE_BUSINESS':
      return 'Create business';
    case 'OPEN_DASHBOARD':
      return 'Open dashboard';
    default:
      return value || 'Ready';
  }
}

function ContextStatus({ state }: { state: LoadState }) {
  switch (state.status) {
    case 'idle':
    case 'loading':
      return <WafloLoadingSkeleton lines={3} />;
    case 'auth-error':
    case 'error':
      return <WafloErrorState title="Could not load your workspace" description="Please sign in again or ask an owner to confirm your business access." />;
    case 'ok':
      return null;
  }
}

function SummaryView({ me }: { me: AdminMeResponse }) {
  const primaryMembership = me.memberships.find((membership) => membership.isActive) || me.memberships[0] || null;

  return (
    <section className="grid gap-4 lg:grid-cols-[1.2fr_0.8fr]">
      <WafloCard className="p-5">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p className="text-xs font-bold uppercase tracking-wide text-waflo-coral">Account</p>
            <h2 className="mt-2 text-xl font-bold text-waflo-charcoal">{me.user.name || 'Signed-in user'}</h2>
            <p className="mt-1 text-sm text-waflo-muted">
              {me.onboarding.hasBusiness ? 'Business access found' : 'No business access yet'}
            </p>
          </div>
          <StatusPill>{me.user.status}</StatusPill>
        </div>

        <div className="mt-5 grid gap-3 sm:grid-cols-3">
          <WafloMetricCard label="Memberships" value={me.memberships.length} />
          <WafloMetricCard label="Active businesses" value={me.onboarding.activeBusinessCount} tone="green" />
          <WafloMetricCard label="Next step" value={formatNextStep(me.onboarding.recommendedNextStep)} tone="gold" />
        </div>

        {primaryMembership ? (
          <div className="mt-5 rounded-xl border border-waflo-border p-4">
            <p className="text-sm font-semibold text-waflo-muted">Current business context</p>
            <h3 className="mt-2 text-lg font-bold text-waflo-charcoal">{primaryMembership.business.name}</h3>
            <p className="mt-1 text-sm text-waflo-muted">
              /m/{primaryMembership.business.slug} - {primaryMembership.business.city || 'No city'} -{' '}
              {primaryMembership.role}
            </p>
          </div>
        ) : null}
      </WafloCard>

      <WafloCard className="p-5">
        <p className="text-xs font-bold uppercase tracking-wide text-waflo-coral">Owner onboarding</p>
        <h2 className="mt-2 text-xl font-bold text-waflo-charcoal">
          {me.onboarding.hasBusiness ? 'Business context available' : 'No business created yet'}
        </h2>
        <p className="mt-2 text-sm leading-6 text-waflo-muted">
          {me.onboarding.hasBusiness
            ? 'Your account has at least one active business ready to manage.'
            : 'Create your first business before opening the dashboard.'}
        </p>
        <div className="mt-4">
          <StatusPill>{formatNextStep(me.onboarding.recommendedNextStep)}</StatusPill>
        </div>
      </WafloCard>
    </section>
  );
}

function BusinessesView({ me }: { me: AdminMeResponse }) {
  if (!me.onboarding.hasBusiness || me.businesses.length === 0) {
    return (
      <WafloEmptyState title="No business created yet" description="Create your first business before using the dashboard. Once a business exists, it will appear here." />
    );
  }

  return (
    <WafloPanel eyebrow="Businesses" title="Your businesses">
      <WafloTable
        columns={['Name', 'Slug', 'Type', 'Role']}
        rows={me.businesses.map((business) => [
          <span key="name" className="font-bold text-waflo-charcoal">{business.name}</span>,
          `/m/${business.slug}`,
          business.type,
          <WafloBadge key="role" tone="charcoal">{business.role}</WafloBadge>
        ])}
      />
    </WafloPanel>
  );
}

export function OwnerContextPanel({ apiBaseUrl, variant = 'summary' }: OwnerContextPanelProps) {
  const { getToken, isLoaded, isSignedIn } = useAuth();
  const [state, setState] = useState<LoadState>({ status: 'idle' });

  useEffect(() => {
    if (!isLoaded || !isSignedIn) {
      return;
    }

    const controller = new AbortController();

    async function loadMe() {
      setState({ status: 'loading' });
      const apiUrl = `${apiBaseUrl.replace(/\/+$/, '')}/me`;

      try {
        const token = await getToken();
        const result = await fetchAdminMe({
          apiBaseUrl,
          token,
          signal: controller.signal
        });

        if (!controller.signal.aborted) {
          setState(result);
        }
      } catch (error) {
        if (!controller.signal.aborted) {
          setState({
            status: 'auth-error',
            apiUrl,
            message: error instanceof Error ? error.message : 'Unable to confirm the signed-in session.'
          });
        }
      }
    }

    void loadMe();

    return () => {
      controller.abort();
    };
  }, [apiBaseUrl, getToken, isLoaded, isSignedIn]);

  if (state.status !== 'ok') {
    return <ContextStatus state={state} />;
  }

  return variant === 'businesses' ? <BusinessesView me={state.data} /> : <SummaryView me={state.data} />;
}

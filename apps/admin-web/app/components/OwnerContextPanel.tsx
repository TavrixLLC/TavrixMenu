'use client';

import { useEffect, useState } from 'react';
import { useAuth } from '@clerk/nextjs';
import { fetchAdminMe, type AdminMeFetchResult, type AdminMeResponse } from '../lib/admin-api';

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
  return (
    <span className="inline-flex rounded-full bg-neutral-100 px-2 py-1 text-xs font-semibold text-neutral-700">
      {children}
    </span>
  );
}

function ContextStatus({ state }: { state: LoadState }) {
  switch (state.status) {
    case 'idle':
    case 'loading':
      return (
        <section className="rounded-lg border border-neutral-200 bg-white p-5">
          <p className="text-sm font-semibold uppercase text-accent">Owner context</p>
          <h2 className="mt-2 text-xl font-bold text-ink">Loading authenticated context</h2>
          <p className="mt-2 text-sm leading-6 text-neutral-600">
            Fetching the Sprint 3 /me response with a Clerk JWT.
          </p>
        </section>
      );
    case 'auth-error':
    case 'error':
      return (
        <section className="rounded-lg border border-rose-200 bg-rose-50 p-5">
          <p className="text-sm font-semibold uppercase text-rose-700">Owner context unavailable</p>
          <h2 className="mt-2 text-xl font-bold text-ink">Could not load GET /me</h2>
          <p className="mt-2 text-sm leading-6 text-rose-900">{state.message}</p>
          <p className="mt-3 rounded-md bg-white/70 p-3 text-xs font-semibold text-rose-800">{state.apiUrl}</p>
        </section>
      );
    case 'ok':
      return null;
  }
}

function SummaryView({ me }: { me: AdminMeResponse }) {
  const primaryMembership = me.memberships.find((membership) => membership.isActive) || me.memberships[0] || null;

  return (
    <section className="grid gap-4 lg:grid-cols-[1.2fr_0.8fr]">
      <article className="rounded-lg border border-neutral-200 bg-white p-5">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase text-accent">GET /me</p>
            <h2 className="mt-2 text-xl font-bold text-ink">{me.user.name || me.user.email || me.user.clerkUserId}</h2>
            <p className="mt-1 text-sm text-neutral-600">{me.user.email || 'No email returned'}</p>
          </div>
          <StatusPill>{me.user.status}</StatusPill>
        </div>

        <div className="mt-5 grid gap-3 sm:grid-cols-3">
          <div className="rounded-lg bg-neutral-50 p-3">
            <p className="text-xs font-semibold uppercase text-neutral-500">Memberships</p>
            <p className="mt-2 text-2xl font-bold text-ink">{me.memberships.length}</p>
          </div>
          <div className="rounded-lg bg-neutral-50 p-3">
            <p className="text-xs font-semibold uppercase text-neutral-500">Active businesses</p>
            <p className="mt-2 text-2xl font-bold text-ink">{me.onboarding.activeBusinessCount}</p>
          </div>
          <div className="rounded-lg bg-neutral-50 p-3">
            <p className="text-xs font-semibold uppercase text-neutral-500">Next step</p>
            <p className="mt-2 text-sm font-bold text-ink">{me.onboarding.recommendedNextStep || 'Not returned'}</p>
          </div>
        </div>

        {primaryMembership ? (
          <div className="mt-5 rounded-lg border border-neutral-200 p-4">
            <p className="text-sm font-semibold text-neutral-500">Current business context</p>
            <h3 className="mt-2 text-lg font-bold text-ink">{primaryMembership.business.name}</h3>
            <p className="mt-1 text-sm text-neutral-600">
              /m/{primaryMembership.business.slug} - {primaryMembership.business.city || 'No city'} -{' '}
              {primaryMembership.role}
            </p>
          </div>
        ) : null}
      </article>

      <article className="rounded-lg border border-neutral-200 bg-white p-5">
        <p className="text-sm font-semibold uppercase text-accent">Owner onboarding</p>
        <h2 className="mt-2 text-xl font-bold text-ink">
          {me.onboarding.hasBusiness ? 'Business context available' : 'No business created yet'}
        </h2>
        <p className="mt-2 text-sm leading-6 text-neutral-600">
          {me.onboarding.hasBusiness
            ? 'The signed-in owner has at least one active business returned by the Sprint 3 backend.'
            : 'Create the first business from the mobile app / owner onboarding flow before opening the dashboard.'}
        </p>
        <div className="mt-4">
          <StatusPill>{me.onboarding.recommendedNextStep || 'WAITING_FOR_ONBOARDING'}</StatusPill>
        </div>
      </article>
    </section>
  );
}

function BusinessesView({ me }: { me: AdminMeResponse }) {
  if (!me.onboarding.hasBusiness || me.businesses.length === 0) {
    return (
      <section className="rounded-lg border border-neutral-200 bg-white p-5">
        <p className="text-sm font-semibold uppercase text-accent">Businesses</p>
        <h2 className="mt-2 text-xl font-bold text-ink">No business created yet</h2>
        <p className="mt-2 text-sm leading-6 text-neutral-600">
          Create your first business from the mobile app / owner onboarding flow. Admin-web is only displaying Sprint 3
          owner context right now.
        </p>
      </section>
    );
  }

  return (
    <section className="rounded-lg border border-neutral-200 bg-white">
      <div className="border-b border-neutral-200 p-4">
        <p className="text-sm font-semibold uppercase text-accent">GET /me businesses</p>
        <h2 className="mt-2 text-xl font-bold text-ink">Signed-in owner businesses</h2>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[640px] text-left text-sm">
          <thead className="bg-neutral-50 text-neutral-500">
            <tr>
              <th className="px-4 py-3">Name</th>
              <th className="px-4 py-3">Slug</th>
              <th className="px-4 py-3">Type</th>
              <th className="px-4 py-3">Role</th>
            </tr>
          </thead>
          <tbody>
            {me.businesses.map((business) => (
              <tr key={business.id} className="border-t border-neutral-100">
                <td className="px-4 py-3 font-semibold text-ink">{business.name}</td>
                <td className="px-4 py-3 text-neutral-600">/m/{business.slug}</td>
                <td className="px-4 py-3 text-neutral-600">{business.type}</td>
                <td className="px-4 py-3 text-neutral-600">{business.role}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
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
            message: error instanceof Error ? error.message : 'Unable to read the Clerk JWT.'
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

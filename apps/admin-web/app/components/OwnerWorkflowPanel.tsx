'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { useAuth } from '@clerk/nextjs';
import {
  fetchAdminMe,
  getCategories,
  getDashboardSummary,
  getItems,
  reorderCategories,
  reorderItems,
  restoreCategory,
  restoreItem,
  type AdminCategory,
  type AdminDashboardSummary,
  type AdminMeResponse,
  type AdminMenuItem,
  type AdminPermissions
} from '../lib/admin-api';

type OwnerWorkflowPanelProps = {
  apiBaseUrl: string;
};

type WorkflowState =
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
      categories: AdminCategory[];
      items: AdminMenuItem[];
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

const permissionLabels: Array<[keyof AdminPermissions, string]> = [
  ['canManageBusiness', 'Manage business'],
  ['canManageMenu', 'Manage menu'],
  ['canManageMembers', 'Manage members'],
  ['canViewMembers', 'View members'],
  ['canViewPublicLink', 'View public link']
];

function sortCategories(categories: AdminCategory[]) {
  return [...categories].sort((left, right) => left.sortOrder - right.sortOrder || left.nameAr.localeCompare(right.nameAr));
}

function sortItems(items: AdminMenuItem[]) {
  return [...items].sort((left, right) => left.sortOrder - right.sortOrder || left.nameAr.localeCompare(right.nameAr));
}

function moveListItem<T>(items: T[], index: number, direction: -1 | 1) {
  const nextIndex = index + direction;

  if (nextIndex < 0 || nextIndex >= items.length) {
    return items;
  }

  const next = [...items];
  const [item] = next.splice(index, 1);
  next.splice(nextIndex, 0, item);
  return next;
}

function pickCurrentBusinessId(me: AdminMeResponse) {
  const activeMembership = me.memberships.find((membership) => membership.isActive && membership.business.id);
  const firstMembership = me.memberships.find((membership) => membership.business.id);

  return activeMembership?.business.id || firstMembership?.business.id || me.businesses[0]?.id || null;
}

function isMenuManager(summary: AdminDashboardSummary) {
  const role = summary.currentUser.role.toUpperCase();
  return summary.currentUser.permissions.canManageMenu && (role === 'OWNER' || role === 'MANAGER');
}

function StatusPill({
  children,
  tone = 'neutral'
}: Readonly<{
  children: React.ReactNode;
  tone?: 'neutral' | 'success' | 'warning';
}>) {
  const toneClass =
    tone === 'success'
      ? 'bg-emerald-50 text-emerald-700 ring-emerald-200'
      : tone === 'warning'
        ? 'bg-amber-50 text-amber-800 ring-amber-200'
        : 'bg-neutral-100 text-neutral-700 ring-neutral-200';

  return <span className={`inline-flex rounded-full px-2 py-1 text-xs font-semibold ring-1 ${toneClass}`}>{children}</span>;
}

function BlockingState({ state }: { state: Exclude<WorkflowState, { status: 'ok' }> }) {
  const titleByStatus = {
    'auth-error': 'Authentication required',
    forbidden: 'Permission denied',
    'validation-error': 'Validation error',
    error: 'Owner workflow unavailable'
  };

  switch (state.status) {
    case 'idle':
    case 'loading':
      return (
        <section className="rounded-lg border border-neutral-200 bg-white p-5">
          <p className="text-sm font-semibold uppercase text-accent">Owner workflow</p>
          <h2 className="mt-2 text-xl font-bold text-ink">Loading dashboard summary</h2>
          <p className="mt-2 text-sm leading-6 text-neutral-600">
            Fetching the selected business context, dashboard counts, and menu records.
          </p>
        </section>
      );
    case 'missing-business':
      return (
        <section className="rounded-lg border border-amber-200 bg-amber-50 p-5">
          <p className="text-sm font-semibold uppercase text-amber-700">Missing selected business</p>
          <h2 className="mt-2 text-xl font-bold text-ink">No business is available for this account</h2>
          <p className="mt-2 text-sm leading-6 text-amber-900">{state.message}</p>
        </section>
      );
  }

  return (
    <section className="rounded-lg border border-rose-200 bg-rose-50 p-5">
      <p className="text-sm font-semibold uppercase text-rose-700">{titleByStatus[state.status]}</p>
      <h2 className="mt-2 text-xl font-bold text-ink">Could not load Sprint 4 owner workflow</h2>
      <p className="mt-2 text-sm leading-6 text-rose-900">{state.message}</p>
      {state.apiUrl ? <p className="mt-3 rounded-md bg-white/70 p-3 text-xs font-semibold text-rose-800">{state.apiUrl}</p> : null}
    </section>
  );
}

function DetailRow({ label, value }: Readonly<{ label: string; value: React.ReactNode }>) {
  return (
    <div>
      <p className="text-xs font-semibold uppercase text-neutral-500">{label}</p>
      <p className="mt-1 text-sm font-semibold text-ink">{value}</p>
    </div>
  );
}

function DashboardSummarySection({ summary }: { summary: AdminDashboardSummary }) {
  const counts = [
    ['Active categories', summary.counts.activeCategories],
    ['Inactive categories', summary.counts.inactiveCategories],
    ['Active items', summary.counts.activeItems],
    ['Inactive items', summary.counts.inactiveItems],
    ['Available items', summary.counts.availableItems],
    ['Unavailable items', summary.counts.unavailableItems],
    ['Active members', summary.counts.activeMembers]
  ];

  const nextStep = summary.onboardingHints.recommendedNextStep || 'READY';
  const nextStepCopy =
    nextStep === 'ADD_CATEGORY'
      ? {
          title: 'Add category',
          description: 'Create the first menu category before adding items.',
          cta: 'Add category',
          href: '#menu-workflow'
        }
      : nextStep === 'ADD_ITEM'
        ? {
            title: 'Add item',
            description: 'Add at least one menu item to make the public menu useful.',
            cta: 'Add item',
            href: '#menu-workflow'
          }
        : nextStep === 'SHARE_PUBLIC_MENU'
          ? {
              title: 'Share public menu',
              description: 'The menu is ready for owners to copy and share.',
              cta: 'Copy or share',
              href: '#public-menu-share'
            }
          : {
              title: 'Menu is ready',
              description: 'Categories, items, and public menu details are available.',
              cta: null,
              href: null
            };

  return (
    <section className="grid gap-4">
      <div className="grid gap-4 lg:grid-cols-[1.1fr_0.9fr]">
        <article className="rounded-lg border border-neutral-200 bg-white p-5">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <p className="text-sm font-semibold uppercase text-accent">Dashboard summary</p>
              <h2 className="mt-2 text-xl font-bold text-ink">{summary.business.name}</h2>
              <p className="mt-1 text-sm text-neutral-600">/m/{summary.business.slug}</p>
            </div>
            <StatusPill tone="success">{summary.business.status || 'ACTIVE'}</StatusPill>
          </div>

          <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <DetailRow label="Type" value={summary.business.type} />
            <DetailRow label="City" value={summary.business.city || 'Not set'} />
            <DetailRow label="Currency" value={summary.business.currency} />
            <DetailRow label="Language" value={summary.business.language} />
          </div>
        </article>

        <article className="rounded-lg border border-neutral-200 bg-white p-5">
          <p className="text-sm font-semibold uppercase text-accent">Current user</p>
          <h2 className="mt-2 text-xl font-bold text-ink">{summary.currentUser.role}</h2>
          <div className="mt-4 flex flex-wrap gap-2">
            {permissionLabels.map(([key, label]) => (
              <StatusPill key={key} tone={summary.currentUser.permissions[key] ? 'success' : 'neutral'}>
                {label}: {summary.currentUser.permissions[key] ? 'Yes' : 'No'}
              </StatusPill>
            ))}
          </div>
        </article>
      </div>

      <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {counts.map(([label, value]) => (
          <article key={label} className="rounded-lg border border-neutral-200 bg-white p-4">
            <p className="text-sm font-semibold text-neutral-500">{label}</p>
            <p className="mt-3 text-3xl font-bold text-ink">{value}</p>
          </article>
        ))}
      </section>

      <article className="rounded-lg border border-neutral-200 bg-white p-5">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase text-accent">Onboarding hints</p>
            <h2 className="mt-2 text-xl font-bold text-ink">{nextStepCopy.title}</h2>
            <p className="mt-2 text-sm leading-6 text-neutral-600">{nextStepCopy.description}</p>
          </div>
          {nextStepCopy.cta && nextStepCopy.href ? (
            <a className="inline-flex rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white" href={nextStepCopy.href}>
              {nextStepCopy.cta}
            </a>
          ) : (
            <StatusPill tone="success">READY</StatusPill>
          )}
        </div>
        <div className="mt-4 flex flex-wrap gap-2">
          <StatusPill tone={summary.onboardingHints.hasCategories ? 'success' : 'warning'}>
            hasCategories: {summary.onboardingHints.hasCategories ? 'true' : 'false'}
          </StatusPill>
          <StatusPill tone={summary.onboardingHints.hasItems ? 'success' : 'warning'}>
            hasItems: {summary.onboardingHints.hasItems ? 'true' : 'false'}
          </StatusPill>
          <StatusPill tone={summary.onboardingHints.hasPublicMenuReady ? 'success' : 'warning'}>
            hasPublicMenuReady: {summary.onboardingHints.hasPublicMenuReady ? 'true' : 'false'}
          </StatusPill>
          <StatusPill>{summary.onboardingHints.recommendedNextStep || 'READY'}</StatusPill>
        </div>
      </article>
    </section>
  );
}

function PublicMenuShareSection({
  summary,
  copyStatus,
  onCopy
}: {
  summary: AdminDashboardSummary;
  copyStatus: string | null;
  onCopy: (value: string, label: string) => void;
}) {
  return (
    <section id="public-menu-share" className="rounded-lg border border-neutral-200 bg-white p-5">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
        <div>
          <p className="text-sm font-semibold uppercase text-accent">Public menu share</p>
          <h2 className="mt-2 text-xl font-bold text-ink">Owner share link</h2>
          <p className="mt-2 max-w-2xl text-sm leading-6 text-neutral-600">
            This uses dashboard-summary.publicMenu from the Sprint 4 backend.
          </p>
        </div>
        <button
          type="button"
          className="inline-flex rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white"
          onClick={() => onCopy(summary.publicMenu.url, 'public menu URL')}
        >
          Copy URL
        </button>
      </div>

      <div className="mt-5 grid gap-4 lg:grid-cols-2">
        <div>
          <p className="text-xs font-semibold uppercase text-neutral-500">Public menu URL</p>
          <p className="mt-2 break-all rounded-md border border-neutral-200 bg-neutral-50 p-3 text-sm font-semibold text-ink">
            {summary.publicMenu.url}
          </p>
        </div>
        <div>
          <p className="text-xs font-semibold uppercase text-neutral-500">QR payload</p>
          <div className="mt-2 grid gap-2">
            <p className="break-all rounded-md border border-neutral-200 bg-neutral-50 p-3 text-sm font-semibold text-ink">
              {summary.publicMenu.qrPayload}
            </p>
            <button
              type="button"
              className="inline-flex w-fit rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-semibold text-neutral-700"
              onClick={() => onCopy(summary.publicMenu.qrPayload, 'QR payload')}
            >
              Copy QR payload
            </button>
          </div>
        </div>
      </div>

      {copyStatus ? <p className="mt-4 text-sm font-semibold text-neutral-700">{copyStatus}</p> : null}
    </section>
  );
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
        : 'border-blue-200 bg-blue-50 text-blue-800';

  return <p className={`rounded-lg border p-3 text-sm font-semibold ${toneClass}`}>{actionState.message}</p>;
}

function CategoryManager({
  categories,
  canManage,
  actionPending,
  onMove,
  onSave,
  onRestore
}: {
  categories: AdminCategory[];
  canManage: boolean;
  actionPending: boolean;
  onMove: (index: number, direction: -1 | 1) => void;
  onSave: () => void;
  onRestore: (category: AdminCategory) => void;
}) {
  return (
    <article className="rounded-lg border border-neutral-200 bg-white">
      <div className="border-b border-neutral-200 p-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase text-accent">Categories</p>
            <h2 className="mt-2 text-xl font-bold text-ink">Category reorder and restore</h2>
          </div>
          <button
            type="button"
            className="rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:bg-neutral-300"
            disabled={!canManage || actionPending || categories.length === 0}
            onClick={onSave}
          >
            Save category order
          </button>
        </div>
        {!canManage ? (
          <p className="mt-3 rounded-md border border-amber-200 bg-amber-50 p-3 text-sm font-semibold text-amber-900">
            Reorder and restore require OWNER or MANAGER with canManageMenu.
          </p>
        ) : null}
      </div>

      {categories.length === 0 ? (
        <div className="p-4">
          <p className="text-sm font-semibold text-neutral-700">No categories returned for this business.</p>
        </div>
      ) : (
        <div className="divide-y divide-neutral-100">
          {categories.map((category, index) => (
            <div key={category.id} className="grid gap-3 p-4 lg:grid-cols-[1fr_auto] lg:items-center">
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <p className="font-semibold text-ink">{category.nameAr}</p>
                  {category.nameEn ? <span className="text-sm text-neutral-500">{category.nameEn}</span> : null}
                  <StatusPill tone={category.isActive ? 'success' : 'warning'}>
                    {category.isActive ? 'active' : 'archived/inactive'}
                  </StatusPill>
                </div>
                <p className="mt-1 text-sm text-neutral-500">sortOrder {category.sortOrder}</p>
              </div>
              <div className="flex flex-wrap gap-2">
                <button
                  type="button"
                  className="rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-semibold text-neutral-700 disabled:cursor-not-allowed disabled:text-neutral-300"
                  disabled={!canManage || actionPending || index === 0}
                  onClick={() => onMove(index, -1)}
                >
                  Up
                </button>
                <button
                  type="button"
                  className="rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-semibold text-neutral-700 disabled:cursor-not-allowed disabled:text-neutral-300"
                  disabled={!canManage || actionPending || index === categories.length - 1}
                  onClick={() => onMove(index, 1)}
                >
                  Down
                </button>
                {!category.isActive ? (
                  <button
                    type="button"
                    className="rounded-md border border-emerald-200 bg-emerald-50 px-3 py-2 text-sm font-semibold text-emerald-700 disabled:cursor-not-allowed disabled:bg-neutral-100 disabled:text-neutral-400"
                    disabled={!canManage || actionPending}
                    onClick={() => onRestore(category)}
                  >
                    Restore
                  </button>
                ) : null}
              </div>
            </div>
          ))}
        </div>
      )}
    </article>
  );
}

function ItemManager({
  items,
  categoryNameById,
  canManage,
  actionPending,
  onMove,
  onSave,
  onRestore
}: {
  items: AdminMenuItem[];
  categoryNameById: Map<string, string>;
  canManage: boolean;
  actionPending: boolean;
  onMove: (index: number, direction: -1 | 1) => void;
  onSave: () => void;
  onRestore: (item: AdminMenuItem) => void;
}) {
  return (
    <article className="rounded-lg border border-neutral-200 bg-white">
      <div className="border-b border-neutral-200 p-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase text-accent">Items</p>
            <h2 className="mt-2 text-xl font-bold text-ink">Item reorder and restore</h2>
          </div>
          <button
            type="button"
            className="rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:bg-neutral-300"
            disabled={!canManage || actionPending || items.length === 0}
            onClick={onSave}
          >
            Save item order
          </button>
        </div>
        {!canManage ? (
          <p className="mt-3 rounded-md border border-amber-200 bg-amber-50 p-3 text-sm font-semibold text-amber-900">
            Reorder and restore require OWNER or MANAGER with canManageMenu.
          </p>
        ) : null}
      </div>

      {items.length === 0 ? (
        <div className="p-4">
          <p className="text-sm font-semibold text-neutral-700">No items returned for this business.</p>
        </div>
      ) : (
        <div className="divide-y divide-neutral-100">
          {items.map((item, index) => (
            <div key={item.id} className="grid gap-3 p-4 lg:grid-cols-[1fr_auto] lg:items-center">
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <p className="font-semibold text-ink">{item.nameAr}</p>
                  {item.nameEn ? <span className="text-sm text-neutral-500">{item.nameEn}</span> : null}
                  <StatusPill tone={item.isAvailable ? 'success' : 'warning'}>
                    {item.isAvailable ? 'available' : 'archived/unavailable'}
                  </StatusPill>
                </div>
                <p className="mt-1 text-sm text-neutral-500">
                  {categoryNameById.get(item.categoryId) || item.categoryId} - {item.price} - sortOrder {item.sortOrder}
                </p>
              </div>
              <div className="flex flex-wrap gap-2">
                <button
                  type="button"
                  className="rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-semibold text-neutral-700 disabled:cursor-not-allowed disabled:text-neutral-300"
                  disabled={!canManage || actionPending || index === 0}
                  onClick={() => onMove(index, -1)}
                >
                  Up
                </button>
                <button
                  type="button"
                  className="rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-semibold text-neutral-700 disabled:cursor-not-allowed disabled:text-neutral-300"
                  disabled={!canManage || actionPending || index === items.length - 1}
                  onClick={() => onMove(index, 1)}
                >
                  Down
                </button>
                {!item.isAvailable ? (
                  <button
                    type="button"
                    className="rounded-md border border-emerald-200 bg-emerald-50 px-3 py-2 text-sm font-semibold text-emerald-700 disabled:cursor-not-allowed disabled:bg-neutral-100 disabled:text-neutral-400"
                    disabled={!canManage || actionPending}
                    onClick={() => onRestore(item)}
                  >
                    Restore
                  </button>
                ) : null}
              </div>
            </div>
          ))}
        </div>
      )}
    </article>
  );
}

export function OwnerWorkflowPanel({ apiBaseUrl }: OwnerWorkflowPanelProps) {
  const { getToken, isLoaded, isSignedIn } = useAuth();
  const [state, setState] = useState<WorkflowState>({ status: 'idle' });
  const [actionState, setActionState] = useState<ActionState>({ status: 'idle' });
  const [copyStatus, setCopyStatus] = useState<string | null>(null);

  const loadWorkflow = useCallback(
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
            message: 'GET /me did not return an active membership or business summary to use as the selected business.'
          });
          return;
        }

        const [summaryResult, categoriesResult, itemsResult] = await Promise.all([
          getDashboardSummary({
            apiBaseUrl,
            token,
            businessId,
            signal
          }),
          getCategories({
            apiBaseUrl,
            token,
            businessId,
            includeInactive: true,
            signal
          }),
          getItems({
            apiBaseUrl,
            token,
            businessId,
            includeInactive: true,
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

        if (categoriesResult.status !== 'ok') {
          setState({
            status: categoriesResult.status,
            apiUrl: categoriesResult.apiUrl,
            message: categoriesResult.message
          });
          return;
        }

        if (itemsResult.status !== 'ok') {
          setState({
            status: itemsResult.status,
            apiUrl: itemsResult.apiUrl,
            message: itemsResult.message
          });
          return;
        }

        setState({
          status: 'ok',
          me: meResult.data,
          businessId,
          summary: summaryResult.data,
          categories: sortCategories(categoriesResult.data),
          items: sortItems(itemsResult.data)
        });
      } catch (error) {
        if (!signal?.aborted) {
          setState({
            status: 'error',
            message: error instanceof Error ? error.message : 'Unable to load the owner workflow.'
          });
        }
      }
    },
    [apiBaseUrl, getToken, isLoaded, isSignedIn]
  );

  const refreshWorkflowData = useCallback(
    async (businessId: string, token: string) => {
      const [summaryResult, categoriesResult, itemsResult] = await Promise.all([
        getDashboardSummary({
          apiBaseUrl,
          token,
          businessId
        }),
        getCategories({
          apiBaseUrl,
          token,
          businessId,
          includeInactive: true
        }),
        getItems({
          apiBaseUrl,
          token,
          businessId,
          includeInactive: true
        })
      ]);

      if (summaryResult.status !== 'ok') {
        return summaryResult.message;
      }

      if (categoriesResult.status !== 'ok') {
        return categoriesResult.message;
      }

      if (itemsResult.status !== 'ok') {
        return itemsResult.message;
      }

      setState((current) =>
        current.status === 'ok'
          ? {
              ...current,
              summary: summaryResult.data,
              categories: sortCategories(categoriesResult.data),
              items: sortItems(itemsResult.data)
            }
          : current
      );

      return null;
    },
    [apiBaseUrl]
  );

  useEffect(() => {
    const controller = new AbortController();

    void loadWorkflow(controller.signal);

    return () => {
      controller.abort();
    };
  }, [loadWorkflow]);

  const categoryNameById = useMemo(() => {
    if (state.status !== 'ok') {
      return new Map<string, string>();
    }

    return new Map(state.categories.map((category) => [category.id, category.nameEn || category.nameAr]));
  }, [state]);

  async function copyToClipboard(value: string, label: string) {
    setCopyStatus(null);

    try {
      await navigator.clipboard.writeText(value);
      setCopyStatus(`Copied ${label}.`);
    } catch (error) {
      setCopyStatus(error instanceof Error ? error.message : `Could not copy ${label}.`);
    }
  }

  function moveCategory(index: number, direction: -1 | 1) {
    setState((current) =>
      current.status === 'ok'
        ? {
            ...current,
            categories: moveListItem(current.categories, index, direction)
          }
        : current
    );
  }

  function moveItem(index: number, direction: -1 | 1) {
    setState((current) =>
      current.status === 'ok'
        ? {
            ...current,
            items: moveListItem(current.items, index, direction)
          }
        : current
    );
  }

  async function runMutation(
    pendingMessage: string,
    successMessage: string,
    mutation: (token: string, businessId: string) => Promise<{ status: string; message?: string }>
  ) {
    if (state.status !== 'ok') {
      return;
    }

    setActionState({ status: 'pending', message: pendingMessage });

    try {
      const token = await getToken();

      if (!token) {
        setActionState({
          status: 'error',
          message: 'Clerk did not return a JWT for the signed-in session.'
        });
        return;
      }

      const result = await mutation(token, state.businessId);

      if (result.status !== 'ok') {
        setActionState({
          status: 'error',
          message: result.message || `${pendingMessage} failed.`
        });
        return;
      }

      const refreshError = await refreshWorkflowData(state.businessId, token);

      if (refreshError) {
        setActionState({
          status: 'error',
          message: `Saved, but refresh failed: ${refreshError}`
        });
        return;
      }

      setActionState({
        status: 'success',
        message: successMessage
      });
    } catch (error) {
      setActionState({
        status: 'error',
        message: error instanceof Error ? error.message : `${pendingMessage} failed.`
      });
    }
  }

  if (state.status !== 'ok') {
    return <BlockingState state={state} />;
  }

  const canManage = isMenuManager(state.summary);
  const actionPending = actionState.status === 'pending';

  return (
    <div className="grid gap-6">
      <DashboardSummarySection summary={state.summary} />

      <PublicMenuShareSection summary={state.summary} copyStatus={copyStatus} onCopy={copyToClipboard} />

      <section id="menu-workflow" className="grid gap-4">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p className="text-sm font-semibold uppercase text-accent">Menu management</p>
            <h2 className="mt-2 text-xl font-bold text-ink">Reorder and restore records</h2>
            <p className="mt-2 max-w-3xl text-sm leading-6 text-neutral-600">
              Loaded with includeInactive=true so archived categories and unavailable items stay visible to owners.
            </p>
          </div>
          <button
            type="button"
            className="w-fit rounded-md border border-neutral-200 bg-white px-4 py-2 text-sm font-semibold text-neutral-700"
            disabled={actionPending}
            onClick={() => void loadWorkflow()}
          >
            Refresh
          </button>
        </div>

        <ActionBanner actionState={actionState} />

        <div className="grid gap-4 xl:grid-cols-2">
          <CategoryManager
            categories={state.categories}
            canManage={canManage}
            actionPending={actionPending}
            onMove={moveCategory}
            onSave={() =>
              void runMutation('Saving category order...', 'Category order saved.', async (token, businessId) => {
                const result = await reorderCategories({
                  apiBaseUrl,
                  token,
                  businessId,
                  orders: state.categories.map((category, index) => ({
                    id: category.id,
                    sortOrder: index
                  }))
                });

                return result.status === 'ok'
                  ? { status: 'ok' }
                  : { status: result.status, message: `Category reorder failed: ${result.message}` };
              })
            }
            onRestore={(category) =>
              void runMutation(`Restoring ${category.nameAr}...`, 'Category restored.', async (token) => {
                const result = await restoreCategory({
                  apiBaseUrl,
                  token,
                  categoryId: category.id
                });

                return result.status === 'ok'
                  ? { status: 'ok' }
                  : { status: result.status, message: `Category restore failed: ${result.message}` };
              })
            }
          />

          <ItemManager
            items={state.items}
            categoryNameById={categoryNameById}
            canManage={canManage}
            actionPending={actionPending}
            onMove={moveItem}
            onSave={() =>
              void runMutation('Saving item order...', 'Item order saved.', async (token, businessId) => {
                const result = await reorderItems({
                  apiBaseUrl,
                  token,
                  businessId,
                  orders: state.items.map((item, index) => ({
                    id: item.id,
                    sortOrder: index
                  }))
                });

                return result.status === 'ok'
                  ? { status: 'ok' }
                  : { status: result.status, message: `Item reorder failed: ${result.message}` };
              })
            }
            onRestore={(item) =>
              void runMutation(`Restoring ${item.nameAr}...`, 'Item restored.', async (token) => {
                const result = await restoreItem({
                  apiBaseUrl,
                  token,
                  itemId: item.id
                });

                return result.status === 'ok'
                  ? { status: 'ok' }
                  : { status: result.status, message: `Item restore failed: ${result.message}` };
              })
            }
          />
        </div>
      </section>
    </div>
  );
}

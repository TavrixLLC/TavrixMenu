'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { useAuth } from '@clerk/nextjs';
import {
  fetchAdminMe,
  getCategories,
  getDashboardSummary,
  getItems,
  getMenuAppearance,
  getMenuTemplateCatalog,
  reorderCategories,
  reorderItems,
  restoreCategory,
  restoreItem,
  updateMenuAppearance,
  type AdminCategory,
  type AdminDashboardSummary,
  type AdminMeResponse,
  type AdminMenuAppearance,
  type AdminMenuItem,
  type AdminMenuTemplate,
  type AdminPermissions
} from '../lib/admin-api';
import {
  WafloBadge,
  WafloButton,
  WafloCard,
  WafloEmptyState,
  WafloErrorState,
  WafloLoadingSkeleton,
  WafloMetricCard,
  WafloPageHeader,
  WafloPanel,
  WafloSection,
  WafloTable,
  WafloToast
} from './waflo';

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
      menuAppearance: AdminMenuAppearance;
      templates: AdminMenuTemplate[];
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
  ['canViewPublicLink', 'View public link'],
  ['canManageAppearance', 'Manage appearance']
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

function isAppearanceManager(summary: AdminDashboardSummary) {
  return summary.currentUser.permissions.canManageAppearance || summary.currentUser.permissions.canManageBusiness;
}

function getMenuTemplate(templates: AdminMenuTemplate[], value: string) {
  return templates.find((template) => template.id === value) || templates[0] || null;
}

function StatusPill({
  children,
  tone = 'neutral'
}: Readonly<{
  children: React.ReactNode;
  tone?: 'neutral' | 'success' | 'warning';
}>) {
  return <WafloBadge tone={tone === 'success' ? 'green' : tone === 'warning' ? 'gold' : 'neutral'}>{children}</WafloBadge>;
}

function getOwnerFacingErrorMessage(status: Exclude<WorkflowState, { status: 'ok' }>['status']) {
  switch (status) {
    case 'auth-error':
      return 'Please sign in again to continue managing this business.';
    case 'forbidden':
      return 'Your account can view this area, but it does not have permission to make this change.';
    case 'validation-error':
      return 'Some menu information needs attention before it can be saved.';
    case 'missing-business':
      return 'Create or choose a business before opening the owner dashboard.';
    case 'error':
    default:
      return 'We could not load this workspace right now. Please refresh the page or try again in a moment.';
  }
}

function BlockingState({ state }: { state: Exclude<WorkflowState, { status: 'ok' }> }) {
  const titleByStatus = {
    'auth-error': 'Sign-in required',
    forbidden: 'Permission denied',
    'validation-error': 'Menu information needs attention',
    error: 'Owner dashboard unavailable'
  };

  switch (state.status) {
    case 'idle':
    case 'loading':
      return (
        <WafloLoadingSkeleton lines={4} />
      );
    case 'missing-business':
      return (
        <WafloEmptyState
          title="No business is available for this account"
          description={getOwnerFacingErrorMessage(state.status)}
        />
      );
  }

  return (
    <WafloErrorState
      title={titleByStatus[state.status] || 'Could not load the owner dashboard'}
      description={getOwnerFacingErrorMessage(state.status)}
    />
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
    ['Active categories', summary.counts.activeCategories, 'green'],
    ['Active items', summary.counts.activeItems, 'green'],
    ['Available items', summary.counts.availableItems, 'coral'],
    ['Active members', summary.counts.activeMembers, 'gold']
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
    <WafloSection>
      <WafloPageHeader
        eyebrow="Owner workspace"
        title={summary.business.name}
        description="Manage the live customer menu, loyalty program, and wallet appearance from one launch-ready dashboard."
        meta={
          <>
            <WafloBadge tone="green">{summary.business.status || 'ACTIVE'}</WafloBadge>
            <WafloBadge tone="neutral">/m/{summary.business.slug}</WafloBadge>
            <WafloBadge tone="charcoal">{summary.currentUser.role}</WafloBadge>
          </>
        }
        actions={
          nextStepCopy.cta && nextStepCopy.href ? (
            <a className="inline-flex min-h-11 items-center rounded-lg bg-waflo-charcoal px-4 py-2 text-sm font-bold text-white shadow-subtle transition hover:-translate-y-0.5" href={nextStepCopy.href}>
              {nextStepCopy.cta}
            </a>
          ) : (
            <WafloBadge tone="green">Ready</WafloBadge>
          )
        }
      />

      <div className="grid gap-4 lg:grid-cols-[1.2fr_0.8fr]">
        <WafloCard className="p-5">
          <p className="text-xs font-bold uppercase tracking-wide text-waflo-coral">Business identity</p>
          <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <DetailRow label="Type" value={summary.business.type} />
            <DetailRow label="City" value={summary.business.city || 'Not set'} />
            <DetailRow label="Currency" value={summary.business.currency} />
            <DetailRow label="Language" value={summary.business.language} />
          </div>
        </WafloCard>

        <WafloCard className="p-5">
          <p className="text-xs font-bold uppercase tracking-wide text-waflo-coral">Role and permissions</p>
          <div className="mt-4 flex flex-wrap gap-2">
            {permissionLabels.map(([key, label]) => (
              <StatusPill key={key} tone={summary.currentUser.permissions[key] ? 'success' : 'neutral'}>
                {label}
              </StatusPill>
            ))}
          </div>
        </WafloCard>
      </div>

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {counts.map(([label, value, tone]) => (
          <WafloMetricCard key={label} label={String(label)} value={value} tone={tone as 'green' | 'coral' | 'gold'} />
        ))}
      </section>

      <WafloPanel
        eyebrow="Quick actions"
        title={nextStepCopy.title}
        description={nextStepCopy.description}
        actions={
          <div className="flex flex-wrap gap-2">
            <StatusPill tone={summary.onboardingHints.hasCategories ? 'success' : 'warning'}>
              {summary.onboardingHints.hasCategories ? 'Categories ready' : 'Add category'}
            </StatusPill>
            <StatusPill tone={summary.onboardingHints.hasItems ? 'success' : 'warning'}>
              {summary.onboardingHints.hasItems ? 'Items ready' : 'Add item'}
            </StatusPill>
            <StatusPill tone={summary.onboardingHints.hasPublicMenuReady ? 'success' : 'warning'}>
              {summary.onboardingHints.hasPublicMenuReady ? 'Public menu ready' : 'Menu not ready'}
            </StatusPill>
          </div>
        }
      />
    </WafloSection>
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
    <WafloPanel
      className="scroll-mt-24"
      eyebrow="Public menu"
      title="Share your live menu"
      description="Copy this link for table QR codes, social pages, or staff testing. Customers will see the live public menu."
      actions={
        <WafloButton onClick={() => onCopy(summary.publicMenu.url, 'public menu URL')}>
          Copy menu link
        </WafloButton>
      }
    >
      <div className="grid gap-4 lg:grid-cols-2">
        <div>
          <p className="text-xs font-bold uppercase tracking-wide text-waflo-muted">Live menu link</p>
          <p className="mt-2 break-all rounded-lg border border-waflo-border bg-waflo-cream p-3 text-sm font-semibold text-waflo-charcoal">
            {summary.publicMenu.url}
          </p>
        </div>
        <div>
          <p className="text-xs font-bold uppercase tracking-wide text-waflo-muted">QR handoff</p>
          <p className="mt-2 rounded-lg border border-waflo-border bg-waflo-cream p-3 text-sm font-semibold text-waflo-muted">
            QR content stays hidden here. Use the copied menu link when creating printed table QR codes.
          </p>
        </div>
      </div>

      {copyStatus ? <div className="mt-4"><WafloToast tone="green">{copyStatus}</WafloToast></div> : null}
    </WafloPanel>
  );
}

function MenuAppearanceSection({
  summary,
  appearance,
  templates,
  draftTemplateId,
  canManage,
  actionPending,
  onDraftTemplate,
  onPreview,
  onSave
}: {
  summary: AdminDashboardSummary;
  appearance: AdminMenuAppearance;
  templates: AdminMenuTemplate[];
  draftTemplateId: string;
  canManage: boolean;
  actionPending: boolean;
  onDraftTemplate: (templateId: string) => void;
  onPreview: (templateId: string) => void;
  onSave: () => void;
}) {
  const currentTemplateId = appearance.effectiveTemplateId || appearance.menuTemplateId;
  const currentTemplate = getMenuTemplate(templates, currentTemplateId);
  const draftTemplate = getMenuTemplate(templates, draftTemplateId);
  const hasDraftChange = draftTemplateId !== currentTemplateId;

  return (
    <WafloPanel
      eyebrow="Menu appearance"
      title="Public menu template"
      description={`Current template: ${currentTemplate?.displayName || currentTemplateId}. Existing menu data and public URLs stay unchanged.${draftTemplate ? ` Draft selection: ${draftTemplate.displayName}.` : ''}`}
      actions={
        <>
          <WafloButton variant="secondary" disabled={!draftTemplate || actionPending} onClick={() => onPreview(draftTemplateId)}>
            Preview draft
          </WafloButton>
          <WafloButton disabled={!canManage || actionPending || !draftTemplate || !hasDraftChange} onClick={onSave}>
            Save template
          </WafloButton>
        </>
      }
    >
      {!canManage ? (
        <div className="mb-4">
          <WafloToast tone="gold">Template changes require owner appearance permission.</WafloToast>
        </div>
      ) : null}

      <div className="grid gap-4 xl:grid-cols-4">
        {templates.map((template) => {
          const current = template.id === currentTemplateId;
          const draft = template.id === draftTemplateId;

          return (
            <article
              key={template.id}
              className={`rounded-xl border p-4 shadow-subtle transition hover:-translate-y-0.5 ${
                draft ? 'border-waflo-coral bg-waflo-coralSoft' : 'border-waflo-border bg-white'
              }`}
            >
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h3 className="font-bold text-waflo-charcoal">{template.displayName}</h3>
                  <p className="mt-1 text-xs font-bold uppercase tracking-wide text-waflo-muted">{template.id}</p>
                </div>
                <div className="flex flex-wrap justify-end gap-2">
                  {current ? <StatusPill tone="success">Current</StatusPill> : null}
                  {draft && !current ? <StatusPill tone="warning">Draft</StatusPill> : null}
                </div>
              </div>
              <p className="mt-3 text-sm leading-6 text-waflo-muted">{template.description}</p>
              <p className="mt-3 text-xs font-bold uppercase tracking-wide text-waflo-muted">Best for</p>
              <p className="mt-1 text-sm leading-6 text-waflo-charcoal">{template.bestFor}</p>
              <div
                className="admin-template-preview"
                data-template={template.id}
                aria-label={`${template.displayName} CSS template preview`}
              >
                <div data-slot="merchant-hero">
                  <span data-slot="merchant-logo" />
                  <span data-slot="merchant-name" />
                </div>
                <div data-slot="category-navigation">
                  <span />
                  <span />
                  <span />
                </div>
                <div data-slot="item-list">
                  <span data-slot="item-image" />
                  <span data-slot="item-copy" />
                  <span data-slot="item-price" />
                </div>
                <div data-slot="loyalty-block" />
              </div>
              <div className="mt-3 flex items-center justify-between gap-3 rounded-lg border border-waflo-border bg-white p-3">
                <p className="text-xs font-bold uppercase tracking-wide text-waflo-muted">{template.preview.previewLayout}</p>
                <div className="flex gap-1.5">
                  {template.preview.previewColors.map((swatch) => (
                    <span key={swatch} className="h-5 w-5 rounded-full border border-neutral-200" style={{ backgroundColor: swatch }} />
                  ))}
                </div>
              </div>
              <div className="mt-4 grid gap-2 sm:grid-cols-2">
                <button
                  type="button"
                  className="rounded-lg border border-waflo-border bg-white px-4 py-2 text-sm font-bold text-waflo-charcoal transition hover:bg-waflo-cream disabled:cursor-not-allowed disabled:text-waflo-muted"
                  disabled={actionPending}
                  onClick={() => onPreview(template.id)}
                >
                  Preview
                </button>
                <button
                  type="button"
                  className="rounded-lg bg-waflo-charcoal px-4 py-2 text-sm font-bold text-white transition hover:-translate-y-0.5 disabled:cursor-not-allowed disabled:translate-y-0 disabled:bg-neutral-300"
                  disabled={!canManage || actionPending || draft}
                  onClick={() => onDraftTemplate(template.id)}
                >
                  {draft ? 'Selected' : 'Choose'}
                </button>
              </div>
            </article>
          );
        })}
      </div>
    </WafloPanel>
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
        : 'border-amber-200 bg-amber-50 text-amber-900';

  const message =
    actionState.status === 'error'
      ? 'That change could not be saved. Please try again or check your permission for this business.'
      : actionState.message;

  return <WafloToast tone={actionState.status === 'success' ? 'green' : actionState.status === 'error' ? 'red' : 'gold'}>{message}</WafloToast>;
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
    <WafloPanel
      eyebrow="Categories"
      title="Category order"
      description="Reorder sections and restore inactive categories without changing menu content."
      actions={
        <WafloButton disabled={!canManage || actionPending || categories.length === 0} onClick={onSave}>
          Save order
        </WafloButton>
      }
    >
      {!canManage ? <div className="mb-4"><WafloToast tone="gold">Reorder and restore require owner or manager menu permission.</WafloToast></div> : null}
      {categories.length === 0 ? (
        <WafloEmptyState title="No categories yet" description="Add the first category before launching a public menu." />
      ) : (
        <WafloTable
          columns={['Category', 'Status', 'Order', 'Actions']}
          rows={categories.map((category, index) => [
            <div key="category">
              <p className="font-bold text-waflo-charcoal">{category.nameAr}</p>
              {category.nameEn ? <p className="mt-1 text-sm text-waflo-muted">{category.nameEn}</p> : null}
            </div>,
            <StatusPill key="status" tone={category.isActive ? 'success' : 'warning'}>
              {category.isActive ? 'Active' : 'Inactive'}
            </StatusPill>,
            <span key="order" className="text-sm font-semibold text-waflo-muted">{category.sortOrder}</span>,
            <div key="actions" className="flex flex-wrap gap-2">
                <button
                  type="button"
                  className="rounded-lg border border-waflo-border bg-white px-3 py-2 text-sm font-bold text-waflo-charcoal disabled:cursor-not-allowed disabled:text-waflo-muted"
                  disabled={!canManage || actionPending || index === 0}
                  onClick={() => onMove(index, -1)}
                >
                  Up
                </button>
                <button
                  type="button"
                  className="rounded-lg border border-waflo-border bg-white px-3 py-2 text-sm font-bold text-waflo-charcoal disabled:cursor-not-allowed disabled:text-waflo-muted"
                  disabled={!canManage || actionPending || index === categories.length - 1}
                  onClick={() => onMove(index, 1)}
                >
                  Down
                </button>
                {!category.isActive ? (
                  <button
                    type="button"
                    className="rounded-lg border border-waflo-green/25 bg-waflo-greenSoft px-3 py-2 text-sm font-bold text-waflo-greenDark disabled:cursor-not-allowed disabled:bg-neutral-100 disabled:text-neutral-400"
                    disabled={!canManage || actionPending}
                    onClick={() => onRestore(category)}
                  >
                    Restore
                  </button>
                ) : null}
            </div>
          ])}
        />
      )}
    </WafloPanel>
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
    <WafloPanel
      eyebrow="Items"
      title="Item order"
      description="Keep inactive and unavailable items visible for controlled restoration."
      actions={
        <WafloButton disabled={!canManage || actionPending || items.length === 0} onClick={onSave}>
          Save order
        </WafloButton>
      }
    >
      {!canManage ? <div className="mb-4"><WafloToast tone="gold">Reorder and restore require owner or manager menu permission.</WafloToast></div> : null}
      {items.length === 0 ? (
        <WafloEmptyState title="No items yet" description="Add menu items before sharing the public menu with customers." />
      ) : (
        <WafloTable
          columns={['Item', 'Category', 'Status', 'Actions']}
          rows={items.map((item, index) => [
            <div key="item">
              <p className="font-bold text-waflo-charcoal">{item.nameAr}</p>
              {item.nameEn ? <p className="mt-1 text-sm text-waflo-muted">{item.nameEn}</p> : null}
              <p className="mt-1 text-sm font-semibold text-waflo-muted">{item.price}</p>
            </div>,
            <span key="category" className="text-sm font-semibold text-waflo-muted">{categoryNameById.get(item.categoryId) || item.categoryId}</span>,
            <StatusPill key="status" tone={item.isAvailable ? 'success' : 'warning'}>
              {item.isAvailable ? 'Available' : 'Unavailable'}
            </StatusPill>,
            <div key="actions" className="flex flex-wrap gap-2">
                <button
                  type="button"
                  className="rounded-lg border border-waflo-border bg-white px-3 py-2 text-sm font-bold text-waflo-charcoal disabled:cursor-not-allowed disabled:text-waflo-muted"
                  disabled={!canManage || actionPending || index === 0}
                  onClick={() => onMove(index, -1)}
                >
                  Up
                </button>
                <button
                  type="button"
                  className="rounded-lg border border-waflo-border bg-white px-3 py-2 text-sm font-bold text-waflo-charcoal disabled:cursor-not-allowed disabled:text-waflo-muted"
                  disabled={!canManage || actionPending || index === items.length - 1}
                  onClick={() => onMove(index, 1)}
                >
                  Down
                </button>
                {!item.isAvailable ? (
                  <button
                    type="button"
                    className="rounded-lg border border-waflo-green/25 bg-waflo-greenSoft px-3 py-2 text-sm font-bold text-waflo-greenDark disabled:cursor-not-allowed disabled:bg-neutral-100 disabled:text-neutral-400"
                    disabled={!canManage || actionPending}
                    onClick={() => onRestore(item)}
                  >
                    Restore
                  </button>
                ) : null}
            </div>
          ])}
        />
      )}
    </WafloPanel>
  );
}

export function OwnerWorkflowPanel({ apiBaseUrl }: OwnerWorkflowPanelProps) {
  const { getToken, isLoaded, isSignedIn } = useAuth();
  const [state, setState] = useState<WorkflowState>({ status: 'idle' });
  const [actionState, setActionState] = useState<ActionState>({ status: 'idle' });
  const [copyStatus, setCopyStatus] = useState<string | null>(null);
  const [draftTemplateId, setDraftTemplateId] = useState('waflo-warm');

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
            message: 'No active business is available for this account.'
          });
          return;
        }

        const [summaryResult, menuAppearanceResult, templateCatalogResult, categoriesResult, itemsResult] = await Promise.all([
          getDashboardSummary({
            apiBaseUrl,
            token,
            businessId,
            signal
          }),
          getMenuAppearance({
            apiBaseUrl,
            token,
            businessId,
            signal
          }),
          getMenuTemplateCatalog({
            apiBaseUrl,
            token,
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

        if (menuAppearanceResult.status !== 'ok') {
          setState({
            status: menuAppearanceResult.status,
            apiUrl: menuAppearanceResult.apiUrl,
            message: menuAppearanceResult.message
          });
          return;
        }

        if (templateCatalogResult.status !== 'ok') {
          setState({
            status: templateCatalogResult.status,
            apiUrl: templateCatalogResult.apiUrl,
            message: templateCatalogResult.message
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

        setDraftTemplateId(menuAppearanceResult.data.effectiveTemplateId || menuAppearanceResult.data.menuTemplateId);

        setState({
          status: 'ok',
          me: meResult.data,
          businessId,
          summary: summaryResult.data,
          menuAppearance: menuAppearanceResult.data,
          templates: templateCatalogResult.data.templates,
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
      const [summaryResult, menuAppearanceResult, categoriesResult, itemsResult] = await Promise.all([
        getDashboardSummary({
          apiBaseUrl,
          token,
          businessId
        }),
        getMenuAppearance({
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

      if (menuAppearanceResult.status !== 'ok') {
        return menuAppearanceResult.message;
      }

      if (categoriesResult.status !== 'ok') {
        return categoriesResult.message;
      }

      if (itemsResult.status !== 'ok') {
        return itemsResult.message;
      }

      setDraftTemplateId(menuAppearanceResult.data.effectiveTemplateId || menuAppearanceResult.data.menuTemplateId);

      setState((current) =>
        current.status === 'ok'
          ? {
              ...current,
              summary: summaryResult.data,
              menuAppearance: menuAppearanceResult.data,
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

  function previewTemplate(templateId: string) {
    if (state.status !== 'ok') {
      return;
    }

    const previewUrl = new URL(state.summary.publicMenu.url);
    previewUrl.searchParams.set('previewTemplateId', templateId);
    window.open(previewUrl.toString(), '_blank', 'noopener,noreferrer');
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
          message: 'Please sign in again before saving changes.'
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
  const canManageAppearance = isAppearanceManager(state.summary);
  const actionPending = actionState.status === 'pending';

  return (
    <div className="grid gap-6">
      <DashboardSummarySection summary={state.summary} />

      <PublicMenuShareSection summary={state.summary} copyStatus={copyStatus} onCopy={copyToClipboard} />

      <ActionBanner actionState={actionState} />

      <MenuAppearanceSection
        summary={state.summary}
        appearance={state.menuAppearance}
        templates={state.templates}
        draftTemplateId={draftTemplateId}
        canManage={canManageAppearance}
        actionPending={actionPending}
        onDraftTemplate={setDraftTemplateId}
        onPreview={previewTemplate}
        onSave={() => {
          const draftTemplate = getMenuTemplate(state.templates, draftTemplateId);

          void runMutation(`Saving ${draftTemplate?.displayName || draftTemplateId}...`, 'Menu template saved.', async (token, businessId) => {
            const result = await updateMenuAppearance({
              apiBaseUrl,
              token,
              businessId,
              menuTemplateId: draftTemplateId
            });

            return result.status === 'ok'
              ? { status: 'ok' }
              : { status: result.status, message: `Template save failed: ${result.message}` };
          });
        }}
      />

      <section id="menu-workflow" className="grid scroll-mt-24 gap-4">
        <WafloPageHeader
          eyebrow="Menu management"
          title="Reorder and restore menu content"
          description="Archived categories and sold-out items stay visible here so owners can restore or reorder them safely."
          actions={
            <WafloButton variant="secondary" disabled={actionPending} onClick={() => void loadWorkflow()}>
              Refresh
            </WafloButton>
          }
        />

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

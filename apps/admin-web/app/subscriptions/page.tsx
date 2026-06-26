import { AdminAuthBoundary } from '../components/AuthState';
import { AdminShell } from '../components/AdminShell';
import { WafloBadge, WafloPageHeader, WafloPanel, WafloTable } from '../components/waflo';
import { isClerkConfigured } from '../lib/config';
import { subscriptions } from '../mock-data';

export default function SubscriptionsPage() {
  const clerkConfigured = isClerkConfigured();

  return (
    <AdminShell>
      <AdminAuthBoundary clerkConfigured={clerkConfigured}>
        <div className="grid gap-6">
          <WafloPageHeader
            eyebrow="Billing"
            title="Subscriptions"
            description="Billing actions are not available in this dashboard yet. Menu and loyalty management are the launch focus."
          />
          <WafloPanel eyebrow="Plans" title="Billing tools are coming soon">
            <WafloTable
              columns={['Business', 'Plan', 'Status', 'Current period end']}
              rows={subscriptions.map((subscription) => [
                <span key="business" className="font-bold text-waflo-charcoal">{subscription.business}</span>,
                subscription.plan,
                <WafloBadge key="status" tone="gold">{subscription.status}</WafloBadge>,
                subscription.periodEnd
              ])}
            />
          </WafloPanel>
        </div>
      </AdminAuthBoundary>
    </AdminShell>
  );
}

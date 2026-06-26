import { AdminAuthBoundary } from '../components/AuthState';
import { AdminShell } from '../components/AdminShell';
import { OwnerContextPanel } from '../components/OwnerContextPanel';
import { WafloBadge, WafloPageHeader, WafloPanel, WafloTable } from '../components/waflo';
import { getPublicApiBaseUrl, isClerkConfigured } from '../lib/config';
import { businesses } from '../mock-data';

export default function BusinessesPage() {
  const clerkConfigured = isClerkConfigured();
  const apiBaseUrl = getPublicApiBaseUrl();

  return (
    <AdminShell>
      <AdminAuthBoundary clerkConfigured={clerkConfigured}>
        <div className="grid gap-6">
          <WafloPageHeader
            eyebrow="Settings"
            title="Businesses"
            description="Review the businesses connected to your account and prepare owner workflows for launch."
          />

          <OwnerContextPanel apiBaseUrl={apiBaseUrl} variant="businesses" />

          <WafloPanel
            eyebrow="Business management"
            title="Business tools are coming soon"
            description="You can view business access here today. Creating and editing businesses will be added to this owner dashboard later."
          >
            <WafloTable
              columns={['Name', 'Type', 'City', 'Status']}
              rows={businesses.map((business) => [
                <span key="name" className="font-bold text-waflo-charcoal">{business.name}</span>,
                business.type,
                business.city,
                <WafloBadge key="status" tone="green">{business.status}</WafloBadge>
              ])}
            />
          </WafloPanel>
        </div>
      </AdminAuthBoundary>
    </AdminShell>
  );
}

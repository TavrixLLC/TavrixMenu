import { AdminAuthBoundary } from '../components/AuthState';
import { AdminShell } from '../components/AdminShell';
import { LoyaltyPanel } from '../components/LoyaltyPanel';
import { getPublicApiBaseUrl, isClerkConfigured } from '../lib/config';

export default function LoyaltyPage() {
  const clerkConfigured = isClerkConfigured();
  const apiBaseUrl = getPublicApiBaseUrl();

  return (
    <AdminShell>
      <AdminAuthBoundary clerkConfigured={clerkConfigured}>
        <LoyaltyPanel apiBaseUrl={apiBaseUrl} />
      </AdminAuthBoundary>
    </AdminShell>
  );
}

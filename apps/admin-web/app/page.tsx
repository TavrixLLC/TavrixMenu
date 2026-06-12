import { AdminAuthBoundary } from './components/AuthState';
import { AdminShell } from './components/AdminShell';
import { OwnerWorkflowPanel } from './components/OwnerWorkflowPanel';
import { getPublicApiBaseUrl, isClerkConfigured } from './lib/config';

export default function DashboardPage() {
  const clerkConfigured = isClerkConfigured();
  const apiBaseUrl = getPublicApiBaseUrl();

  return (
    <AdminShell>
      <AdminAuthBoundary clerkConfigured={clerkConfigured}>
        <OwnerWorkflowPanel apiBaseUrl={apiBaseUrl} />
      </AdminAuthBoundary>
    </AdminShell>
  );
}

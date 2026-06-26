import { AdminAuthBoundary } from '../components/AuthState';
import { AdminShell } from '../components/AdminShell';
import { OwnerContextPanel } from '../components/OwnerContextPanel';
import { getPublicApiBaseUrl, isClerkConfigured } from '../lib/config';
import { businesses } from '../mock-data';

export default function BusinessesPage() {
  const clerkConfigured = isClerkConfigured();
  const apiBaseUrl = getPublicApiBaseUrl();

  return (
    <AdminShell>
      <AdminAuthBoundary clerkConfigured={clerkConfigured}>
        <div className="grid gap-6">
          <OwnerContextPanel apiBaseUrl={apiBaseUrl} variant="businesses" />

          <section className="rounded-lg border border-neutral-200 bg-white">
            <div className="border-b border-neutral-200 p-4">
              <p className="text-sm font-semibold uppercase text-accent">Business management</p>
              <h2 className="mt-2 text-xl font-bold text-ink">Business tools are coming soon</h2>
              <p className="mt-2 text-sm text-neutral-600">
                You can view business access here today. Creating and editing businesses will be added to this owner dashboard later.
              </p>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full min-w-[640px] text-left text-sm">
                <thead className="bg-neutral-50 text-neutral-500">
                  <tr>
                    <th className="px-4 py-3">Name</th>
                    <th className="px-4 py-3">Type</th>
                    <th className="px-4 py-3">City</th>
                    <th className="px-4 py-3">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {businesses.map((business) => (
                    <tr key={business.name} className="border-t border-neutral-100">
                      <td className="px-4 py-3 font-semibold text-ink">{business.name}</td>
                      <td className="px-4 py-3 text-neutral-600">{business.type}</td>
                      <td className="px-4 py-3 text-neutral-600">{business.city}</td>
                      <td className="px-4 py-3 text-neutral-600">{business.status}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>
        </div>
      </AdminAuthBoundary>
    </AdminShell>
  );
}

import { AdminAuthBoundary } from '../components/AuthState';
import { AdminShell } from '../components/AdminShell';
import { isClerkConfigured } from '../lib/config';
import { subscriptions } from '../mock-data';

export default function SubscriptionsPage() {
  const clerkConfigured = isClerkConfigured();

  return (
    <AdminShell>
      <AdminAuthBoundary clerkConfigured={clerkConfigured}>
        <section className="rounded-lg border border-neutral-200 bg-white">
          <div className="border-b border-neutral-200 p-4">
            <p className="text-sm font-semibold uppercase text-accent">Subscriptions</p>
            <h2 className="mt-2 text-xl font-bold text-ink">Billing tools are coming soon</h2>
            <p className="mt-2 text-sm text-neutral-600">
              Billing actions are not available in this dashboard yet. Menu and loyalty management are the launch focus.
            </p>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[640px] text-left text-sm">
              <thead className="bg-neutral-50 text-neutral-500">
                <tr>
                  <th className="px-4 py-3">Business</th>
                  <th className="px-4 py-3">Plan</th>
                  <th className="px-4 py-3">Status</th>
                  <th className="px-4 py-3">Current period end</th>
                </tr>
              </thead>
              <tbody>
                {subscriptions.map((subscription) => (
                  <tr key={subscription.business} className="border-t border-neutral-100">
                    <td className="px-4 py-3 font-semibold text-ink">{subscription.business}</td>
                    <td className="px-4 py-3 text-neutral-600">{subscription.plan}</td>
                    <td className="px-4 py-3 text-neutral-600">{subscription.status}</td>
                    <td className="px-4 py-3 text-neutral-600">{subscription.periodEnd}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </AdminAuthBoundary>
    </AdminShell>
  );
}

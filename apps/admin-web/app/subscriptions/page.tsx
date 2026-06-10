import { AdminShell, EmptyState, PendingIntegrationBanner, StatusBadge } from '../components/AdminShell';
import { subscriptions } from '../mock-data';

export default function SubscriptionsPage() {
  return (
    <AdminShell
      title="Subscriptions"
      description="Internal subscription monitoring shell. Billing provider sync and service-owner actions are intentionally disabled until backend support exists."
    >
      <PendingIntegrationBanner />

      <section className="grid gap-4 sm:grid-cols-3">
        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <p className="text-sm font-bold text-neutral-500">Active plans</p>
          <p className="mt-2 text-2xl font-extrabold text-ink">
            {subscriptions.filter((subscription) => subscription.status === 'ACTIVE').length}
          </p>
        </article>
        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <p className="text-sm font-bold text-neutral-500">Trials</p>
          <p className="mt-2 text-2xl font-extrabold text-ink">
            {subscriptions.filter((subscription) => subscription.status === 'TRIALING').length}
          </p>
        </article>
        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <p className="text-sm font-bold text-neutral-500">Past due</p>
          <p className="mt-2 text-2xl font-extrabold text-ink">
            {subscriptions.filter((subscription) => subscription.status === 'PAST_DUE').length}
          </p>
        </article>
      </section>

      <section className="mt-6 rounded-lg border border-neutral-200 bg-white shadow-sm">
        <div className="flex flex-col gap-2 border-b border-neutral-200 p-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-xl font-extrabold text-ink">Subscription ledger</h2>
            <p className="mt-1 text-sm text-neutral-500">Mock/dev rows only. No billing actions are wired.</p>
          </div>
          <span className="rounded-full border border-amber-200 bg-amber-50 px-3 py-1 text-xs font-extrabold text-amber-700">
            Pending backend
          </span>
        </div>
        {subscriptions.length === 0 ? (
          <div className="p-4">
            <EmptyState title="No subscriptions loaded" message="Connect an admin billing endpoint to populate this table." />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full min-w-[720px] text-left text-sm">
              <thead className="bg-neutral-50 text-neutral-500">
                <tr>
                  <th className="px-4 py-3 font-extrabold">Business</th>
                  <th className="px-4 py-3 font-extrabold">Plan</th>
                  <th className="px-4 py-3 font-extrabold">Amount</th>
                  <th className="px-4 py-3 font-extrabold">Current period end</th>
                  <th className="px-4 py-3 font-extrabold">Status</th>
                </tr>
              </thead>
              <tbody>
                {subscriptions.map((subscription) => (
                  <tr key={subscription.business} className="border-t border-neutral-100">
                    <td className="px-4 py-3 font-bold text-ink">{subscription.business}</td>
                    <td className="px-4 py-3 text-neutral-600">{subscription.plan}</td>
                    <td className="px-4 py-3 text-neutral-600">{subscription.amount}</td>
                    <td className="px-4 py-3 text-neutral-600">{subscription.periodEnd}</td>
                    <td className="px-4 py-3">
                      <StatusBadge status={subscription.status} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </AdminShell>
  );
}

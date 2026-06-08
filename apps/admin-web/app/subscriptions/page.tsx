import { AdminShell } from '../components/AdminShell';
import { subscriptions } from '../mock-data';

export default function SubscriptionsPage() {
  return (
    <AdminShell>
      <section className="rounded-lg border border-neutral-200 bg-white">
        <div className="border-b border-neutral-200 p-4">
          <h2 className="text-xl font-bold text-ink">Subscriptions</h2>
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
    </AdminShell>
  );
}

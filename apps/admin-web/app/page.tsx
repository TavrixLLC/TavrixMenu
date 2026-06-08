import { AdminShell } from './components/AdminShell';
import { businesses, logs, stats, subscriptions } from './mock-data';

export default function DashboardPage() {
  return (
    <AdminShell>
      <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <article key={stat.label} className="rounded-lg border border-neutral-200 bg-white p-4">
            <p className="text-sm font-semibold text-neutral-500">{stat.label}</p>
            <p className="mt-3 text-3xl font-bold text-ink">{stat.value}</p>
          </article>
        ))}
      </section>

      <section className="mt-6 grid gap-4 lg:grid-cols-2">
        <article className="rounded-lg border border-neutral-200 bg-white p-4">
          <h2 className="text-lg font-bold text-ink">Businesses table placeholder</h2>
          <div className="mt-4 grid gap-3">
            {businesses.map((business) => (
              <div key={business.name} className="flex items-center justify-between gap-3 border-t border-neutral-100 pt-3">
                <div>
                  <p className="font-semibold text-ink">{business.name}</p>
                  <p className="text-sm text-neutral-500">{business.type}</p>
                </div>
                <span className="text-sm font-semibold text-neutral-600">{business.status}</span>
              </div>
            ))}
          </div>
        </article>

        <article className="rounded-lg border border-neutral-200 bg-white p-4">
          <h2 className="text-lg font-bold text-ink">Subscription status placeholder</h2>
          <div className="mt-4 grid gap-3">
            {subscriptions.map((subscription) => (
              <div key={subscription.business} className="flex items-center justify-between gap-3 border-t border-neutral-100 pt-3">
                <div>
                  <p className="font-semibold text-ink">{subscription.business}</p>
                  <p className="text-sm text-neutral-500">{subscription.plan}</p>
                </div>
                <span className="text-sm font-semibold text-neutral-600">{subscription.status}</span>
              </div>
            ))}
          </div>
        </article>
      </section>

      <section className="mt-6 rounded-lg border border-neutral-200 bg-white p-4">
        <h2 className="text-lg font-bold text-ink">Recent logs placeholder</h2>
        <div className="mt-4 grid gap-3">
          {logs.map((log) => (
            <div key={`${log.action}-${log.business}`} className="grid gap-1 border-t border-neutral-100 pt-3 sm:grid-cols-3">
              <p className="font-semibold text-ink">{log.action}</p>
              <p className="text-sm text-neutral-500">{log.business}</p>
              <p className="text-sm text-neutral-500">{log.user}</p>
            </div>
          ))}
        </div>
      </section>
    </AdminShell>
  );
}

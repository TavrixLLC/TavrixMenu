import { AdminShell, PendingIntegrationBanner, StatusBadge } from './components/AdminShell';
import { businesses, integrationStates, logs, stats, subscriptions } from './mock-data';

export default function DashboardPage() {
  return (
    <AdminShell
      title="Operations dashboard"
      description="Internal overview for Tavrix service owners. The dashboard is intentionally read-only until backend admin APIs and production admin auth are available."
    >
      <PendingIntegrationBanner />

      <section className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <article key={stat.label} className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
            <p className="text-sm font-bold text-neutral-500">{stat.label}</p>
            <p className="mt-3 text-3xl font-extrabold text-ink">{stat.value}</p>
            <p className="mt-2 text-xs font-semibold text-neutral-500">{stat.detail}</p>
          </article>
        ))}
      </section>

      <section className="mt-6 grid gap-4 lg:grid-cols-2">
        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <div className="flex items-start justify-between gap-3">
            <div>
              <h2 className="text-lg font-extrabold text-ink">Business review queue</h2>
              <p className="mt-1 text-sm text-neutral-500">Sample records pending live admin endpoints.</p>
            </div>
            <StatusBadge status="PENDING" />
          </div>
          <div className="mt-4 grid gap-3">
            {businesses.map((business) => (
              <div key={business.name} className="flex items-center justify-between gap-3 border-t border-neutral-100 pt-3">
                <div>
                  <p className="font-bold text-ink">{business.name}</p>
                  <p className="text-sm text-neutral-500">{business.type} / {business.city}</p>
                </div>
                <StatusBadge status={business.status} />
              </div>
            ))}
          </div>
        </article>

        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <div className="flex items-start justify-between gap-3">
            <div>
              <h2 className="text-lg font-extrabold text-ink">Subscription status</h2>
              <p className="mt-1 text-sm text-neutral-500">Static shell values for billing review.</p>
            </div>
            <StatusBadge status="PENDING" />
          </div>
          <div className="mt-4 grid gap-3">
            {subscriptions.map((subscription) => (
              <div key={subscription.business} className="flex items-center justify-between gap-3 border-t border-neutral-100 pt-3">
                <div>
                  <p className="font-bold text-ink">{subscription.business}</p>
                  <p className="text-sm text-neutral-500">{subscription.plan} / {subscription.amount}</p>
                </div>
                <StatusBadge status={subscription.status} />
              </div>
            ))}
          </div>
        </article>
      </section>

      <section className="mt-6 grid gap-4 lg:grid-cols-[1.25fr_0.75fr]">
        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <h2 className="text-lg font-extrabold text-ink">Recent audit events</h2>
          <p className="mt-1 text-sm text-neutral-500">Representative log table until an admin logs endpoint exists.</p>
          <div className="mt-4 grid gap-3">
          {logs.map((log) => (
            <div key={`${log.action}-${log.business}`} className="grid gap-1 border-t border-neutral-100 pt-3 sm:grid-cols-3">
              <p className="font-bold text-ink">{log.action}</p>
              <p className="text-sm text-neutral-500">{log.business}</p>
              <div className="flex items-center gap-2">
                <StatusBadge status={log.severity} />
                <span className="text-sm text-neutral-500">{log.timestamp}</span>
              </div>
            </div>
          ))}
          </div>
        </article>

        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <h2 className="text-lg font-extrabold text-ink">Integration readiness</h2>
          <div className="mt-4 grid gap-3">
            {integrationStates.map((integration) => (
              <div key={integration.label} className="border-t border-neutral-100 pt-3">
                <div className="flex items-center justify-between gap-3">
                  <p className="font-bold text-ink">{integration.label}</p>
                  <span className="rounded-full border border-amber-200 bg-amber-50 px-2 py-1 text-xs font-extrabold text-amber-700">
                    {integration.state}
                  </span>
                </div>
                <p className="mt-1 text-sm leading-6 text-neutral-500">{integration.detail}</p>
              </div>
            ))}
          </div>
        </article>
      </section>
    </AdminShell>
  );
}

import { AdminShell, EmptyState, PendingIntegrationBanner, StatusBadge } from '../components/AdminShell';
import { businesses } from '../mock-data';

export default function BusinessesPage() {
  return (
    <AdminShell
      title="Businesses"
      description="Internal business registry shell for service-owner review. Records are static until a dedicated admin business API is available."
    >
      <PendingIntegrationBanner />

      <section className="grid gap-4 sm:grid-cols-3">
        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <p className="text-sm font-bold text-neutral-500">Active</p>
          <p className="mt-2 text-2xl font-extrabold text-ink">
            {businesses.filter((business) => business.status === 'ACTIVE').length}
          </p>
        </article>
        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <p className="text-sm font-bold text-neutral-500">Pending review</p>
          <p className="mt-2 text-2xl font-extrabold text-ink">
            {businesses.filter((business) => business.status === 'PENDING').length}
          </p>
        </article>
        <article className="rounded-lg border border-neutral-200 bg-white p-4 shadow-sm">
          <p className="text-sm font-bold text-neutral-500">Suspended</p>
          <p className="mt-2 text-2xl font-extrabold text-ink">
            {businesses.filter((business) => business.status === 'SUSPENDED').length}
          </p>
        </article>
      </section>

      <section className="mt-6 rounded-lg border border-neutral-200 bg-white shadow-sm">
        <div className="flex flex-col gap-2 border-b border-neutral-200 p-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-xl font-extrabold text-ink">Business registry</h2>
            <p className="mt-1 text-sm text-neutral-500">Mock/dev rows only. Live moderation actions are not enabled.</p>
          </div>
          <span className="rounded-full border border-amber-200 bg-amber-50 px-3 py-1 text-xs font-extrabold text-amber-700">
            Pending backend
          </span>
        </div>
        {businesses.length === 0 ? (
          <div className="p-4">
            <EmptyState title="No businesses loaded" message="Connect an admin business endpoint to populate this table." />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full min-w-[760px] text-left text-sm">
              <thead className="bg-neutral-50 text-neutral-500">
                <tr>
                  <th className="px-4 py-3 font-extrabold">Name</th>
                  <th className="px-4 py-3 font-extrabold">Slug</th>
                  <th className="px-4 py-3 font-extrabold">Type</th>
                  <th className="px-4 py-3 font-extrabold">City</th>
                  <th className="px-4 py-3 font-extrabold">Owner</th>
                  <th className="px-4 py-3 font-extrabold">Updated</th>
                  <th className="px-4 py-3 font-extrabold">Status</th>
                </tr>
              </thead>
              <tbody>
                {businesses.map((business) => (
                  <tr key={business.name} className="border-t border-neutral-100">
                    <td className="px-4 py-3 font-bold text-ink">{business.name}</td>
                    <td className="px-4 py-3 font-mono text-xs text-neutral-600">{business.slug}</td>
                    <td className="px-4 py-3 text-neutral-600">{business.type}</td>
                    <td className="px-4 py-3 text-neutral-600">{business.city}</td>
                    <td className="px-4 py-3 text-neutral-600">{business.owner}</td>
                    <td className="px-4 py-3 text-neutral-600">{business.lastUpdated}</td>
                    <td className="px-4 py-3">
                      <StatusBadge status={business.status} />
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

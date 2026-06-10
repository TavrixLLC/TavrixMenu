import { AdminShell, EmptyState, PendingIntegrationBanner, StatusBadge } from '../components/AdminShell';
import { logs } from '../mock-data';

export default function LogsPage() {
  return (
    <AdminShell
      title="Audit logs"
      description="Internal event log shell for Tavrix service owners. Entries are sample records until a backend admin logs endpoint is available."
    >
      <PendingIntegrationBanner />

      <section className="rounded-lg border border-neutral-200 bg-white shadow-sm">
        <div className="flex flex-col gap-2 border-b border-neutral-200 p-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-xl font-extrabold text-ink">Recent events</h2>
            <p className="mt-1 text-sm text-neutral-500">Mock/dev rows only. No live audit stream is connected.</p>
          </div>
          <span className="rounded-full border border-amber-200 bg-amber-50 px-3 py-1 text-xs font-extrabold text-amber-700">
            Pending backend
          </span>
        </div>
        {logs.length === 0 ? (
          <div className="p-4">
            <EmptyState title="No logs loaded" message="Connect an admin logs endpoint to populate this table." />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full min-w-[760px] text-left text-sm">
              <thead className="bg-neutral-50 text-neutral-500">
                <tr>
                  <th className="px-4 py-3 font-extrabold">Time</th>
                  <th className="px-4 py-3 font-extrabold">Severity</th>
                  <th className="px-4 py-3 font-extrabold">Action</th>
                  <th className="px-4 py-3 font-extrabold">Business</th>
                  <th className="px-4 py-3 font-extrabold">Actor</th>
                </tr>
              </thead>
              <tbody>
                {logs.map((log) => (
                  <tr key={`${log.action}-${log.business}-${log.timestamp}`} className="border-t border-neutral-100">
                    <td className="px-4 py-3 font-mono text-xs text-neutral-600">{log.timestamp}</td>
                    <td className="px-4 py-3">
                      <StatusBadge status={log.severity} />
                    </td>
                    <td className="px-4 py-3 font-bold text-ink">{log.action}</td>
                    <td className="px-4 py-3 text-neutral-600">{log.business}</td>
                    <td className="px-4 py-3 text-neutral-600">{log.user}</td>
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

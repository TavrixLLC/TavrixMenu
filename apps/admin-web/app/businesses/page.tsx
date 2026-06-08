import { AdminShell } from '../components/AdminShell';
import { businesses } from '../mock-data';

export default function BusinessesPage() {
  return (
    <AdminShell>
      <section className="rounded-lg border border-neutral-200 bg-white">
        <div className="border-b border-neutral-200 p-4">
          <h2 className="text-xl font-bold text-ink">Businesses</h2>
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
    </AdminShell>
  );
}

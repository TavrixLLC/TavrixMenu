import Link from 'next/link';
import type { ReactNode } from 'react';

const navItems = [
  { href: '/', label: 'Dashboard' },
  { href: '/businesses', label: 'Businesses' },
  { href: '/subscriptions', label: 'Subscriptions' },
  { href: '/logs', label: 'Logs' }
];

const badgeClassByStatus: Record<string, string> = {
  ACTIVE: 'border-emerald-200 bg-emerald-50 text-emerald-700',
  PENDING: 'border-amber-200 bg-amber-50 text-amber-700',
  SUSPENDED: 'border-red-200 bg-red-50 text-red-700',
  TRIALING: 'border-sky-200 bg-sky-50 text-sky-700',
  PAST_DUE: 'border-red-200 bg-red-50 text-red-700',
  INFO: 'border-blue-200 bg-blue-50 text-blue-700',
  WARN: 'border-amber-200 bg-amber-50 text-amber-700'
};

type AdminShellProps = Readonly<{
  title: string;
  description: string;
  children: ReactNode;
}>;

export function AdminShell({ title, description, children }: AdminShellProps) {
  return (
    <main className="min-h-screen bg-[#f6f7f9]">
      <header className="border-b border-neutral-200 bg-white">
        <div className="mx-auto flex w-full max-w-6xl flex-col gap-4 px-4 py-4 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <p className="text-sm font-bold text-accent">Tavrix Menu Internal</p>
            <h1 className="text-2xl font-extrabold text-ink">Service Admin</h1>
          </div>
          <nav className="flex flex-wrap gap-2" aria-label="Admin navigation">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-bold text-neutral-700 shadow-sm hover:border-accent hover:text-accent"
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </div>
      </header>
      <div className="mx-auto w-full max-w-6xl px-4 py-6">
        <section className="mb-6">
          <p className="text-sm font-bold text-accent">Sprint 2 admin shell</p>
          <h2 className="mt-1 text-3xl font-extrabold text-ink">{title}</h2>
          <p className="mt-2 max-w-3xl text-sm leading-6 text-neutral-600">{description}</p>
        </section>
        {children}
      </div>
    </main>
  );
}

export function PendingIntegrationBanner() {
  return (
    <section className="mb-6 rounded-lg border border-dashed border-amber-300 bg-amber-50 p-4">
      <p className="text-sm font-extrabold text-amber-800">Pending backend integration</p>
      <p className="mt-1 text-sm leading-6 text-amber-800">
        This admin surface is a safe internal shell. Data shown here is mock/dev data until dedicated backend admin
        endpoints and production admin authorization are available.
      </p>
    </section>
  );
}

export function StatusBadge({ status }: { status: string }) {
  const className = badgeClassByStatus[status] || 'border-neutral-200 bg-neutral-50 text-neutral-600';

  return (
    <span className={`inline-flex rounded-full border px-2 py-1 text-xs font-extrabold ${className}`}>
      {status}
    </span>
  );
}

export function EmptyState({ title, message }: { title: string; message: string }) {
  return (
    <div className="rounded-lg border border-dashed border-neutral-300 bg-neutral-50 p-6 text-center">
      <p className="font-extrabold text-ink">{title}</p>
      <p className="mt-2 text-sm leading-6 text-neutral-600">{message}</p>
    </div>
  );
}

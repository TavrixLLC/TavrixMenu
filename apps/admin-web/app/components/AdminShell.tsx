import Link from 'next/link';
import { getAppEnv, isClerkConfigured } from '../lib/config';
import { AdminAuthControls } from './AuthState';

const navItems = [
  { href: '/', label: 'Dashboard' },
  { href: '/loyalty', label: 'Loyalty' },
  { href: '/businesses', label: 'Businesses' },
  { href: '/subscriptions', label: 'Subscriptions' },
  { href: '/logs', label: 'Logs' }
];

export function AdminShell({ children }: Readonly<{ children: React.ReactNode }>) {
  const appEnv = getAppEnv();
  const clerkConfigured = isClerkConfigured();

  return (
    <main className="min-h-screen bg-[#f6f7f9]">
      <header className="border-b border-neutral-200 bg-white">
        <div className="mx-auto flex w-full max-w-6xl flex-col gap-4 px-4 py-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-sm font-semibold text-accent">Tavrix Menu</p>
            <h1 className="text-2xl font-bold text-ink">Service Admin</h1>
            <p className="mt-1 text-xs font-semibold uppercase text-neutral-500">
              {appEnv} - internal owner/admin shell
            </p>
          </div>
          <div className="flex flex-col gap-3 sm:items-end">
            <AdminAuthControls clerkConfigured={clerkConfigured} />
            <nav className="flex flex-wrap gap-2">
              {navItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-semibold text-neutral-700"
                >
                  {item.label}
                </Link>
              ))}
            </nav>
          </div>
        </div>
      </header>
      <div className="mx-auto w-full max-w-6xl px-4 py-6">{children}</div>
    </main>
  );
}

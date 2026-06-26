import Link from 'next/link';
import { getAppEnv, isClerkConfigured } from '../lib/config';
import { AdminNavigation, Breadcrumbs } from './AdminNavigation';
import { AdminAuthControls } from './AuthState';

export function AdminShell({ children }: Readonly<{ children: React.ReactNode }>) {
  const appEnv = getAppEnv();
  const clerkConfigured = isClerkConfigured();

  return (
    <main className="min-h-screen bg-waflo-cream">
      <div className="mx-auto grid min-h-screen w-full max-w-[1440px] lg:grid-cols-[280px_minmax(0,1fr)]">
        <aside className="hidden border-r border-waflo-border/80 bg-white/88 px-4 py-5 backdrop-blur lg:block">
          <Link href="/" className="flex items-center gap-3 rounded-xl p-2 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-waflo-coral">
            <span className="grid h-10 w-10 place-items-center rounded-xl bg-waflo-charcoal text-sm font-black text-white shadow-subtle">
              W
            </span>
            <span>
              <span className="block text-sm font-bold text-waflo-charcoal">Waflo</span>
              <span className="block text-xs font-semibold uppercase text-waflo-muted">{appEnv} workspace</span>
            </span>
          </Link>

          <div className="mt-8">
            <p className="px-3 text-xs font-bold uppercase tracking-wide text-waflo-muted">Operate</p>
            <div className="mt-3">
              <AdminNavigation />
            </div>
          </div>

          <section className="mt-8 rounded-xl border border-waflo-border bg-waflo-cream p-4">
            <p className="text-xs font-bold uppercase tracking-wide text-waflo-coral">Launch readiness</p>
            <p className="mt-2 text-sm font-semibold leading-6 text-waflo-charcoal">
              Keep public menus, loyalty, and wallet appearance pilot-ready.
            </p>
          </section>
        </aside>

        <section className="min-w-0">
          <header className="sticky top-0 z-30 border-b border-waflo-border/80 bg-white/90 backdrop-blur">
            <div className="flex min-h-16 items-center justify-between gap-4 px-4 py-3 sm:px-6">
              <div className="min-w-0">
                <div className="lg:hidden">
                  <Link href="/" className="inline-flex min-h-11 items-center rounded-lg text-base font-black text-waflo-charcoal focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-waflo-coral">
                    Waflo
                  </Link>
                </div>
                <div className="hidden lg:block">
                  <Breadcrumbs />
                </div>
              </div>
              <AdminAuthControls clerkConfigured={clerkConfigured} />
            </div>
            <div className="border-t border-waflo-border/70 px-4 py-2 sm:px-6 lg:hidden">
              <AdminNavigation />
            </div>
          </header>

          <div className="px-4 py-6 sm:px-6 lg:px-8">{children}</div>
        </section>
      </div>
    </main>
  );
}

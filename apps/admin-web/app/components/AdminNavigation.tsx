'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const navItems = [
  { href: '/', label: 'Dashboard', icon: 'D' },
  { href: '/loyalty', label: 'Loyalty', icon: 'L' },
  { href: '/businesses', label: 'Businesses', icon: 'B' },
  { href: '/subscriptions', label: 'Billing', icon: 'P' },
  { href: '/logs', label: 'Activity', icon: 'A' }
];

function isActive(pathname: string, href: string) {
  if (href === '/') {
    return pathname === '/';
  }

  return pathname === href || pathname.startsWith(`${href}/`);
}

export function AdminNavigation() {
  const pathname = usePathname();

  return (
    <nav aria-label="Primary navigation" className="grid gap-1">
      {navItems.map((item) => {
        const active = isActive(pathname, item.href);

        return (
          <Link
            key={item.href}
            href={item.href}
            aria-current={active ? 'page' : undefined}
            className={`group flex min-h-11 items-center gap-3 rounded-lg px-3 py-2 text-sm font-semibold transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-waflo-coral focus-visible:ring-offset-2 ${
              active
                ? 'bg-waflo-charcoal text-white shadow-subtle'
                : 'text-waflo-muted hover:bg-waflo-cream hover:text-waflo-charcoal'
            }`}
          >
            <span
              className={`grid h-7 w-7 place-items-center rounded-md text-xs font-bold ${
                active ? 'bg-white/15 text-white' : 'bg-white text-waflo-coral ring-1 ring-waflo-border group-hover:ring-waflo-coral/30'
              }`}
              aria-hidden="true"
            >
              {item.icon}
            </span>
            {item.label}
          </Link>
        );
      })}
    </nav>
  );
}

export function Breadcrumbs() {
  const pathname = usePathname();
  const current = navItems.find((item) => isActive(pathname, item.href));

  return (
    <nav aria-label="Breadcrumb" className="text-sm font-semibold text-waflo-muted">
      <ol className="flex flex-wrap items-center gap-2">
        <li>Waflo</li>
        <li aria-hidden="true" className="text-waflo-border">
          /
        </li>
        <li className="text-waflo-charcoal">{current?.label || 'Workspace'}</li>
      </ol>
    </nav>
  );
}

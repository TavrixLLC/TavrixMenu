import Link from 'next/link';
import type { ButtonHTMLAttributes, InputHTMLAttributes, ReactNode, SelectHTMLAttributes } from 'react';

type Tone = 'neutral' | 'coral' | 'green' | 'gold' | 'red' | 'charcoal';
type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';

const toneClasses: Record<Tone, string> = {
  neutral: 'bg-waflo-cream text-waflo-muted ring-waflo-border',
  coral: 'bg-waflo-coralSoft text-waflo-coralDark ring-waflo-coral/25',
  green: 'bg-waflo-greenSoft text-waflo-greenDark ring-waflo-green/25',
  gold: 'bg-waflo-goldSoft text-waflo-goldDark ring-waflo-gold/25',
  red: 'bg-waflo-redSoft text-waflo-red ring-waflo-red/20',
  charcoal: 'bg-waflo-charcoal text-white ring-waflo-charcoal'
};

const buttonClasses: Record<ButtonVariant, string> = {
  primary:
    'bg-waflo-charcoal text-white shadow-premium hover:-translate-y-0.5 hover:bg-[#17212b] focus-visible:ring-waflo-coral',
  secondary:
    'border border-waflo-border bg-white text-waflo-charcoal shadow-subtle hover:-translate-y-0.5 hover:border-waflo-coral/40 hover:bg-waflo-cream focus-visible:ring-waflo-coral',
  ghost:
    'text-waflo-muted hover:bg-waflo-cream hover:text-waflo-charcoal focus-visible:ring-waflo-coral',
  danger:
    'bg-waflo-red text-white shadow-subtle hover:-translate-y-0.5 hover:bg-[#b91c1c] focus-visible:ring-waflo-red'
};

function cx(...values: Array<string | false | null | undefined>) {
  return values.filter(Boolean).join(' ');
}

export function WafloButton({
  children,
  className,
  variant = 'primary',
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
}) {
  return (
    <button
      type="button"
      className={cx(
        'inline-flex min-h-11 items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-semibold transition duration-150 ease-out focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:translate-y-0 disabled:opacity-50',
        buttonClasses[variant],
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
}

export function WafloLinkButton({
  children,
  className,
  href,
  variant = 'secondary'
}: {
  children: ReactNode;
  className?: string;
  href: string;
  variant?: ButtonVariant;
}) {
  return (
    <Link
      href={href}
      className={cx(
        'inline-flex min-h-11 items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-semibold transition duration-150 ease-out focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-waflo-coral focus-visible:ring-offset-2',
        buttonClasses[variant],
        className
      )}
    >
      {children}
    </Link>
  );
}

export function WafloCard({
  children,
  className,
  interactive = false
}: {
  children: ReactNode;
  className?: string;
  interactive?: boolean;
}) {
  return (
    <article
      className={cx(
        'rounded-xl border border-waflo-border bg-white shadow-subtle',
        interactive && 'transition duration-150 hover:-translate-y-0.5 hover:border-waflo-coral/35 hover:shadow-premium',
        className
      )}
    >
      {children}
    </article>
  );
}

export function WafloPanel({
  actions,
  children,
  className,
  eyebrow,
  title,
  description
}: {
  actions?: ReactNode;
  children?: ReactNode;
  className?: string;
  eyebrow?: string;
  title: string;
  description?: string;
}) {
  return (
    <WafloCard className={className}>
      <div className="border-b border-waflo-border/80 p-5">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
          <div>
            {eyebrow ? <p className="text-xs font-bold uppercase tracking-wide text-waflo-coral">{eyebrow}</p> : null}
            <h2 className="mt-1 text-xl font-bold text-waflo-charcoal">{title}</h2>
            {description ? <p className="mt-2 max-w-3xl text-sm leading-6 text-waflo-muted">{description}</p> : null}
          </div>
          {actions ? <div className="flex flex-wrap gap-2">{actions}</div> : null}
        </div>
      </div>
      {children ? <div className="p-5">{children}</div> : null}
    </WafloCard>
  );
}

export function WafloMetricCard({
  label,
  value,
  detail,
  tone = 'neutral'
}: {
  label: string;
  value: ReactNode;
  detail?: string;
  tone?: Tone;
}) {
  return (
    <WafloCard className="p-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-sm font-semibold text-waflo-muted">{label}</p>
          <p className="mt-3 text-3xl font-bold tracking-tight text-waflo-charcoal">{value}</p>
          {detail ? <p className="mt-2 text-xs font-semibold text-waflo-muted">{detail}</p> : null}
        </div>
        <span className={cx('h-2.5 w-2.5 rounded-full ring-4', toneClasses[tone])} />
      </div>
    </WafloCard>
  );
}

export function WafloInput({
  className,
  label,
  error,
  helper,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & {
  label?: string;
  error?: string | null;
  helper?: string;
}) {
  return (
    <label className="grid gap-2 text-sm font-semibold text-waflo-charcoal">
      {label}
      <input
        className={cx(
          'min-h-11 rounded-lg border border-waflo-border bg-white px-3 py-2 text-sm font-normal text-waflo-charcoal outline-none transition focus:border-waflo-coral focus:ring-4 focus:ring-waflo-coral/15 disabled:bg-waflo-cream disabled:text-waflo-muted',
          error && 'border-waflo-red focus:border-waflo-red focus:ring-waflo-red/15',
          className
        )}
        aria-invalid={error ? true : undefined}
        {...props}
      />
      {helper ? <span className="text-xs font-medium leading-5 text-waflo-muted">{helper}</span> : null}
      {error ? <span className="text-xs font-semibold leading-5 text-waflo-red">{error}</span> : null}
    </label>
  );
}

export function WafloSelect({
  children,
  className,
  label,
  error,
  helper,
  ...props
}: SelectHTMLAttributes<HTMLSelectElement> & {
  label?: string;
  error?: string | null;
  helper?: string;
}) {
  return (
    <label className="grid gap-2 text-sm font-semibold text-waflo-charcoal">
      {label}
      <select
        className={cx(
          'min-h-11 rounded-lg border border-waflo-border bg-white px-3 py-2 text-sm font-normal text-waflo-charcoal outline-none transition focus:border-waflo-coral focus:ring-4 focus:ring-waflo-coral/15 disabled:bg-waflo-cream disabled:text-waflo-muted',
          error && 'border-waflo-red focus:border-waflo-red focus:ring-waflo-red/15',
          className
        )}
        aria-invalid={error ? true : undefined}
        {...props}
      >
        {children}
      </select>
      {helper ? <span className="text-xs font-medium leading-5 text-waflo-muted">{helper}</span> : null}
      {error ? <span className="text-xs font-semibold leading-5 text-waflo-red">{error}</span> : null}
    </label>
  );
}

export function WafloBadge({
  children,
  tone = 'neutral'
}: {
  children: ReactNode;
  tone?: Tone;
}) {
  return (
    <span className={cx('inline-flex items-center rounded-full px-2.5 py-1 text-xs font-bold ring-1', toneClasses[tone])}>
      {children}
    </span>
  );
}

export function WafloToast({
  children,
  tone = 'neutral'
}: {
  children: ReactNode;
  tone?: Tone;
}) {
  return (
    <div className={cx('rounded-xl border p-4 text-sm font-semibold shadow-subtle', toneClasses[tone].replace('ring-', 'border-'))} role="status">
      {children}
    </div>
  );
}

export function WafloTable({
  columns,
  rows,
  empty
}: {
  columns: string[];
  rows: ReactNode[][];
  empty?: ReactNode;
}) {
  if (rows.length === 0) {
    return <div className="rounded-xl border border-dashed border-waflo-border p-5">{empty || 'No records yet.'}</div>;
  }

  return (
    <div className="overflow-hidden rounded-xl border border-waflo-border">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-waflo-border text-left text-sm">
          <thead className="bg-waflo-cream/80 text-xs font-bold uppercase tracking-wide text-waflo-muted">
            <tr>
              {columns.map((column) => (
                <th key={column} className="px-4 py-3">
                  {column}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-waflo-border bg-white">
            {rows.map((row, rowIndex) => (
              <tr key={rowIndex} className="transition hover:bg-waflo-cream/50">
                {row.map((cell, cellIndex) => (
                  <td key={cellIndex} className="px-4 py-3 align-top">
                    {cell}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export function WafloSection({
  children,
  className
}: {
  children: ReactNode;
  className?: string;
}) {
  return <section className={cx('grid gap-4', className)}>{children}</section>;
}

export function WafloPageHeader({
  actions,
  eyebrow,
  title,
  description,
  meta
}: {
  actions?: ReactNode;
  eyebrow?: string;
  title: string;
  description?: string;
  meta?: ReactNode;
}) {
  return (
    <header className="flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
      <div>
        {eyebrow ? <p className="text-xs font-bold uppercase tracking-wide text-waflo-coral">{eyebrow}</p> : null}
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-waflo-charcoal sm:text-4xl">{title}</h1>
        {description ? <p className="mt-3 max-w-3xl text-sm leading-6 text-waflo-muted">{description}</p> : null}
        {meta ? <div className="mt-4 flex flex-wrap gap-2">{meta}</div> : null}
      </div>
      {actions ? <div className="flex flex-wrap gap-2">{actions}</div> : null}
    </header>
  );
}

export function WafloEmptyState({
  title,
  description,
  action
}: {
  title: string;
  description?: string;
  action?: ReactNode;
}) {
  return (
    <div className="rounded-xl border border-dashed border-waflo-border bg-waflo-cream/50 p-6 text-center">
      <h3 className="text-base font-bold text-waflo-charcoal">{title}</h3>
      {description ? <p className="mx-auto mt-2 max-w-xl text-sm leading-6 text-waflo-muted">{description}</p> : null}
      {action ? <div className="mt-4 flex justify-center">{action}</div> : null}
    </div>
  );
}

export function WafloErrorState({
  title,
  description,
  action
}: {
  title: string;
  description?: string;
  action?: ReactNode;
}) {
  return (
    <div className="rounded-xl border border-waflo-red/20 bg-waflo-redSoft p-6">
      <p className="text-xs font-bold uppercase tracking-wide text-waflo-red">Needs attention</p>
      <h3 className="mt-2 text-xl font-bold text-waflo-charcoal">{title}</h3>
      {description ? <p className="mt-2 max-w-2xl text-sm leading-6 text-waflo-muted">{description}</p> : null}
      {action ? <div className="mt-4">{action}</div> : null}
    </div>
  );
}

export function WafloLoadingSkeleton({
  lines = 3
}: {
  lines?: number;
}) {
  return (
    <div className="grid gap-3 rounded-xl border border-waflo-border bg-white p-5" role="status" aria-label="Loading">
      {Array.from({ length: lines }, (_, index) => (
        <span
          key={index}
          className={cx('h-4 animate-pulse rounded-full bg-waflo-border', index === 0 ? 'w-2/3' : index === lines - 1 ? 'w-1/2' : 'w-full')}
        />
      ))}
    </div>
  );
}

export function WafloModal({
  children,
  title,
  open
}: {
  children: ReactNode;
  title: string;
  open: boolean;
}) {
  if (!open) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-waflo-charcoal/40 p-4" role="dialog" aria-modal="true" aria-label={title}>
      <WafloCard className="w-full max-w-lg p-5">{children}</WafloCard>
    </div>
  );
}

export function WafloDrawer({
  children,
  title,
  open
}: {
  children: ReactNode;
  title: string;
  open: boolean;
}) {
  if (!open) {
    return null;
  }

  return (
    <aside className="fixed inset-y-0 right-0 z-50 w-full max-w-md border-l border-waflo-border bg-white p-5 shadow-premium" role="dialog" aria-modal="true" aria-label={title}>
      {children}
    </aside>
  );
}

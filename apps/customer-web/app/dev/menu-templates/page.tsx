import Link from 'next/link';
import { publicMenuTemplates } from '../../lib/menu-templates';

export default function MenuTemplatePreviewPage() {
  return (
    <main className="min-h-screen bg-[#111827] text-white">
      <section className="mx-auto max-w-7xl px-4 py-6">
        <p className="text-sm font-semibold uppercase text-[#F59E0B]">CSS-first template preview</p>
        <h1 className="mt-1 text-3xl font-bold">Waflo public menu templates</h1>
        <p className="mt-3 max-w-3xl text-sm leading-6 text-white/70">
          Each preview iframe renders the same demo menu route and the same semantic public menu DOM. Only the selected CSS
          template changes.
        </p>
        <div className="mt-4 flex flex-wrap gap-2">
          {publicMenuTemplates.map((template) => (
            <Link
              key={template.id}
              href={`/dev/menu-templates/${template.id}`}
              className="rounded-full border border-white/20 px-3 py-2 text-sm font-semibold text-white"
            >
              {template.displayName}
            </Link>
          ))}
        </div>
      </section>

      <section className="mx-auto grid max-w-7xl gap-8 px-4 pb-10">
        {publicMenuTemplates.map((template) => (
          <article key={template.id} className="min-w-0 rounded-lg border border-white/15 bg-white/[0.03] p-4">
            <div className="flex min-w-0 flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
              <div className="min-w-0">
                <p className="text-sm font-semibold uppercase text-[#F59E0B]">{template.id}</p>
                <h2 className="mt-1 text-2xl font-bold">{template.displayName}</h2>
                <p className="mt-2 max-w-3xl text-sm leading-6 text-white/70">{template.description}</p>
              </div>
              <Link
                href={`/dev/menu-templates/${template.id}`}
                className="inline-flex w-fit rounded-md border border-white/20 px-3 py-2 text-sm font-semibold text-white"
              >
                Open full preview
              </Link>
            </div>

            <div className="mt-4 grid min-w-0 gap-4 xl:grid-cols-[390px_minmax(0,1fr)]">
              <div className="w-full max-w-[390px]">
                <p className="mb-2 text-xs font-semibold uppercase text-white/60">Mobile width</p>
                <iframe
                  title={`${template.displayName} mobile preview`}
                  src={`/dev/menu-templates/${template.id}`}
                  className="h-[720px] w-full rounded-lg border border-white/20 bg-white"
                />
              </div>
              <div className="min-w-0">
                <p className="mb-2 text-xs font-semibold uppercase text-white/60">Desktop width</p>
                <iframe
                  title={`${template.displayName} desktop preview`}
                  src={`/dev/menu-templates/${template.id}`}
                  className="h-[720px] w-full rounded-lg border border-white/20 bg-white"
                />
              </div>
            </div>
          </article>
        ))}
      </section>
    </main>
  );
}

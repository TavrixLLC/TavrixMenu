import Link from 'next/link';
import { PublicMenuTemplateView } from '../../components/PublicMenuTemplateView';
import { publicMenuTemplates } from '../../lib/menu-templates';
import { demoLoyalty, demoMenu } from './preview-data';

export default function MenuTemplatePreviewPage() {
  return (
    <main className="bg-[#111827]">
      <section className="mx-auto max-w-5xl px-4 py-5 text-white">
        <p className="text-sm font-semibold uppercase text-[#F59E0B]">Template preview</p>
        <h1 className="mt-1 text-2xl font-bold">Waflo public menu templates</h1>
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

      {publicMenuTemplates.map((template) => (
        <section key={template.id} className="border-b border-white/15">
          <div className="mx-auto max-w-5xl px-4 py-5 text-white">
            <p className="text-sm font-semibold uppercase text-[#F59E0B]">{template.id}</p>
            <h2 className="mt-1 text-2xl font-bold">{template.displayName}</h2>
            <p className="mt-2 max-w-3xl text-sm leading-6 text-white/70">{template.description}</p>
          </div>
          <PublicMenuTemplateView
            menu={{
              ...demoMenu,
              business: {
                ...demoMenu.business,
                menuTemplateId: template.id
              }
            }}
            template={template}
            loyaltyContext={demoLoyalty}
          />
        </section>
      ))}
    </main>
  );
}

import { PublicMenuTemplateView } from '../../../components/PublicMenuTemplateView';
import { getPublicMenuTemplate } from '../../../lib/menu-templates';
import { fetchPublicMenu } from '../../../lib/public-menu';
import { fetchPublicLoyaltyContext } from '../../../lib/public-loyalty';

type MenuPageProps = {
  params: Promise<{
    slug: string;
  }>;
};

function MenuState({
  title,
  message,
  detail
}: {
  title: string;
  message: string;
  detail?: string;
}) {
  return (
    <main className="flex min-h-screen items-center bg-cream px-4 py-12">
      <section className="mx-auto w-full max-w-xl rounded-xl border border-borderSoft bg-white p-6 shadow-sm">
        <p className="text-sm font-semibold uppercase text-coral">Public menu</p>
        <h1 className="mt-2 text-3xl font-bold text-ink">{title}</h1>
        <p className="mt-3 text-base leading-7 text-muted">{message}</p>
        {detail ? <p className="mt-4 rounded-md bg-[#FFF8F2] p-3 text-sm text-muted">{detail}</p> : null}
      </section>
    </main>
  );
}

export default async function MenuPage({ params }: MenuPageProps) {
  const { slug } = await params;
  const [menuResult, loyaltyResult] = await Promise.all([fetchPublicMenu(slug), fetchPublicLoyaltyContext(slug)]);

  if (menuResult.status === 'not-found') {
    return (
      <MenuState
        title="Menu not found"
        message="This business menu could not be found. Check the menu link and try again."
        detail={menuResult.apiUrl}
      />
    );
  }

  if (menuResult.status === 'error') {
    return (
      <MenuState
        title="Menu unavailable"
        message="The customer menu could not be loaded right now because the public API is unreachable or returned an error."
        detail={`${menuResult.apiUrl} - ${menuResult.message}`}
      />
    );
  }

  const menu = menuResult.data;
  const template = getPublicMenuTemplate(menu.business.menuTemplateId);
  const loyaltyContext = loyaltyResult.status === 'ok' ? loyaltyResult.data : null;

  return <PublicMenuTemplateView menu={menu} template={template} loyaltyContext={loyaltyContext} />;
}

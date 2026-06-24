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
  slug,
  title,
  message,
  state
}: {
  slug: string;
  title: string;
  message: string;
  state: 'not-found' | 'error';
}) {
  return (
    <main
      className="waflo-menu waflo-template-waflo-warm"
      data-template="waflo-warm"
      data-business-slug={slug}
      data-component="public-menu"
      data-state={state}
      data-dir="ltr"
      data-loyalty-enabled="false"
      lang="en"
      dir="ltr"
    >
      <section className="waflo-menu__shell" data-slot="merchant-shell" data-component="menu-shell">
        <div className="waflo-menu__state" data-slot="error-state" data-component="menu-state" data-state={state}>
          <p className="waflo-menu__eyebrow">Public menu</p>
          <h1>{title}</h1>
          <p>{message}</p>
        </div>
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
        slug={slug}
        title="Menu not found"
        message="This business menu could not be found. Check the menu link and try again."
        state="not-found"
      />
    );
  }

  if (menuResult.status === 'error') {
    return (
      <MenuState
        slug={slug}
        title="Menu unavailable"
        message="The customer menu could not be loaded right now because the public API is unreachable or returned an error."
        state="error"
      />
    );
  }

  const menu = menuResult.data;
  const template = getPublicMenuTemplate(menu.business.menuTemplateId);
  const loyaltyContext = loyaltyResult.status === 'ok' ? loyaltyResult.data : null;

  return <PublicMenuTemplateView menu={menu} template={template} loyaltyContext={loyaltyContext} />;
}

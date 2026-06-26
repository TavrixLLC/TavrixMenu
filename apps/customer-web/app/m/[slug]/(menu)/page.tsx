import { PublicMenuTemplateView } from '../../../components/PublicMenuTemplateView';
import { MENU_UNAVAILABLE_MESSAGE, MenuState } from '../../../components/PublicMenuStates';
import { getPublicMenuTemplate, isPublicMenuTemplateId } from '../../../lib/menu-templates';
import { fetchPublicMenu } from '../../../lib/public-menu';
import { fetchPublicLoyaltyContext } from '../../../lib/public-loyalty';

type MenuPageProps = {
  params: Promise<{
    slug: string;
  }>;
  searchParams?: Promise<{
    previewTemplateId?: string | string[];
  }>;
};

function readPreviewTemplateId(searchParams: { previewTemplateId?: string | string[] } | undefined) {
  const value = searchParams?.previewTemplateId;

  return Array.isArray(value) ? value[0] : value;
}

export default async function MenuPage({ params, searchParams }: MenuPageProps) {
  const { slug } = await params;
  const resolvedSearchParams = searchParams ? await searchParams : undefined;
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
        message={MENU_UNAVAILABLE_MESSAGE}
        state="error"
      />
    );
  }

  const menu = menuResult.data;
  const previewTemplateId = readPreviewTemplateId(resolvedSearchParams);
  const template = getPublicMenuTemplate(
    previewTemplateId && isPublicMenuTemplateId(previewTemplateId)
      ? previewTemplateId
      : menu.appearance.effectiveTemplateId
  );
  const loyaltyContext = loyaltyResult.status === 'ok' ? loyaltyResult.data : null;

  return <PublicMenuTemplateView menu={menu} template={template} loyaltyContext={loyaltyContext} />;
}

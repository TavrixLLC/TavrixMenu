import Link from 'next/link';
import { PlaceholderImage } from '../../../../components/PlaceholderImage';
import { formatPrice, getCategoryName, getItemDescription, getItemName, isRtlLanguage } from '../../../../lib/menu-format';
import { getPublicMenuTemplate } from '../../../../lib/menu-templates';
import { fetchPublicItem, fetchPublicMenu } from '../../../../lib/public-menu';

type ProductDetailPageProps = {
  params: Promise<{
    slug: string;
    itemId: string;
  }>;
};

function DetailState({
  slug,
  title,
  message,
  detail
}: {
  slug: string;
  title: string;
  message: string;
  detail?: string;
}) {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col justify-center bg-cream px-4 py-12">
      <Link href={`/m/${slug}`} className="text-sm font-semibold text-muted">
        Back to menu
      </Link>
      <section className="mt-5 rounded-xl border border-borderSoft bg-white p-6 shadow-sm">
        <p className="text-sm font-semibold uppercase text-coral">Menu item</p>
        <h1 className="mt-2 text-3xl font-bold text-ink">{title}</h1>
        <p className="mt-3 text-base leading-7 text-muted">{message}</p>
        {detail ? <p className="mt-4 rounded-md bg-[#FFF8F2] p-3 text-sm text-muted">{detail}</p> : null}
      </section>
    </main>
  );
}

export default async function ProductDetailPage({ params }: ProductDetailPageProps) {
  const { slug, itemId } = await params;
  const itemResult = await fetchPublicItem(slug, itemId);

  if (itemResult.status === 'not-found') {
    return (
      <DetailState
        slug={slug}
        title="Item not found"
        message="This menu item is unavailable or does not exist on the public menu."
        detail={itemResult.apiUrl}
      />
    );
  }

  if (itemResult.status === 'error') {
    return (
      <DetailState
        slug={slug}
        title="Menu unavailable"
        message="The menu item could not be loaded right now because the public API is unreachable or returned an error."
        detail={`${itemResult.apiUrl} - ${itemResult.message}`}
      />
    );
  }

  const menuContext =
    !itemResult.data.business || !itemResult.data.category ? await fetchPublicMenu(slug) : null;
  const menu = menuContext?.status === 'ok' ? menuContext.data : null;
  const item = itemResult.data.item;
  const business = itemResult.data.business || menu?.business || null;
  const category =
    itemResult.data.category ||
    menu?.categories.find((menuCategory) => menuCategory.items.some((menuItem) => menuItem.id === item.id)) ||
    null;

  if (!item.isAvailable) {
    return (
      <DetailState
        slug={slug}
        title="Item not found"
        message="This menu item is unavailable or does not exist on the public menu."
      />
    );
  }

  const businessName = business?.name || 'menu';
  const businessSlug = business?.slug || slug;
  const currency = business?.currency || '';
  const language = business?.language || null;
  const itemName = getItemName(item, language);
  const description = getItemDescription(item, language);
  const template = getPublicMenuTemplate(business?.menuTemplateId);
  const direction = isRtlLanguage(language) ? 'rtl' : 'ltr';

  return (
    <main
      dir={direction}
      lang={language || undefined}
      className={`waflo-menu waflo-item-detail ${template.cssClass}`}
      data-template={template.id}
      data-business-slug={businessSlug}
      data-component="public-menu-item"
      data-state="ready"
      data-dir={direction}
    >
      <article className="waflo-item-detail__shell" data-slot="item-detail-shell" data-component="item-detail-shell">
        <Link href={`/m/${slug}`} className="waflo-item-detail__back" data-slot="back-link">
          Back to {businessName}
        </Link>

        <section className="waflo-item-detail__card" data-slot="item-detail" data-component="menu-item" data-item-id={item.id}>
          <div
            className="waflo-item-detail__image"
            data-slot="item-image"
            data-component="item-image"
            data-state={item.imageUrl ? 'image' : 'placeholder'}
            data-has-image={item.imageUrl ? 'true' : 'false'}
          >
            {item.imageUrl ? <img src={item.imageUrl} alt={itemName} /> : <PlaceholderImage label="Product image" />}
          </div>
          <div className="waflo-item-detail__body" data-slot="item-copy">
            <div className="waflo-item-detail__heading">
              <div>
                <p className="waflo-item-detail__category" data-slot="category-title">
                  {category ? getCategoryName(category, language) : 'Menu item'}
                </p>
                <h1 className="waflo-item-detail__name" data-slot="item-name">
                  {itemName}
                </h1>
                <p className="waflo-item-detail__merchant" data-slot="merchant-metadata">
                  /m/{businessSlug}
                </p>
              </div>
              <div className="waflo-item-detail__price-block" data-slot="item-price">
                <p>{formatPrice(item.price, currency)}</p>
                <span data-slot="item-status" data-state="available">
                  Available
                </span>
              </div>
            </div>
            {description ? (
              <p className="waflo-item-detail__description" data-slot="item-description">
                {description}
              </p>
            ) : null}
          </div>
        </section>
      </article>
    </main>
  );
}

import Link from 'next/link';
import { PlaceholderImage } from '../../../../components/PlaceholderImage';
import {
  DetailState,
  ITEM_NOT_AVAILABLE_MESSAGE,
  ITEM_UNAVAILABLE_MESSAGE
} from '../../../../components/PublicMenuStates';
import { formatPrice, getCategoryName, getItemDescription, getItemName, isRtlLanguage } from '../../../../lib/menu-format';
import { getPublicMenuTemplate } from '../../../../lib/menu-templates';
import { fetchPublicItem, fetchPublicMenu } from '../../../../lib/public-menu';

type ProductDetailPageProps = {
  params: Promise<{
    slug: string;
    itemId: string;
  }>;
};

export default async function ProductDetailPage({ params }: ProductDetailPageProps) {
  const { slug, itemId } = await params;
  const itemResult = await fetchPublicItem(slug, itemId);

  if (itemResult.status === 'not-found') {
    return (
      <DetailState
        slug={slug}
        title="Item not found"
        message={ITEM_NOT_AVAILABLE_MESSAGE}
      />
    );
  }

  if (itemResult.status === 'error') {
    return (
      <DetailState
        slug={slug}
        title="Menu unavailable"
        message={ITEM_UNAVAILABLE_MESSAGE}
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

  const businessName = business?.name || 'menu';
  const businessSlug = business?.slug || slug;
  const currency = business?.currency || '';
  const language = business?.language || null;
  const itemName = getItemName(item, language);
  const description = getItemDescription(item, language);
  const template = getPublicMenuTemplate(menu?.appearance.effectiveTemplateId || business?.menuTemplateId);
  const direction = isRtlLanguage(language) ? 'rtl' : 'ltr';
  const itemState = item.isAvailable ? 'available' : 'sold-out';

  return (
    <main
      dir={direction}
      lang={language || undefined}
      className={`waflo-menu waflo-item-detail ${template.cssClass}`}
      data-template={template.id}
      data-business-slug={businessSlug}
      data-component="public-menu-item"
      data-state={itemState}
      data-dir={direction}
    >
      <article className="waflo-item-detail__shell" data-slot="item-detail-shell" data-component="item-detail-shell">
        <Link href={`/m/${slug}`} className="waflo-item-detail__back" data-slot="back-link">
          Back to {businessName}
        </Link>

        <section
          className="waflo-item-detail__card"
          data-slot="item-detail"
          data-component="menu-item"
          data-item-id={item.id}
          data-state={itemState}
        >
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
                <span data-slot="item-status" data-state={itemState}>
                  {item.isAvailable ? 'Available' : 'Sold out'}
                </span>
              </div>
            </div>
            {!item.isAvailable ? (
              <p className="waflo-item-detail__notice" role="status">
                This item is currently sold out. Please check the menu for other available options.
              </p>
            ) : null}
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

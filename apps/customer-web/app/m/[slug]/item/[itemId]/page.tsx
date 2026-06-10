import type { Metadata } from 'next';
import Link from 'next/link';
import { PlaceholderImage } from '../../../../components/PlaceholderImage';
import {
  formatPrice,
  getCategoryName,
  getItemDescription,
  getItemName,
  getMenuDirection,
  getTextDirection
} from '../../../../lib/menu-format';
import { fetchPublicMenu, fetchPublicMenuItem } from '../../../../lib/public-menu';

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
  actionLabel = 'Back to menu'
}: {
  slug: string;
  title: string;
  message: string;
  actionLabel?: string;
}) {
  return (
    <main className="flex min-h-screen items-center bg-[#fbf7ef] px-4 py-12">
      <section className="mx-auto w-full max-w-xl rounded-lg border border-[#eadfce] bg-white p-6 shadow-sm">
        <p className="text-sm font-bold uppercase text-[#1f7a5a]">Menu item</p>
        <h1 className="mt-2 text-3xl font-extrabold text-ink">{title}</h1>
        <p className="mt-3 text-base leading-7 text-neutral-600">{message}</p>
        <Link
          href={`/m/${slug}`}
          className="mt-6 inline-flex rounded-md bg-[#1f7a5a] px-4 py-3 text-sm font-bold text-white shadow-sm"
        >
          {actionLabel}
        </Link>
      </section>
    </main>
  );
}

export async function generateMetadata({ params }: ProductDetailPageProps): Promise<Metadata> {
  const { slug, itemId } = await params;
  const result = await fetchPublicMenuItem(slug, itemId);

  if (result.status !== 'ok') {
    return {
      title: result.status === 'not-found' ? 'Item not found | Tavrix Menu' : 'Item unavailable | Tavrix Menu',
      description: 'View public menu item details in Tavrix Menu.'
    };
  }

  const itemName = getItemName(result.data);
  const description = getItemDescription(result.data);

  return {
    title: `${itemName} | Tavrix Menu`,
    description: description || `View price and details for ${itemName}.`
  };
}

export default async function ProductDetailPage({ params }: ProductDetailPageProps) {
  const { slug, itemId } = await params;
  const [itemResult, menuResult] = await Promise.all([fetchPublicMenuItem(slug, itemId), fetchPublicMenu(slug)]);

  if (itemResult.status === 'not-found') {
    return (
      <DetailState
        slug={slug}
        title={menuResult.status === 'not-found' ? 'Menu not found' : 'Item not found'}
        message="This menu item is unavailable or does not exist on the public menu."
      />
    );
  }

  if (itemResult.status === 'error') {
    return (
      <DetailState
        slug={slug}
        title="Item unavailable"
        message="The menu item could not be loaded right now. Please try again in a moment."
        actionLabel="Retry item"
      />
    );
  }

  const item = itemResult.data;
  const menu = menuResult.status === 'ok' ? menuResult.data : null;
  const business = menu?.business;
  const language = business?.language ?? null;
  const category = menu?.categories.find((menuCategory) => menuCategory.items.some((menuItem) => menuItem.id === item.id));
  const itemName = getItemName(item, language);
  const description = getItemDescription(item, language);

  return (
    <main className="min-h-screen bg-[#fbf7ef] px-4 py-5" dir={getMenuDirection(language)}>
      <section className="mx-auto w-full max-w-3xl">
      <Link href={`/m/${slug}`} className="inline-flex rounded-md bg-white px-3 py-2 text-sm font-bold text-[#5b4635] shadow-sm">
        Back to {business?.name || 'menu'}
      </Link>

      <article className="mt-5">
        {item.imageUrl ? (
          <img src={item.imageUrl} alt={itemName} className="aspect-[4/3] w-full rounded-lg object-cover shadow-sm" />
        ) : (
          <PlaceholderImage label="Menu item image" className="aspect-[4/3] w-full rounded-lg shadow-sm" />
        )}
        <div className="mt-5 rounded-lg border border-[#eadfce] bg-white p-5 shadow-sm">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div className="min-w-0">
              {category ? (
                <p className="text-sm font-bold text-[#1f7a5a]" dir={getTextDirection(getCategoryName(category, language))}>
                  {getCategoryName(category, language)}
                </p>
              ) : null}
              <h1 className="mt-1 break-words text-3xl font-extrabold leading-tight text-ink" dir={getTextDirection(itemName)}>
                {itemName}
              </h1>
              <div className="mt-3 flex flex-wrap gap-2 text-sm font-medium text-neutral-600">
                {business ? <span>{business.name}</span> : <span>Public menu</span>}
                {business?.city ? <span>{business.city}</span> : null}
                {business?.type ? <span>{business.type}</span> : null}
              </div>
            </div>
            <div className="shrink-0 rounded-md bg-[#eef7f1] px-4 py-3 text-left">
              <p className="text-xs font-bold uppercase text-[#1f7a5a]">Price</p>
              <p className="mt-1 text-xl font-extrabold text-ink" dir="ltr">
                {formatPrice(item.price, business?.currency || 'IQD')}
              </p>
            </div>
          </div>
          {description ? (
            <p className="mt-5 break-words text-base leading-7 text-neutral-700" dir={getTextDirection(description)}>
              {description}
            </p>
          ) : null}
          {!item.isAvailable ? (
            <p className="mt-5 rounded-md bg-neutral-100 p-3 text-sm font-semibold text-neutral-600">
              This item is currently unavailable.
            </p>
          ) : null}
        </div>
      </article>
      </section>
    </main>
  );
}

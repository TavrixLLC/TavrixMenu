import Link from 'next/link';
import { PlaceholderImage } from '../../../../components/PlaceholderImage';
import { formatPrice, getCategoryName, getItemDescription, getItemName } from '../../../../lib/menu-format';
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
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col justify-center bg-[#fafaf7] px-4 py-12">
      <Link href={`/m/${slug}`} className="text-sm font-semibold text-neutral-600">
        Back to menu
      </Link>
      <section className="mt-5 rounded-lg border border-neutral-200 bg-white p-6 shadow-sm">
        <p className="text-sm font-semibold uppercase text-mint">Menu item</p>
        <h1 className="mt-2 text-3xl font-bold text-ink">{title}</h1>
        <p className="mt-3 text-base leading-7 text-neutral-600">{message}</p>
        {detail ? <p className="mt-4 rounded-md bg-neutral-50 p-3 text-sm text-neutral-500">{detail}</p> : null}
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

  const itemName = getItemName(item);
  const description = getItemDescription(item);
  const businessName = business?.name || 'menu';
  const businessSlug = business?.slug || slug;
  const currency = business?.currency || '';

  return (
    <main className="mx-auto min-h-screen w-full max-w-3xl bg-[#fafaf7] px-4 py-5">
      <Link href={`/m/${slug}`} className="text-sm font-semibold text-neutral-600">
        Back to {businessName}
      </Link>

      <section className="mt-5">
        {item.imageUrl ? (
          <img src={item.imageUrl} alt={itemName} className="aspect-[4/3] w-full rounded-lg object-cover" />
        ) : (
          <PlaceholderImage label="Product image" className="aspect-[4/3] w-full rounded-lg" />
        )}
        <div className="mt-5 flex items-start justify-between gap-4">
          <div>
            <p className="text-sm font-semibold text-mint">{category ? getCategoryName(category) : 'Menu item'}</p>
            <h1 className="mt-1 text-3xl font-bold text-ink">{itemName}</h1>
            <p className="mt-2 text-sm text-neutral-500">/m/{businessSlug}</p>
          </div>
          <div className="shrink-0 text-right">
            <p className="text-base font-bold text-ink">{formatPrice(item.price, currency)}</p>
            <span className="mt-2 inline-flex rounded-full bg-emerald-50 px-2 py-1 text-xs font-semibold text-emerald-700">
              Available
            </span>
          </div>
        </div>
        {description ? <p className="mt-4 text-base leading-7 text-neutral-700">{description}</p> : null}
      </section>
    </main>
  );
}

import Link from 'next/link';
import { PlaceholderImage } from '../../../../components/PlaceholderImage';
import { formatPrice, getCategoryName, getItemDescription, getItemName } from '../../../../lib/menu-format';
import { fetchPublicMenu } from '../../../../lib/public-menu';

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
  const result = await fetchPublicMenu(slug);

  if (result.status === 'not-found') {
    return (
      <DetailState
        slug={slug}
        title="Menu not found"
        message="This business menu could not be found. Check the menu link and try again."
        detail={result.apiUrl}
      />
    );
  }

  if (result.status === 'error') {
    return (
      <DetailState
        slug={slug}
        title="Menu unavailable"
        message="The menu item could not be loaded right now because the public API is unreachable or returned an error."
        detail={`${result.apiUrl} - ${result.message}`}
      />
    );
  }

  const menu = result.data;
  const category = menu.categories.find((menuCategory) => menuCategory.items.some((item) => item.id === itemId));
  const item = category?.items.find((menuItem) => menuItem.id === itemId);

  if (!category || !item) {
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

  return (
    <main className="mx-auto min-h-screen w-full max-w-3xl bg-[#fafaf7] px-4 py-5">
      <Link href={`/m/${slug}`} className="text-sm font-semibold text-neutral-600">
        Back to {menu.business.name}
      </Link>

      <section className="mt-5">
        {item.imageUrl ? (
          <img src={item.imageUrl} alt={itemName} className="aspect-[4/3] w-full rounded-lg object-cover" />
        ) : (
          <PlaceholderImage label="Product image" className="aspect-[4/3] w-full rounded-lg" />
        )}
        <div className="mt-5 flex items-start justify-between gap-4">
          <div>
            <p className="text-sm font-semibold text-mint">{getCategoryName(category)}</p>
            <h1 className="mt-1 text-3xl font-bold text-ink">{itemName}</h1>
            <p className="mt-2 text-sm text-neutral-500">/m/{menu.business.slug}</p>
          </div>
          <div className="shrink-0 text-right">
            <p className="text-base font-bold text-ink">{formatPrice(item.price, menu.business.currency)}</p>
            <span
              className={`mt-2 inline-flex rounded-full px-2 py-1 text-xs font-semibold ${
                item.isAvailable ? 'bg-emerald-50 text-emerald-700' : 'bg-neutral-100 text-neutral-500'
              }`}
            >
              {item.isAvailable ? 'Available' : 'Unavailable'}
            </span>
          </div>
        </div>
        {description ? <p className="mt-4 text-base leading-7 text-neutral-700">{description}</p> : null}
      </section>
    </main>
  );
}

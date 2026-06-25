import Link from 'next/link';
import { PlaceholderImage } from './PlaceholderImage';
import type { PublicMenuItem } from '../lib/public-menu';
import { formatPrice, getItemDescription, getItemName } from '../lib/menu-format';

type ProductCardProps = {
  item: PublicMenuItem;
  currency: string;
  href?: string;
};

export function ProductCard({ item, currency, href }: ProductCardProps) {
  if (!item.isAvailable) {
    return null;
  }

  const name = getItemName(item);
  const description = getItemDescription(item);
  const cardContent = (
    <>
      {item.imageUrl ? (
        <img src={item.imageUrl} alt={name} className="aspect-square rounded object-cover" />
      ) : (
        <PlaceholderImage label="Image" className="aspect-square" />
      )}
      <div className="min-w-0">
        <div className="flex items-start justify-between gap-3">
          <h3 className="text-base font-semibold text-ink">{name}</h3>
          <span className="shrink-0 rounded-full bg-emerald-50 px-2 py-1 text-xs font-semibold text-emerald-700">
            Available
          </span>
        </div>
        {description ? <p className="mt-1 text-sm text-neutral-600">{description}</p> : null}
        <p className="mt-3 text-sm font-bold text-ink">{formatPrice(item.price, currency)}</p>
      </div>
    </>
  );

  const className =
    'grid grid-cols-[96px_1fr] gap-4 rounded-lg border border-neutral-200 bg-white p-3 shadow-sm transition hover:border-neutral-300';

  if (href) {
    return (
      <Link href={href} className={className}>
        {cardContent}
      </Link>
    );
  }

  return (
    <article className={className}>
      {cardContent}
    </article>
  );
}

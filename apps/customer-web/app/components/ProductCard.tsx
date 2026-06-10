import Link from 'next/link';
import { PlaceholderImage } from './PlaceholderImage';
import type { PublicMenuItem } from '../lib/public-menu';
import { formatPrice, getItemDescription, getItemName, getTextDirection } from '../lib/menu-format';

type ProductCardProps = {
  item: PublicMenuItem;
  currency: string;
  language?: string | null;
  href?: string;
};

export function ProductCard({ item, currency, language, href }: ProductCardProps) {
  const name = getItemName(item, language);
  const description = getItemDescription(item, language);
  const isUnavailable = !item.isAvailable;
  const cardContent = (
    <>
      {item.imageUrl ? (
        <img src={item.imageUrl} alt={name} className="aspect-square rounded-md object-cover" />
      ) : (
        <PlaceholderImage label="Menu image" className="aspect-square rounded-md" />
      )}
      <div className="min-w-0">
        <div className="flex items-start justify-between gap-3">
          <h3 className="min-w-0 break-words text-base font-bold leading-6 text-ink" dir={getTextDirection(name)}>
            {name}
          </h3>
          {isUnavailable ? (
            <span className="shrink-0 rounded-full bg-neutral-100 px-2 py-1 text-xs font-semibold text-neutral-500">
              Unavailable
            </span>
          ) : null}
        </div>
        {description ? (
          <p className="mt-1 line-clamp-2 break-words text-sm leading-6 text-neutral-600" dir={getTextDirection(description)}>
            {description}
          </p>
        ) : null}
        <p className="mt-3 text-sm font-extrabold text-[#1f7a5a]" dir="ltr">
          {formatPrice(item.price, currency)}
        </p>
      </div>
    </>
  );

  const className = `grid grid-cols-[88px_1fr] gap-3 rounded-lg border bg-white p-3 shadow-sm transition sm:grid-cols-[104px_1fr] sm:gap-4 ${
    isUnavailable
      ? 'border-neutral-200 opacity-60'
      : 'border-[#eadfce] hover:border-[#1f7a5a] hover:shadow-md'
  }`;

  if (href && !isUnavailable) {
    return (
      <Link href={href} className={className} aria-label={`View ${name}`}>
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

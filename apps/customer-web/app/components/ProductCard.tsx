import Link from 'next/link';
import type { MockMenuItem } from '../mock-data';
import { PlaceholderImage } from './PlaceholderImage';

type ProductCardProps = {
  item: MockMenuItem;
  slug: string;
};

export function ProductCard({ item, slug }: ProductCardProps) {
  return (
    <Link
      href={`/m/${slug}/item/${item.id}`}
      className="grid grid-cols-[96px_1fr] gap-4 rounded-lg border border-neutral-200 bg-white p-3 shadow-sm transition hover:border-neutral-300"
    >
      <PlaceholderImage label="Image" className="aspect-square" />
      <div className="min-w-0">
        <div className="flex items-start justify-between gap-3">
          <h3 className="text-base font-semibold text-ink">{item.name}</h3>
          <span
            className={`shrink-0 rounded-full px-2 py-1 text-xs font-semibold ${
              item.available ? 'bg-emerald-50 text-emerald-700' : 'bg-neutral-100 text-neutral-500'
            }`}
          >
            {item.available ? 'Available' : 'Unavailable'}
          </span>
        </div>
        <p className="mt-1 text-sm text-neutral-600">{item.description}</p>
        <p className="mt-3 text-sm font-bold text-ink">{item.price}</p>
      </div>
    </Link>
  );
}

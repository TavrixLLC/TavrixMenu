import Link from 'next/link';
import { PlaceholderImage } from '../../../../components/PlaceholderImage';
import { mockBusiness, mockPairings } from '../../../../mock-data';

type ProductDetailPageProps = {
  params: Promise<{
    slug: string;
    itemId: string;
  }>;
};

export default async function ProductDetailPage({ params }: ProductDetailPageProps) {
  const { slug, itemId } = await params;
  const item = mockBusiness.items.find((menuItem) => menuItem.id === itemId) ?? mockBusiness.items[0];

  return (
    <main className="mx-auto min-h-screen w-full max-w-3xl bg-[#fafaf7] px-4 py-5">
      <Link href={`/m/${slug}`} className="text-sm font-semibold text-neutral-600">
        Back to menu
      </Link>

      <section className="mt-5">
        <PlaceholderImage label="Product image placeholder" className="aspect-[4/3] w-full rounded-lg" />
        <div className="mt-5 flex items-start justify-between gap-4">
          <div>
            <p className="text-sm font-semibold text-mint">{item.category}</p>
            <h1 className="mt-1 text-3xl font-bold text-ink">{item.name}</h1>
          </div>
          <p className="shrink-0 text-base font-bold text-ink">{item.price}</p>
        </div>
        <p className="mt-4 text-base leading-7 text-neutral-700">{item.description}</p>
        <button className="mt-6 w-full rounded-md bg-ink px-5 py-3 text-base font-bold text-white">
          شنو آخذ وياها؟
        </button>
      </section>

      <section className="mt-8">
        <h2 className="text-xl font-bold text-ink">Suggested pairings</h2>
        <div className="mt-4 grid gap-3">
          {mockPairings.map((pairing) => (
            <article key={pairing.id} className="grid grid-cols-[88px_1fr] gap-4 rounded-lg border border-neutral-200 bg-white p-3">
              <PlaceholderImage label="Image" className="aspect-square" />
              <div>
                <div className="flex items-start justify-between gap-3">
                  <h3 className="font-bold text-ink">{pairing.name}</h3>
                  <p className="shrink-0 text-sm font-bold text-ink">{pairing.price}</p>
                </div>
                <p className="mt-2 text-sm leading-6 text-neutral-600">{pairing.reason}</p>
                <Link
                  href={`/m/${slug}/item/${pairing.id}`}
                  className="mt-3 inline-flex rounded-md border border-neutral-200 px-3 py-2 text-sm font-semibold text-neutral-700"
                >
                  عرض المنتج
                </Link>
              </div>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}

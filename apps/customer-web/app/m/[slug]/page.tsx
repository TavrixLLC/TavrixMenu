import { PlaceholderImage } from '../../components/PlaceholderImage';
import { ProductCard } from '../../components/ProductCard';
import { mockBusiness } from '../../mock-data';

type MenuPageProps = {
  params: Promise<{
    slug: string;
  }>;
};

export default async function MenuPage({ params }: MenuPageProps) {
  const { slug } = await params;

  return (
    <main className="min-h-screen bg-[#fafaf7] pb-10">
      <section className="mx-auto w-full max-w-4xl px-4 pt-4">
        <PlaceholderImage label="Cover placeholder" className="h-40 w-full rounded-lg sm:h-56" />
        <div className="-mt-8 flex items-end gap-4 px-3">
          <PlaceholderImage label="Logo" className="h-20 w-20 shrink-0 rounded-lg bg-white shadow-sm" />
          <div className="pb-1">
            <p className="text-sm font-semibold text-mint">{mockBusiness.type}</p>
            <h1 className="text-3xl font-bold text-ink">{mockBusiness.name}</h1>
            <p className="text-sm text-neutral-500">{mockBusiness.city}</p>
          </div>
        </div>
      </section>

      <section className="mx-auto mt-8 w-full max-w-4xl px-4">
        <div className="flex gap-2 overflow-x-auto pb-2">
          {mockBusiness.categories.map((category) => (
            <span
              key={category}
              className="shrink-0 rounded-full border border-neutral-200 bg-white px-4 py-2 text-sm font-semibold text-neutral-700"
            >
              {category}
            </span>
          ))}
        </div>
      </section>

      <section className="mx-auto mt-5 grid w-full max-w-4xl gap-3 px-4">
        {mockBusiness.items.map((item) => (
          <ProductCard key={item.id} item={item} slug={slug} />
        ))}
      </section>
    </main>
  );
}

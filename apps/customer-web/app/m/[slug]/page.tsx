import { PlaceholderImage } from '../../components/PlaceholderImage';
import { ProductCard } from '../../components/ProductCard';
import { getCategoryName } from '../../lib/menu-format';
import { fetchPublicMenu, type PublicMenuResponse } from '../../lib/public-menu';

type MenuPageProps = {
  params: Promise<{
    slug: string;
  }>;
};

function MenuState({
  title,
  message,
  detail
}: {
  title: string;
  message: string;
  detail?: string;
}) {
  return (
    <main className="flex min-h-screen items-center bg-[#fafaf7] px-4 py-12">
      <section className="mx-auto w-full max-w-xl rounded-lg border border-neutral-200 bg-white p-6 shadow-sm">
        <p className="text-sm font-semibold uppercase text-mint">Public menu</p>
        <h1 className="mt-2 text-3xl font-bold text-ink">{title}</h1>
        <p className="mt-3 text-base leading-7 text-neutral-600">{message}</p>
        {detail ? <p className="mt-4 rounded-md bg-neutral-50 p-3 text-sm text-neutral-500">{detail}</p> : null}
      </section>
    </main>
  );
}

function MenuHeader({ menu }: { menu: PublicMenuResponse }) {
  const { business } = menu;

  return (
    <section className="mx-auto w-full max-w-4xl px-4 pt-4">
      {business.coverUrl ? (
        <img
          src={business.coverUrl}
          alt={`${business.name} cover`}
          className="h-40 w-full rounded-lg object-cover sm:h-56"
        />
      ) : (
        <PlaceholderImage label="Cover" className="h-40 w-full rounded-lg sm:h-56" />
      )}
      <div className="-mt-8 flex items-end gap-4 px-3">
        {business.logoUrl ? (
          <img
            src={business.logoUrl}
            alt={`${business.name} logo`}
            className="h-20 w-20 shrink-0 rounded-lg bg-white object-cover shadow-sm"
          />
        ) : (
          <PlaceholderImage label="Logo" className="h-20 w-20 shrink-0 rounded-lg bg-white shadow-sm" />
        )}
        <div className="pb-1">
          <p className="text-sm font-semibold capitalize text-mint">{business.type || 'Menu'}</p>
          <h1 className="text-3xl font-bold text-ink">{business.name}</h1>
          <div className="mt-1 flex flex-wrap items-center gap-2 text-sm text-neutral-500">
            {business.city ? <span>{business.city}</span> : null}
            <span>/m/{business.slug}</span>
          </div>
        </div>
      </div>
    </section>
  );
}

function EmptyMenuState() {
  return (
    <section className="mx-auto mt-8 w-full max-w-4xl px-4">
      <div className="rounded-lg border border-neutral-200 bg-white p-6 text-center shadow-sm">
        <h2 className="text-xl font-bold text-ink">No menu items yet</h2>
        <p className="mt-2 text-sm leading-6 text-neutral-600">
          This public menu is available, but it does not have any categories with items yet.
        </p>
      </div>
    </section>
  );
}

export default async function MenuPage({ params }: MenuPageProps) {
  const { slug } = await params;
  const result = await fetchPublicMenu(slug);

  if (result.status === 'not-found') {
    return (
      <MenuState
        title="Menu not found"
        message="This business menu could not be found. Check the menu link and try again."
        detail={result.apiUrl}
      />
    );
  }

  if (result.status === 'error') {
    return (
      <MenuState
        title="Menu unavailable"
        message="The customer menu could not be loaded right now because the public API is unreachable or returned an error."
        detail={`${result.apiUrl} - ${result.message}`}
      />
    );
  }

  const menu = result.data;
  const categories = menu.categories;
  const hasMenuItems = categories.some((category) => category.items.length > 0);

  return (
    <main className="min-h-screen bg-[#fafaf7] pb-10">
      <MenuHeader menu={menu} />

      {categories.length > 0 ? (
        <section className="mx-auto mt-8 w-full max-w-4xl px-4">
          <div className="flex gap-2 overflow-x-auto pb-2">
            {categories.map((category) => (
              <a
                key={category.id}
                href={`#category-${category.id}`}
                className="shrink-0 rounded-full border border-neutral-200 bg-white px-4 py-2 text-sm font-semibold text-neutral-700"
              >
                {getCategoryName(category)}
              </a>
            ))}
          </div>
        </section>
      ) : null}

      {!hasMenuItems ? (
        <EmptyMenuState />
      ) : (
        <section className="mx-auto mt-5 grid w-full max-w-4xl gap-8 px-4">
          {categories.map((category) => (
            <section key={category.id} id={`category-${category.id}`} className="scroll-mt-4">
              <h2 className="text-xl font-bold text-ink">{getCategoryName(category)}</h2>
              {category.items.length > 0 ? (
                <div className="mt-3 grid gap-3">
                  {category.items.map((item) => (
                    <ProductCard
                      key={item.id}
                      item={item}
                      currency={menu.business.currency}
                      href={`/m/${menu.business.slug}/item/${item.id}`}
                    />
                  ))}
                </div>
              ) : (
                <p className="mt-3 rounded-lg border border-neutral-200 bg-white p-4 text-sm text-neutral-600">
                  No available items in this category.
                </p>
              )}
            </section>
          ))}
        </section>
      )}
    </main>
  );
}

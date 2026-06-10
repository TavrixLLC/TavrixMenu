import type { Metadata } from 'next';
import Link from 'next/link';
import { PlaceholderImage } from '../../components/PlaceholderImage';
import { ProductCard } from '../../components/ProductCard';
import { getCategoryName, getMenuDirection, getTextDirection } from '../../lib/menu-format';
import { fetchPublicMenu, type PublicMenuCategory, type PublicMenuResponse } from '../../lib/public-menu';

type MenuPageProps = {
  params: Promise<{
    slug: string;
  }>;
};

function bySortOrder<TValue extends { sortOrder: number }>(first: TValue, second: TValue) {
  return first.sortOrder - second.sortOrder;
}

function getVisibleCategories(menu: PublicMenuResponse): PublicMenuCategory[] {
  return [...menu.categories]
    .sort(bySortOrder)
    .map((category) => ({
      ...category,
      items: [...category.items].filter((item) => item.isAvailable).sort(bySortOrder)
    }));
}

function formatBusinessType(type: string | null) {
  if (!type) {
    return 'Public menu';
  }

  return type
    .replace(/[-_]+/g, ' ')
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function MenuState({
  title,
  message,
  actionHref,
  actionLabel
}: {
  title: string;
  message: string;
  actionHref: string;
  actionLabel: string;
}) {
  return (
    <main className="flex min-h-screen items-center bg-[#fbf7ef] px-4 py-12">
      <section className="mx-auto w-full max-w-xl rounded-lg border border-[#eadfce] bg-white p-6 shadow-sm">
        <p className="text-sm font-bold uppercase text-[#1f7a5a]">Public menu</p>
        <h1 className="mt-2 text-3xl font-extrabold text-ink">{title}</h1>
        <p className="mt-3 text-base leading-7 text-neutral-600">{message}</p>
        <Link
          href={actionHref}
          className="mt-6 inline-flex rounded-md bg-[#1f7a5a] px-4 py-3 text-sm font-bold text-white shadow-sm"
        >
          {actionLabel}
        </Link>
      </section>
    </main>
  );
}

function MenuHeader({
  menu,
  categoryCount,
  itemCount
}: {
  menu: PublicMenuResponse;
  categoryCount: number;
  itemCount: number;
}) {
  const { business } = menu;
  const businessType = formatBusinessType(business.type);

  return (
    <section className="mx-auto w-full max-w-4xl px-4 pt-4">
      {business.coverUrl ? (
        <img
          src={business.coverUrl}
          alt={`${business.name} cover`}
          className="h-44 w-full rounded-lg object-cover shadow-sm sm:h-60"
        />
      ) : (
        <PlaceholderImage label={`${business.name} cover`} className="h-44 w-full rounded-lg shadow-sm sm:h-60" />
      )}
      <div className="flex items-start gap-4 px-3">
        {business.logoUrl ? (
          <img
            src={business.logoUrl}
            alt={`${business.name} logo`}
            className="-mt-10 relative z-10 h-20 w-20 shrink-0 rounded-lg border border-white bg-white object-cover shadow-md"
          />
        ) : (
          <PlaceholderImage label="Logo" className="-mt-10 relative z-10 h-20 w-20 shrink-0 rounded-lg bg-white shadow-md" />
        )}
        <div className="min-w-0 pt-2 pb-1">
          <p className="text-sm font-bold text-[#1f7a5a]">{businessType}</p>
          <h1 className="break-words text-3xl font-extrabold leading-tight text-ink" dir={getTextDirection(business.name)}>
            {business.name}
          </h1>
          <div className="mt-2 flex flex-wrap items-center gap-2 text-sm font-medium text-neutral-600">
            {business.city ? <span>{business.city}</span> : null}
            {business.city && businessType ? <span aria-hidden="true">/</span> : null}
            <span>
              {categoryCount} categories
            </span>
            <span aria-hidden="true">/</span>
            <span>{itemCount} items</span>
          </div>
        </div>
      </div>
    </section>
  );
}

function EmptyMenuState({ businessName }: { businessName: string }) {
  return (
    <section className="mx-auto mt-8 w-full max-w-4xl px-4">
      <div className="rounded-lg border border-[#eadfce] bg-white p-6 text-center shadow-sm">
        <h2 className="text-xl font-extrabold text-ink">No menu items yet</h2>
        <p className="mt-2 text-sm leading-6 text-neutral-600">
          {businessName} is online, but there are no available menu items to show right now.
        </p>
      </div>
    </section>
  );
}

export async function generateMetadata({ params }: MenuPageProps): Promise<Metadata> {
  const { slug } = await params;
  const result = await fetchPublicMenu(slug);

  if (result.status !== 'ok') {
    return {
      title: result.status === 'not-found' ? 'Menu not found | Tavrix Menu' : 'Menu unavailable | Tavrix Menu',
      description: 'Browse public Tavrix Menu pages in the browser.'
    };
  }

  const { business } = result.data;
  const location = business.city ? ` in ${business.city}` : '';

  return {
    title: `${business.name} Menu | Tavrix Menu`,
    description: `Browse ${business.name}${location}: categories, item details, and prices.`
  };
}

export default async function MenuPage({ params }: MenuPageProps) {
  const { slug } = await params;
  const result = await fetchPublicMenu(slug);

  if (result.status === 'not-found') {
    return (
      <MenuState
        title="Menu not found"
        message="This business menu could not be found. Check the menu link and try again."
        actionHref="/"
        actionLabel="Back to Tavrix Menu"
      />
    );
  }

  if (result.status === 'error') {
    return (
      <MenuState
        title="Menu unavailable"
        message="The customer menu could not be loaded right now. Please try again in a moment."
        actionHref={`/m/${slug}`}
        actionLabel="Retry menu"
      />
    );
  }

  const menu = result.data;
  const categories = getVisibleCategories(menu);
  const itemCount = categories.reduce((count, category) => count + category.items.length, 0);
  const hasMenuItems = categories.some((category) => category.items.length > 0);
  const language = menu.business.language;

  return (
    <main className="min-h-screen bg-[#fbf7ef] pb-12" dir={getMenuDirection(language)}>
      <MenuHeader menu={menu} categoryCount={categories.length} itemCount={itemCount} />

      {categories.length > 0 ? (
        <section className="mx-auto mt-8 w-full max-w-4xl px-4">
          <nav aria-label="Menu categories" className="flex gap-2 overflow-x-auto pb-2">
            {categories.map((category) => (
              <a
                key={category.id}
                href={`#category-${category.id}`}
                className="shrink-0 rounded-full border border-[#d7c8b6] bg-white px-4 py-2 text-sm font-bold text-[#5b4635] shadow-sm"
                dir={getTextDirection(getCategoryName(category, language))}
              >
                {getCategoryName(category, language)}
              </a>
            ))}
          </nav>
        </section>
      ) : null}

      {!hasMenuItems ? (
        <EmptyMenuState businessName={menu.business.name} />
      ) : (
        <section className="mx-auto mt-5 grid w-full max-w-4xl gap-8 px-4">
          {categories.map((category) => (
            <section key={category.id} id={`category-${category.id}`} className="scroll-mt-4">
              <div className="mb-3 flex items-end justify-between gap-3">
                <h2
                  className="min-w-0 break-words text-xl font-extrabold text-ink"
                  dir={getTextDirection(getCategoryName(category, language))}
                >
                  {getCategoryName(category, language)}
                </h2>
                <span className="shrink-0 text-xs font-bold uppercase text-[#1f7a5a]">
                  {category.items.length} items
                </span>
              </div>
              {category.items.length > 0 ? (
                <div className="grid gap-3">
                  {category.items.map((item) => (
                    <ProductCard
                      key={item.id}
                      item={item}
                      currency={menu.business.currency}
                      language={language}
                      href={`/m/${menu.business.slug}/item/${item.id}`}
                    />
                  ))}
                </div>
              ) : (
                <p className="rounded-lg border border-[#eadfce] bg-white p-4 text-sm leading-6 text-neutral-600">
                  No available items in this category right now.
                </p>
              )}
            </section>
          ))}
        </section>
      )}
    </main>
  );
}

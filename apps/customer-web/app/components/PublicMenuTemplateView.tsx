import Link from 'next/link';
import { PlaceholderImage } from './PlaceholderImage';
import { formatPrice, getCategoryName, getItemDescription, getItemName, isRtlLanguage } from '../lib/menu-format';
import type { PublicMenuCategory, PublicMenuItem, PublicMenuResponse } from '../lib/public-menu';
import type { PublicLoyaltyContext } from '../lib/public-loyalty';
import type { PublicMenuTemplateDefinition } from '../lib/menu-templates';

type PublicMenuTemplateViewProps = {
  menu: PublicMenuResponse;
  template: PublicMenuTemplateDefinition;
  loyaltyContext?: PublicLoyaltyContext | null;
};

function templateShellClass(template: PublicMenuTemplateDefinition) {
  if (template.layoutVariant === 'minimal-list') {
    return 'min-h-screen overflow-x-hidden bg-white pb-14 text-ink';
  }

  if (template.layoutVariant === 'editorial-premium') {
    return 'min-h-screen overflow-x-hidden bg-[#f8f1e7] pb-14 text-ink';
  }

  if (template.layoutVariant === 'street-rows') {
    return 'min-h-screen overflow-x-hidden bg-[#fff3ec] pb-14 text-ink';
  }

  return 'min-h-screen overflow-x-hidden bg-cream pb-14 text-ink';
}

function MerchantHeader({
  menu,
  template
}: {
  menu: PublicMenuResponse;
  template: PublicMenuTemplateDefinition;
}) {
  const { business } = menu;
  const textDirection = isRtlLanguage(business.language) ? 'rtl' : 'ltr';

  if (template.layoutVariant === 'editorial-premium') {
    return (
      <section className="bg-[#12392F] text-white">
        <div className="mx-auto grid max-w-6xl gap-6 px-4 py-6 lg:grid-cols-[1fr_360px] lg:items-end lg:py-10">
          <div>
            <p className="text-sm font-semibold uppercase tracking-normal text-[#F5C56A]">{business.type || 'Menu'}</p>
            <h1 dir={textDirection} className="mt-3 text-4xl font-bold leading-tight sm:text-5xl">
              {business.name}
            </h1>
            <div className="mt-4 flex flex-wrap items-center gap-2 text-sm text-white/75">
              {business.city ? <span>{business.city}</span> : null}
              <span>{business.currency}</span>
            </div>
          </div>
          {business.coverUrl ? (
            <img
              src={business.coverUrl}
              alt={`${business.name} cover`}
              className="aspect-[4/3] w-full rounded-xl object-cover shadow-lg"
            />
          ) : (
            <PlaceholderImage label="Cover" className="aspect-[4/3] w-full rounded-xl bg-white/10 text-white" />
          )}
        </div>
      </section>
    );
  }

  if (template.layoutVariant === 'minimal-list') {
    return (
      <section className="mx-auto max-w-5xl px-4 pt-8">
        <div className="border-b border-neutral-200 pb-6">
          <div className="flex items-start gap-4">
            {business.logoUrl ? (
              <img src={business.logoUrl} alt={`${business.name} logo`} className="h-16 w-16 rounded-lg object-cover" />
            ) : (
              <PlaceholderImage label="Logo" className="h-16 w-16 shrink-0 rounded-lg" />
            )}
            <div className="min-w-0">
              <p className="text-sm font-semibold uppercase text-muted">{business.type || 'Menu'}</p>
              <h1 dir={textDirection} className="mt-1 text-3xl font-bold leading-tight text-ink">
                {business.name}
              </h1>
              <p className="mt-2 text-sm text-muted">{business.city || `/m/${business.slug}`}</p>
            </div>
          </div>
        </div>
      </section>
    );
  }

  if (template.layoutVariant === 'street-rows') {
    return (
      <section className="mx-auto max-w-5xl px-4 pt-4">
        <div className="overflow-hidden rounded-xl border-2 border-[#FF6B4A] bg-white shadow-[0_10px_0_#FFD5C8]">
          <div className="h-3 bg-[#FF6B4A]" />
          <div className="grid gap-4 p-4 sm:grid-cols-[1fr_180px] sm:items-center">
            <div className="min-w-0">
              <p className="text-sm font-black uppercase text-[#D94B2B]">{business.type || 'Fresh menu'}</p>
              <h1 dir={textDirection} className="mt-2 break-words text-3xl font-black leading-tight text-ink sm:text-4xl">
                {business.name}
              </h1>
              <p className="mt-3 text-sm font-semibold text-muted">{business.city || `/m/${business.slug}`}</p>
            </div>
            {business.logoUrl ? (
              <img src={business.logoUrl} alt={`${business.name} logo`} className="aspect-square w-full rounded-lg object-cover" />
            ) : (
              <PlaceholderImage label="Logo" className="aspect-square w-full rounded-lg" />
            )}
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="mx-auto max-w-5xl px-4 pt-4">
      {business.coverUrl ? (
        <img src={business.coverUrl} alt={`${business.name} cover`} className="h-44 w-full rounded-xl object-cover sm:h-64" />
      ) : (
        <PlaceholderImage label="Cover" className="h-44 w-full rounded-xl sm:h-64" />
      )}
      <div className="-mt-9 flex flex-col gap-4 px-3 sm:flex-row sm:items-end">
        <div className="flex items-end gap-4">
          {business.logoUrl ? (
            <img src={business.logoUrl} alt={`${business.name} logo`} className="h-20 w-20 rounded-xl bg-white object-cover shadow-sm" />
          ) : (
            <PlaceholderImage label="Logo" className="h-20 w-20 shrink-0 rounded-xl bg-white shadow-sm" />
          )}
          <div className="pb-1">
            <p className="text-sm font-semibold capitalize text-green-dark">{business.type || 'Menu'}</p>
            <h1 dir={textDirection} className="text-3xl font-bold text-ink">
              {business.name}
            </h1>
            <div className="mt-1 flex flex-wrap items-center gap-2 text-sm text-muted">
              {business.city ? <span>{business.city}</span> : null}
              <span>{business.currency}</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function CategoryNavigation({
  categories,
  template,
  language
}: {
  categories: PublicMenuCategory[];
  template: PublicMenuTemplateDefinition;
  language: string | null;
}) {
  if (categories.length === 0) {
    return null;
  }

  const baseClass =
    template.layoutVariant === 'minimal-list'
      ? 'border-b border-transparent px-1 py-2 text-sm font-semibold text-muted transition hover:border-coral hover:text-ink'
      : template.layoutVariant === 'editorial-premium'
        ? 'shrink-0 rounded-full border border-[#d8c29f] bg-[#fff8f2] px-4 py-2 text-sm font-semibold text-[#12392F]'
        : template.layoutVariant === 'street-rows'
          ? 'shrink-0 rounded-md bg-[#1F2933] px-4 py-2 text-sm font-black uppercase text-white shadow-[0_3px_0_#FF6B4A]'
          : 'shrink-0 rounded-full border border-borderSoft bg-white px-4 py-2 text-sm font-semibold text-ink shadow-sm';

  return (
    <section className="sticky top-0 z-10 mx-auto mt-6 max-w-5xl px-4 py-3 backdrop-blur">
      <div className="flex gap-2 overflow-x-auto pb-1">
        {categories.map((category) => (
          <a key={category.id} href={`#category-${category.id}`} dir={isRtlLanguage(language) ? 'rtl' : 'ltr'} className={baseClass}>
            {getCategoryName(category, language)}
          </a>
        ))}
      </div>
    </section>
  );
}

function LoyaltyBlock({
  menu,
  template,
  loyaltyContext
}: {
  menu: PublicMenuResponse;
  template: PublicMenuTemplateDefinition;
  loyaltyContext: PublicLoyaltyContext | null;
}) {
  if (!loyaltyContext) {
    return null;
  }

  const { loyaltyProgram } = loyaltyContext;
  const premium = template.layoutVariant === 'editorial-premium';
  const street = template.layoutVariant === 'street-rows';
  const minimal = template.layoutVariant === 'minimal-list';

  const textDirection = isRtlLanguage(menu.business.language) ? 'rtl' : 'ltr';

  return (
    <section className="mx-auto mt-6 max-w-5xl px-4">
      <div
        className={
          premium
            ? 'rounded-xl bg-[#12392F] p-5 text-white shadow-sm'
            : street
              ? 'rounded-xl border-2 border-[#FF6B4A] bg-white p-5 shadow-[0_8px_0_#FFD5C8]'
              : minimal
                ? 'border-y border-neutral-200 py-5'
                : 'rounded-xl border border-borderSoft bg-white p-5 shadow-sm'
        }
      >
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div className="min-w-0">
            <p className={premium ? 'text-sm font-semibold uppercase text-[#F5C56A]' : 'text-sm font-semibold uppercase text-green-dark'}>
              Loyalty
            </p>
            <h2
              dir={textDirection}
              className={premium ? 'mt-2 break-words text-2xl font-bold text-white' : 'mt-2 break-words text-2xl font-bold text-ink'}
            >
              {loyaltyProgram.name}
            </h2>
            <p className={premium ? 'mt-2 text-sm leading-6 text-white/75' : 'mt-2 text-sm leading-6 text-muted'}>
              Earn stamps toward {loyaltyProgram.rewardName}.
            </p>
          </div>
          <Link
            href={`/m/${menu.business.slug}/loyalty`}
            className={
              premium
                ? 'inline-flex w-fit rounded-full bg-[#F59E0B] px-5 py-3 text-sm font-bold text-[#12392F]'
                : 'inline-flex w-fit rounded-full bg-coral px-5 py-3 text-sm font-bold text-white transition hover:bg-coralDark'
            }
          >
            Join loyalty
          </Link>
        </div>
      </div>
    </section>
  );
}

function ItemImage({ item, name, className }: { item: PublicMenuItem; name: string; className: string }) {
  if (item.imageUrl) {
    return <img src={item.imageUrl} alt={name} className={`${className} object-cover`} />;
  }

  return <PlaceholderImage label="Image" className={className} />;
}

function MenuItemCard({
  item,
  currency,
  template,
  slug,
  language
}: {
  item: PublicMenuItem;
  currency: string;
  template: PublicMenuTemplateDefinition;
  slug: string;
  language: string | null;
}) {
  const name = getItemName(item, language);
  const description = getItemDescription(item, language);
  const price = formatPrice(item.price, currency);
  const href = `/m/${slug}/item/${item.id}`;
  const soldOut = !item.isAvailable;
  const textDirection = isRtlLanguage(language) ? 'rtl' : 'ltr';

  if (template.layoutVariant === 'editorial-premium') {
    return (
      <Link
        href={href}
        className="group overflow-hidden rounded-xl border border-[#e7d7c1] bg-white shadow-sm transition hover:-translate-y-0.5 hover:shadow-md"
      >
        <ItemImage item={item} name={name} className="aspect-[4/3] w-full" />
        <div className="p-4">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
            <h3 dir={textDirection} className="text-lg font-bold text-ink">{name}</h3>
            <span className="w-fit shrink-0 text-sm font-bold text-[#12392F]">{price}</span>
          </div>
          {description ? <p dir={textDirection} className="mt-2 line-clamp-2 text-sm leading-6 text-muted">{description}</p> : null}
          <p className="mt-4 text-xs font-bold uppercase text-[#F59E0B]">{soldOut ? 'Sold out' : 'Available'}</p>
        </div>
      </Link>
    );
  }

  if (template.layoutVariant === 'street-rows') {
    return (
      <Link href={href} className="grid gap-3 rounded-xl border-2 border-[#FFD5C8] bg-white p-3 transition hover:border-[#FF6B4A] sm:grid-cols-[120px_1fr_112px]">
        <ItemImage item={item} name={name} className="hidden aspect-square rounded-lg sm:block" />
        <div className="min-w-0">
          <h3 dir={textDirection} className="text-lg font-black uppercase leading-tight text-ink">{name}</h3>
          {description ? <p dir={textDirection} className="mt-2 line-clamp-2 text-sm leading-6 text-muted">{description}</p> : null}
          {soldOut ? <p className="mt-3 text-xs font-black uppercase text-danger">Sold out</p> : null}
        </div>
        <div className="flex w-fit items-center justify-center rounded-lg bg-[#FF6B4A] px-4 py-3 text-center text-sm font-black text-white sm:w-auto sm:px-2">
          {price}
        </div>
      </Link>
    );
  }

  if (template.layoutVariant === 'minimal-list') {
    return (
      <Link href={href} className="grid gap-4 border-b border-neutral-200 py-5 transition hover:border-coral sm:grid-cols-[1fr_120px] sm:items-center">
        <div>
          <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
            <h3 dir={textDirection} className="text-lg font-semibold text-ink">{name}</h3>
            <span className="w-fit shrink-0 text-sm font-semibold text-ink">{price}</span>
          </div>
          {description ? <p dir={textDirection} className="mt-2 max-w-2xl text-sm leading-6 text-muted">{description}</p> : null}
          {soldOut ? <p className="mt-2 text-xs font-semibold uppercase text-danger">Sold out</p> : null}
        </div>
        <ItemImage item={item} name={name} className="aspect-[4/3] w-full rounded-lg sm:aspect-square" />
      </Link>
    );
  }

  return (
    <Link href={href} className="grid grid-cols-[104px_1fr] gap-4 rounded-xl border border-borderSoft bg-white p-3 shadow-sm transition hover:border-coral sm:grid-cols-[132px_1fr]">
      <ItemImage item={item} name={name} className="aspect-square rounded-lg" />
      <div className="min-w-0">
        <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
          <h3 dir={textDirection} className="text-lg font-bold text-ink">{name}</h3>
          <span className="w-fit shrink-0 rounded-full bg-[#FFF0EA] px-3 py-1 text-sm font-bold text-coralDark">{price}</span>
        </div>
        {description ? <p dir={textDirection} className="mt-2 line-clamp-2 text-sm leading-6 text-muted">{description}</p> : null}
        <p className={soldOut ? 'mt-3 text-xs font-semibold uppercase text-danger' : 'mt-3 text-xs font-semibold uppercase text-green-dark'}>
          {soldOut ? 'Sold out' : 'Available'}
        </p>
      </div>
    </Link>
  );
}

function EmptyMenuState({ template }: { template: PublicMenuTemplateDefinition }) {
  const premium = template.layoutVariant === 'editorial-premium';

  return (
    <section className="mx-auto mt-8 max-w-5xl px-4">
      <div className={premium ? 'rounded-xl bg-[#12392F] p-6 text-center text-white' : 'rounded-xl border border-borderSoft bg-white p-6 text-center shadow-sm'}>
        <h2 className={premium ? 'text-xl font-bold text-white' : 'text-xl font-bold text-ink'}>No menu items yet</h2>
        <p className={premium ? 'mt-2 text-sm leading-6 text-white/75' : 'mt-2 text-sm leading-6 text-muted'}>
          This public menu is available, but it does not have active items yet.
        </p>
      </div>
    </section>
  );
}

function CategorySection({
  category,
  menu,
  template
}: {
  category: PublicMenuCategory;
  menu: PublicMenuResponse;
  template: PublicMenuTemplateDefinition;
}) {
  const language = menu.business.language;
  const textDirection = isRtlLanguage(language) ? 'rtl' : 'ltr';
  const gridClass =
    template.layoutVariant === 'editorial-premium'
      ? 'mt-4 grid gap-4 sm:grid-cols-2'
      : template.layoutVariant === 'minimal-list'
        ? 'mt-1'
        : 'mt-3 grid gap-3';

  return (
    <section id={`category-${category.id}`} className="scroll-mt-24">
      <div className={template.layoutVariant === 'minimal-list' ? 'mb-2' : ''}>
        <h2
          dir={textDirection}
          className={
            template.layoutVariant === 'street-rows'
              ? 'text-2xl font-black uppercase text-ink'
              : template.layoutVariant === 'editorial-premium'
                ? 'text-2xl font-bold text-[#12392F]'
                : 'text-xl font-bold text-ink'
          }
        >
          {getCategoryName(category, language)}
        </h2>
      </div>
      {category.items.length > 0 ? (
        <div className={gridClass}>
          {category.items.map((item) => (
            <MenuItemCard
              key={item.id}
              item={item}
              currency={menu.business.currency}
              template={template}
              slug={menu.business.slug}
              language={language}
            />
          ))}
        </div>
      ) : (
        <p className="mt-3 rounded-lg border border-borderSoft bg-white p-4 text-sm text-muted">
          No available items in this category.
        </p>
      )}
    </section>
  );
}

export function PublicMenuTemplateView({ menu, template, loyaltyContext = null }: PublicMenuTemplateViewProps) {
  const direction = isRtlLanguage(menu.business.language) ? 'rtl' : 'ltr';
  const hasMenuItems = menu.categories.some((category) => category.items.length > 0);

  return (
    <main dir="ltr" lang={menu.business.language || undefined} className={templateShellClass(template)}>
      <div data-direction={direction}>
        <MerchantHeader menu={menu} template={template} />
        <CategoryNavigation categories={menu.categories} template={template} language={menu.business.language} />
        <LoyaltyBlock menu={menu} template={template} loyaltyContext={loyaltyContext} />

        {!hasMenuItems ? (
          <EmptyMenuState template={template} />
        ) : (
          <section className="mx-auto mt-8 grid max-w-5xl gap-10 px-4">
            {menu.categories.map((category) => (
              <CategorySection key={category.id} category={category} menu={menu} template={template} />
            ))}
          </section>
        )}
      </div>
    </main>
  );
}

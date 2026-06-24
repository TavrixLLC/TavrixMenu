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

function getCategoryAnchor(category: PublicMenuCategory) {
  return `category-${category.id}`;
}

function MerchantImage({
  src,
  alt,
  label,
  slot,
  className
}: {
  src: string | null;
  alt: string;
  label: string;
  slot: string;
  className: string;
}) {
  const state = src ? 'image' : 'placeholder';

  return (
    <div
      className={className}
      data-slot={slot}
      data-component="merchant-media"
      data-state={state}
      data-has-image={src ? 'true' : 'false'}
    >
      {src ? <img src={src} alt={alt} /> : <PlaceholderImage label={label} />}
    </div>
  );
}

function ItemImage({ item, name }: { item: PublicMenuItem; name: string }) {
  const state = item.imageUrl ? 'image' : 'placeholder';

  return (
    <div
      className="waflo-menu__item-image"
      data-slot="item-image"
      data-component="item-image"
      data-state={state}
      data-has-image={item.imageUrl ? 'true' : 'false'}
    >
      {item.imageUrl ? <img src={item.imageUrl} alt={name} /> : <PlaceholderImage label="Menu item image" />}
    </div>
  );
}

function MerchantHeader({ menu }: { menu: PublicMenuResponse }) {
  const { business } = menu;
  const direction = isRtlLanguage(business.language) ? 'rtl' : 'ltr';
  const locationText = business.city || `/m/${business.slug}`;

  return (
    <header className="waflo-menu__hero" data-slot="merchant-hero" data-component="merchant-header">
      <MerchantImage
        src={business.coverUrl}
        alt={`${business.name} cover`}
        label="Business cover"
        slot="merchant-cover"
        className="waflo-menu__cover"
      />

      <section className="waflo-menu__identity" data-slot="merchant-identity" data-component="merchant-identity">
        <MerchantImage
          src={business.logoUrl}
          alt={`${business.name} logo`}
          label="Business logo"
          slot="merchant-logo"
          className="waflo-menu__logo"
        />
        <div className="waflo-menu__identity-copy" data-slot="merchant-copy">
          <p className="waflo-menu__merchant-type" data-slot="merchant-type">
            {business.type || 'Public menu'}
          </p>
          <h1 className="waflo-menu__merchant-name" data-slot="merchant-name" dir={direction}>
            {business.name}
          </h1>
          <dl className="waflo-menu__metadata" data-slot="merchant-metadata" data-component="metadata-list">
            <div data-component="metadata-item">
              <dt>Location</dt>
              <dd>{locationText}</dd>
            </div>
            <div data-component="metadata-item">
              <dt>Currency</dt>
              <dd>{business.currency || 'Menu'}</dd>
            </div>
          </dl>
          <p className="waflo-menu__status" data-slot="merchant-status" data-component="merchant-status" data-state="available">
            Menu available
          </p>
        </div>
      </section>
    </header>
  );
}

function LoyaltyBlock({
  menu,
  loyaltyContext
}: {
  menu: PublicMenuResponse;
  loyaltyContext: PublicLoyaltyContext | null;
}) {
  if (!loyaltyContext) {
    return null;
  }

  const direction = isRtlLanguage(menu.business.language) ? 'rtl' : 'ltr';
  const { loyaltyProgram } = loyaltyContext;

  return (
    <section
      className="waflo-menu__loyalty"
      data-slot="loyalty-block"
      data-component="loyalty-block"
      data-state="enabled"
    >
      <div className="waflo-menu__loyalty-copy" data-slot="loyalty-copy">
        <p className="waflo-menu__eyebrow" data-slot="loyalty-eyebrow">
          Loyalty
        </p>
        <h2 className="waflo-menu__loyalty-title" data-slot="loyalty-title" dir={direction}>
          {loyaltyProgram.name}
        </h2>
        <p className="waflo-menu__loyalty-description" data-slot="loyalty-description" dir={direction}>
          Earn stamps toward {loyaltyProgram.rewardName}.
        </p>
      </div>
      <Link className="waflo-menu__loyalty-action" data-slot="loyalty-action" href={`/m/${menu.business.slug}/loyalty`}>
        Join loyalty
      </Link>
    </section>
  );
}

function CategoryNavigation({ menu }: { menu: PublicMenuResponse }) {
  if (menu.categories.length === 0) {
    return null;
  }

  const direction = isRtlLanguage(menu.business.language) ? 'rtl' : 'ltr';

  return (
    <nav
      className="waflo-menu__category-nav"
      data-slot="category-navigation"
      data-component="category-navigation"
      aria-label="Menu categories"
    >
      <ol className="waflo-menu__category-list" data-slot="category-navigation-list">
        {menu.categories.map((category) => (
          <li key={category.id} data-component="category-navigation-item" data-category-id={category.id}>
            <a
              className="waflo-menu__category-link"
              data-slot="category-link"
              data-component="category-link"
              data-category-id={category.id}
              href={`#${getCategoryAnchor(category)}`}
              dir={direction}
            >
              {getCategoryName(category, menu.business.language)}
            </a>
          </li>
        ))}
      </ol>
    </nav>
  );
}

function ItemStatus({ item }: { item: PublicMenuItem }) {
  const state = item.isAvailable ? 'available' : 'sold-out';

  return (
    <p className="waflo-menu__item-status" data-slot="item-status" data-component="item-status" data-state={state}>
      {item.isAvailable ? 'Available' : 'Sold out'}
    </p>
  );
}

function MenuItemCard({
  item,
  currency,
  slug,
  language
}: {
  item: PublicMenuItem;
  currency: string;
  slug: string;
  language: string | null;
}) {
  const direction = isRtlLanguage(language) ? 'rtl' : 'ltr';
  const name = getItemName(item, language);
  const description = getItemDescription(item, language);
  const price = formatPrice(item.price, currency);
  const state = item.isAvailable ? 'available' : 'sold-out';

  return (
    <li
      className="waflo-menu__item"
      data-slot="menu-item"
      data-component="menu-item"
      data-state={state}
      data-item-id={item.id}
      data-has-image={item.imageUrl ? 'true' : 'false'}
    >
      <Link className="waflo-menu__item-link" data-slot="item-link" href={`/m/${slug}/item/${item.id}`}>
        <ItemImage item={item} name={name} />
        <div className="waflo-menu__item-copy" data-slot="item-copy">
          <h3 className="waflo-menu__item-name" data-slot="item-name" dir={direction}>
            {name}
          </h3>
          {description ? (
            <p className="waflo-menu__item-description" data-slot="item-description" dir={direction}>
              {description}
            </p>
          ) : null}
          <div className="waflo-menu__item-badges" data-slot="item-badges">
            <ItemStatus item={item} />
          </div>
        </div>
        <p className="waflo-menu__item-price" data-slot="item-price">
          {price}
        </p>
      </Link>
    </li>
  );
}

function CategorySection({
  category,
  menu
}: {
  category: PublicMenuCategory;
  menu: PublicMenuResponse;
}) {
  const direction = isRtlLanguage(menu.business.language) ? 'rtl' : 'ltr';
  const hasItems = category.items.length > 0;

  return (
    <section
      id={getCategoryAnchor(category)}
      className="waflo-menu__category"
      data-slot="category-section"
      data-component="category-section"
      data-category-id={category.id}
      data-state={hasItems ? 'ready' : 'empty'}
    >
      <header className="waflo-menu__category-header" data-slot="category-header">
        <h2 className="waflo-menu__category-title" data-slot="category-title" dir={direction}>
          {getCategoryName(category, menu.business.language)}
        </h2>
      </header>

      {hasItems ? (
        <ol className="waflo-menu__items" data-slot="item-list" data-component="item-list">
          {category.items.map((item) => (
            <MenuItemCard
              key={item.id}
              item={item}
              currency={menu.business.currency}
              slug={menu.business.slug}
              language={menu.business.language}
            />
          ))}
        </ol>
      ) : (
        <div className="waflo-menu__category-empty" data-slot="empty-state" data-component="menu-state" data-state="empty-category">
          <p>No available items in this category.</p>
        </div>
      )}
    </section>
  );
}

function EmptyMenuState() {
  return (
    <section className="waflo-menu__empty" data-slot="empty-state" data-component="menu-state" data-state="empty-menu">
      <h2>No menu items yet</h2>
      <p>This public menu is available, but it does not have active items yet.</p>
    </section>
  );
}

function AiRecommendationSlot() {
  return (
    <section
      className="waflo-menu__ai-recommendation"
      data-slot="ai-recommendation"
      data-component="ai-recommendation"
      data-state="not-configured"
      hidden
    />
  );
}

function MenuFooter({ businessName }: { businessName: string }) {
  return (
    <footer className="waflo-menu__footer" data-slot="footer-branding" data-component="footer-branding">
      <p>{businessName} menu powered by Waflo</p>
    </footer>
  );
}

export function PublicMenuTemplateView({ menu, template, loyaltyContext = null }: PublicMenuTemplateViewProps) {
  const direction = isRtlLanguage(menu.business.language) ? 'rtl' : 'ltr';
  const hasMenuItems = menu.categories.some((category) => category.items.length > 0);

  return (
    <main
      className={`waflo-menu ${template.cssClass}`}
      data-template={template.id}
      data-business-slug={menu.business.slug}
      data-component="public-menu"
      data-state={hasMenuItems ? 'ready' : 'empty'}
      data-dir={direction}
      data-loyalty-enabled={loyaltyContext ? 'true' : 'false'}
      lang={menu.business.language || undefined}
      dir={direction}
    >
      <div className="waflo-menu__shell" data-slot="merchant-shell" data-component="menu-shell">
        <MerchantHeader menu={menu} />
        <LoyaltyBlock menu={menu} loyaltyContext={loyaltyContext} />
        <CategoryNavigation menu={menu} />
        <AiRecommendationSlot />

        <section className="waflo-menu__body" data-slot="menu-body" data-component="menu-body">
          {hasMenuItems ? (
            menu.categories.map((category) => <CategorySection key={category.id} category={category} menu={menu} />)
          ) : (
            <EmptyMenuState />
          )}
        </section>

        <MenuFooter businessName={menu.business.name} />
      </div>
    </main>
  );
}

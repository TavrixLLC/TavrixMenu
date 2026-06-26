import Link from 'next/link';

export const MENU_UNAVAILABLE_MESSAGE =
  'We could not load this menu right now. Please refresh the page or try the menu link again in a moment.';

export const ITEM_NOT_AVAILABLE_MESSAGE =
  'This item is not available on the menu right now. Please go back to the menu and choose another item.';

export const ITEM_UNAVAILABLE_MESSAGE =
  'We could not load this item right now. Please refresh the page or go back to the menu.';

export function MenuState({
  slug,
  title,
  message,
  state
}: {
  slug: string;
  title: string;
  message: string;
  state: 'not-found' | 'error';
}) {
  return (
    <main
      className="waflo-menu waflo-template-waflo-warm"
      data-template="waflo-warm"
      data-business-slug={slug}
      data-component="public-menu"
      data-state={state}
      data-dir="ltr"
      data-loyalty-enabled="false"
      lang="en"
      dir="ltr"
    >
      <section className="waflo-menu__shell" data-slot="merchant-shell" data-component="menu-shell">
        <div className="waflo-menu__state" data-slot="error-state" data-component="menu-state" data-state={state}>
          <p className="waflo-menu__eyebrow">Public menu</p>
          <h1>{title}</h1>
          <p>{message}</p>
        </div>
      </section>
    </main>
  );
}

export function DetailState({
  slug,
  title,
  message
}: {
  slug: string;
  title: string;
  message: string;
}) {
  return (
    <main
      className="waflo-menu waflo-template-waflo-warm"
      data-template="waflo-warm"
      data-business-slug={slug}
      data-component="public-menu"
      data-state="detail-error"
      data-dir="ltr"
      data-loyalty-enabled="false"
      lang="en"
      dir="ltr"
    >
      <section className="waflo-menu__shell" data-slot="merchant-shell" data-component="menu-shell">
        <Link href={`/m/${slug}`} className="waflo-item-detail__back">
          Back to menu
        </Link>
        <div className="waflo-menu__state" data-slot="error-state" data-component="menu-state" data-state="detail-error">
          <p className="waflo-menu__eyebrow">Menu item</p>
          <h1>{title}</h1>
          <p>{message}</p>
        </div>
      </section>
    </main>
  );
}

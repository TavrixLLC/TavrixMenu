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
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col justify-center bg-cream px-4 py-12">
      <Link href={`/m/${slug}`} className="text-sm font-semibold text-muted">
        Back to menu
      </Link>
      <section className="mt-5 rounded-xl border border-borderSoft bg-white p-6 shadow-sm">
        <p className="text-sm font-semibold uppercase text-coral">Menu item</p>
        <h1 className="mt-2 text-3xl font-bold text-ink">{title}</h1>
        <p className="mt-3 text-base leading-7 text-muted">{message}</p>
      </section>
    </main>
  );
}

import Link from 'next/link';

export default function HomePage() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col justify-center px-6 py-12">
      <p className="text-sm font-semibold uppercase tracking-wide text-mint">Public menu shell</p>
      <h1 className="mt-3 text-4xl font-bold text-ink">Tavrix Menu Customer Web</h1>
      <p className="mt-4 max-w-xl text-base leading-7 text-neutral-600">
        Customers browse public menu pages directly in the browser without logging in or downloading an app.
      </p>
      <Link
        href="/m/tavrix-cafe"
        className="mt-8 inline-flex w-fit rounded-md bg-ink px-5 py-3 text-sm font-semibold text-white"
      >
        View mock menu
      </Link>
    </main>
  );
}

export default function LoginPage() {
  return (
    <main className="flex min-h-screen items-center bg-[#f6f7f9] px-6 py-12">
      <section className="mx-auto w-full max-w-md">
        <p className="text-sm font-bold text-accent">Tavrix Menu Internal</p>
        <h1 className="mt-3 text-3xl font-extrabold text-ink">Service owner login</h1>
        <p className="mt-4 text-base leading-7 text-neutral-600">
          This dashboard is reserved for Tavrix service owners and administrators.
        </p>

        <div className="mt-8 rounded-lg border border-dashed border-amber-300 bg-amber-50 p-4">
          <p className="text-sm font-extrabold text-amber-800">Auth pending backend integration</p>
          <p className="mt-1 text-sm leading-6 text-amber-800">
            Production admin auth is not enabled in this shell. Connect the approved admin auth flow before allowing
            live access.
          </p>
        </div>

        <div className="mt-4 rounded-lg border border-neutral-200 bg-white p-5 shadow-sm">
          <label className="block text-sm font-bold text-neutral-600" htmlFor="admin-email">
            Admin email
          </label>
          <input
            id="admin-email"
            disabled
            placeholder="admin@example.com"
            className="mt-2 w-full rounded-md border border-neutral-200 bg-neutral-50 px-3 py-3 text-sm text-neutral-500"
          />
          <button
            type="button"
            disabled
            className="mt-4 w-full rounded-md bg-neutral-300 px-4 py-3 text-sm font-extrabold text-neutral-600"
          >
            Sign in disabled
          </button>
        </div>
      </section>
    </main>
  );
}

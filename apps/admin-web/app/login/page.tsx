export default function LoginPage() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col justify-center px-6 py-12">
      <p className="text-sm font-semibold text-accent">Tavrix Menu Admin</p>
      <h1 className="mt-3 text-3xl font-bold text-ink">Service owner login</h1>
      <p className="mt-4 text-base leading-7 text-neutral-600">
        This internal dashboard is for Tavrix Menu service owners only.
      </p>
      {/* Clerk SignIn will be connected here for service-owner admin access. */}
      <div className="mt-8 rounded-lg border border-dashed border-neutral-300 bg-white p-6 text-sm font-semibold text-neutral-500">
        Clerk login placeholder
      </div>
    </main>
  );
}

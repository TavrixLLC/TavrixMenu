import { SignIn } from '@clerk/nextjs';
import Link from 'next/link';
import { isClerkConfigured } from '../lib/config';

export default function LoginPage() {
  const clerkConfigured = isClerkConfigured();

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col justify-center px-6 py-12">
      <p className="text-sm font-semibold text-accent">Tavrix Menu Admin</p>
      <h1 className="mt-3 text-3xl font-bold text-ink">Service owner login</h1>
      <p className="mt-4 text-base leading-7 text-neutral-600">
        This internal dashboard is for Tavrix Menu service owners only.
      </p>

      {clerkConfigured ? (
        <div className="mt-8">
          <SignIn routing="hash" fallbackRedirectUrl="/" signUpFallbackRedirectUrl="/" />
        </div>
      ) : (
        <div className="mt-8 rounded-lg border border-amber-200 bg-amber-50 p-6">
          <p className="text-sm font-semibold uppercase text-amber-700">Clerk is not configured</p>
          <p className="mt-2 text-sm leading-6 text-amber-900">
            Add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY to enable real service-owner login. The admin app remains build-safe
            without live Clerk credentials.
          </p>
          <Link
            href="/"
            className="mt-4 inline-flex rounded-md border border-amber-300 bg-white px-3 py-2 text-sm font-semibold text-amber-800"
          >
            Back to admin shell
          </Link>
        </div>
      )}
    </main>
  );
}

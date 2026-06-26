'use client';

import Link from 'next/link';
import { SignInButton, SignOutButton, SignedIn, SignedOut, UserButton } from '@clerk/nextjs';

type ClerkConfigProps = {
  clerkConfigured: boolean;
};

export function AdminAuthControls({ clerkConfigured }: ClerkConfigProps) {
  if (!clerkConfigured) {
    return (
      <Link
        href="/login"
        className="rounded-md border border-amber-200 bg-amber-50 px-3 py-2 text-sm font-semibold text-amber-800"
      >
        Sign-in unavailable
      </Link>
    );
  }

  return (
    <div className="flex items-center gap-2">
      <SignedOut>
        <Link
          href="/login"
          className="rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-semibold text-neutral-700"
        >
          Sign in
        </Link>
      </SignedOut>
      <SignedIn>
        <UserButton afterSignOutUrl="/login" />
        <SignOutButton>
          <button
            type="button"
            className="rounded-md border border-neutral-200 bg-white px-3 py-2 text-sm font-semibold text-neutral-700"
          >
            Sign out
          </button>
        </SignOutButton>
      </SignedIn>
    </div>
  );
}

export function AdminAuthBoundary({
  children,
  clerkConfigured
}: Readonly<
  ClerkConfigProps & {
    children: React.ReactNode;
  }
>) {
  if (!clerkConfigured) {
    return (
      <section className="rounded-lg border border-amber-200 bg-amber-50 p-5">
        <p className="text-sm font-semibold uppercase text-amber-700">Sign-in unavailable</p>
        <h2 className="mt-2 text-xl font-bold text-ink">Owner access is not ready yet</h2>
        <p className="mt-2 max-w-3xl text-sm leading-6 text-amber-900">
          The owner dashboard needs sign-in to be enabled before restaurant teams can manage their menu here.
        </p>
      </section>
    );
  }

  return (
    <>
      <SignedOut>
        <section className="rounded-lg border border-neutral-200 bg-white p-5">
          <p className="text-sm font-semibold uppercase text-accent">Admin login required</p>
          <h2 className="mt-2 text-xl font-bold text-ink">Sign in to manage your business</h2>
          <p className="mt-2 max-w-3xl text-sm leading-6 text-neutral-600">
            This area is for owners and approved team members. Customers can still browse public menus without signing in.
          </p>
          <div className="mt-4">
            <SignInButton mode="modal">
              <button type="button" className="rounded-md bg-accent px-4 py-2 text-sm font-semibold text-white">
                Sign in
              </button>
            </SignInButton>
          </div>
        </section>
      </SignedOut>
      <SignedIn>{children}</SignedIn>
    </>
  );
}

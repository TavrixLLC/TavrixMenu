'use client';

import Link from 'next/link';
import { SignInButton, SignOutButton, SignedIn, SignedOut, UserButton } from '@clerk/nextjs';
import { WafloButton, WafloEmptyState, WafloErrorState, WafloLinkButton } from './waflo';

type ClerkConfigProps = {
  clerkConfigured: boolean;
};

export function AdminAuthControls({ clerkConfigured }: ClerkConfigProps) {
  if (!clerkConfigured) {
    return (
      <Link href="/login" className="rounded-lg border border-waflo-gold/25 bg-waflo-goldSoft px-3 py-2 text-sm font-bold text-waflo-goldDark">
        Sign-in unavailable
      </Link>
    );
  }

  return (
    <div className="flex items-center gap-2">
      <SignedOut>
        <Link
          href="/login"
          className="rounded-lg border border-waflo-border bg-white px-3 py-2 text-sm font-bold text-waflo-charcoal shadow-subtle transition hover:bg-waflo-cream"
        >
          Sign in
        </Link>
      </SignedOut>
      <SignedIn>
        <UserButton afterSignOutUrl="/login" />
        <SignOutButton>
          <button type="button" className="rounded-lg border border-waflo-border bg-white px-3 py-2 text-sm font-bold text-waflo-charcoal shadow-subtle transition hover:bg-waflo-cream">
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
      <WafloErrorState
        title="Owner access is not ready yet"
        description="The dashboard needs sign-in to be enabled before restaurant teams can manage their menu here."
        action={<WafloLinkButton href="/login">Open login</WafloLinkButton>}
      />
    );
  }

  return (
    <>
      <SignedOut>
        <WafloEmptyState
          title="Sign in to manage your business"
          description="This area is for owners and approved team members. Customers can still browse public menus without signing in."
          action={
            <SignInButton mode="modal">
              <WafloButton>Sign in</WafloButton>
            </SignInButton>
          }
        />
      </SignedOut>
      <SignedIn>{children}</SignedIn>
    </>
  );
}

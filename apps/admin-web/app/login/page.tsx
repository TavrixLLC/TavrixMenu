import { SignIn } from '@clerk/nextjs';
import Link from 'next/link';
import { isClerkConfigured } from '../lib/config';
import { WafloErrorState } from '../components/waflo';

export default function LoginPage() {
  const clerkConfigured = isClerkConfigured();

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col justify-center px-6 py-12">
      <p className="text-xs font-bold uppercase tracking-wide text-waflo-coral">Waflo Admin</p>
      <h1 className="mt-3 text-4xl font-bold tracking-tight text-waflo-charcoal">Owner login</h1>
      <p className="mt-4 text-base leading-7 text-waflo-muted">
        Sign in to manage your menu, loyalty program, wallet appearance, and launch operations.
      </p>

      {clerkConfigured ? (
        <div className="mt-8">
          <SignIn routing="hash" fallbackRedirectUrl="/" signUpFallbackRedirectUrl="/" />
        </div>
      ) : (
        <div className="mt-8">
          <WafloErrorState
            title="Sign-in unavailable"
            description="Owner sign-in is not ready in this environment yet. Menu browsing remains available from public links."
            action={
              <Link href="/" className="inline-flex min-h-11 items-center rounded-lg border border-waflo-border bg-white px-4 py-2 text-sm font-bold text-waflo-charcoal">
                Back to dashboard
              </Link>
            }
          />
        </div>
      )}
    </main>
  );
}

import Link from 'next/link';
import { PlaceholderImage } from '../../../components/PlaceholderImage';
import { isAppleWalletButtonEnabled } from '../../../lib/apple-wallet';
import { getApiBaseUrl } from '../../../lib/public-menu';
import { fetchPublicLoyaltyContext, type PublicLoyaltyContext } from '../../../lib/public-loyalty';
import { LoyaltyEnrollmentClient } from './LoyaltyEnrollmentClient';

type LoyaltyPageProps = {
  params: Promise<{
    slug: string;
  }>;
};

function LoyaltyState({
  slug,
  title,
  message
}: {
  slug: string;
  title: string;
  message: string;
}) {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col justify-center bg-[#fafaf7] px-4 py-12">
      <Link href={`/m/${slug}`} className="text-sm font-semibold text-neutral-600">
        Back to menu
      </Link>
      <section className="mt-5 rounded-lg border border-neutral-200 bg-white p-6 shadow-sm">
        <p className="text-sm font-semibold uppercase text-mint">Loyalty card</p>
        <h1 className="mt-2 text-3xl font-bold text-ink">{title}</h1>
        <p className="mt-3 text-base leading-7 text-neutral-600">{message}</p>
      </section>
    </main>
  );
}

function LoyaltyHeader({ context }: { context: PublicLoyaltyContext }) {
  const { business, loyaltyProgram } = context;

  return (
    <section className="mx-auto w-full max-w-4xl px-4 pt-4">
      {business.coverUrl ? (
        <img
          src={business.coverUrl}
          alt={`${business.name} cover`}
          className="h-40 w-full rounded-lg object-cover sm:h-56"
        />
      ) : (
        <PlaceholderImage label="Cover" className="h-40 w-full rounded-lg sm:h-56" />
      )}

      <div className="-mt-8 flex items-end gap-4 px-3">
        {business.logoUrl || loyaltyProgram.logoUrl ? (
          <img
            src={business.logoUrl || loyaltyProgram.logoUrl || ''}
            alt={`${business.name} logo`}
            className="h-20 w-20 shrink-0 rounded-lg bg-white object-cover shadow-sm"
          />
        ) : (
          <PlaceholderImage label="Logo" className="h-20 w-20 shrink-0 rounded-lg bg-white shadow-sm" />
        )}
        <div className="pb-1">
          <p className="text-sm font-semibold text-mint">Loyalty rewards</p>
          <h1 className="text-3xl font-bold text-ink">{business.name}</h1>
          <p className="mt-1 text-sm text-neutral-500">
            Join, collect stamps, and keep your card ready on this phone.
          </p>
        </div>
      </div>
    </section>
  );
}

export default async function LoyaltyPage({ params }: LoyaltyPageProps) {
  const { slug } = await params;
  const result = await fetchPublicLoyaltyContext(slug);

  if (result.status === 'not-found') {
    return (
      <LoyaltyState
        slug={slug}
        title="Loyalty card unavailable"
        message="This business does not have an active public loyalty card right now."
      />
    );
  }

  if (result.status === 'error') {
    return (
      <LoyaltyState
        slug={slug}
        title="Loyalty card unavailable"
        message="We could not load the loyalty card right now. Please refresh the page or ask staff for help."
      />
    );
  }

  const context = result.data;
  const { loyaltyProgram } = context;

  return (
    <main className="min-h-screen bg-[#fafaf7] pb-10">
      <LoyaltyHeader context={context} />

      <section className="mx-auto mt-8 grid w-full max-w-4xl gap-5 px-4 lg:grid-cols-[1fr_380px]">
        <div className="rounded-lg border border-neutral-200 bg-white p-5 shadow-sm">
          <p className="text-sm font-semibold uppercase text-mint">Loyalty card</p>
          <h2 className="mt-2 text-2xl font-bold text-ink">{loyaltyProgram.name}</h2>
          {loyaltyProgram.description ? (
            <p className="mt-3 text-base leading-7 text-neutral-700">{loyaltyProgram.description}</p>
          ) : null}

          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-4">
              <p className="text-sm font-semibold text-neutral-500">Stamp goal</p>
              <p className="mt-1 text-2xl font-bold text-ink">{loyaltyProgram.stampGoal}</p>
            </div>
            <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-4">
              <p className="text-sm font-semibold text-neutral-500">Reward</p>
              <p className="mt-1 text-lg font-bold text-ink">{loyaltyProgram.rewardName}</p>
            </div>
          </div>

          {loyaltyProgram.rewardDescription ? (
            <p className="mt-5 rounded-md bg-emerald-50 p-4 text-sm leading-6 text-emerald-800">
              {loyaltyProgram.rewardDescription}
            </p>
          ) : null}

          {loyaltyProgram.terms ? (
            <p className="mt-3 rounded-md bg-neutral-50 p-4 text-sm leading-6 text-neutral-600">
              {loyaltyProgram.terms}
            </p>
          ) : null}

          <p className="mt-5 text-sm leading-6 text-neutral-600">
            Join once from this phone. Staff add stamps in the shop, and your
            live web card shows the newest progress first.
          </p>
        </div>

        <section className="rounded-lg border border-neutral-200 bg-white p-5 shadow-sm">
          <h2 className="text-xl font-bold text-ink">Get your card</h2>
          <p className="mt-2 text-sm leading-6 text-neutral-600">
            One quick step, then we will show the right Wallet button for this
            device.
          </p>
          <div className="mt-5">
            <LoyaltyEnrollmentClient
              slug={context.business.slug}
              apiBaseUrl={getApiBaseUrl()}
              appleWalletEnabled={isAppleWalletButtonEnabled()}
            />
          </div>
        </section>
      </section>
    </main>
  );
}

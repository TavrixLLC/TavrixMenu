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
    <main className="flex min-h-screen bg-[#fff8f2] px-4 py-12">
      <section className="mx-auto flex w-full max-w-3xl flex-col justify-center">
      <Link
        href={`/m/${slug}`}
        className="inline-flex min-h-11 w-fit items-center text-sm font-bold text-[#667085] transition hover:text-[#151b24]"
      >
        Back to menu
      </Link>
      <section className="mt-5 rounded-[24px] border border-[#f0dfd2] bg-white/90 p-6 shadow-[0_24px_70px_rgb(21_27_36_/_10%)] backdrop-blur">
        <p className="text-sm font-black uppercase text-[#c84326]">Loyalty card</p>
        <h1 className="mt-2 text-3xl font-black tracking-[-0.02em] text-[#151b24]">{title}</h1>
        <p className="mt-3 text-base leading-7 text-[#667085]">{message}</p>
      </section>
      </section>
    </main>
  );
}

function LoyaltyHeader({ context }: { context: PublicLoyaltyContext }) {
  const { business, loyaltyProgram } = context;

  return (
    <section className="mx-auto w-full max-w-5xl px-4 pt-4">
      {business.coverUrl ? (
        <img
          src={business.coverUrl}
          alt={`${business.name} cover`}
          className="h-48 w-full rounded-[28px] object-cover shadow-[0_24px_70px_rgb(21_27_36_/_10%)] sm:h-64"
        />
      ) : (
        <PlaceholderImage label="Cover" className="h-48 w-full rounded-[28px] shadow-[0_24px_70px_rgb(21_27_36_/_10%)] sm:h-64" />
      )}

      <div className="-mt-10 flex items-end gap-4 px-4">
        {business.logoUrl || loyaltyProgram.logoUrl ? (
          <img
            src={business.logoUrl || loyaltyProgram.logoUrl || ''}
            alt={`${business.name} logo`}
            className="h-24 w-24 shrink-0 rounded-2xl border-4 border-white bg-white object-cover shadow-[0_16px_40px_rgb(21_27_36_/_10%)]"
          />
        ) : (
          <PlaceholderImage label="Logo" className="h-24 w-24 shrink-0 rounded-2xl border-4 border-white bg-white shadow-[0_16px_40px_rgb(21_27_36_/_10%)]" />
        )}
        <div className="rounded-3xl border border-[#f0dfd2] bg-white/90 px-4 py-3 shadow-[0_16px_40px_rgb(21_27_36_/_8%)] backdrop-blur">
          <p className="text-sm font-black uppercase text-[#c84326]">Web loyalty card</p>
          <h1 className="text-3xl font-black tracking-[-0.02em] text-[#151b24]">{business.name}</h1>
          <p className="mt-1 text-sm font-semibold text-[#667085]">/m/{business.slug}/loyalty</p>
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
    <main className="min-h-screen bg-[radial-gradient(circle_at_top_left,rgb(255_107_74_/_10%),transparent_32rem),#fff8f2] pb-10">
      <LoyaltyHeader context={context} />

      <section className="mx-auto mt-10 grid w-full max-w-5xl gap-5 px-4 lg:grid-cols-[1fr_400px]">
        <div className="rounded-[24px] border border-[#f0dfd2] bg-white/90 p-6 shadow-[0_20px_60px_rgb(21_27_36_/_8%)] backdrop-blur">
          <p className="text-sm font-black uppercase text-[#c84326]">Loyalty card</p>
          <h2 className="mt-2 text-3xl font-black tracking-[-0.02em] text-[#151b24]">{loyaltyProgram.name}</h2>
          {loyaltyProgram.description ? (
            <p className="mt-3 text-base leading-7 text-[#667085]">{loyaltyProgram.description}</p>
          ) : null}

          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            <div className="rounded-2xl border border-[#f0dfd2] bg-[#fff8f2] p-4">
              <p className="text-sm font-bold text-[#667085]">Stamp goal</p>
              <p className="mt-1 text-3xl font-black text-[#151b24]">{loyaltyProgram.stampGoal}</p>
            </div>
            <div className="rounded-2xl border border-[#f0dfd2] bg-[#fff8f2] p-4">
              <p className="text-sm font-bold text-[#667085]">Reward</p>
              <p className="mt-1 text-lg font-black text-[#151b24]">{loyaltyProgram.rewardName}</p>
            </div>
          </div>

          {loyaltyProgram.rewardDescription ? (
            <p className="mt-5 rounded-2xl bg-emerald-50 p-4 text-sm font-medium leading-6 text-emerald-800">
              {loyaltyProgram.rewardDescription}
            </p>
          ) : null}

          {loyaltyProgram.terms ? (
            <p className="mt-3 rounded-2xl bg-white p-4 text-sm leading-6 text-[#667085] ring-1 ring-[#f0dfd2]">
              {loyaltyProgram.terms}
            </p>
          ) : null}

          <p className="mt-5 text-sm leading-6 text-[#667085]">
            Join once and keep this web loyalty card in your browser. Staff will add stamps and redeem rewards in the
            shop.
          </p>
        </div>

        <section className="rounded-[24px] border border-[#f0dfd2] bg-white/90 p-6 shadow-[0_20px_60px_rgb(21_27_36_/_8%)] backdrop-blur">
          <h2 className="text-2xl font-black tracking-[-0.02em] text-[#151b24]">Join loyalty</h2>
          <p className="mt-2 text-sm leading-6 text-[#667085]">
            Join in one step. We will show the best wallet option for this device as soon as your card is ready.
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

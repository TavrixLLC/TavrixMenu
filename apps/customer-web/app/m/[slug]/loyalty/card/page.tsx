import { getApiBaseUrl } from '../../../../lib/public-menu';
import { LoyaltyCardClient } from './LoyaltyCardClient';

type LoyaltyCardPageProps = {
  params: Promise<{
    slug: string;
  }>;
  searchParams: Promise<{
    token?: string | string[];
  }>;
};

function readSearchToken(value: string | string[] | undefined) {
  if (Array.isArray(value)) {
    return value[0] || null;
  }

  return value || null;
}

export default async function LoyaltyCardPage({ params, searchParams }: LoyaltyCardPageProps) {
  const { slug } = await params;
  const query = await searchParams;

  return <LoyaltyCardClient slug={slug} initialToken={readSearchToken(query.token)} apiBaseUrl={getApiBaseUrl()} />;
}

export function buildLoyaltyTransferUrl(
  origin: string,
  slug: string,
  transferToken: string
) {
  return `${origin}/m/${encodeURIComponent(slug)}/loyalty#transfer=${encodeURIComponent(transferToken)}`;
}

export function extractLoyaltyTransferToken(value: string): string | null {
  const normalized = value.trim();

  if (!normalized) {
    return null;
  }

  if (!normalized.includes('#')) {
    return normalized;
  }

  try {
    const url = new URL(normalized);
    return new URLSearchParams(url.hash.slice(1)).get('transfer')?.trim() || null;
  } catch {
    const hash = normalized.slice(normalized.indexOf('#') + 1);
    return new URLSearchParams(hash).get('transfer')?.trim() || null;
  }
}

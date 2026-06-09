const DEFAULT_API_BASE_URL = 'http://localhost:3000';

export type PublicMenuBusiness = {
  id: string;
  name: string;
  slug: string;
  type: string | null;
  logoUrl: string | null;
  coverUrl: string | null;
  currency: string;
  language: string | null;
  city: string | null;
};

export type PublicMenuItem = {
  id: string;
  nameAr: string | null;
  nameEn: string | null;
  descriptionAr: string | null;
  descriptionEn: string | null;
  price: string;
  imageUrl: string | null;
  isAvailable: boolean;
  sortOrder: number;
};

export type PublicMenuCategory = {
  id: string;
  nameAr: string | null;
  nameEn: string | null;
  sortOrder: number;
  items: PublicMenuItem[];
};

export type PublicMenuResponse = {
  business: PublicMenuBusiness;
  categories: PublicMenuCategory[];
};

export type PublicMenuResult =
  | {
      status: 'ok';
      data: PublicMenuResponse;
      apiUrl: string;
    }
  | {
      status: 'not-found';
      apiUrl: string;
    }
  | {
      status: 'error';
      apiUrl: string;
      message: string;
    };

export function getApiBaseUrl() {
  return (process.env.API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE_URL || DEFAULT_API_BASE_URL).replace(/\/+$/, '');
}

export async function fetchPublicMenu(slug: string): Promise<PublicMenuResult> {
  const apiBaseUrl = getApiBaseUrl();
  const apiUrl = `${apiBaseUrl}/public/m/${encodeURIComponent(slug)}`;

  try {
    const response = await fetch(apiUrl, {
      cache: 'no-store',
      headers: {
        Accept: 'application/json'
      }
    });

    if (response.status === 404) {
      return {
        status: 'not-found',
        apiUrl
      };
    }

    if (!response.ok) {
      return {
        status: 'error',
        apiUrl,
        message: `API returned HTTP ${response.status}`
      };
    }

    const data = (await response.json()) as PublicMenuResponse;

    return {
      status: 'ok',
      data,
      apiUrl
    };
  } catch (error) {
    return {
      status: 'error',
      apiUrl,
      message: error instanceof Error ? error.message : 'Unable to reach the public menu API'
    };
  }
}

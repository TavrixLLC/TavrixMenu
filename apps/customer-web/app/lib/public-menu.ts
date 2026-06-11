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

export type PublicMenuCategorySummary = Omit<PublicMenuCategory, 'items'>;

export type PublicMenuItemDetail = {
  business: PublicMenuBusiness | null;
  category: PublicMenuCategorySummary | null;
  item: PublicMenuItem;
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

export type PublicMenuItemResult =
  | {
      status: 'ok';
      data: PublicMenuItemDetail;
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

function getAvailableMenu(menu: PublicMenuResponse): PublicMenuResponse {
  return {
    ...menu,
    categories: menu.categories.map((category) => ({
      ...category,
      items: category.items.filter((item) => item.isAvailable)
    }))
  };
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null ? (value as Record<string, unknown>) : null;
}

function readString(value: unknown): string | null {
  return typeof value === 'string' ? value : null;
}

function readNullableString(value: unknown): string | null {
  return typeof value === 'string' ? value : null;
}

function readNumber(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function readBoolean(value: unknown, fallback = false): boolean {
  return typeof value === 'boolean' ? value : fallback;
}

function parsePublicMenuBusiness(value: unknown): PublicMenuBusiness | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const name = readString(record.name);
  const slug = readString(record.slug);

  if (!id || !name || !slug) {
    return null;
  }

  return {
    id,
    name,
    slug,
    type: readNullableString(record.type),
    logoUrl: readNullableString(record.logoUrl),
    coverUrl: readNullableString(record.coverUrl),
    currency: readString(record.currency) || '',
    language: readNullableString(record.language),
    city: readNullableString(record.city)
  };
}

function parsePublicMenuCategorySummary(value: unknown): PublicMenuCategorySummary | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);

  if (!id) {
    return null;
  }

  return {
    id,
    nameAr: readNullableString(record.nameAr),
    nameEn: readNullableString(record.nameEn),
    sortOrder: readNumber(record.sortOrder)
  };
}

function parsePublicMenuItem(value: unknown): PublicMenuItem | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const price = readString(record.price);

  if (!id || !price) {
    return null;
  }

  return {
    id,
    nameAr: readNullableString(record.nameAr),
    nameEn: readNullableString(record.nameEn),
    descriptionAr: readNullableString(record.descriptionAr),
    descriptionEn: readNullableString(record.descriptionEn),
    price,
    imageUrl: readNullableString(record.imageUrl),
    isAvailable: readBoolean(record.isAvailable, true),
    sortOrder: readNumber(record.sortOrder)
  };
}

function parsePublicItemDetail(value: unknown): PublicMenuItemDetail | null {
  const directItem = parsePublicMenuItem(value);

  if (directItem) {
    return directItem.isAvailable
      ? {
          business: null,
          category: null,
          item: directItem
        }
      : null;
  }

  const record = asRecord(value);
  const item = parsePublicMenuItem(record?.item);

  if (!item?.isAvailable) {
    return null;
  }

  return {
    business: parsePublicMenuBusiness(record?.business),
    category: parsePublicMenuCategorySummary(record?.category),
    item
  };
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

    const data = getAvailableMenu((await response.json()) as PublicMenuResponse);

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

export async function fetchPublicItem(slug: string, itemId: string): Promise<PublicMenuItemResult> {
  const apiBaseUrl = getApiBaseUrl();
  const apiUrl = `${apiBaseUrl}/public/m/${encodeURIComponent(slug)}/items/${encodeURIComponent(itemId)}`;

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

    const data = parsePublicItemDetail(await response.json());

    if (!data) {
      return {
        status: 'not-found',
        apiUrl
      };
    }

    return {
      status: 'ok',
      data,
      apiUrl
    };
  } catch (error) {
    return {
      status: 'error',
      apiUrl,
      message: error instanceof Error ? error.message : 'Unable to reach the public menu item API'
    };
  }
}

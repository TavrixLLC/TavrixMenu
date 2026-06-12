export type AdminUser = {
  id: string;
  clerkUserId: string;
  name: string | null;
  email: string | null;
  phone: string | null;
  status: string;
  createdAt: string;
  updatedAt: string;
};

export type AdminBusiness = {
  id: string;
  name: string;
  slug: string;
  type: string;
  city: string | null;
  currency: string;
  language: string;
  logoUrl: string | null;
  coverUrl: string | null;
  status?: string;
};

export type AdminMembership = {
  id: string;
  role: string;
  isActive: boolean;
  business: AdminBusiness;
};

export type AdminOnboarding = {
  hasBusiness: boolean;
  activeBusinessCount: number;
  recommendedNextStep: string | null;
};

export type AdminBusinessSummary = {
  id: string;
  name: string;
  slug: string;
  type: string;
  role: string;
};

export type AdminPermissions = {
  canManageBusiness: boolean;
  canManageMenu: boolean;
  canManageMembers: boolean;
  canViewMembers: boolean;
  canViewPublicLink: boolean;
};

export type AdminPublicMenuLink = {
  slug: string;
  path: string;
  url: string;
  qrPayload: string;
};

export type AdminDashboardCounts = {
  activeCategories: number;
  inactiveCategories: number;
  activeItems: number;
  inactiveItems: number;
  availableItems: number;
  unavailableItems: number;
  activeMembers: number;
};

export type AdminDashboardOnboardingHints = {
  hasCategories: boolean;
  hasItems: boolean;
  hasPublicMenuReady: boolean;
  recommendedNextStep: 'ADD_CATEGORY' | 'ADD_ITEM' | 'SHARE_PUBLIC_MENU' | 'READY' | string | null;
};

export type AdminDashboardSummary = {
  business: AdminBusiness;
  currentUser: {
    role: string;
    permissions: AdminPermissions;
  };
  counts: AdminDashboardCounts;
  publicMenu: Pick<AdminPublicMenuLink, 'path' | 'url' | 'qrPayload'>;
  onboardingHints: AdminDashboardOnboardingHints;
};

export type AdminCategory = {
  id: string;
  businessId: string;
  nameAr: string;
  nameEn: string | null;
  sortOrder: number;
  isActive: boolean;
};

export type AdminMenuItem = {
  id: string;
  businessId: string;
  categoryId: string;
  nameAr: string;
  nameEn: string | null;
  descriptionAr: string | null;
  descriptionEn: string | null;
  price: string;
  imageUrl: string | null;
  isAvailable: boolean;
  sortOrder: number;
};

export type AdminReorderOrder = {
  id: string;
  sortOrder: number;
};

export type AdminBusinessPublicLink = {
  businessId: string;
  slug: string;
  publicMenuPath: string;
  publicMenuUrl: string;
  qrPayload: string;
};

export type AdminBusinessAppContext = {
  business: AdminBusiness;
  currentMembership: Pick<AdminMembership, 'id' | 'role' | 'isActive'>;
  permissions: AdminPermissions;
  publicMenu: AdminPublicMenuLink;
};

export type AdminMeResponse = {
  user: AdminUser;
  memberships: AdminMembership[];
  onboarding: AdminOnboarding;
  businesses: AdminBusinessSummary[];
};

export type AdminMeFetchResult =
  | {
      status: 'ok';
      data: AdminMeResponse;
      apiUrl: string;
    }
  | {
      status: 'auth-error' | 'error';
      apiUrl: string;
      message: string;
    };

export type AdminApiResult<T> =
  | {
      status: 'ok';
      data: T;
      apiUrl: string;
    }
  | {
      status: 'auth-error' | 'forbidden' | 'validation-error' | 'error';
      apiUrl: string;
      message: string;
    };

function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null ? (value as Record<string, unknown>) : null;
}

function readString(value: unknown): string | null {
  return typeof value === 'string' ? value : null;
}

function readNullableString(value: unknown): string | null {
  return typeof value === 'string' ? value : null;
}

function readBoolean(value: unknown): boolean {
  return typeof value === 'boolean' ? value : false;
}

function readNumber(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function compact<T>(items: Array<T | null>): T[] {
  return items.filter((item): item is T => item !== null);
}

function parseAdminUser(value: unknown): AdminUser | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const clerkUserId = readString(record.clerkUserId);

  if (!id || !clerkUserId) {
    return null;
  }

  return {
    id,
    clerkUserId,
    name: readNullableString(record.name),
    email: readNullableString(record.email),
    phone: readNullableString(record.phone),
    status: readString(record.status) || 'UNKNOWN',
    createdAt: readString(record.createdAt) || '',
    updatedAt: readString(record.updatedAt) || ''
  };
}

function parseAdminBusiness(value: unknown): AdminBusiness | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const name = readString(record.name);
  const slug = readString(record.slug);
  const type = readString(record.type);

  if (!id || !name || !slug || !type) {
    return null;
  }

  return {
    id,
    name,
    slug,
    type,
    city: readNullableString(record.city),
    currency: readString(record.currency) || 'IQD',
    language: readString(record.language) || 'ar',
    logoUrl: readNullableString(record.logoUrl),
    coverUrl: readNullableString(record.coverUrl),
    status: readString(record.status) || undefined
  };
}

function parseMembership(value: unknown): AdminMembership | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const role = readString(record.role);
  const business = parseAdminBusiness(record.business);

  if (!id || !role || !business) {
    return null;
  }

  return {
    id,
    role,
    isActive: readBoolean(record.isActive),
    business
  };
}

function parseOnboarding(value: unknown): AdminOnboarding {
  const record = asRecord(value);

  if (!record) {
    return {
      hasBusiness: false,
      activeBusinessCount: 0,
      recommendedNextStep: null
    };
  }

  return {
    hasBusiness: readBoolean(record.hasBusiness),
    activeBusinessCount: readNumber(record.activeBusinessCount),
    recommendedNextStep: readNullableString(record.recommendedNextStep)
  };
}

function parseBusinessSummary(value: unknown): AdminBusinessSummary | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const name = readString(record.name);
  const slug = readString(record.slug);
  const type = readString(record.type);
  const role = readString(record.role);

  if (!id || !name || !slug || !type || !role) {
    return null;
  }

  return {
    id,
    name,
    slug,
    type,
    role
  };
}

function parsePermissions(value: unknown): AdminPermissions {
  const record = asRecord(value);

  if (!record) {
    return {
      canManageBusiness: false,
      canManageMenu: false,
      canManageMembers: false,
      canViewMembers: false,
      canViewPublicLink: false
    };
  }

  return {
    canManageBusiness: readBoolean(record.canManageBusiness),
    canManageMenu: readBoolean(record.canManageMenu),
    canManageMembers: readBoolean(record.canManageMembers),
    canViewMembers: readBoolean(record.canViewMembers),
    canViewPublicLink: readBoolean(record.canViewPublicLink)
  };
}

function parseDashboardCounts(value: unknown): AdminDashboardCounts {
  const record = asRecord(value);

  return {
    activeCategories: readNumber(record?.activeCategories),
    inactiveCategories: readNumber(record?.inactiveCategories),
    activeItems: readNumber(record?.activeItems),
    inactiveItems: readNumber(record?.inactiveItems),
    availableItems: readNumber(record?.availableItems),
    unavailableItems: readNumber(record?.unavailableItems),
    activeMembers: readNumber(record?.activeMembers)
  };
}

function parseDashboardOnboardingHints(value: unknown): AdminDashboardOnboardingHints {
  const record = asRecord(value);

  return {
    hasCategories: readBoolean(record?.hasCategories),
    hasItems: readBoolean(record?.hasItems),
    hasPublicMenuReady: readBoolean(record?.hasPublicMenuReady),
    recommendedNextStep: readNullableString(record?.recommendedNextStep)
  };
}

function parseDashboardPublicMenu(value: unknown): AdminDashboardSummary['publicMenu'] | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const path = readString(record.path);
  const url = readString(record.url);
  const qrPayload = readString(record.qrPayload);

  if (!path || !url || !qrPayload) {
    return null;
  }

  return {
    path,
    url,
    qrPayload
  };
}

function parseDashboardSummary(value: unknown): AdminDashboardSummary | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const business = parseAdminBusiness(record.business);
  const currentUserRecord = asRecord(record.currentUser);
  const role = readString(currentUserRecord?.role);
  const publicMenu = parseDashboardPublicMenu(record.publicMenu);

  if (!business || !role || !publicMenu) {
    return null;
  }

  return {
    business,
    currentUser: {
      role,
      permissions: parsePermissions(currentUserRecord?.permissions)
    },
    counts: parseDashboardCounts(record.counts),
    publicMenu,
    onboardingHints: parseDashboardOnboardingHints(record.onboardingHints)
  };
}

function parseCategory(value: unknown): AdminCategory | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const businessId = readString(record.businessId);
  const nameAr = readString(record.nameAr);

  if (!id || !businessId || !nameAr) {
    return null;
  }

  return {
    id,
    businessId,
    nameAr,
    nameEn: readNullableString(record.nameEn),
    sortOrder: readNumber(record.sortOrder),
    isActive: readBoolean(record.isActive)
  };
}

function parseMenuItem(value: unknown): AdminMenuItem | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const businessId = readString(record.businessId);
  const categoryId = readString(record.categoryId);
  const nameAr = readString(record.nameAr);
  const price = readString(record.price);

  if (!id || !businessId || !categoryId || !nameAr || !price) {
    return null;
  }

  return {
    id,
    businessId,
    categoryId,
    nameAr,
    nameEn: readNullableString(record.nameEn),
    descriptionAr: readNullableString(record.descriptionAr),
    descriptionEn: readNullableString(record.descriptionEn),
    price,
    imageUrl: readNullableString(record.imageUrl),
    isAvailable: readBoolean(record.isAvailable),
    sortOrder: readNumber(record.sortOrder)
  };
}

function parseCategories(value: unknown): AdminCategory[] | null {
  if (!Array.isArray(value)) {
    return null;
  }

  return compact(value.map(parseCategory));
}

function parseMenuItems(value: unknown): AdminMenuItem[] | null {
  if (!Array.isArray(value)) {
    return null;
  }

  return compact(value.map(parseMenuItem));
}

function parsePublicLink(value: unknown): AdminBusinessPublicLink | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const businessId = readString(record.businessId);
  const slug = readString(record.slug);
  const publicMenuPath = readString(record.publicMenuPath);
  const publicMenuUrl = readString(record.publicMenuUrl);
  const qrPayload = readString(record.qrPayload);

  if (!businessId || !slug || !publicMenuPath || !publicMenuUrl || !qrPayload) {
    return null;
  }

  return {
    businessId,
    slug,
    publicMenuPath,
    publicMenuUrl,
    qrPayload
  };
}

export function parseAdminMeResponse(value: unknown): AdminMeResponse | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const user = parseAdminUser(record.user);

  if (!user) {
    return null;
  }

  return {
    user,
    memberships: compact((Array.isArray(record.memberships) ? record.memberships : []).map(parseMembership)),
    onboarding: parseOnboarding(record.onboarding),
    businesses: compact((Array.isArray(record.businesses) ? record.businesses : []).map(parseBusinessSummary))
  };
}

function apiBase(apiBaseUrl: string) {
  return apiBaseUrl.replace(/\/+$/, '');
}

function buildApiUrl(apiBaseUrl: string, path: string) {
  return `${apiBase(apiBaseUrl)}${path.startsWith('/') ? path : `/${path}`}`;
}

function formatApiErrorMessage(status: number, payload: unknown) {
  const record = asRecord(payload);
  const message = record?.message;

  if (Array.isArray(message) && message.every((item) => typeof item === 'string')) {
    return message.join(' ');
  }

  if (typeof message === 'string') {
    return message;
  }

  if (typeof record?.error === 'string') {
    return record.error;
  }

  return `API returned HTTP ${status}.`;
}

async function requestAdminJson<T>({
  apiBaseUrl,
  token,
  path,
  method = 'GET',
  body,
  signal,
  parse,
  contractName
}: {
  apiBaseUrl: string;
  token: string | null;
  path: string;
  method?: 'GET' | 'PATCH';
  body?: unknown;
  signal?: AbortSignal;
  parse: (value: unknown) => T | null;
  contractName: string;
}): Promise<AdminApiResult<T>> {
  const apiUrl = buildApiUrl(apiBaseUrl, path);

  if (!token) {
    return {
      status: 'auth-error',
      apiUrl,
      message: 'Clerk did not return a JWT for the signed-in session.'
    };
  }

  try {
    const response = await fetch(apiUrl, {
      cache: 'no-store',
      method,
      headers: {
        Accept: 'application/json',
        Authorization: `Bearer ${token}`,
        ...(body === undefined ? {} : { 'Content-Type': 'application/json' })
      },
      body: body === undefined ? undefined : JSON.stringify(body),
      signal
    });

    const responseText = await response.text();
    let payload: unknown = null;

    if (responseText) {
      try {
        payload = JSON.parse(responseText);
      } catch {
        payload = responseText;
      }
    }

    if (response.status === 401) {
      return {
        status: 'auth-error',
        apiUrl,
        message: formatApiErrorMessage(response.status, payload)
      };
    }

    if (response.status === 403) {
      return {
        status: 'forbidden',
        apiUrl,
        message: formatApiErrorMessage(response.status, payload)
      };
    }

    if (response.status === 400) {
      return {
        status: 'validation-error',
        apiUrl,
        message: formatApiErrorMessage(response.status, payload)
      };
    }

    if (!response.ok) {
      return {
        status: 'error',
        apiUrl,
        message: formatApiErrorMessage(response.status, payload)
      };
    }

    const data = parse(payload);

    if (!data) {
      return {
        status: 'error',
        apiUrl,
        message: `The response did not match the ${contractName} contract.`
      };
    }

    return {
      status: 'ok',
      data,
      apiUrl
    };
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      return {
        status: 'error',
        apiUrl,
        message: 'The request was cancelled.'
      };
    }

    return {
      status: 'error',
      apiUrl,
      message: error instanceof Error ? error.message : `Unable to reach ${apiUrl}.`
    };
  }
}

export async function fetchAdminMe({
  apiBaseUrl,
  token,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  signal?: AbortSignal;
}): Promise<AdminMeFetchResult> {
  const apiUrl = `${apiBaseUrl.replace(/\/+$/, '')}/me`;

  if (!token) {
    return {
      status: 'auth-error',
      apiUrl,
      message: 'Clerk did not return a JWT for the signed-in session.'
    };
  }

  try {
    const response = await fetch(apiUrl, {
      cache: 'no-store',
      headers: {
        Accept: 'application/json',
        Authorization: `Bearer ${token}`
      },
      signal
    });

    if (response.status === 401 || response.status === 403) {
      return {
        status: 'auth-error',
        apiUrl,
        message: `Backend rejected the Clerk JWT with HTTP ${response.status}.`
      };
    }

    if (!response.ok) {
      return {
        status: 'error',
        apiUrl,
        message: `API returned HTTP ${response.status}.`
      };
    }

    const data = parseAdminMeResponse(await response.json());

    if (!data) {
      return {
        status: 'error',
        apiUrl,
        message: 'The /me response did not match the Sprint 3 contract.'
      };
    }

    return {
      status: 'ok',
      data,
      apiUrl
    };
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      return {
        status: 'error',
        apiUrl,
        message: 'The /me request was cancelled.'
      };
    }

    return {
      status: 'error',
      apiUrl,
      message: error instanceof Error ? error.message : 'Unable to reach the backend /me endpoint.'
    };
  }
}

export function getDashboardSummary({
  apiBaseUrl,
  token,
  businessId,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/dashboard-summary`,
    signal,
    parse: parseDashboardSummary,
    contractName: 'GET /businesses/{id}/dashboard-summary'
  });
}

export function getCategories({
  apiBaseUrl,
  token,
  businessId,
  includeInactive,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  includeInactive: boolean;
  signal?: AbortSignal;
}) {
  const search = includeInactive ? '?includeInactive=true' : '';

  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/categories${search}`,
    signal,
    parse: parseCategories,
    contractName: 'GET /businesses/{id}/categories'
  });
}

export function getItems({
  apiBaseUrl,
  token,
  businessId,
  includeInactive,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  includeInactive: boolean;
  signal?: AbortSignal;
}) {
  const search = includeInactive ? '?includeInactive=true' : '';

  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/items${search}`,
    signal,
    parse: parseMenuItems,
    contractName: 'GET /businesses/{id}/items'
  });
}

export function reorderCategories({
  apiBaseUrl,
  token,
  businessId,
  orders,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  orders: AdminReorderOrder[];
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/categories/reorder`,
    method: 'PATCH',
    body: { orders },
    signal,
    parse: parseCategories,
    contractName: 'PATCH /businesses/{id}/categories/reorder'
  });
}

export function reorderItems({
  apiBaseUrl,
  token,
  businessId,
  orders,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  orders: AdminReorderOrder[];
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/items/reorder`,
    method: 'PATCH',
    body: { orders },
    signal,
    parse: parseMenuItems,
    contractName: 'PATCH /businesses/{id}/items/reorder'
  });
}

export function restoreCategory({
  apiBaseUrl,
  token,
  categoryId,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  categoryId: string;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/categories/${encodeURIComponent(categoryId)}`,
    method: 'PATCH',
    body: { isActive: true },
    signal,
    parse: parseCategory,
    contractName: 'PATCH /categories/{id}'
  });
}

export function restoreItem({
  apiBaseUrl,
  token,
  itemId,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  itemId: string;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/items/${encodeURIComponent(itemId)}`,
    method: 'PATCH',
    body: { isAvailable: true },
    signal,
    parse: parseMenuItem,
    contractName: 'PATCH /items/{id}'
  });
}

export function getPublicLink({
  apiBaseUrl,
  token,
  businessId,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/public-link`,
    signal,
    parse: parsePublicLink,
    contractName: 'GET /businesses/{id}/public-link'
  });
}

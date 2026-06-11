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

import { getApiBaseUrl } from './public-menu';

export type PublicLoyaltyBusiness = {
  id: string;
  name: string;
  slug: string;
  type: string | null;
  city: string | null;
  logoUrl: string | null;
  coverUrl: string | null;
  currency: string;
  language: string | null;
};

export type PublicLoyaltyProgram = {
  id: string;
  name: string;
  description: string | null;
  stampGoal: number;
  rewardName: string;
  rewardDescription: string | null;
  cardColor: string | null;
  accentColor: string | null;
  logoUrl: string | null;
  terms: string | null;
};

export type PublicLoyaltyContext = {
  business: PublicLoyaltyBusiness;
  loyaltyProgram: PublicLoyaltyProgram;
  enrollment: {
    acceptsPhone: boolean;
    acceptsEmail: boolean;
    requiresOtp: boolean;
  };
};

export type PublicLoyaltyEnrollRequest = {
  phone: string;
  email?: string | null;
  name?: string | null;
  intent?: 'JOIN' | 'RECOVER';
};

export type PublicLoyaltyCardState = {
  stampCount: number;
  stampGoal: number;
  rewardReady: boolean;
  progressPercent: number;
  rewardName: string;
  programName: string;
  totalStampsEarned: number;
  totalRewardsRedeemed: number;
};

export type PublicLoyaltyEnrollment = {
  customer: {
    name: string | null;
  };
  business: {
    name: string;
    slug: string;
    logoUrl: string | null;
    coverUrl: string | null;
  };
  program: {
    name: string;
    stampGoal: number;
    rewardName: string;
    rewardDescription: string | null;
  };
  cardState: PublicLoyaltyCardState;
  cardAccess: {
    token: string;
    cardUrlPath: string;
  };
};

export type PublicLoyaltyCard = {
  business: {
    id: string | null;
    name: string;
    slug: string;
    logoUrl: string | null;
    coverUrl: string | null;
  };
  program: {
    name: string;
    stampGoal: number;
    rewardName: string;
    rewardDescription: string | null;
    terms: string | null;
  };
  customer: {
    name: string | null;
  };
  cardState: PublicLoyaltyCardState;
};

export type PublicLoyaltyContextResult =
  | {
      status: 'ok';
      data: PublicLoyaltyContext;
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

export type PublicLoyaltyEnrollResult =
  | {
      status: 'ok';
      data: PublicLoyaltyEnrollment;
      apiUrl: string;
    }
  | {
      status:
        | 'bad-request'
        | 'conflict'
        | 'not-found'
        | 'verification-required';
      apiUrl: string;
      message: string;
    }
  | {
      status: 'error';
      apiUrl: string;
      message: string;
    };

export type PublicLoyaltyCardResult =
  | {
      status: 'ok';
      data: PublicLoyaltyCard;
      apiUrl: string;
    }
  | {
      status: 'bad-request' | 'not-found';
      apiUrl: string;
      message: string;
    }
  | {
      status: 'error';
      apiUrl: string;
      message: string;
    };

function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null ? (value as Record<string, unknown>) : null;
}

function readString(value: unknown): string | null {
  return typeof value === 'string' ? value : null;
}

function readNumber(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function readBoolean(value: unknown, fallback = false): boolean {
  return typeof value === 'boolean' ? value : fallback;
}

function parseApiMessage(value: unknown, fallback: string): string {
  const record = asRecord(value);
  const message = record?.message;

  if (typeof message === 'string') {
    return message;
  }

  if (Array.isArray(message) && message.every((item) => typeof item === 'string')) {
    return message.join(' ');
  }

  return fallback;
}

function parseApiCode(value: unknown): string | null {
  return readString(asRecord(value)?.code);
}

function parseBusiness(value: unknown): PublicLoyaltyBusiness | null {
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
    type: readString(record.type),
    city: readString(record.city),
    logoUrl: readString(record.logoUrl),
    coverUrl: readString(record.coverUrl),
    currency: readString(record.currency) || '',
    language: readString(record.language)
  };
}

function parseProgram(value: unknown): PublicLoyaltyProgram | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const id = readString(record.id);
  const name = readString(record.name);
  const rewardName = readString(record.rewardName);

  if (!id || !name || !rewardName) {
    return null;
  }

  return {
    id,
    name,
    description: readString(record.description),
    stampGoal: readNumber(record.stampGoal),
    rewardName,
    rewardDescription: readString(record.rewardDescription),
    cardColor: readString(record.cardColor),
    accentColor: readString(record.accentColor),
    logoUrl: readString(record.logoUrl),
    terms: readString(record.terms)
  };
}

function parseCardState(value: unknown): PublicLoyaltyCardState | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const rewardName = readString(record.rewardName);
  const programName = readString(record.programName);

  if (!rewardName || !programName) {
    return null;
  }

  return {
    stampCount: readNumber(record.stampCount),
    stampGoal: readNumber(record.stampGoal),
    rewardReady: readBoolean(record.rewardReady),
    progressPercent: Math.min(Math.max(readNumber(record.progressPercent), 0), 100),
    rewardName,
    programName,
    totalStampsEarned: readNumber(record.totalStampsEarned),
    totalRewardsRedeemed: readNumber(record.totalRewardsRedeemed)
  };
}

function parseContext(value: unknown): PublicLoyaltyContext | null {
  const record = asRecord(value);
  const business = parseBusiness(record?.business);
  const loyaltyProgram = parseProgram(record?.loyaltyProgram);
  const enrollment = asRecord(record?.enrollment);

  if (!business || !loyaltyProgram || !enrollment) {
    return null;
  }

  return {
    business,
    loyaltyProgram,
    enrollment: {
      acceptsPhone: readBoolean(enrollment.acceptsPhone),
      acceptsEmail: readBoolean(enrollment.acceptsEmail),
      requiresOtp: readBoolean(enrollment.requiresOtp)
    }
  };
}

function parseEnrollment(value: unknown): PublicLoyaltyEnrollment | null {
  const record = asRecord(value);
  const customer = asRecord(record?.customer);
  const business = asRecord(record?.business);
  const program = asRecord(record?.program);
  const cardState = parseCardState(record?.cardState);
  const cardAccess = asRecord(record?.cardAccess);
  const businessName = readString(business?.name);
  const businessSlug = readString(business?.slug);
  const programName = readString(program?.name);
  const rewardName = readString(program?.rewardName);
  const token = readString(cardAccess?.token);
  const cardUrlPath = readString(cardAccess?.cardUrlPath);

  if (!businessName || !businessSlug || !programName || !rewardName || !cardState || !token || !cardUrlPath) {
    return null;
  }

  return {
    customer: {
      name: readString(customer?.name)
    },
    business: {
      name: businessName,
      slug: businessSlug,
      logoUrl: readString(business?.logoUrl),
      coverUrl: readString(business?.coverUrl)
    },
    program: {
      name: programName,
      stampGoal: readNumber(program?.stampGoal),
      rewardName,
      rewardDescription: readString(program?.rewardDescription)
    },
    cardState,
    cardAccess: {
      token,
      cardUrlPath
    }
  };
}

function parseCard(value: unknown): PublicLoyaltyCard | null {
  const record = asRecord(value);
  const business = asRecord(record?.business);
  const program = asRecord(record?.program);
  const customer = asRecord(record?.customer);
  const cardState = parseCardState(record?.cardState);
  const businessName = readString(business?.name);
  const businessSlug = readString(business?.slug);
  const programName = readString(program?.name);
  const rewardName = readString(program?.rewardName);

  if (!businessName || !businessSlug || !programName || !rewardName || !cardState) {
    return null;
  }

  return {
    business: {
      id: readString(business?.id),
      name: businessName,
      slug: businessSlug,
      logoUrl: readString(business?.logoUrl),
      coverUrl: readString(business?.coverUrl)
    },
    program: {
      name: programName,
      stampGoal: readNumber(program?.stampGoal),
      rewardName,
      rewardDescription: readString(program?.rewardDescription),
      terms: readString(program?.terms)
    },
    customer: {
      name: readString(customer?.name)
    },
    cardState
  };
}

export async function fetchPublicLoyaltyContext(
  slug: string,
  apiBaseUrl = getApiBaseUrl()
): Promise<PublicLoyaltyContextResult> {
  const apiUrl = `${apiBaseUrl}/public/m/${encodeURIComponent(slug)}/loyalty`;

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

    const data = parseContext(await response.json());

    if (!data) {
      return {
        status: 'error',
        apiUrl,
        message: 'API returned an unexpected loyalty context payload'
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
      message: error instanceof Error ? error.message : 'Unable to reach the public loyalty API'
    };
  }
}

export async function enrollPublicLoyaltyCustomer(
  slug: string,
  request: PublicLoyaltyEnrollRequest,
  apiBaseUrl = getApiBaseUrl()
): Promise<PublicLoyaltyEnrollResult> {
  const apiUrl = `${apiBaseUrl}/public/m/${encodeURIComponent(slug)}/loyalty/enroll`;

  try {
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(request)
    });
    const body = await response.json().catch(() => null);

    if (response.status === 400) {
      return {
        status: 'bad-request',
        apiUrl,
        message: parseApiMessage(body, 'Please enter a valid Iraqi phone number.')
      };
    }

    if (response.status === 404) {
      return {
        status: 'not-found',
        apiUrl,
        message: 'This business does not have an active loyalty card right now.'
      };
    }

    if (
      response.status === 403 &&
      parseApiCode(body) === 'RECOVERY_REQUIRES_VERIFICATION'
    ) {
      return {
        status: 'verification-required',
        apiUrl,
        message: 'Recovery requires phone verification or staff help.'
      };
    }

    if (response.status === 409) {
      return {
        status: 'conflict',
        apiUrl,
        message: 'The phone and email appear to belong to different customers. Please use one identifier or ask staff.'
      };
    }

    if (!response.ok) {
      return {
        status: 'error',
        apiUrl,
        message: `API returned HTTP ${response.status}`
      };
    }

    const data = parseEnrollment(body);

    if (!data) {
      return {
        status: 'error',
        apiUrl,
        message: 'API returned an unexpected enrollment payload'
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
      message: error instanceof Error ? error.message : 'Unable to reach the public loyalty API'
    };
  }
}

export async function fetchPublicLoyaltyCard(
  token: string,
  apiBaseUrl = getApiBaseUrl()
): Promise<PublicLoyaltyCardResult> {
  const apiUrl = `${apiBaseUrl}/public/loyalty/cards/${encodeURIComponent(token)}`;

  try {
    const response = await fetch(apiUrl, {
      cache: 'no-store',
      headers: {
        Accept: 'application/json'
      }
    });
    const body = await response.json().catch(() => null);

    if (response.status === 400) {
      return {
        status: 'bad-request',
        apiUrl,
        message: parseApiMessage(body, 'This loyalty card link is not valid.')
      };
    }

    if (response.status === 404) {
      return {
        status: 'not-found',
        apiUrl,
        message: 'This loyalty card could not be found. Please enroll again or ask staff.'
      };
    }

    if (!response.ok) {
      return {
        status: 'error',
        apiUrl,
        message: `API returned HTTP ${response.status}`
      };
    }

    const data = parseCard(body);

    if (!data) {
      return {
        status: 'error',
        apiUrl,
        message: 'API returned an unexpected card payload'
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
      message: error instanceof Error ? error.message : 'Unable to reach the public loyalty card API'
    };
  }
}

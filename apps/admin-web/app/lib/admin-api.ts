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
  menuTemplateId?: string;
  menuThemeOverrides?: Record<string, unknown> | null;
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
  canManageAppearance: boolean;
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
  menuAppearance?: AdminMenuAppearance;
  counts: AdminDashboardCounts;
  publicMenu: Pick<AdminPublicMenuLink, 'path' | 'url' | 'qrPayload'>;
  onboardingHints: AdminDashboardOnboardingHints;
};

export type AdminMenuAppearance = {
  businessId: string;
  menuTemplateId: string;
  effectiveTemplateId: string;
  fallbackApplied: boolean;
  defaultTemplateId: string;
  menuThemeOverrides: Record<string, unknown> | null;
};

export type AdminMenuTemplate = {
  id: string;
  displayName: string;
  description: string;
  bestFor: string;
  version: string;
  status: string;
  enabled: boolean;
  isDefault: boolean;
  preview: {
    previewColors: string[];
    previewLayout: string;
    thumbnailUrl: string | null;
    mobilePreviewUrl: string | null;
    desktopPreviewUrl: string | null;
  };
  supportedFeatures: Record<string, boolean>;
};

export type AdminMenuTemplateCatalog = {
  templates: AdminMenuTemplate[];
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

export type AdminLoyaltyProgram = {
  id: string;
  businessId: string | null;
  name: string;
  description: string | null;
  stampGoal: number;
  rewardName: string;
  rewardDescription: string | null;
  isActive: boolean;
  cardColor: string | null;
  accentColor: string | null;
  logoUrl: string | null;
  terms: string | null;
  createdAt: string | null;
  updatedAt: string | null;
};

export type AdminStampPresetKey = 'STAR' | 'COOKIE' | 'COFFEE' | 'BOWL' | 'BURGER' | 'PIZZA' | 'HEART' | 'CUPCAKE';
export type AdminWalletThemePresetKey = 'DEFAULT' | 'COFFEE' | 'RESTAURANT' | 'DESSERT' | 'MINIMAL' | 'CUSTOM';
export type AdminWalletColorMode = 'PRESET' | 'CUSTOM';
export type AdminStampLayoutVariant = 'MODERN' | 'COMPACT';

export type AdminWalletThemePalette = {
  walletBackgroundColor: string;
  imageBackgroundColor: string;
  imageSurfaceColor: string;
  imageAccentColor: string;
  imageTextColor: string;
  stampFilledColor: string;
  stampEmptyColor: string;
  rewardBannerColor: string;
};

export type AdminLoyaltyStampPreset = {
  key: AdminStampPresetKey;
  label: string;
};

export type AdminWalletThemePreset = {
  key: AdminWalletThemePresetKey;
  label: string;
  recommendedPalette: AdminWalletThemePalette;
};

export type AdminLoyaltyStampPresetCatalog = {
  presets: AdminLoyaltyStampPreset[];
  stampPresets: AdminLoyaltyStampPreset[];
  themePresets: AdminWalletThemePreset[];
  styleTypes: string[];
  colorModes: AdminWalletColorMode[];
  layoutVariants: AdminStampLayoutVariant[];
};

export type AdminLoyaltyStampStyle = AdminWalletThemePalette & {
  id: string | null;
  loyaltyProgramId: string;
  styleType: 'PRESET' | string;
  presetKey: AdminStampPresetKey;
  backgroundColor: string;
  accentColor: string;
  textColor: string;
  themePreset: AdminWalletThemePresetKey;
  colorMode: AdminWalletColorMode;
  layoutVariant: AdminStampLayoutVariant;
  isDefault: boolean;
  createdAt: string | null;
  updatedAt: string | null;
};

export type AdminLoyaltyStampStyleInput = AdminWalletThemePalette & {
  themePreset: AdminWalletThemePresetKey;
  colorMode: AdminWalletColorMode;
  presetKey: AdminStampPresetKey;
  layoutVariant: AdminStampLayoutVariant;
};

export type AdminLoyaltyCustomer = {
  id: string;
  phone: string | null;
  email: string | null;
  name: string | null;
};

export type AdminLoyaltyCardState = {
  stampCount: number;
  stampGoal: number;
  rewardReady: boolean;
  progressPercent: number;
  rewardName: string;
  programName: string;
};

export type AdminLoyaltyTransaction = {
  id: string;
  businessId: string | null;
  loyaltyProgramId: string | null;
  membershipId: string | null;
  customerId: string | null;
  actorUserId: string | null;
  type: string;
  stampsDelta: number;
  reason: string | null;
  createdAt: string | null;
};

export type AdminLoyaltyMembership = {
  id: string;
  businessId: string | null;
  loyaltyProgramId: string | null;
  customerId: string | null;
  stampCount: number;
  rewardReady: boolean;
  totalStampsEarned: number | null;
  totalRewardsRedeemed: number | null;
  status: string;
  customer: AdminLoyaltyCustomer | null;
  program: AdminLoyaltyProgram | null;
  cardState: AdminLoyaltyCardState | null;
  transactions: AdminLoyaltyTransaction[];
};

export type AdminLoyaltyEnrollResult = {
  customer: AdminLoyaltyCustomer;
  membership: AdminLoyaltyMembership;
  program: AdminLoyaltyProgram;
  cardState: AdminLoyaltyCardState;
};

export type AdminLoyaltyActionResult = {
  membership: AdminLoyaltyMembership;
  cardState: AdminLoyaltyCardState;
};

export type AdminLoyaltyProgramInput = {
  name: string;
  description?: string | null;
  stampGoal: number;
  rewardName: string;
  rewardDescription?: string | null;
  isActive: boolean;
  cardColor?: string | null;
  accentColor?: string | null;
  logoUrl?: string | null;
  terms?: string | null;
};

export type AdminEnrollLoyaltyCustomerInput = {
  phone?: string | null;
  email?: string | null;
  name?: string | null;
  programId?: string | null;
};

export type AdminAddStampsInput = {
  count: number;
  reason?: string | null;
};

export type AdminRedeemRewardInput = {
  reason?: string | null;
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

function readNullableRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null && !Array.isArray(value) ? (value as Record<string, unknown>) : null;
}

function readBoolean(value: unknown): boolean {
  return typeof value === 'boolean' ? value : false;
}

function readNumber(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function readOptionalNumber(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
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
    menuTemplateId: readString(record.menuTemplateId) || undefined,
    menuThemeOverrides: readNullableRecord(record.menuThemeOverrides),
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
      canViewPublicLink: false,
      canManageAppearance: false
    };
  }

  return {
    canManageBusiness: readBoolean(record.canManageBusiness),
    canManageMenu: readBoolean(record.canManageMenu),
    canManageMembers: readBoolean(record.canManageMembers),
    canViewMembers: readBoolean(record.canViewMembers),
    canViewPublicLink: readBoolean(record.canViewPublicLink),
    canManageAppearance: readBoolean(record.canManageAppearance)
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

function parseMenuAppearance(value: unknown): AdminMenuAppearance | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const businessId = readString(record.businessId);
  const menuTemplateId = readString(record.menuTemplateId);

  if (!businessId || !menuTemplateId) {
    return null;
  }

  return {
    businessId,
    menuTemplateId,
    effectiveTemplateId: readString(record.effectiveTemplateId) || menuTemplateId,
    fallbackApplied: readBoolean(record.fallbackApplied),
    defaultTemplateId: readString(record.defaultTemplateId) || 'waflo-warm',
    menuThemeOverrides: readNullableRecord(record.menuThemeOverrides)
  };
}

function parseMenuTemplate(value: unknown): AdminMenuTemplate | null {
  const record = asRecord(value);
  const preview = asRecord(record?.preview);
  const supportedFeatures = readNullableRecord(record?.supportedFeatures);

  if (!record || !preview || !supportedFeatures) {
    return null;
  }

  const id = readString(record.id);
  const displayName = readString(record.displayName);
  const description = readString(record.description);
  const bestFor = readString(record.bestFor);
  const version = readString(record.version);
  const status = readString(record.status);
  const previewLayout = readString(preview.previewLayout);
  const previewColors = Array.isArray(preview.previewColors)
    ? preview.previewColors.filter((color): color is string => typeof color === 'string')
    : [];

  if (!id || !displayName || !description || !bestFor || !version || !status || !previewLayout || previewColors.length === 0) {
    return null;
  }

  return {
    id,
    displayName,
    description,
    bestFor,
    version,
    status,
    enabled: readBoolean(record.enabled),
    isDefault: readBoolean(record.isDefault),
    preview: {
      previewColors,
      previewLayout,
      thumbnailUrl: readNullableString(preview.thumbnailUrl),
      mobilePreviewUrl: readNullableString(preview.mobilePreviewUrl),
      desktopPreviewUrl: readNullableString(preview.desktopPreviewUrl)
    },
    supportedFeatures: Object.fromEntries(
      Object.entries(supportedFeatures).filter((entry): entry is [string, boolean] => typeof entry[1] === 'boolean')
    )
  };
}

function parseMenuTemplateCatalog(value: unknown): AdminMenuTemplateCatalog | null {
  const record = asRecord(value);
  const templates = Array.isArray(record?.templates)
    ? compact(record.templates.map(parseMenuTemplate))
    : null;

  if (!templates || templates.length === 0) {
    return null;
  }

  return { templates };
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
    menuAppearance: parseMenuAppearance(record.menuAppearance) || undefined,
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

function parseLoyaltyProgram(value: unknown): AdminLoyaltyProgram | null {
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
    businessId: readNullableString(record.businessId),
    name,
    description: readNullableString(record.description),
    stampGoal: readNumber(record.stampGoal),
    rewardName,
    rewardDescription: readNullableString(record.rewardDescription),
    isActive: typeof record.isActive === 'boolean' ? record.isActive : true,
    cardColor: readNullableString(record.cardColor),
    accentColor: readNullableString(record.accentColor),
    logoUrl: readNullableString(record.logoUrl),
    terms: readNullableString(record.terms),
    createdAt: readNullableString(record.createdAt),
    updatedAt: readNullableString(record.updatedAt)
  };
}

function parseNullableLoyaltyProgram(value: unknown): { program: AdminLoyaltyProgram | null } | null {
  if (value === null) {
    return { program: null };
  }

  const program = parseLoyaltyProgram(value);

  if (!program) {
    return null;
  }

  return { program };
}

const stampPresetKeys: AdminStampPresetKey[] = ['STAR', 'COOKIE', 'COFFEE', 'BOWL', 'BURGER', 'PIZZA', 'HEART', 'CUPCAKE'];
const walletThemePresetKeys: AdminWalletThemePresetKey[] = ['DEFAULT', 'COFFEE', 'RESTAURANT', 'DESSERT', 'MINIMAL', 'CUSTOM'];
const walletColorModes: AdminWalletColorMode[] = ['PRESET', 'CUSTOM'];
const stampLayoutVariants: AdminStampLayoutVariant[] = ['MODERN', 'COMPACT'];

function parseStampPresetKey(value: unknown, fallback: AdminStampPresetKey): AdminStampPresetKey {
  const normalized = readString(value)?.toUpperCase();

  return stampPresetKeys.includes(normalized as AdminStampPresetKey) ? (normalized as AdminStampPresetKey) : fallback;
}

function parseWalletThemePresetKey(value: unknown, fallback: AdminWalletThemePresetKey): AdminWalletThemePresetKey {
  const normalized = readString(value)?.toUpperCase();

  return walletThemePresetKeys.includes(normalized as AdminWalletThemePresetKey) ? (normalized as AdminWalletThemePresetKey) : fallback;
}

function parseWalletColorMode(value: unknown, fallback: AdminWalletColorMode): AdminWalletColorMode {
  const normalized = readString(value)?.toUpperCase();

  return walletColorModes.includes(normalized as AdminWalletColorMode) ? (normalized as AdminWalletColorMode) : fallback;
}

function parseStampLayoutVariant(value: unknown, fallback: AdminStampLayoutVariant): AdminStampLayoutVariant {
  const normalized = readString(value)?.toUpperCase();

  return stampLayoutVariants.includes(normalized as AdminStampLayoutVariant) ? (normalized as AdminStampLayoutVariant) : fallback;
}

function parseWalletThemePalette(value: unknown): AdminWalletThemePalette | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const walletBackgroundColor = readString(record.walletBackgroundColor);
  const imageBackgroundColor = readString(record.imageBackgroundColor);
  const imageSurfaceColor = readString(record.imageSurfaceColor);
  const imageAccentColor = readString(record.imageAccentColor);
  const imageTextColor = readString(record.imageTextColor);
  const stampFilledColor = readString(record.stampFilledColor);
  const stampEmptyColor = readString(record.stampEmptyColor);
  const rewardBannerColor = readString(record.rewardBannerColor);

  if (
    !walletBackgroundColor ||
    !imageBackgroundColor ||
    !imageSurfaceColor ||
    !imageAccentColor ||
    !imageTextColor ||
    !stampFilledColor ||
    !stampEmptyColor ||
    !rewardBannerColor
  ) {
    return null;
  }

  return {
    walletBackgroundColor,
    imageBackgroundColor,
    imageSurfaceColor,
    imageAccentColor,
    imageTextColor,
    stampFilledColor,
    stampEmptyColor,
    rewardBannerColor
  };
}

function parseLoyaltyStampPreset(value: unknown): AdminLoyaltyStampPreset | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const key = readString(record.key)?.toUpperCase();
  const label = readString(record.label);

  if (!key || !stampPresetKeys.includes(key as AdminStampPresetKey)) {
    return null;
  }

  return {
    key: key as AdminStampPresetKey,
    label: label || key
  };
}

function parseWalletThemePreset(value: unknown): AdminWalletThemePreset | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const key = readString(record.key)?.toUpperCase();
  const label = readString(record.label);
  const recommendedPalette = parseWalletThemePalette(record.recommendedPalette);

  if (!key || !walletThemePresetKeys.includes(key as AdminWalletThemePresetKey) || !recommendedPalette) {
    return null;
  }

  return {
    key: key as AdminWalletThemePresetKey,
    label: label || key,
    recommendedPalette
  };
}

function parseLoyaltyStampPresetCatalog(value: unknown): AdminLoyaltyStampPresetCatalog | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const stampPresetSource = Array.isArray(record.stampPresets) ? record.stampPresets : record.presets;
  const stampPresets = Array.isArray(stampPresetSource) ? compact(stampPresetSource.map(parseLoyaltyStampPreset)) : [];
  const themePresets = Array.isArray(record.themePresets) ? compact(record.themePresets.map(parseWalletThemePreset)) : [];
  const colorModes = Array.isArray(record.colorModes)
    ? compact(record.colorModes.map((value) => (walletColorModes.includes(readString(value) as AdminWalletColorMode) ? (readString(value) as AdminWalletColorMode) : null)))
    : walletColorModes;
  const layoutVariants = Array.isArray(record.layoutVariants)
    ? compact(record.layoutVariants.map((value) => (stampLayoutVariants.includes(readString(value) as AdminStampLayoutVariant) ? (readString(value) as AdminStampLayoutVariant) : null)))
    : stampLayoutVariants;

  if (!stampPresets.length || !themePresets.length) {
    return null;
  }

  return {
    presets: stampPresets,
    stampPresets,
    themePresets,
    styleTypes: Array.isArray(record.styleTypes) ? compact(record.styleTypes.map(readString)) : ['PRESET'],
    colorModes: colorModes.length ? colorModes : walletColorModes,
    layoutVariants: layoutVariants.length ? layoutVariants : stampLayoutVariants
  };
}

function parseLoyaltyStampStyle(value: unknown): AdminLoyaltyStampStyle | null {
  const record = asRecord(value);
  const palette = parseWalletThemePalette(value);

  if (!record || !palette) {
    return null;
  }

  const loyaltyProgramId = readString(record.loyaltyProgramId);

  if (!loyaltyProgramId) {
    return null;
  }

  return {
    id: readNullableString(record.id),
    loyaltyProgramId,
    styleType: readString(record.styleType) || 'PRESET',
    presetKey: parseStampPresetKey(record.presetKey, 'STAR'),
    backgroundColor: readString(record.backgroundColor) || palette.imageBackgroundColor,
    accentColor: readString(record.accentColor) || palette.imageAccentColor,
    textColor: readString(record.textColor) || palette.imageTextColor,
    ...palette,
    themePreset: parseWalletThemePresetKey(record.themePreset, 'DEFAULT'),
    colorMode: parseWalletColorMode(record.colorMode, 'PRESET'),
    layoutVariant: parseStampLayoutVariant(record.layoutVariant, 'MODERN'),
    isDefault: readBoolean(record.isDefault),
    createdAt: readNullableString(record.createdAt),
    updatedAt: readNullableString(record.updatedAt)
  };
}

function parseLoyaltyCustomer(value: unknown): AdminLoyaltyCustomer | null {
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
    phone: readNullableString(record.phone),
    email: readNullableString(record.email),
    name: readNullableString(record.name)
  };
}

function parseLoyaltyCardState(value: unknown): AdminLoyaltyCardState | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  return {
    stampCount: readNumber(record.stampCount),
    stampGoal: readNumber(record.stampGoal),
    rewardReady: readBoolean(record.rewardReady),
    progressPercent: readNumber(record.progressPercent),
    rewardName: readString(record.rewardName) || 'Reward',
    programName: readString(record.programName) || 'Loyalty program'
  };
}

function parseLoyaltyTransaction(value: unknown): AdminLoyaltyTransaction | null {
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
    businessId: readNullableString(record.businessId),
    loyaltyProgramId: readNullableString(record.loyaltyProgramId),
    membershipId: readNullableString(record.membershipId),
    customerId: readNullableString(record.customerId),
    actorUserId: readNullableString(record.actorUserId),
    type: readString(record.type) || 'UNKNOWN',
    stampsDelta: readNumber(record.stampsDelta),
    reason: readNullableString(record.reason),
    createdAt: readNullableString(record.createdAt)
  };
}

function parseLoyaltyTransactions(value: unknown): AdminLoyaltyTransaction[] | null {
  if (!Array.isArray(value)) {
    return null;
  }

  return compact(value.map(parseLoyaltyTransaction));
}

function parseLoyaltyMembership(value: unknown): AdminLoyaltyMembership | null {
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
    businessId: readNullableString(record.businessId),
    loyaltyProgramId: readNullableString(record.loyaltyProgramId),
    customerId: readNullableString(record.customerId),
    stampCount: readNumber(record.stampCount),
    rewardReady: readBoolean(record.rewardReady),
    totalStampsEarned: readOptionalNumber(record.totalStampsEarned),
    totalRewardsRedeemed: readOptionalNumber(record.totalRewardsRedeemed),
    status: readString(record.status) || 'ACTIVE',
    customer: parseLoyaltyCustomer(record.customer),
    program: parseLoyaltyProgram(record.program),
    cardState: parseLoyaltyCardState(record.cardState),
    transactions: Array.isArray(record.transactions) ? compact(record.transactions.map(parseLoyaltyTransaction)) : []
  };
}

function parseLoyaltyMemberships(value: unknown): AdminLoyaltyMembership[] | null {
  if (!Array.isArray(value)) {
    return null;
  }

  return compact(value.map(parseLoyaltyMembership));
}

function parseLoyaltyEnrollResult(value: unknown): AdminLoyaltyEnrollResult | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const customer = parseLoyaltyCustomer(record.customer);
  const membership = parseLoyaltyMembership(record.membership);
  const program = parseLoyaltyProgram(record.program);
  const cardState = parseLoyaltyCardState(record.cardState);

  if (!customer || !membership || !program || !cardState) {
    return null;
  }

  return {
    customer,
    membership: {
      ...membership,
      customer,
      program,
      cardState
    },
    program,
    cardState
  };
}

function parseLoyaltyActionResult(value: unknown): AdminLoyaltyActionResult | null {
  const record = asRecord(value);

  if (!record) {
    return null;
  }

  const membership = parseLoyaltyMembership(record.membership);
  const cardState = parseLoyaltyCardState(record.cardState);

  if (!membership || !cardState) {
    return null;
  }

  return {
    membership: {
      ...membership,
      cardState
    },
    cardState
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
  contractName,
  notFoundValue
}: {
  apiBaseUrl: string;
  token: string | null;
  path: string;
  method?: 'GET' | 'POST' | 'PATCH';
  body?: unknown;
  signal?: AbortSignal;
  parse: (value: unknown) => T | null;
  contractName: string;
  notFoundValue?: T;
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

    if (response.status === 404 && notFoundValue !== undefined) {
      return {
        status: 'ok',
        data: notFoundValue,
        apiUrl
      };
    }

    if (response.status === 400 || response.status === 422) {
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

export function getMenuTemplateCatalog({
  apiBaseUrl,
  token,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: '/menu-templates',
    signal,
    parse: parseMenuTemplateCatalog,
    contractName: 'GET /menu-templates'
  });
}

export function getMenuAppearance({
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
    path: `/businesses/${encodeURIComponent(businessId)}/appearance`,
    signal,
    parse: parseMenuAppearance,
    contractName: 'GET /businesses/{id}/appearance'
  });
}

export function updateMenuAppearance({
  apiBaseUrl,
  token,
  businessId,
  menuTemplateId,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  menuTemplateId: string;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/appearance`,
    method: 'PATCH',
    body: { menuTemplateId },
    signal,
    parse: parseMenuAppearance,
    contractName: 'PATCH /businesses/{id}/appearance'
  });
}

export async function getActiveLoyaltyProgram({
  apiBaseUrl,
  token,
  businessId,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  signal?: AbortSignal;
}): Promise<AdminApiResult<AdminLoyaltyProgram | null>> {
  const result = await requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/program`,
    signal,
    parse: parseNullableLoyaltyProgram,
    notFoundValue: { program: null },
    contractName: 'GET /businesses/{id}/loyalty/program'
  });

  return result.status === 'ok'
    ? {
        ...result,
        data: result.data.program
      }
    : result;
}

export function getLoyaltyStampPresets({
  apiBaseUrl,
  token,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: '/loyalty/stamp-presets',
    signal,
    parse: parseLoyaltyStampPresetCatalog,
    contractName: 'GET /loyalty/stamp-presets'
  });
}

export function getLoyaltyStampStyle({
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
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/stamp-style`,
    signal,
    parse: parseLoyaltyStampStyle,
    contractName: 'GET /businesses/{id}/loyalty/stamp-style'
  });
}

export function updateLoyaltyStampStyle({
  apiBaseUrl,
  token,
  businessId,
  input,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  input: AdminLoyaltyStampStyleInput;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/stamp-style`,
    method: 'PATCH',
    body: input,
    signal,
    parse: parseLoyaltyStampStyle,
    contractName: 'PATCH /businesses/{id}/loyalty/stamp-style'
  });
}

export function createLoyaltyProgram({
  apiBaseUrl,
  token,
  businessId,
  input,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  input: AdminLoyaltyProgramInput;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/program`,
    method: 'POST',
    body: compactLoyaltyBody(input),
    signal,
    parse: parseLoyaltyProgram,
    contractName: 'POST /businesses/{id}/loyalty/program'
  });
}

export function updateLoyaltyProgram({
  apiBaseUrl,
  token,
  businessId,
  programId,
  input,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  programId: string;
  input: AdminLoyaltyProgramInput;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/program/${encodeURIComponent(programId)}`,
    method: 'PATCH',
    body: compactLoyaltyUpdateBody(input),
    signal,
    parse: parseLoyaltyProgram,
    contractName: 'PATCH /businesses/{id}/loyalty/program/{programId}'
  });
}

export function enrollLoyaltyCustomer({
  apiBaseUrl,
  token,
  businessId,
  input,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  input: AdminEnrollLoyaltyCustomerInput;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/enroll`,
    method: 'POST',
    body: compactLoyaltyBody(input),
    signal,
    parse: parseLoyaltyEnrollResult,
    contractName: 'POST /businesses/{id}/loyalty/enroll'
  });
}

export function listLoyaltyMemberships({
  apiBaseUrl,
  token,
  businessId,
  search,
  status,
  rewardReady,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  search?: string;
  status?: 'ACTIVE' | 'INACTIVE' | '';
  rewardReady?: boolean | null;
  signal?: AbortSignal;
}) {
  const params = new URLSearchParams();
  const cleanSearch = search?.trim();

  if (cleanSearch) {
    params.set('search', cleanSearch);
  }

  if (status) {
    params.set('status', status);
  }

  if (rewardReady !== undefined && rewardReady !== null) {
    params.set('rewardReady', String(rewardReady));
  }

  const query = params.toString();

  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/memberships${query ? `?${query}` : ''}`,
    signal,
    parse: parseLoyaltyMemberships,
    contractName: 'GET /businesses/{id}/loyalty/memberships'
  });
}

export function getLoyaltyMembership({
  apiBaseUrl,
  token,
  businessId,
  membershipId,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  membershipId: string;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/memberships/${encodeURIComponent(membershipId)}`,
    signal,
    parse: parseLoyaltyMembership,
    contractName: 'GET /businesses/{id}/loyalty/memberships/{membershipId}'
  });
}

export function addLoyaltyStamps({
  apiBaseUrl,
  token,
  businessId,
  membershipId,
  input,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  membershipId: string;
  input: AdminAddStampsInput;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/memberships/${encodeURIComponent(membershipId)}/stamps`,
    method: 'POST',
    body: compactLoyaltyBody(input),
    signal,
    parse: parseLoyaltyActionResult,
    contractName: 'POST /businesses/{id}/loyalty/memberships/{membershipId}/stamps'
  });
}

export function redeemLoyaltyReward({
  apiBaseUrl,
  token,
  businessId,
  membershipId,
  input,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  membershipId: string;
  input: AdminRedeemRewardInput;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/memberships/${encodeURIComponent(membershipId)}/redeem`,
    method: 'POST',
    body: compactLoyaltyBody(input),
    signal,
    parse: parseLoyaltyActionResult,
    contractName: 'POST /businesses/{id}/loyalty/memberships/{membershipId}/redeem'
  });
}

export function listLoyaltyTransactions({
  apiBaseUrl,
  token,
  businessId,
  membershipId,
  signal
}: {
  apiBaseUrl: string;
  token: string | null;
  businessId: string;
  membershipId: string;
  signal?: AbortSignal;
}) {
  return requestAdminJson({
    apiBaseUrl,
    token,
    path: `/businesses/${encodeURIComponent(businessId)}/loyalty/memberships/${encodeURIComponent(membershipId)}/transactions`,
    signal,
    parse: parseLoyaltyTransactions,
    contractName: 'GET /businesses/{id}/loyalty/memberships/{membershipId}/transactions'
  });
}

const nullableLoyaltyProgramFields = new Set(['description', 'rewardDescription', 'cardColor', 'accentColor', 'logoUrl', 'terms']);

function compactLoyaltyBody<T extends Record<string, unknown>>(input: T) {
  return Object.fromEntries(
    Object.entries(input).filter(([, value]) => {
      if (value === undefined || value === null) {
        return false;
      }

      return typeof value !== 'string' || value.trim().length > 0;
    })
  );
}

function compactLoyaltyUpdateBody(input: AdminLoyaltyProgramInput) {
  const entries: Array<[string, unknown]> = [];

  for (const [key, value] of Object.entries(input)) {
    if (value === undefined) {
      continue;
    }

    if (nullableLoyaltyProgramFields.has(key)) {
      entries.push([key, value === null || (typeof value === 'string' && value.trim().length === 0) ? null : value]);
      continue;
    }

    if (value === null || (typeof value === 'string' && value.trim().length === 0)) {
      continue;
    }

    entries.push([key, value]);
  }

  return Object.fromEntries(entries);
}

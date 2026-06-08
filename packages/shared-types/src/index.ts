export type BusinessType = 'CAFE' | 'RESTAURANT' | 'BAKERY' | 'TEA_HOUSE' | 'OTHER';

export type BusinessStatus = 'ACTIVE' | 'SUSPENDED' | 'PENDING';

export type PlanName = 'BASIC' | 'PRO';

export type MenuItemDTO = {
  id: string;
  businessId: string;
  categoryId: string;
  nameAr: string;
  nameEn?: string | null;
  descriptionAr?: string | null;
  descriptionEn?: string | null;
  price: string;
  imageUrl?: string | null;
  isAvailable: boolean;
  sortOrder: number;
};

export type BusinessDTO = {
  id: string;
  ownerId: string;
  name: string;
  slug: string;
  type: BusinessType | string;
  logoUrl?: string | null;
  coverUrl?: string | null;
  currency: string;
  language: string;
  city?: string | null;
  status: BusinessStatus;
};

export type SubscriptionDTO = {
  id: string;
  businessId: string;
  planId: string;
  planName: PlanName;
  status: 'INACTIVE' | 'TRIALING' | 'ACTIVE' | 'PAST_DUE' | 'CANCELED';
  currentPeriodEnd?: string | null;
};

import type { PublicMenuCategory, PublicMenuItem } from './public-menu';

function prefersArabic(language?: string | null) {
  return language?.toLowerCase().startsWith('ar') ?? false;
}

function localizedText(
  arabicValue: string | null,
  englishValue: string | null,
  fallback: string,
  language?: string | null
) {
  if (prefersArabic(language)) {
    return arabicValue || englishValue || fallback;
  }

  return englishValue || arabicValue || fallback;
}

export function getCategoryName(category: PublicMenuCategory, language?: string | null) {
  return localizedText(category.nameAr, category.nameEn, 'Untitled category', language);
}

export function getItemName(item: PublicMenuItem, language?: string | null) {
  return localizedText(item.nameAr, item.nameEn, 'Unnamed item', language);
}

export function getItemDescription(item: PublicMenuItem, language?: string | null) {
  return localizedText(item.descriptionAr, item.descriptionEn, '', language);
}

export function getMenuDirection(language?: string | null) {
  return prefersArabic(language) ? 'rtl' : 'ltr';
}

export function getTextDirection(value?: string | null) {
  return value && /[\u0600-\u06FF]/.test(value) ? 'rtl' : 'ltr';
}

export function formatPrice(price: string, currency: string) {
  const numericPrice = Number(price);
  const displayPrice = Number.isFinite(numericPrice) ? new Intl.NumberFormat('en-US').format(numericPrice) : price;

  return currency ? `${displayPrice} ${currency.toUpperCase()}` : displayPrice;
}

import type { PublicMenuCategorySummary, PublicMenuItem } from './public-menu';

export function isRtlLanguage(language: string | null | undefined) {
  const normalized = language?.toLowerCase() ?? '';
  return normalized.startsWith('ar') || normalized.startsWith('ku') || normalized.startsWith('fa') || normalized.startsWith('he');
}

export function getCategoryName(category: PublicMenuCategorySummary, language?: string | null) {
  return isRtlLanguage(language)
    ? category.nameAr || category.nameEn || 'Untitled category'
    : category.nameEn || category.nameAr || 'Untitled category';
}

export function getItemName(item: PublicMenuItem, language?: string | null) {
  return isRtlLanguage(language) ? item.nameAr || item.nameEn || 'Unnamed item' : item.nameEn || item.nameAr || 'Unnamed item';
}

export function getItemDescription(item: PublicMenuItem, language?: string | null) {
  return isRtlLanguage(language) ? item.descriptionAr || item.descriptionEn : item.descriptionEn || item.descriptionAr;
}

export function formatPrice(price: string, currency: string) {
  const numericPrice = Number(price);
  const displayPrice = Number.isFinite(numericPrice) ? new Intl.NumberFormat('en-US').format(numericPrice) : price;

  return currency ? `${displayPrice} ${currency}` : displayPrice;
}

import type { PublicMenuCategorySummary, PublicMenuItem } from './public-menu';

export function getCategoryName(category: PublicMenuCategorySummary) {
  return category.nameEn || category.nameAr || 'Untitled category';
}

export function getItemName(item: PublicMenuItem) {
  return item.nameEn || item.nameAr || 'Unnamed item';
}

export function getItemDescription(item: PublicMenuItem) {
  return item.descriptionEn || item.descriptionAr;
}

export function formatPrice(price: string, currency: string) {
  const numericPrice = Number(price);
  const displayPrice = Number.isFinite(numericPrice) ? new Intl.NumberFormat('en-US').format(numericPrice) : price;

  return currency ? `${displayPrice} ${currency}` : displayPrice;
}

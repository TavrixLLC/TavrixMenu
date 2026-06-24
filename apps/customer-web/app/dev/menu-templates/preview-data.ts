import type { PublicMenuResponse } from '../../lib/public-menu';
import type { PublicLoyaltyContext } from '../../lib/public-loyalty';

export const demoMenu: PublicMenuResponse = {
  business: {
    id: 'demo-happy-birthday-2',
    name: 'Happy Birthday 2',
    slug: 'happy-birthday-2',
    type: 'cafe',
    logoUrl: null,
    coverUrl: null,
    currency: 'IQD',
    language: 'ar',
    city: 'Baghdad',
    menuTemplateId: 'waflo-warm',
    menuThemeOverrides: null
  },
  categories: [
    {
      id: 'cakes',
      nameAr: 'كيك',
      nameEn: 'Cakes',
      sortOrder: 0,
      items: [
        {
          id: 'strawberry-cake',
          nameAr: 'كيكة الفراولة',
          nameEn: 'Strawberry Cake',
          descriptionAr: 'كيكة ناعمة مع كريمة خفيفة وفراولة طازجة.',
          descriptionEn: 'Soft cake with light cream and fresh strawberries.',
          price: '5500',
          imageUrl: null,
          isAvailable: true,
          sortOrder: 0
        },
        {
          id: 'chocolate-slice',
          nameAr: 'قطعة شوكولاتة',
          nameEn: 'Chocolate Slice',
          descriptionAr: 'شوكولاتة غنية بطبقات كريمة.',
          descriptionEn: 'Rich chocolate with layered cream.',
          price: '4500',
          imageUrl: null,
          isAvailable: true,
          sortOrder: 1
        }
      ]
    },
    {
      id: 'drinks',
      nameAr: 'مشروبات',
      nameEn: 'Drinks',
      sortOrder: 1,
      items: [
        {
          id: 'iced-latte',
          nameAr: 'لاتيه بارد',
          nameEn: 'Iced Latte',
          descriptionAr: 'إسبريسو وحليب بارد مع ثلج.',
          descriptionEn: 'Espresso and cold milk over ice.',
          price: '3500',
          imageUrl: null,
          isAvailable: true,
          sortOrder: 0
        },
        {
          id: 'mint-lemonade',
          nameAr: 'ليمون نعناع',
          nameEn: 'Mint Lemonade',
          descriptionAr: 'ليمون منعش مع نعناع.',
          descriptionEn: 'Fresh lemon with mint.',
          price: '3000',
          imageUrl: null,
          isAvailable: false,
          sortOrder: 1
        }
      ]
    }
  ]
};

export const demoLoyalty: PublicLoyaltyContext = {
  business: {
    id: demoMenu.business.id,
    name: demoMenu.business.name,
    slug: demoMenu.business.slug,
    type: demoMenu.business.type,
    city: demoMenu.business.city,
    logoUrl: null,
    coverUrl: null,
    currency: demoMenu.business.currency,
    language: demoMenu.business.language
  },
  loyaltyProgram: {
    id: 'demo-loyalty',
    name: 'Birthday Rewards',
    description: 'Collect stamps with each visit.',
    stampGoal: 10,
    rewardName: 'Free birthday slice',
    rewardDescription: 'One dessert reward after 10 stamps.',
    cardColor: null,
    accentColor: null,
    logoUrl: null,
    terms: null
  },
  enrollment: {
    acceptsPhone: true,
    acceptsEmail: true,
    requiresOtp: false
  }
};

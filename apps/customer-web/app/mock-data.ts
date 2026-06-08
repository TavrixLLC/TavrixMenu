export type MockMenuItem = {
  id: string;
  name: string;
  price: string;
  description: string;
  category: string;
  available: boolean;
};

export const mockBusiness = {
  slug: 'tavrix-cafe',
  name: 'Tavrix Cafe',
  type: 'Cafe',
  city: 'Baghdad',
  currency: 'IQD',
  categories: ['Coffee', 'Desserts', 'Cold Drinks'],
  items: [
    {
      id: 'turkish-coffee',
      name: 'Turkish Coffee',
      price: '4,500 IQD',
      description: 'Rich, bold coffee served in a small cup.',
      category: 'Coffee',
      available: true
    },
    {
      id: 'date-cake',
      name: 'Date Cake',
      price: '5,000 IQD',
      description: 'Soft cake with dates and light spice.',
      category: 'Desserts',
      available: true
    },
    {
      id: 'iced-latte',
      name: 'Iced Latte',
      price: '6,000 IQD',
      description: 'Cold espresso with milk over ice.',
      category: 'Cold Drinks',
      available: false
    }
  ] satisfies MockMenuItem[]
};

export const mockPairings = [
  {
    id: 'tamriya',
    name: 'تمرية',
    price: '3,000 IQD',
    reason: 'حلاوتها توازن الطعم القوي للقهوة التركية.'
  },
  {
    id: 'water',
    name: 'ماء',
    price: '1,000 IQD',
    reason: 'اختيار خفيف يخلي طعم القهوة أوضح.'
  }
];

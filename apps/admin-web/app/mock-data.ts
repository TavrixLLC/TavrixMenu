export const stats = [
  { label: 'Total businesses', value: '128' },
  { label: 'Active subscriptions', value: '86' },
  { label: 'AI usage placeholder', value: '0' },
  { label: 'Loyalty cards placeholder', value: '0' }
];

export const businesses = [
  { name: 'Tavrix Cafe', type: 'Cafe', city: 'Baghdad', status: 'ACTIVE' },
  { name: 'North Bakery', type: 'Bakery', city: 'Erbil', status: 'PENDING' },
  { name: 'River Tea', type: 'Tea House', city: 'Basra', status: 'SUSPENDED' }
];

export const subscriptions = [
  { business: 'Tavrix Cafe', plan: 'Pro', status: 'ACTIVE', periodEnd: '2026-07-01' },
  { business: 'North Bakery', plan: 'Basic', status: 'TRIALING', periodEnd: '2026-06-20' },
  { business: 'River Tea', plan: 'Basic', status: 'PAST_DUE', periodEnd: '2026-06-03' }
];

export const logs = [
  { action: 'business.created', user: 'admin@example.com', business: 'North Bakery' },
  { action: 'subscription.updated', user: 'billing@example.com', business: 'Tavrix Cafe' },
  { action: 'business.suspended', user: 'admin@example.com', business: 'River Tea' }
];

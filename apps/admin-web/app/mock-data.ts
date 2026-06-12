export const stats = [
  { label: 'Auth foundation', value: 'Clerk' },
  { label: 'Owner context', value: '/me' },
  { label: 'Admin APIs', value: 'Pending' },
  { label: 'Customer menus', value: 'Public' }
];

export const businesses = [
  { name: 'Tavrix Cafe', type: 'Cafe', city: 'Baghdad', status: 'ACTIVE' },
  { name: 'North Bakery', type: 'Bakery', city: 'Erbil', status: 'PENDING' },
  { name: 'River Tea', type: 'Tea House', city: 'Basra', status: 'SUSPENDED' }
];

export const subscriptions = [
  { business: 'Tavrix Cafe', plan: 'Plan display pending', status: 'Sprint 6 backend pending', periodEnd: 'Not connected' },
  { business: 'North Bakery', plan: 'Plan display pending', status: 'Sprint 6 backend pending', periodEnd: 'Not connected' },
  { business: 'River Tea', plan: 'Plan display pending', status: 'Sprint 6 backend pending', periodEnd: 'Not connected' }
];

export const logs = [
  { action: 'owner.context.loaded', user: 'admin-dev@example.com', business: 'Tavrix Cafe' },
  { action: 'business.shell.opened', user: 'admin-dev@example.com', business: 'North Bakery' },
  { action: 'logs.shell.viewed', user: 'admin-dev@example.com', business: 'River Tea' }
];

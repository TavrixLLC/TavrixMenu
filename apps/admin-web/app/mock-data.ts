export const stats = [
  { label: 'Sign-in', value: 'Enabled' },
  { label: 'Owner context', value: '/me' },
  { label: 'Owner tools', value: 'In progress' },
  { label: 'Customer menus', value: 'Public' }
];

export const businesses = [
  { name: 'Tavrix Cafe', type: 'Cafe', city: 'Baghdad', status: 'ACTIVE' },
  { name: 'North Bakery', type: 'Bakery', city: 'Erbil', status: 'PENDING' },
  { name: 'River Tea', type: 'Tea House', city: 'Basra', status: 'SUSPENDED' }
];

export const subscriptions = [
  { business: 'Tavrix Cafe', plan: 'Coming soon', status: 'Billing not active', periodEnd: 'Not connected' },
  { business: 'North Bakery', plan: 'Coming soon', status: 'Billing not active', periodEnd: 'Not connected' },
  { business: 'River Tea', plan: 'Coming soon', status: 'Billing not active', periodEnd: 'Not connected' }
];

export const logs = [
  { action: 'owner.context.loaded', user: 'admin-dev@example.com', business: 'Tavrix Cafe' },
  { action: 'business.shell.opened', user: 'admin-dev@example.com', business: 'North Bakery' },
  { action: 'logs.shell.viewed', user: 'admin-dev@example.com', business: 'River Tea' }
];

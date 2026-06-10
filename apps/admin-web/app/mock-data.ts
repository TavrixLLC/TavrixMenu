export const stats = [
  { label: 'Businesses tracked', value: '128', detail: 'Static Sprint 2 shell data' },
  { label: 'Active subscriptions', value: '86', detail: 'Billing API pending' },
  { label: 'Needs review', value: '7', detail: 'Owner onboarding checks' },
  { label: 'Audit events', value: '214', detail: 'Sample operational log volume' }
];

export const businesses = [
  {
    name: 'Tavrix Cafe',
    slug: 'tavrix-cafe',
    type: 'Cafe',
    city: 'Baghdad',
    owner: 'owner@tavrix.example',
    status: 'ACTIVE',
    lastUpdated: '2026-06-09'
  },
  {
    name: 'North Bakery',
    slug: 'north-bakery',
    type: 'Bakery',
    city: 'Erbil',
    owner: 'ops+north@example.com',
    status: 'PENDING',
    lastUpdated: '2026-06-08'
  },
  {
    name: 'River Tea',
    slug: 'river-tea',
    type: 'Tea House',
    city: 'Basra',
    owner: 'ops+river@example.com',
    status: 'SUSPENDED',
    lastUpdated: '2026-06-03'
  }
];

export const subscriptions = [
  { business: 'Tavrix Cafe', plan: 'Pro', status: 'ACTIVE', amount: '45,000 IQD', periodEnd: '2026-07-01' },
  { business: 'North Bakery', plan: 'Basic', status: 'TRIALING', amount: '0 IQD', periodEnd: '2026-06-20' },
  { business: 'River Tea', plan: 'Basic', status: 'PAST_DUE', amount: '20,000 IQD', periodEnd: '2026-06-03' }
];

export const logs = [
  {
    timestamp: '2026-06-10 16:42',
    severity: 'INFO',
    action: 'business.created',
    user: 'admin@example.com',
    business: 'North Bakery'
  },
  {
    timestamp: '2026-06-10 15:18',
    severity: 'INFO',
    action: 'subscription.updated',
    user: 'billing@example.com',
    business: 'Tavrix Cafe'
  },
  {
    timestamp: '2026-06-09 21:04',
    severity: 'WARN',
    action: 'business.suspended',
    user: 'admin@example.com',
    business: 'River Tea'
  }
];

export const integrationStates = [
  { label: 'Admin auth', state: 'Pending', detail: 'Login screen is a protected-shell placeholder until admin auth is wired.' },
  { label: 'Business admin API', state: 'Pending', detail: 'Tables render sample data only; backend admin endpoints are not assumed.' },
  { label: 'Billing sync', state: 'Pending', detail: 'Subscription status is static shell data for Sprint 2 review.' }
];

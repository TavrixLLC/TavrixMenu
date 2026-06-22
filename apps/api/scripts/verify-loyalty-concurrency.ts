import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';
import type { LoyaltyTransactionType as LoyaltyTransactionTypeValue } from '../src/generated/prisma';
import type { PrismaClient as PrismaClientType } from '../src/generated/prisma';

type ApiResult = {
  status: number;
  body: unknown;
};

type LoyaltyPrisma = typeof import('../src/generated/prisma');

loadEnvFile();

const apiBaseUrl = process.env.API_BASE_URL ?? 'http://localhost:3000';
const authHeader =
  'Bearer dev:user_tavrix_owner;email=owner@tavrix.local;name=Tavrix%20Owner';

const {
  PrismaClient,
  LoyaltyMembershipStatus,
  LoyaltyTransactionType
} = require('../src/generated/prisma') as LoyaltyPrisma;

const prisma: PrismaClientType = new PrismaClient();

async function main() {
  const context = await loadContext();

  await assertHealth();

  const testOne = await createMembership(context, {
    label: 'from-3',
    stampCount: 3,
    rewardReady: false,
    totalStampsEarned: 3,
    totalRewardsRedeemed: 0
  });

  await runConcurrentAddFromThree(context, testOne.id);

  const testTwo = await createMembership(context, {
    label: 'from-4',
    stampCount: 4,
    rewardReady: false,
    totalStampsEarned: 4,
    totalRewardsRedeemed: 0
  });

  await runConcurrentAddFromFour(context, testTwo.id);

  const testThree = await createMembership(context, {
    label: 'redeem-ready',
    stampCount: context.program.stampGoal,
    rewardReady: true,
    totalStampsEarned: context.program.stampGoal,
    totalRewardsRedeemed: 0
  });

  await runConcurrentRedeem(context, testThree.id);

  console.log(
    JSON.stringify(
      {
        passed: true,
        apiBaseUrl,
        businessId: context.business.id,
        programId: context.program.id,
        cases: [
          'concurrent add from stampCount 3',
          'concurrent add from stampCount 4',
          'concurrent redeem from rewardReady true'
        ]
      },
      null,
      2
    )
  );
}

function loadEnvFile() {
  const envPath = resolve(__dirname, '..', '.env');

  if (!existsSync(envPath)) {
    return;
  }

  const envFile = readFileSync(envPath, 'utf8');

  for (const rawLine of envFile.split(/\r?\n/)) {
    const line = rawLine.trim();

    if (!line || line.startsWith('#')) {
      continue;
    }

    const separatorIndex = line.indexOf('=');

    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    const rawValue = line.slice(separatorIndex + 1).trim();
    const value = rawValue.replace(/^['"]|['"]$/g, '');

    if (key && process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
}

async function loadContext() {
  const business = await prisma.business.findUnique({
    where: {
      slug: 'tavrix-cafe'
    }
  });

  assert(business, 'Seeded tavrix-cafe business is required');

  const owner = await prisma.user.findUnique({
    where: {
      clerkUserId: 'user_tavrix_owner'
    }
  });

  assert(owner, 'Seeded owner user is required');

  const program = await prisma.loyaltyProgram.findFirst({
    where: {
      businessId: business.id,
      isActive: true
    },
    orderBy: [{ createdAt: 'asc' }, { id: 'asc' }]
  });

  assert(program, 'Active loyalty program is required');
  assert(program.stampGoal === 5, 'Concurrency verifier expects a stampGoal of 5');

  return {
    business,
    owner,
    program
  };
}

async function assertHealth() {
  const response = await fetch(`${apiBaseUrl}/health`);
  assert(response.ok, `API health failed with ${response.status}`);
}

async function createMembership(
  context: Awaited<ReturnType<typeof loadContext>>,
  input: {
    label: string;
    stampCount: number;
    rewardReady: boolean;
    totalStampsEarned: number;
    totalRewardsRedeemed: number;
  }
) {
  const suffix = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  const customer = await prisma.customer.create({
    data: {
      email: `loyalty-${input.label}-${suffix}@example.com`,
      name: `Loyalty ${input.label}`
    }
  });

  return prisma.loyaltyMembership.create({
    data: {
      businessId: context.business.id,
      loyaltyProgramId: context.program.id,
      customerId: customer.id,
      stampCount: input.stampCount,
      rewardReady: input.rewardReady,
      totalStampsEarned: input.totalStampsEarned,
      totalRewardsRedeemed: input.totalRewardsRedeemed,
      status: LoyaltyMembershipStatus.ACTIVE
    }
  });
}

async function runConcurrentAddFromThree(
  context: Awaited<ReturnType<typeof loadContext>>,
  membershipId: string
) {
  const results = await Promise.all([
    addStamp(context.business.id, membershipId),
    addStamp(context.business.id, membershipId)
  ]);

  assertStatuses(results, [201, 201], 'add from 3');

  const { membership, transactions } = await loadMembershipState(
    membershipId,
    LoyaltyTransactionType.STAMP_ADDED
  );

  assert(membership, 'add from 3 membership must exist');
  assert(membership.stampCount === 5, 'add from 3 final stampCount must be 5');
  assert(membership.rewardReady === true, 'add from 3 rewardReady must be true');
  assert(
    membership.totalStampsEarned === 5,
    'add from 3 totalStampsEarned must increase by 2'
  );
  assert(
    transactions.length === 2,
    'add from 3 must create exactly two STAMP_ADDED transactions'
  );
  assert(
    sum(transactions.map((transaction) => transaction.stampsDelta)) === 2,
    'add from 3 transaction delta sum must be 2'
  );
}

async function runConcurrentAddFromFour(
  context: Awaited<ReturnType<typeof loadContext>>,
  membershipId: string
) {
  const results = await Promise.all([
    addStamp(context.business.id, membershipId),
    addStamp(context.business.id, membershipId)
  ]);
  const successCount = results.filter((result) => result.status === 201).length;
  const cleanFailureCount = results.filter((result) =>
    [400, 409].includes(result.status)
  ).length;

  assert(successCount === 1, 'add from 4 must have exactly one success');
  assert(cleanFailureCount === 1, 'add from 4 must have exactly one clean failure');

  const { membership, transactions } = await loadMembershipState(
    membershipId,
    LoyaltyTransactionType.STAMP_ADDED
  );

  assert(membership, 'add from 4 membership must exist');
  assert(membership.stampCount === 5, 'add from 4 final stampCount must be 5');
  assert(membership.rewardReady === true, 'add from 4 rewardReady must be true');
  assert(
    membership.totalStampsEarned === 5,
    'add from 4 totalStampsEarned must increase by 1'
  );
  assert(
    transactions.length === 1,
    'add from 4 must create exactly one STAMP_ADDED transaction'
  );
  assert(
    transactions[0]?.stampsDelta === 1,
    'add from 4 transaction delta must be 1'
  );
}

async function runConcurrentRedeem(
  context: Awaited<ReturnType<typeof loadContext>>,
  membershipId: string
) {
  const results = await Promise.all([
    redeemReward(context.business.id, membershipId),
    redeemReward(context.business.id, membershipId)
  ]);
  const successCount = results.filter((result) => result.status === 201).length;
  const cleanFailureCount = results.filter((result) =>
    [400, 409].includes(result.status)
  ).length;

  assert(successCount === 1, 'redeem must have exactly one success');
  assert(cleanFailureCount === 1, 'redeem must have exactly one clean failure');

  const { membership, transactions } = await loadMembershipState(
    membershipId,
    LoyaltyTransactionType.REWARD_REDEEMED
  );

  assert(membership, 'redeem membership must exist');
  assert(membership.stampCount === 0, 'redeem final stampCount must be 0');
  assert(membership.rewardReady === false, 'redeem final rewardReady must be false');
  assert(
    membership.totalRewardsRedeemed === 1,
    'redeem totalRewardsRedeemed must increment by 1'
  );
  assert(
    transactions.length === 1,
    'redeem must create exactly one REWARD_REDEEMED transaction'
  );
  assert(
    transactions[0]?.stampsDelta === -context.program.stampGoal,
    'redeem transaction delta must equal the redeemed stamp count'
  );
}

async function addStamp(businessId: string, membershipId: string) {
  return post(
    `/businesses/${businessId}/loyalty/memberships/${membershipId}/stamps`,
    {
      count: 1,
      reason: 'Concurrency verifier'
    }
  );
}

async function redeemReward(businessId: string, membershipId: string) {
  return post(
    `/businesses/${businessId}/loyalty/memberships/${membershipId}/redeem`,
    {
      reason: 'Concurrency verifier'
    }
  );
}

async function post(path: string, body: unknown): Promise<ApiResult> {
  const response = await fetch(`${apiBaseUrl}${path}`, {
    method: 'POST',
    headers: {
      Authorization: authHeader,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
  });

  const text = await response.text();

  return {
    status: response.status,
    body: text ? JSON.parse(text) : null
  };
}

async function loadMembershipState(
  membershipId: string,
  type: LoyaltyTransactionTypeValue
) {
  const membership = await prisma.loyaltyMembership.findUnique({
    where: {
      id: membershipId
    }
  });

  const transactions = await prisma.loyaltyTransaction.findMany({
    where: {
      membershipId,
      type
    },
    orderBy: [{ createdAt: 'asc' }, { id: 'asc' }]
  });

  return {
    membership,
    transactions
  };
}

function assertStatuses(results: ApiResult[], statuses: number[], label: string) {
  const actualStatuses = results.map((result) => result.status).sort();
  const expectedStatuses = [...statuses].sort();
  assert(
    JSON.stringify(actualStatuses) === JSON.stringify(expectedStatuses),
    `${label} expected statuses ${expectedStatuses.join(', ')} but received ${actualStatuses.join(', ')}`
  );
}

function assert(value: unknown, message: string): asserts value {
  if (!value) {
    throw new Error(message);
  }
}

function sum(values: number[]) {
  return values.reduce((total, value) => total + value, 0);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

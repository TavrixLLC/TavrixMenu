import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import {
  LoyaltyMembershipStatus,
  LoyaltyTransactionType,
  WalletRefreshJobReason
} from '../../generated/prisma';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { LoyaltyService } from './loyalty.service';

describe('LoyaltyService compatibility', () => {
  it('keeps active program response backward compatible', async () => {
    const now = new Date('2026-06-15T00:00:00.000Z');
    const program = {
      id: 'program_1',
      businessId: 'business_1',
      name: 'Tavrix Cafe Stamp Card',
      description: 'Collect stamps.',
      stampGoal: 5,
      rewardName: 'Free coffee',
      rewardDescription: 'One free coffee after 5 stamps.',
      isActive: true,
      cardColor: '#111827',
      accentColor: '#f59e0b',
      logoUrl: null,
      terms: null,
      createdAt: now,
      updatedAt: now
    };
    const prisma = {
      loyaltyProgram: {
        findFirst: async () => program
      }
    };
    const businessAccess = {
      assertRole: async () => undefined
    };
    const service = new LoyaltyService(prisma as any, businessAccess as any);

    const response = await service.getActiveProgram(
      user('staff'),
      'business_1'
    );

    assert.deepEqual(response, program);
    assert.equal(Object.hasOwn(response as object, 'stampStyle'), false);
  });
});

describe('LoyaltyService wallet refresh hooks', () => {
  it('enqueues a Google Wallet refresh job after add stamp transaction succeeds', async () => {
    const setup = createMutationService();

    const response = await setup.service.addStamps(
      user('staff'),
      'business_1',
      'membership_1',
      {
        count: 1
      }
    );

    assert.equal(response.membership.stampCount, 4);
    assert.deepEqual(setup.enqueueCalls, [
      {
        businessId: 'business_1',
        membershipId: 'membership_1',
        reason: WalletRefreshJobReason.STAMP_ADDED
      }
    ]);
    assert.deepEqual(setup.order, [
      'transaction:start',
      'transaction:end',
      'wallet:enqueue'
    ]);
    assert.equal(setup.transactions[0]?.type, LoyaltyTransactionType.STAMP_ADDED);
  });

  it('enqueues a Google Wallet refresh job after redeem transaction succeeds', async () => {
    const setup = createMutationService({
      membership: mutationMembership({
        stampCount: 5,
        rewardReady: true
      })
    });

    const response = await setup.service.redeemReward(
      user('staff'),
      'business_1',
      'membership_1',
      {
        reason: 'Reward claimed'
      }
    );

    assert.equal(response.membership.stampCount, 0);
    assert.equal(response.membership.rewardReady, false);
    assert.deepEqual(setup.enqueueCalls, [
      {
        businessId: 'business_1',
        membershipId: 'membership_1',
        reason: WalletRefreshJobReason.REWARD_REDEEMED
      }
    ]);
    assert.deepEqual(setup.order, [
      'transaction:start',
      'transaction:end',
      'wallet:enqueue'
    ]);
    assert.equal(
      setup.transactions[0]?.type,
      LoyaltyTransactionType.REWARD_REDEEMED
    );
  });

  it('does not fail add stamps when wallet refresh enqueue throws', async () => {
    const setup = createMutationService({
      enqueueError: new Error('Wallet refresh enqueue failed')
    });

    const response = await setup.service.addStamps(
      user('staff'),
      'business_1',
      'membership_1',
      {
        count: 1
      }
    );

    assert.equal(response.membership.stampCount, 4);
    assert.equal(setup.enqueueCalls.length, 1);
  });

  it('does not fail redeem when wallet refresh enqueue throws', async () => {
    const setup = createMutationService({
      membership: mutationMembership({
        stampCount: 5,
        rewardReady: true
      }),
      enqueueError: new Error('Wallet refresh enqueue failed')
    });

    const response = await setup.service.redeemReward(
      user('staff'),
      'business_1',
      'membership_1',
      {}
    );

    assert.equal(response.membership.stampCount, 0);
    assert.equal(response.membership.rewardReady, false);
    assert.equal(setup.enqueueCalls.length, 1);
  });
});

function createMutationService(overrides: {
  membership?: ReturnType<typeof mutationMembership>;
  enqueueError?: Error;
} = {}) {
  let currentMembership = overrides.membership ?? mutationMembership();
  const order: string[] = [];
  const enqueueCalls: Array<{
    businessId: string;
    membershipId: string;
    reason: WalletRefreshJobReason;
  }> = [];
  const transactions: Array<Record<string, unknown>> = [];
  const transaction = {
    $queryRaw: async () => [{ id: currentMembership.id }],
    loyaltyMembership: {
      findFirst: async () => currentMembership,
      update: async (args: { data: Record<string, any> }) => {
        currentMembership = {
          ...currentMembership,
          stampCount: args.data.stampCount ?? currentMembership.stampCount,
          rewardReady: args.data.rewardReady ?? currentMembership.rewardReady,
          totalStampsEarned:
            currentMembership.totalStampsEarned +
            (args.data.totalStampsEarned?.increment ?? 0),
          totalRewardsRedeemed:
            currentMembership.totalRewardsRedeemed +
            (args.data.totalRewardsRedeemed?.increment ?? 0)
        };

        return currentMembership;
      }
    },
    loyaltyTransaction: {
      create: async (args: { data: Record<string, unknown> }) => {
        transactions.push(args.data);

        return args.data;
      }
    }
  };
  const prisma = {
    $transaction: async <T>(callback: (client: typeof transaction) => Promise<T>) => {
      order.push('transaction:start');
      const result = await callback(transaction);
      order.push('transaction:end');

      return result;
    }
  };
  const businessAccess = {
    assertRole: async () => undefined
  };
  const walletRefreshJobService = {
    enqueueWalletRefreshForMembership: async (input: {
      businessId: string;
      membershipId: string;
      reason: WalletRefreshJobReason;
    }) => {
      enqueueCalls.push(input);
      order.push('wallet:enqueue');

      if (overrides.enqueueError) {
        throw overrides.enqueueError;
      }

      return {
        status: 'QUEUED',
        jobId: 'job_1'
      };
    },
    refreshGoogleWalletPassForMembership: async () => {
      throw new Error('Google Wallet API must not be called inline');
    }
  };

  return {
    service: new LoyaltyService(
      prisma as never,
      businessAccess as never,
      walletRefreshJobService as never
    ),
    order,
    enqueueCalls,
    transactions
  };
}

function mutationMembership(overrides: Record<string, any> = {}) {
  const now = new Date('2026-06-17T09:00:00.000Z');

  return {
    id: 'membership_1',
    businessId: 'business_1',
    loyaltyProgramId: 'program_1',
    customerId: 'customer_1',
    stampCount: 3,
    rewardReady: false,
    totalStampsEarned: 3,
    totalRewardsRedeemed: 0,
    publicAccessTokenHash: null,
    publicAccessTokenIssuedAt: null,
    publicAccessTokenLastViewedAt: null,
    status: LoyaltyMembershipStatus.ACTIVE,
    createdAt: now,
    updatedAt: now,
    customer: {
      id: 'customer_1',
      phone: '+9647700000000',
      email: 'customer@example.test',
      name: 'Demo Customer',
      createdAt: now,
      updatedAt: now
    },
    loyaltyProgram: {
      id: 'program_1',
      businessId: 'business_1',
      name: 'Tavrix Cafe Stamp Card',
      description: 'Collect stamps.',
      stampGoal: 5,
      rewardName: 'Free coffee',
      rewardDescription: 'One free coffee after 5 stamps.',
      isActive: true,
      cardColor: '#111827',
      accentColor: '#f59e0b',
      logoUrl: null,
      terms: null,
      createdAt: now,
      updatedAt: now
    },
    ...overrides
  };
}

function user(id: string): AuthenticatedUser {
  const now = new Date('2026-06-15T00:00:00.000Z');

  return {
    id,
    clerkUserId: id,
    name: id,
    email: `${id}@example.test`,
    phone: null,
    status: 'ACTIVE',
    createdAt: now,
    updatedAt: now
  } as AuthenticatedUser;
}

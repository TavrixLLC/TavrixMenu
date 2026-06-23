import 'reflect-metadata';
import { NotFoundException } from '@nestjs/common';
import { strict as assert } from 'assert';
import { validate } from 'class-validator';
import { describe, it } from 'node:test';
import { LoyaltyMembershipStatus } from '../../generated/prisma';
import {
  PublicLoyaltyEnrollDto,
  PublicLoyaltyEnrollmentIntent
} from './dto/public-loyalty-enroll.dto';
import { PublicLoyaltyService } from './public-loyalty.service';

describe('PublicLoyaltyEnrollDto validation', () => {
  it('requires a supported Iraqi phone and keeps email optional', async () => {
    const valid = Object.assign(new PublicLoyaltyEnrollDto(), {
      phone: '07701234567'
    });
    const invalidPhone = Object.assign(new PublicLoyaltyEnrollDto(), {
      phone: '12345'
    });
    const invalidEmail = Object.assign(new PublicLoyaltyEnrollDto(), {
      phone: '+9647701234567',
      email: 'not-an-email'
    });

    assert.equal((await validate(valid)).length, 0);
    assert.ok((await validate(invalidPhone)).length > 0);
    assert.ok((await validate(invalidEmail)).length > 0);
  });
});

describe('PublicLoyaltyService customer identity', () => {
  it('normalizes local and international numbers to one customer and membership', async () => {
    const setup = createSetup();

    const first = await setup.service.enrollCustomer('sample-cafe', {
      phone: '07701234567',
      intent: PublicLoyaltyEnrollmentIntent.JOIN
    });
    const second = await setup.service.enrollCustomer('sample-cafe', {
      phone: '+9647701234567',
      intent: PublicLoyaltyEnrollmentIntent.JOIN
    });

    assert.equal(setup.state.customers.length, 1);
    assert.equal(setup.state.customers[0]?.phone, '+9647701234567');
    assert.equal(setup.state.memberships.length, 1);
    assert.equal(first.cardState.stampCount, second.cardState.stampCount);
  });

  it('recovers an existing active membership without creating a duplicate', async () => {
    const setup = createSetup();

    await setup.service.enrollCustomer('sample-cafe', {
      phone: '07701234567',
      intent: PublicLoyaltyEnrollmentIntent.JOIN
    });
    const recovered = await setup.service.enrollCustomer('sample-cafe', {
      phone: '+9647701234567',
      intent: PublicLoyaltyEnrollmentIntent.RECOVER
    });

    assert.equal(setup.state.customers.length, 1);
    assert.equal(setup.state.memberships.length, 1);
    assert.equal(recovered.business.slug, 'sample-cafe');
  });

  it('does not create a customer or membership when recovery misses', async () => {
    const setup = createSetup();

    await assert.rejects(
      setup.service.enrollCustomer('sample-cafe', {
        phone: '+9647701234567',
        intent: PublicLoyaltyEnrollmentIntent.RECOVER
      }),
      NotFoundException
    );

    assert.equal(setup.state.customers.length, 0);
    assert.equal(setup.state.memberships.length, 0);
  });
});

function createSetup() {
  const now = new Date('2026-06-23T00:00:00.000Z');
  const business = {
    id: 'business_1',
    name: 'Sample cafe',
    slug: 'sample-cafe',
    type: 'CAFE',
    city: 'Baghdad',
    logoUrl: null,
    coverUrl: null,
    currency: 'IQD',
    language: 'en'
  };
  const program = {
    id: 'program_1',
    businessId: business.id,
    name: 'Sample rewards',
    description: null,
    stampGoal: 5,
    rewardName: 'Sample reward',
    rewardDescription: null,
    isActive: true,
    cardColor: null,
    accentColor: null,
    logoUrl: null,
    terms: null,
    createdAt: now,
    updatedAt: now
  };
  const state = {
    customers: [] as Array<any>,
    memberships: [] as Array<any>
  };

  const transaction = {
    customer: {
      findMany: async ({ where }: any) =>
        state.customers.filter((customer) =>
          where.phone.in.includes(customer.phone)
        ),
      findUnique: async ({ where }: any) =>
        state.customers.find((customer) =>
          where.phone
            ? customer.phone === where.phone
            : customer.email === where.email
        ) ?? null,
      create: async ({ data }: any) => {
        const customer = {
          id: `customer_${state.customers.length + 1}`,
          ...data,
          createdAt: now,
          updatedAt: now
        };
        state.customers.push(customer);
        return customer;
      },
      update: async ({ where, data }: any) => {
        const customer = state.customers.find((item) => item.id === where.id);
        Object.assign(customer, data, { updatedAt: now });
        return customer;
      }
    },
    loyaltyMembership: {
      upsert: async ({ where, create, update }: any) => {
        const key = where.customerId_loyaltyProgramId;
        let membership = state.memberships.find(
          (item) =>
            item.customerId === key.customerId &&
            item.loyaltyProgramId === key.loyaltyProgramId
        );

        if (membership) {
          Object.assign(membership, update, { updatedAt: now });
        } else {
          membership = {
            id: `membership_${state.memberships.length + 1}`,
            stampCount: 0,
            rewardReady: false,
            totalStampsEarned: 0,
            totalRewardsRedeemed: 0,
            createdAt: now,
            updatedAt: now,
            ...create
          };
          state.memberships.push(membership);
        }

        return includeRelations(membership);
      },
      findFirst: async ({ where }: any) => {
        const membership = state.memberships.find(
          (item) =>
            item.businessId === where.businessId &&
            item.loyaltyProgramId === where.loyaltyProgramId &&
            item.customerId === where.customerId &&
            item.status === where.status
        );
        return membership ? { id: membership.id } : null;
      },
      update: async ({ where, data }: any) => {
        const membership = state.memberships.find((item) => item.id === where.id);
        Object.assign(membership, data, { updatedAt: now });
        return includeRelations(membership);
      }
    }
  };

  function includeRelations(membership: any) {
    return {
      ...membership,
      business,
      loyaltyProgram: program,
      customer: state.customers.find(
        (customer) => customer.id === membership.customerId
      )
    };
  }

  const prisma = {
    business: {
      findFirst: async () => ({
        ...business,
        loyaltyPrograms: [program]
      })
    },
    $transaction: async (callback: (client: typeof transaction) => unknown) =>
      callback(transaction)
  };

  return {
    service: new PublicLoyaltyService(prisma as any),
    state
  };
}

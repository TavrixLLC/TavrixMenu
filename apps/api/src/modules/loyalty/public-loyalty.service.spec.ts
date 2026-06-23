import 'reflect-metadata';
import { HttpException, HttpStatus } from '@nestjs/common';
import { strict as assert } from 'assert';
import { validate } from 'class-validator';
import { describe, it } from 'node:test';
import { LoyaltyMembershipStatus } from '../../generated/prisma';
import {
  PublicLoyaltyEnrollDto,
  PublicLoyaltyEnrollmentIntent
} from './dto/public-loyalty-enroll.dto';
import {
  PUBLIC_LOYALTY_RECOVERY_REQUIRED_CODE,
  PUBLIC_LOYALTY_RECOVERY_REQUIRED_MESSAGE,
  PublicLoyaltyService
} from './public-loyalty.service';

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
    const emailOnly = Object.assign(new PublicLoyaltyEnrollDto(), {
      email: 'customer@example.test'
    });

    assert.equal((await validate(valid)).length, 0);
    assert.ok((await validate(invalidPhone)).length > 0);
    assert.ok((await validate(invalidEmail)).length > 0);
    assert.ok((await validate(emailOnly)).length > 0);
  });
});

describe('PublicLoyaltyService secure customer identity', () => {
  it('creates a card only for a new phone and optional new email', async () => {
    const setup = createSetup();

    const enrollment = await setup.service.enrollCustomer('sample-cafe', {
      phone: '07701234567',
      email: 'new.customer@example.test',
      intent: PublicLoyaltyEnrollmentIntent.JOIN
    });

    assert.equal(setup.state.customers.length, 1);
    assert.equal(setup.state.customers[0]?.phone, '+9647701234567');
    assert.equal(setup.state.memberships.length, 1);
    assert.equal(typeof enrollment.cardAccess.token, 'string');
  });

  it('returns the same verification response for existing and unknown recovery requests', async () => {
    const existing = createSetup();
    await existing.service.enrollCustomer('sample-cafe', {
      phone: '07701234567',
      intent: PublicLoyaltyEnrollmentIntent.JOIN
    });

    const existingResponse = await captureVerificationRequired(
      existing.service.enrollCustomer('sample-cafe', {
        phone: '+9647701234567',
        intent: PublicLoyaltyEnrollmentIntent.RECOVER
      })
    );

    const unknown = createSetup();
    const unknownResponse = await captureVerificationRequired(
      unknown.service.enrollCustomer('sample-cafe', {
        phone: '+9647712345678',
        intent: PublicLoyaltyEnrollmentIntent.RECOVER
      })
    );

    assert.deepEqual(existingResponse, unknownResponse);
    assert.equal(existing.state.transactionCalls, 1);
    assert.equal(unknown.state.transactionCalls, 0);
    assert.equal(unknown.state.customers.length, 0);
    assert.equal(unknown.state.memberships.length, 0);
  });

  it('blocks JOIN for an existing normalized phone without rotating card access', async () => {
    const setup = createSetup();
    await setup.service.enrollCustomer('sample-cafe', {
      phone: '07701234567',
      intent: PublicLoyaltyEnrollmentIntent.JOIN
    });
    const membershipBefore = {
      ...setup.state.memberships[0]
    };

    await captureVerificationRequired(
      setup.service.enrollCustomer('sample-cafe', {
        phone: '+9647701234567',
        intent: PublicLoyaltyEnrollmentIntent.JOIN
      })
    );

    assert.equal(setup.state.customers.length, 1);
    assert.equal(setup.state.memberships.length, 1);
    assert.deepEqual(setup.state.memberships[0], membershipBefore);
  });

  it('blocks JOIN when the optional email already belongs to a customer', async () => {
    const setup = createSetup();
    await setup.service.enrollCustomer('sample-cafe', {
      phone: '07701234567',
      email: 'existing.customer@example.test',
      intent: PublicLoyaltyEnrollmentIntent.JOIN
    });

    await captureVerificationRequired(
      setup.service.enrollCustomer('sample-cafe', {
        phone: '+9647712345678',
        email: 'existing.customer@example.test',
        intent: PublicLoyaltyEnrollmentIntent.JOIN
      })
    );

    assert.equal(setup.state.customers.length, 1);
    assert.equal(setup.state.memberships.length, 1);
  });

  it('does not log submitted identity or card access material', async () => {
    const setup = createSetup();
    const logs: string[] = [];
    const originalLog = console.log;
    const originalError = console.error;
    console.log = (...values: unknown[]) => logs.push(values.join(' '));
    console.error = (...values: unknown[]) => logs.push(values.join(' '));

    try {
      await setup.service.enrollCustomer('sample-cafe', {
        phone: '07701234567',
        email: 'private.customer@example.test',
        intent: PublicLoyaltyEnrollmentIntent.JOIN
      });
      await captureVerificationRequired(
        setup.service.enrollCustomer('sample-cafe', {
          phone: '+9647701234567',
          intent: PublicLoyaltyEnrollmentIntent.RECOVER
        })
      );
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }

    const output = logs.join('\n');
    assert.equal(output.includes('07701234567'), false);
    assert.equal(output.includes('+9647701234567'), false);
    assert.equal(output.includes('private.customer@example.test'), false);
    assert.equal(output.includes('cardAccess'), false);
    assert.equal(output.includes('publicAccessToken'), false);
  });
});

async function captureVerificationRequired(promise: Promise<unknown>) {
  try {
    await promise;
    assert.fail('Expected recovery verification requirement');
  } catch (error) {
    assert.ok(error instanceof HttpException);
    assert.equal(error.getStatus(), HttpStatus.FORBIDDEN);
    const response = error.getResponse();
    assert.deepEqual(response, {
      statusCode: HttpStatus.FORBIDDEN,
      code: PUBLIC_LOYALTY_RECOVERY_REQUIRED_CODE,
      message: PUBLIC_LOYALTY_RECOVERY_REQUIRED_MESSAGE
    });
    assert.equal(JSON.stringify(response).includes('cardAccess'), false);
    assert.equal(JSON.stringify(response).includes('customer'), false);
    return response;
  }
}

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
    memberships: [] as Array<any>,
    transactionCalls: 0
  };

  const transaction = {
    customer: {
      findFirst: async ({ where }: any) =>
        state.customers.find((customer) =>
          where.phone.in.includes(customer.phone)
        ) ?? null,
      findUnique: async ({ where }: any) =>
        state.customers.find((customer) => customer.email === where.email) ??
        null,
      create: async ({ data }: any) => {
        const customer = {
          id: `customer_${state.customers.length + 1}`,
          ...data,
          createdAt: now,
          updatedAt: now
        };
        state.customers.push(customer);
        return customer;
      }
    },
    loyaltyMembership: {
      create: async ({ data }: any) => {
        const membership = {
          id: `membership_${state.memberships.length + 1}`,
          stampCount: 0,
          rewardReady: false,
          totalStampsEarned: 0,
          totalRewardsRedeemed: 0,
          createdAt: now,
          updatedAt: now,
          ...data
        };
        state.memberships.push(membership);

        return {
          ...membership,
          business,
          loyaltyProgram: program,
          customer: state.customers.find(
            (customer) => customer.id === membership.customerId
          )
        };
      }
    }
  };

  const prisma = {
    business: {
      findFirst: async () => ({
        ...business,
        loyaltyPrograms: [program]
      })
    },
    $transaction: async (callback: (client: typeof transaction) => unknown) => {
      state.transactionCalls += 1;
      return callback(transaction);
    }
  };

  return {
    service: new PublicLoyaltyService(prisma as any),
    state
  };
}

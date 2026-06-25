import 'reflect-metadata';
import { HttpException, HttpStatus } from '@nestjs/common';
import { strict as assert } from 'assert';
import { validate } from 'class-validator';
import { describe, it } from 'node:test';
import {
  BusinessStatus,
  LoyaltyCardAccessSource,
  LoyaltyMembershipStatus
} from '../../generated/prisma';
import {
  PublicLoyaltyEnrollDto,
  PublicLoyaltyEnrollmentIntent
} from './dto/public-loyalty-enroll.dto';
import {
  PUBLIC_LOYALTY_RECOVERY_REQUIRED_CODE,
  PUBLIC_LOYALTY_RECOVERY_REQUIRED_MESSAGE,
  PUBLIC_LOYALTY_TRANSFER_RATE_LIMIT,
  PUBLIC_LOYALTY_TRANSFER_RATE_LIMITED_CODE,
  PUBLIC_LOYALTY_TRANSFER_UNAVAILABLE_CODE,
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

describe('PublicLoyaltyService secure card transfer', () => {
  it('creates a short-lived hash-only transfer from a trusted card session', async () => {
    const setup = createSetup();
    const enrollment = await enrollFixture(setup);

    const transfer = await setup.service.createCardTransfer(
      enrollment.cardAccess.token
    );

    assert.equal(setup.state.cardTransfers.length, 1);
    assert.equal(
      setup.state.cardTransfers[0]?.tokenHash.includes(transfer.transferToken),
      false
    );
    assert.equal(setup.state.cardTransfers[0]?.tokenHash.length, 64);
    assert.doesNotMatch(transfer.transferToken, /^waflo_scan_v1\./);
    assert.ok(
      new Date(transfer.expiresAt).getTime() > Date.now()
    );
  });

  it('rejects transfer creation without a valid trusted card session', async () => {
    const setup = createSetup();

    await assert.rejects(
      setup.service.createCardTransfer('x'.repeat(43)),
      (error: unknown) =>
        error instanceof HttpException &&
        error.getStatus() === HttpStatus.NOT_FOUND
    );

    assert.equal(setup.state.cardTransfers.length, 0);
  });

  it('adds a second card access while keeping the old access and stamp state', async () => {
    const setup = createSetup();
    const enrollment = await enrollFixture(setup);
    setup.state.memberships[0].stampCount = 3;
    setup.state.memberships[0].totalStampsEarned = 7;
    const oldCardBefore = await setup.service.getPublicCard(
      enrollment.cardAccess.token
    );
    const transfer = await setup.service.createCardTransfer(
      enrollment.cardAccess.token
    );

    const redeemed = await setup.service.redeemCardTransfer(
      transfer.transferToken
    );
    const oldCardAfter = await setup.service.getPublicCard(
      enrollment.cardAccess.token
    );
    const newCardAfter = await setup.service.getPublicCard(
      redeemed.cardAccess.token
    );
    const oldMembership =
      await setup.service.findMembershipByPublicCardToken(
        enrollment.cardAccess.token
      );
    const newMembership =
      await setup.service.findMembershipByPublicCardToken(
        redeemed.cardAccess.token
      );

    assert.notEqual(
      redeemed.cardAccess.token,
      enrollment.cardAccess.token
    );
    assert.equal(redeemed.cardState.stampCount, 3);
    assert.equal(redeemed.cardState.totalStampsEarned, 7);
    assert.deepEqual(oldCardAfter.cardState, oldCardBefore.cardState);
    assert.deepEqual(newCardAfter, oldCardAfter);
    assert.equal(newMembership.id, oldMembership.id);
    assert.equal(setup.state.cardAccesses.length, 2);
    assert.equal(
      setup.state.cardAccesses[1]?.source,
      LoyaltyCardAccessSource.TRANSFER
    );
    assert.ok(setup.state.cardTransfers[0]?.usedAt instanceof Date);

    await captureTransferUnavailable(
      setup.service.redeemCardTransfer(transfer.transferToken)
    );
  });

  it('rejects expired transfer credentials without rotating card access', async () => {
    const setup = createSetup();
    const enrollment = await enrollFixture(setup);
    const transfer = await setup.service.createCardTransfer(
      enrollment.cardAccess.token
    );
    const membershipBefore = {
      ...setup.state.memberships[0]
    };
    setup.state.cardTransfers[0].expiresAt = new Date(Date.now() - 1);

    await captureTransferUnavailable(
      setup.service.redeemCardTransfer(transfer.transferToken)
    );

    assert.deepEqual(setup.state.memberships[0], membershipBefore);
  });

  it('keeps a deployed membership-level token working and backfills access lazily', async () => {
    const setup = createSetup();
    const enrollment = await enrollFixture(setup);
    setup.state.cardAccesses.length = 0;

    const card = await setup.service.getPublicCard(
      enrollment.cardAccess.token
    );

    assert.equal(card.business.slug, 'sample-cafe');
    assert.equal(setup.state.cardAccesses.length, 1);
    assert.equal(
      setup.state.cardAccesses[0]?.source,
      LoyaltyCardAccessSource.JOIN
    );
  });

  it('does not let a revoked access fall through to the legacy token lookup', async () => {
    const setup = createSetup();
    const enrollment = await enrollFixture(setup);
    setup.state.cardAccesses[0].revokedAt = new Date();

    await assert.rejects(
      setup.service.getPublicCard(enrollment.cardAccess.token),
      (error: unknown) =>
        error instanceof HttpException &&
        error.getStatus() === HttpStatus.NOT_FOUND
    );
  });

  it('rejects cashier wallet scan QR values as transfer credentials', async () => {
    const setup = createSetup();
    const enrollment = await enrollFixture(setup);
    const membershipBefore = {
      ...setup.state.memberships[0]
    };

    await captureTransferUnavailable(
      setup.service.redeemCardTransfer(
        `waflo_scan_v1.${'x'.repeat(48)}`
      )
    );

    assert.deepEqual(setup.state.memberships[0], membershipBefore);
    assert.equal(enrollment.cardState.stampCount, 0);
  });

  it('rate-limits repeated transfer creation for one membership', async () => {
    const setup = createSetup();
    const enrollment = await enrollFixture(setup);

    for (let index = 0; index < PUBLIC_LOYALTY_TRANSFER_RATE_LIMIT; index += 1) {
      await setup.service.createCardTransfer(enrollment.cardAccess.token);
    }

    await assert.rejects(
      setup.service.createCardTransfer(enrollment.cardAccess.token),
      (error: unknown) => {
        if (!(error instanceof HttpException)) {
          return false;
        }

        const response = error.getResponse() as { code?: string };
        return (
          error.getStatus() === HttpStatus.TOO_MANY_REQUESTS &&
          response.code === PUBLIC_LOYALTY_TRANSFER_RATE_LIMITED_CODE
        );
      }
    );
  });

  it('does not log card or transfer credentials', async () => {
    const setup = createSetup();
    const logs: string[] = [];
    const originalLog = console.log;
    const originalError = console.error;
    console.log = (...values: unknown[]) => logs.push(values.join(' '));
    console.error = (...values: unknown[]) => logs.push(values.join(' '));

    try {
      const enrollment = await enrollFixture(setup);
      const transfer = await setup.service.createCardTransfer(
        enrollment.cardAccess.token
      );
      await setup.service.redeemCardTransfer(transfer.transferToken);

      const output = logs.join('\n');
      assert.equal(output.includes(enrollment.cardAccess.token), false);
      assert.equal(output.includes(transfer.transferToken), false);
      assert.equal(output.includes('customer@example.test'), false);
    } finally {
      console.log = originalLog;
      console.error = originalError;
    }
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

  it('allows the same phone to join a different business without leaking card access', async () => {
    const setup = createSetup();

    const firstEnrollment = await setup.service.enrollCustomer('sample-cafe', {
      phone: '07701234567',
      intent: PublicLoyaltyEnrollmentIntent.JOIN
    });
    const secondEnrollment = await setup.service.enrollCustomer(
      'chocolate-saray',
      {
        phone: '+9647701234567',
        intent: PublicLoyaltyEnrollmentIntent.JOIN
      }
    );
    const firstCard = await setup.service.getPublicCard(
      firstEnrollment.cardAccess.token
    );
    const secondCard = await setup.service.getPublicCard(
      secondEnrollment.cardAccess.token
    );

    assert.equal(setup.state.customers.length, 1);
    assert.equal(setup.state.memberships.length, 2);
    assert.notEqual(
      firstEnrollment.cardAccess.token,
      secondEnrollment.cardAccess.token
    );
    assert.equal(firstCard.business.slug, 'sample-cafe');
    assert.equal(secondCard.business.slug, 'chocolate-saray');
    assert.equal(secondEnrollment.business.slug, 'chocolate-saray');
    assert.equal(
      JSON.stringify(secondEnrollment).includes(firstEnrollment.cardAccess.token),
      false
    );

    await captureVerificationRequired(
      setup.service.enrollCustomer('chocolate-saray', {
        phone: '+9647701234567',
        intent: PublicLoyaltyEnrollmentIntent.RECOVER
      })
    );
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

async function captureTransferUnavailable(promise: Promise<unknown>) {
  try {
    await promise;
    assert.fail('Expected transfer credential to be unavailable');
  } catch (error) {
    assert.ok(error instanceof HttpException);
    assert.equal(error.getStatus(), HttpStatus.GONE);
    assert.deepEqual(error.getResponse(), {
      statusCode: HttpStatus.GONE,
      code: PUBLIC_LOYALTY_TRANSFER_UNAVAILABLE_CODE,
      message: 'This transfer code is invalid, expired, or already used.'
    });
  }
}

function enrollFixture(setup: ReturnType<typeof createSetup>) {
  return setup.service.enrollCustomer('sample-cafe', {
    phone: '07701234567',
    email: 'customer@example.test',
    intent: PublicLoyaltyEnrollmentIntent.JOIN
  });
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
    language: 'en',
    status: BusinessStatus.ACTIVE
  };
  const secondBusiness = {
    ...business,
    id: 'business_2',
    name: 'Chocolate Saray',
    slug: 'chocolate-saray',
    type: 'DESSERT'
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
  const secondProgram = {
    ...program,
    id: 'program_2',
    businessId: secondBusiness.id,
    name: 'Chocolate rewards',
    rewardName: 'Chocolate reward'
  };
  const businesses = [business, secondBusiness];
  const programs = [program, secondProgram];
  const state = {
    customers: [] as Array<any>,
    memberships: [] as Array<any>,
    cardTransfers: [] as Array<any>,
    cardAccesses: [] as Array<any>,
    transactionCalls: 0
  };

  function membershipWithRelations(membership: any) {
    const membershipBusiness =
      businesses.find((item) => item.id === membership.businessId) ?? business;
    const membershipProgram =
      programs.find((item) => item.id === membership.loyaltyProgramId) ??
      program;

    return {
      ...membership,
      business: membershipBusiness,
      loyaltyProgram: {
        ...membershipProgram,
        stampStyle: null
      },
      customer: state.customers.find(
        (customer) => customer.id === membership.customerId
      )
    };
  }

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
      findFirst: async ({ where }: any) => {
        const membership = state.memberships.find(
          (item) =>
            item.businessId === where.businessId &&
            item.loyaltyProgramId === where.loyaltyProgramId &&
            item.customerId === where.customerId
        );

        return membership ? { id: membership.id } : null;
      },
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

        return membershipWithRelations(membership);
      },
      update: async ({ where, data }: any) => {
        const membership = state.memberships.find(
          (item) => item.id === where.id
        );
        Object.assign(membership, data, { updatedAt: new Date() });
        return membershipWithRelations(membership);
      },
      findUniqueOrThrow: async ({ where }: any) => {
        const membership = state.memberships.find(
          (item) => item.id === where.id
        );

        if (!membership) {
          throw new Error('Membership not found');
        }

        return membershipWithRelations(membership);
      }
    },
    loyaltyCardAccess: {
      create: async ({ data }: any) => {
        const access = {
          id: `access_${state.cardAccesses.length + 1}`,
          lastUsedAt: null,
          revokedAt: null,
          createdAt: new Date(),
          ...data
        };
        state.cardAccesses.push(access);
        return access;
      },
      update: async ({ where, data }: any) => {
        const access = state.cardAccesses.find(
          (item) => item.id === where.id
        );
        Object.assign(access, data);
        return access;
      },
      upsert: async ({ where, create, update }: any) => {
        let access = state.cardAccesses.find(
          (item) => item.tokenHash === where.tokenHash
        );

        if (access) {
          Object.assign(access, update);
          return access;
        }

        access = {
          id: `access_${state.cardAccesses.length + 1}`,
          revokedAt: null,
          createdAt: new Date(),
          ...create
        };
        state.cardAccesses.push(access);
        return access;
      }
    },
    loyaltyCardTransfer: {
      count: async ({ where }: any) =>
        state.cardTransfers.filter(
          (transfer) =>
            transfer.membershipId === where.membershipId &&
            transfer.createdAt >= where.createdAt.gte
        ).length,
      create: async ({ data }: any) => {
        const transfer = {
          id: `transfer_${state.cardTransfers.length + 1}`,
          usedAt: null,
          createdAt: new Date(),
          ...data
        };
        state.cardTransfers.push(transfer);
        return transfer;
      },
      findUnique: async ({ where }: any) => {
        const transfer = state.cardTransfers.find(
          (item) => item.tokenHash === where.tokenHash
        );

        if (!transfer) {
          return null;
        }

        return {
          ...transfer,
          membership: membershipWithRelations(
            state.memberships.find(
              (membership) => membership.id === transfer.membershipId
            )
          )
        };
      },
      updateMany: async ({ where, data }: any) => {
        const transfer = state.cardTransfers.find(
          (item) =>
            item.id === where.id &&
            item.usedAt === null &&
            item.expiresAt > where.expiresAt.gt
        );

        if (!transfer) {
          return { count: 0 };
        }

        Object.assign(transfer, data);
        return { count: 1 };
      }
    }
  };

  const prisma = {
    business: {
      findFirst: async ({ where }: any) => {
        const foundBusiness = businesses.find(
          (item) => item.slug === where.slug && item.status === where.status
        );

        if (!foundBusiness) {
          return null;
        }

        return {
          ...foundBusiness,
          loyaltyPrograms: programs.filter(
            (item) => item.businessId === foundBusiness.id && item.isActive
          )
        };
      }
    },
    loyaltyMembership: {
      findFirst: async ({ where }: any) => {
        const membership = state.memberships.find(
          (item) =>
            item.publicAccessTokenHash === where.publicAccessTokenHash &&
            item.status === where.status
        );
        return membership ? { id: membership.id } : null;
      },
      update: transaction.loyaltyMembership.update
    },
    loyaltyCardAccess: {
      findFirst: async ({ where }: any) => {
        const access = state.cardAccesses.find(
          (item) =>
            item.tokenHash === where.tokenHash &&
            item.revokedAt === where.revokedAt
        );

        return access
          ? {
              id: access.id,
              membershipId: access.membershipId
            }
          : null;
      },
      findUnique: async ({ where }: any) => {
        const access = state.cardAccesses.find(
          (item) => item.tokenHash === where.tokenHash
        );

        return access
          ? {
              id: access.id
            }
          : null;
      }
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

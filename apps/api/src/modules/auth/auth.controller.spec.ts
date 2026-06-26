import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
import {
  BusinessUserRole,
  BusinessUserStatus,
  UserStatus
} from '../../generated/prisma';
import { AuthController } from './auth.controller';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface';

describe('AuthController /me contract', () => {
  it('returns OWNER when the active business membership is OWNER', async () => {
    const controller = createController([
      membership({
        id: 'membership_owner',
        role: BusinessUserRole.OWNER,
        business: business({ id: 'business_owner', slug: 'owner-business' })
      })
    ]);

    const response = await controller.getMe(user());

    assert.equal(response.memberships.length, 1);
    assert.equal(response.memberships[0].role, BusinessUserRole.OWNER);
    assert.equal(response.businesses[0].role, BusinessUserRole.OWNER);
    assert.deepEqual(response.onboarding, {
      hasBusiness: true,
      activeBusinessCount: 1,
      recommendedNextStep: 'OPEN_DASHBOARD'
    });
  });

  it('returns STAFF only when the active business membership is STAFF', async () => {
    const controller = createController([
      membership({
        id: 'membership_staff',
        role: BusinessUserRole.STAFF,
        business: business({ id: 'business_staff', slug: 'staff-business' })
      })
    ]);

    const response = await controller.getMe(user());

    assert.equal(response.memberships[0].role, BusinessUserRole.STAFF);
    assert.equal(response.businesses[0].role, BusinessUserRole.STAFF);
    assert.equal(response.onboarding.recommendedNextStep, 'OPEN_DASHBOARD');
  });

  it('preserves the real role for each active membership instead of guessing one role for all businesses', async () => {
    const controller = createController([
      membership({
        id: 'membership_owner',
        role: BusinessUserRole.OWNER,
        business: business({ id: 'business_owner', slug: 'owner-business' })
      }),
      membership({
        id: 'membership_staff',
        role: BusinessUserRole.STAFF,
        business: business({ id: 'business_staff', slug: 'staff-business' })
      })
    ]);

    const response = await controller.getMe(user());

    assert.deepEqual(
      response.memberships.map((item) => item.role),
      [BusinessUserRole.OWNER, BusinessUserRole.STAFF]
    );
    assert.deepEqual(
      response.businesses.map((item) => item.role),
      [BusinessUserRole.OWNER, BusinessUserRole.STAFF]
    );
    assert.deepEqual(response.onboarding, {
      hasBusiness: true,
      activeBusinessCount: 2,
      recommendedNextStep: 'SELECT_BUSINESS'
    });
  });

  it('returns onboarding guidance for an authenticated user with no active business', async () => {
    const controller = createController([]);

    const response = await controller.getMe(user());

    assert.deepEqual(response.memberships, []);
    assert.deepEqual(response.businesses, []);
    assert.deepEqual(response.onboarding, {
      hasBusiness: false,
      activeBusinessCount: 0,
      recommendedNextStep: 'CREATE_BUSINESS'
    });
  });

  it('queries only active memberships ordered by creation time', async () => {
    const calls: unknown[] = [];
    const controller = new AuthController({
      businessUser: {
        findMany: async (args: unknown) => {
          calls.push(args);
          return [];
        }
      }
    } as any);

    await controller.getMe(user());

    assert.deepEqual(calls, [
      {
        where: {
          userId: 'user_operator',
          status: BusinessUserStatus.ACTIVE
        },
        include: {
          business: true
        },
        orderBy: {
          createdAt: 'asc'
        }
      }
    ]);
  });
});

function createController(memberships: Array<ReturnType<typeof membership>>) {
  return new AuthController({
    businessUser: {
      findMany: async () => memberships
    }
  } as any);
}

function user(): AuthenticatedUser {
  const now = new Date('2026-06-26T00:00:00.000Z');

  return {
    id: 'user_operator',
    clerkUserId: 'clerk_operator',
    name: 'Operator',
    email: null,
    phone: null,
    status: UserStatus.ACTIVE,
    createdAt: now,
    updatedAt: now
  };
}

function membership({
  id,
  role,
  business: businessRecord
}: {
  id: string;
  role: BusinessUserRole;
  business: ReturnType<typeof business>;
}) {
  return {
    id,
    userId: 'user_operator',
    businessId: businessRecord.id,
    role,
    status: BusinessUserStatus.ACTIVE,
    createdAt: new Date('2026-06-26T00:00:00.000Z'),
    updatedAt: new Date('2026-06-26T00:00:00.000Z'),
    business: businessRecord
  };
}

function business({
  id,
  slug
}: {
  id: string;
  slug: string;
}) {
  return {
    id,
    ownerId: 'user_operator',
    name: 'Test Business',
    slug,
    type: 'cafe',
    city: 'Baghdad',
    currency: 'IQD',
    language: 'ar',
    logoUrl: null,
    coverUrl: null,
    status: 'ACTIVE',
    menuTemplateId: 'waflo-warm',
    menuThemeOverrides: null,
    createdAt: new Date('2026-06-26T00:00:00.000Z'),
    updatedAt: new Date('2026-06-26T00:00:00.000Z')
  };
}

import { strict as assert } from 'assert';
import { describe, it } from 'node:test';
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

import {
  Business,
  BusinessUserRole,
  BusinessUserStatus,
  LoyaltyTransactionType,
  PrismaClient,
  UserStatus
} from '../src/generated/prisma';

const prisma = new PrismaClient();

async function main() {
  const owner = await prisma.user.upsert({
    where: {
      clerkUserId: 'user_tavrix_owner'
    },
    create: {
      clerkUserId: 'user_tavrix_owner',
      name: 'Tavrix Owner',
      email: 'owner@tavrix.local',
      status: UserStatus.ACTIVE
    },
    update: {
      name: 'Tavrix Owner',
      email: 'owner@tavrix.local',
      status: UserStatus.ACTIVE
    }
  });

  const business = await prisma.business.upsert({
    where: {
      slug: 'tavrix-cafe'
    },
    create: {
      ownerId: owner.id,
      name: 'Tavrix Cafe',
      slug: 'tavrix-cafe',
      type: 'cafe',
      city: 'Baghdad',
      currency: 'IQD',
      language: 'ar'
    },
    update: {
      ownerId: owner.id,
      name: 'Tavrix Cafe',
      type: 'cafe',
      city: 'Baghdad',
      currency: 'IQD',
      language: 'ar'
    }
  });

  await prisma.businessUser.upsert({
    where: {
      businessId_userId: {
        businessId: business.id,
        userId: owner.id
      }
    },
    create: {
      businessId: business.id,
      userId: owner.id,
      role: BusinessUserRole.OWNER
    },
    update: {
      role: BusinessUserRole.OWNER,
      status: BusinessUserStatus.ACTIVE
    }
  });

  await prisma.businessUser.updateMany({
    where: {
      businessId: business.id,
      userId: {
        not: owner.id
      },
      role: BusinessUserRole.OWNER,
      user: {
        clerkUserId: 'dev_tavrix_owner'
      }
    },
    data: {
      status: BusinessUserStatus.DISABLED
    }
  });

  const hotDrinks = await upsertCategory(business, {
    nameAr: 'Hot Drinks',
    nameEn: null,
    sortOrder: 0
  });
  const desserts = await upsertCategory(business, {
    nameAr: 'Desserts',
    nameEn: null,
    sortOrder: 1
  });

  await upsertItem(business, hotDrinks.id, {
    nameAr: 'Turkish Coffee',
    nameEn: null,
    descriptionAr: 'Traditional strong coffee.',
    descriptionEn: null,
    price: '3000',
    sortOrder: 0
  });
  await upsertItem(business, desserts.id, {
    nameAr: 'Tamriya',
    nameEn: null,
    descriptionAr: 'Sweet date pastry.',
    descriptionEn: null,
    price: '1500',
    sortOrder: 0
  });
  await upsertItem(business, desserts.id, {
    nameAr: 'Baklava',
    nameEn: null,
    descriptionAr: 'Layered pastry with nuts.',
    descriptionEn: null,
    price: '2000',
    sortOrder: 1
  });

  await seedLoyaltyDemo(business, owner.id);

  console.log('Seeded Tavrix Cafe demo data.');
  console.log(
    'Development auth token: Bearer dev:user_tavrix_owner;email=owner@tavrix.local;name=Tavrix%20Owner'
  );
}

async function upsertCategory(
  business: Business,
  category: {
    nameAr: string;
    nameEn: string | null;
    sortOrder: number;
  }
) {
  const existingCategory = await prisma.menuCategory.findFirst({
    where: {
      businessId: business.id,
      nameAr: category.nameAr
    }
  });

  if (existingCategory) {
    return prisma.menuCategory.update({
      where: {
        id: existingCategory.id
      },
      data: {
        nameEn: category.nameEn,
        sortOrder: category.sortOrder,
        isActive: true
      }
    });
  }

  return prisma.menuCategory.create({
    data: {
      businessId: business.id,
      nameAr: category.nameAr,
      nameEn: category.nameEn,
      sortOrder: category.sortOrder,
      isActive: true
    }
  });
}

async function upsertItem(
  business: Business,
  categoryId: string,
  item: {
    nameAr: string;
    nameEn: string | null;
    descriptionAr: string;
    descriptionEn: string | null;
    price: string;
    sortOrder: number;
  }
) {
  const existingItem = await prisma.menuItem.findFirst({
    where: {
      businessId: business.id,
      nameAr: item.nameAr
    }
  });

  if (existingItem) {
    return prisma.menuItem.update({
      where: {
        id: existingItem.id
      },
      data: {
        categoryId,
        nameEn: item.nameEn,
        descriptionAr: item.descriptionAr,
        descriptionEn: item.descriptionEn,
        price: item.price,
        sortOrder: item.sortOrder,
        isAvailable: true
      }
    });
  }

  return prisma.menuItem.create({
    data: {
      businessId: business.id,
      categoryId,
      nameAr: item.nameAr,
      nameEn: item.nameEn,
      descriptionAr: item.descriptionAr,
      descriptionEn: item.descriptionEn,
      price: item.price,
      sortOrder: item.sortOrder,
      isAvailable: true
    }
  });
}

async function seedLoyaltyDemo(business: Business, ownerUserId: string) {
  const existingProgram = await prisma.loyaltyProgram.findFirst({
    where: {
      businessId: business.id,
      name: 'Tavrix Cafe Stamp Card'
    }
  });
  const program = existingProgram
    ? await prisma.loyaltyProgram.update({
        where: {
          id: existingProgram.id
        },
        data: {
          description: 'Collect 5 coffee stamps and earn a free coffee.',
          stampGoal: 5,
          rewardName: 'Free coffee',
          rewardDescription: 'One free Turkish Coffee after 5 stamps.',
          isActive: true,
          cardColor: '#111827',
          accentColor: '#f59e0b',
          logoUrl: null,
          terms: 'Reward is valid for one free Turkish Coffee.'
        }
      })
    : await prisma.loyaltyProgram.create({
        data: {
          businessId: business.id,
          name: 'Tavrix Cafe Stamp Card',
          description: 'Collect 5 coffee stamps and earn a free coffee.',
          stampGoal: 5,
          rewardName: 'Free coffee',
          rewardDescription: 'One free Turkish Coffee after 5 stamps.',
          isActive: true,
          cardColor: '#111827',
          accentColor: '#f59e0b',
          terms: 'Reward is valid for one free Turkish Coffee.'
        }
      });

  await prisma.loyaltyProgram.updateMany({
    where: {
      businessId: business.id,
      id: {
        not: program.id
      },
      isActive: true
    },
    data: {
      isActive: false
    }
  });

  const customer = await prisma.customer.upsert({
    where: {
      phone: '+9647700000000'
    },
    create: {
      phone: '+9647700000000',
      email: 'coffee.customer@example.com',
      name: 'Coffee Customer'
    },
    update: {
      email: 'coffee.customer@example.com',
      name: 'Coffee Customer'
    }
  });

  const membership = await prisma.loyaltyMembership.upsert({
    where: {
      customerId_loyaltyProgramId: {
        customerId: customer.id,
        loyaltyProgramId: program.id
      }
    },
    create: {
      businessId: business.id,
      loyaltyProgramId: program.id,
      customerId: customer.id,
      stampCount: 3,
      rewardReady: false,
      totalStampsEarned: 3,
      totalRewardsRedeemed: 0
    },
    update: {
      stampCount: 3,
      rewardReady: false,
      totalStampsEarned: 3,
      totalRewardsRedeemed: 0,
      status: 'ACTIVE'
    }
  });

  await prisma.loyaltyTransaction.deleteMany({
    where: {
      membershipId: membership.id
    }
  });

  await prisma.loyaltyTransaction.createMany({
    data: [
      {
        businessId: business.id,
        loyaltyProgramId: program.id,
        membershipId: membership.id,
        customerId: customer.id,
        actorUserId: ownerUserId,
        type: LoyaltyTransactionType.STAMP_ADDED,
        stampsDelta: 1,
        reason: 'Demo coffee purchase'
      },
      {
        businessId: business.id,
        loyaltyProgramId: program.id,
        membershipId: membership.id,
        customerId: customer.id,
        actorUserId: ownerUserId,
        type: LoyaltyTransactionType.STAMP_ADDED,
        stampsDelta: 1,
        reason: 'Demo pastry purchase'
      },
      {
        businessId: business.id,
        loyaltyProgramId: program.id,
        membershipId: membership.id,
        customerId: customer.id,
        actorUserId: ownerUserId,
        type: LoyaltyTransactionType.STAMP_ADDED,
        stampsDelta: 1,
        reason: 'Demo repeat visit'
      }
    ]
  });
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

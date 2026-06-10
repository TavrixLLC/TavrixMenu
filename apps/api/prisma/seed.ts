import {
  Business,
  BusinessUserRole,
  BusinessUserStatus,
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

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

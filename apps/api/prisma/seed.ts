import {
  Business,
  BusinessUserRole,
  BusinessUserStatus,
  LoyaltyStampLayoutVariant,
  LoyaltyStampPresetKey,
  LoyaltyStampStyleType,
  LoyaltyTransactionType,
  LoyaltyWalletColorMode,
  LoyaltyWalletThemePreset,
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

  // 1. Seed Tavrix Cafe
  const businessTavrix = await prisma.business.upsert({
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
      slug: 'tavrix-cafe',
      type: 'cafe',
      city: 'Baghdad',
      currency: 'IQD',
      language: 'ar'
    }
  });

  await prisma.businessUser.upsert({
    where: {
      businessId_userId: {
        businessId: businessTavrix.id,
        userId: owner.id
      }
    },
    create: {
      businessId: businessTavrix.id,
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
      businessId: businessTavrix.id,
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

  const hotDrinks = await upsertCategory(businessTavrix, {
    nameAr: 'Hot Drinks',
    nameEn: null,
    sortOrder: 0
  });
  const desserts = await upsertCategory(businessTavrix, {
    nameAr: 'Desserts',
    nameEn: null,
    sortOrder: 1
  });

  await upsertItem(businessTavrix, hotDrinks.id, {
    nameAr: 'Turkish Coffee',
    nameEn: null,
    descriptionAr: 'Traditional strong coffee.',
    descriptionEn: null,
    price: '3000',
    sortOrder: 0
  });
  await upsertItem(businessTavrix, desserts.id, {
    nameAr: 'Tamriya',
    nameEn: null,
    descriptionAr: 'Sweet date pastry.',
    descriptionEn: null,
    price: '1500',
    sortOrder: 0
  });
  await upsertItem(businessTavrix, desserts.id, {
    nameAr: 'Baklava',
    nameEn: null,
    descriptionAr: 'Layered pastry with nuts.',
    descriptionEn: null,
    price: '2000',
    sortOrder: 1
  });

  await seedLoyaltyDemo(
    businessTavrix,
    owner.id,
    'Tavrix Cafe Stamp Card',
    'Collect 5 coffee stamps and earn a free coffee.',
    5,
    'Free coffee',
    'One free Turkish Coffee after 5 stamps.',
    'Reward is valid for one free Turkish Coffee.'
  );

  // 2. Seed Happy Birthday Staging
  const businessBirthday = await prisma.business.upsert({
    where: {
      slug: 'happy-birthday-2'
    },
    create: {
      ownerId: owner.id,
      name: 'Happy Birthday Staging',
      slug: 'happy-birthday-2',
      type: 'cafe',
      city: 'Baghdad',
      currency: 'IQD',
      language: 'ar'
    },
    update: {
      ownerId: owner.id,
      name: 'Happy Birthday Staging',
      slug: 'happy-birthday-2',
      type: 'cafe',
      city: 'Baghdad',
      currency: 'IQD',
      language: 'ar'
    }
  });

  await prisma.businessUser.upsert({
    where: {
      businessId_userId: {
        businessId: businessBirthday.id,
        userId: owner.id
      }
    },
    create: {
      businessId: businessBirthday.id,
      userId: owner.id,
      role: BusinessUserRole.OWNER
    },
    update: {
      role: BusinessUserRole.OWNER,
      status: BusinessUserStatus.ACTIVE
    }
  });

  const bdayCategory = await upsertCategory(businessBirthday, {
    nameAr: 'Birthday Specials',
    nameEn: null,
    sortOrder: 0
  });

  await upsertItem(businessBirthday, bdayCategory.id, {
    nameAr: 'Staging Coffee',
    nameEn: null,
    descriptionAr: 'Staging test coffee.',
    descriptionEn: null,
    price: '1000',
    sortOrder: 0
  });

  await seedLoyaltyDemo(
    businessBirthday,
    owner.id,
    'Happy Birthday Loyalty',
    'Collect 10 stamps to get a free staging reward.',
    10,
    'Free Staging Reward',
    'One free custom staging menu item after 10 stamps.',
    'Valid for staging tests only.'
  );

  await seedWalletVisualQaBusinesses(owner.id);

  console.log('Seeded Tavrix Cafe, Happy Birthday, and wallet visual QA data.');
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

async function seedLoyaltyDemo(
  business: Business,
  ownerUserId: string,
  programName: string,
  programDescription: string,
  stampGoal: number,
  rewardName: string,
  rewardDescription: string,
  terms: string
) {
  const existingProgram = await prisma.loyaltyProgram.findFirst({
    where: {
      businessId: business.id,
      name: programName
    }
  });
  const program = existingProgram
    ? await prisma.loyaltyProgram.update({
        where: {
          id: existingProgram.id
        },
        data: {
          description: programDescription,
          stampGoal,
          rewardName,
          rewardDescription,
          isActive: true,
          cardColor: '#111827',
          accentColor: '#f59e0b',
          logoUrl: null,
          terms
        }
      })
    : await prisma.loyaltyProgram.create({
        data: {
          businessId: business.id,
          name: programName,
          description: programDescription,
          stampGoal,
          rewardName,
          rewardDescription,
          isActive: true,
          cardColor: '#111827',
          accentColor: '#f59e0b',
          terms
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

  await prisma.loyaltyStampStyle.upsert({
    where: {
      loyaltyProgramId: program.id
    },
    create: {
      loyaltyProgramId: program.id,
      styleType: LoyaltyStampStyleType.PRESET,
      presetKey: LoyaltyStampPresetKey.COFFEE,
      backgroundColor: '#7c2d12',
      accentColor: '#facc15',
      textColor: '#ffffff',
      walletBackgroundColor: '#7c2d12',
      imageBackgroundColor: '#7c2d12',
      imageSurfaceColor: '#92400e',
      imageAccentColor: '#facc15',
      imageTextColor: '#ffffff',
      stampFilledColor: '#facc15',
      stampEmptyColor: '#d6d3d1',
      rewardBannerColor: '#a16207',
      themePreset: LoyaltyWalletThemePreset.COFFEE,
      colorMode: LoyaltyWalletColorMode.PRESET,
      layoutVariant: LoyaltyStampLayoutVariant.MODERN
    },
    update: {
      styleType: LoyaltyStampStyleType.PRESET,
      presetKey: LoyaltyStampPresetKey.COFFEE,
      backgroundColor: '#7c2d12',
      accentColor: '#facc15',
      textColor: '#ffffff',
      walletBackgroundColor: '#7c2d12',
      imageBackgroundColor: '#7c2d12',
      imageSurfaceColor: '#92400e',
      imageAccentColor: '#facc15',
      imageTextColor: '#ffffff',
      stampFilledColor: '#facc15',
      stampEmptyColor: '#d6d3d1',
      rewardBannerColor: '#a16207',
      themePreset: LoyaltyWalletThemePreset.COFFEE,
      colorMode: LoyaltyWalletColorMode.PRESET,
      layoutVariant: LoyaltyStampLayoutVariant.MODERN
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

async function seedWalletVisualQaBusinesses(ownerUserId: string) {
  const styles = [
    {
      slug: 'wallet-cookie-qa',
      businessName: 'Cookie Wallet QA',
      programName: 'Cookie Club',
      rewardName: 'Free cookie box',
      stampGoal: 5,
      presetKey: LoyaltyStampPresetKey.COOKIE,
      themePreset: LoyaltyWalletThemePreset.DESSERT,
      palette: {
        walletBackgroundColor: '#be185d',
        imageBackgroundColor: '#831843',
        imageSurfaceColor: '#9d174d',
        imageAccentColor: '#f9a8d4',
        imageTextColor: '#fff1f2',
        stampFilledColor: '#f9a8d4',
        stampEmptyColor: '#fce7f3',
        rewardBannerColor: '#be185d'
      }
    },
    {
      slug: 'wallet-coffee-qa',
      businessName: 'Coffee Wallet QA',
      programName: 'Coffee Rewards',
      rewardName: 'Free Turkish coffee',
      stampGoal: 8,
      presetKey: LoyaltyStampPresetKey.COFFEE,
      themePreset: LoyaltyWalletThemePreset.COFFEE,
      palette: {
        walletBackgroundColor: '#7c2d12',
        imageBackgroundColor: '#7c2d12',
        imageSurfaceColor: '#92400e',
        imageAccentColor: '#facc15',
        imageTextColor: '#ffffff',
        stampFilledColor: '#facc15',
        stampEmptyColor: '#d6d3d1',
        rewardBannerColor: '#a16207'
      }
    },
    {
      slug: 'wallet-blue-qa',
      businessName: 'Blue Wallet QA',
      programName: 'Blue Rewards',
      rewardName: 'Free menu item',
      stampGoal: 10,
      presetKey: LoyaltyStampPresetKey.STAR,
      themePreset: LoyaltyWalletThemePreset.DEFAULT,
      palette: {
        walletBackgroundColor: '#2563eb',
        imageBackgroundColor: '#1d4ed8',
        imageSurfaceColor: '#2563eb',
        imageAccentColor: '#fde047',
        imageTextColor: '#eff6ff',
        stampFilledColor: '#fde047',
        stampEmptyColor: '#bfdbfe',
        rewardBannerColor: '#1e40af'
      }
    },
    {
      slug: 'wallet-dark-qa',
      businessName: 'Dark Wallet QA',
      programName: 'After Dark Rewards',
      rewardName: 'VIP dessert',
      stampGoal: 12,
      presetKey: LoyaltyStampPresetKey.HEART,
      themePreset: LoyaltyWalletThemePreset.MINIMAL,
      palette: {
        walletBackgroundColor: '#111827',
        imageBackgroundColor: '#111827',
        imageSurfaceColor: '#1f2937',
        imageAccentColor: '#e5e7eb',
        imageTextColor: '#f9fafb',
        stampFilledColor: '#f9fafb',
        stampEmptyColor: '#9ca3af',
        rewardBannerColor: '#374151'
      }
    }
  ] as const;

  for (const style of styles) {
    const business = await prisma.business.upsert({
      where: {
        slug: style.slug
      },
      create: {
        ownerId: ownerUserId,
        name: style.businessName,
        slug: style.slug,
        type: 'wallet-qa',
        city: 'Baghdad',
        currency: 'IQD',
        language: 'en'
      },
      update: {
        ownerId: ownerUserId,
        name: style.businessName,
        type: 'wallet-qa',
        city: 'Baghdad',
        currency: 'IQD',
        language: 'en',
        status: 'ACTIVE'
      }
    });

    await prisma.businessUser.upsert({
      where: {
        businessId_userId: {
          businessId: business.id,
          userId: ownerUserId
        }
      },
      create: {
        businessId: business.id,
        userId: ownerUserId,
        role: BusinessUserRole.OWNER
      },
      update: {
        role: BusinessUserRole.OWNER,
        status: BusinessUserStatus.ACTIVE
      }
    });

    const existingProgram = await prisma.loyaltyProgram.findFirst({
      where: {
        businessId: business.id,
        name: style.programName
      }
    });
    const program = existingProgram
      ? await prisma.loyaltyProgram.update({
          where: {
            id: existingProgram.id
          },
          data: {
            description: 'Sprint 11 wallet visual QA program.',
            stampGoal: style.stampGoal,
            rewardName: style.rewardName,
            rewardDescription: style.rewardName,
            isActive: true,
            cardColor: style.palette.walletBackgroundColor,
            accentColor: style.palette.imageAccentColor,
            terms: 'Staging visual QA only.'
          }
        })
      : await prisma.loyaltyProgram.create({
          data: {
            businessId: business.id,
            name: style.programName,
            description: 'Sprint 11 wallet visual QA program.',
            stampGoal: style.stampGoal,
            rewardName: style.rewardName,
            rewardDescription: style.rewardName,
            isActive: true,
            cardColor: style.palette.walletBackgroundColor,
            accentColor: style.palette.imageAccentColor,
            terms: 'Staging visual QA only.'
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

    await prisma.loyaltyStampStyle.upsert({
      where: {
        loyaltyProgramId: program.id
      },
      create: {
        loyaltyProgramId: program.id,
        styleType: LoyaltyStampStyleType.PRESET,
        presetKey: style.presetKey,
        backgroundColor: style.palette.imageBackgroundColor,
        accentColor: style.palette.imageAccentColor,
        textColor: style.palette.imageTextColor,
        ...style.palette,
        themePreset: style.themePreset,
        colorMode: LoyaltyWalletColorMode.PRESET,
        layoutVariant: LoyaltyStampLayoutVariant.MODERN
      },
      update: {
        styleType: LoyaltyStampStyleType.PRESET,
        presetKey: style.presetKey,
        backgroundColor: style.palette.imageBackgroundColor,
        accentColor: style.palette.imageAccentColor,
        textColor: style.palette.imageTextColor,
        ...style.palette,
        themePreset: style.themePreset,
        colorMode: LoyaltyWalletColorMode.PRESET,
        layoutVariant: LoyaltyStampLayoutVariant.MODERN
      }
    });
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

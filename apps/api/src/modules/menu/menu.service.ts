import {
  BadRequestException,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import {
  BusinessStatus,
  MenuCategory,
  MenuItem
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessAccessService } from '../businesses/business-access.service';
import { resolveMenuTemplateId } from '../businesses/menu-appearance.constants';
import { CreateCategoryDto } from './dto/create-category.dto';
import { CreateItemDto } from './dto/create-item.dto';
import { ReorderMenuRecordsDto } from './dto/reorder-menu-records.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { UpdateItemDto } from './dto/update-item.dto';

@Injectable()
export class MenuService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly businessAccessService: BusinessAccessService
  ) {}

  async createCategory(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: CreateCategoryDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.businessAccessService.menuManagerRoles
    );

    const category = await this.prisma.menuCategory.create({
      data: {
        businessId,
        nameAr: dto.nameAr,
        nameEn: dto.nameEn,
        sortOrder: dto.sortOrder ?? 0,
        isActive: dto.isActive ?? true
      }
    });

    return this.mapCategory(category);
  }

  async getCategories(
    currentUser: AuthenticatedUser,
    businessId: string,
    includeInactive = false
  ) {
    await this.businessAccessService.assertMembership(businessId, currentUser.id);

    const categories = await this.prisma.menuCategory.findMany({
      where: {
        businessId,
        ...(includeInactive ? {} : { isActive: true })
      },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }, { id: 'asc' }]
    });

    return categories.map((category) => this.mapCategory(category));
  }

  async reorderCategories(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: ReorderMenuRecordsDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.businessAccessService.menuManagerRoles
    );
    this.assertUniqueOrderIds(dto.orders, 'category');

    const ids = dto.orders.map((order) => order.id);
    const categories = await this.prisma.menuCategory.findMany({
      where: {
        id: {
          in: ids
        }
      },
      select: {
        id: true,
        businessId: true
      }
    });

    if (
      categories.length !== ids.length ||
      categories.some((category) => category.businessId !== businessId)
    ) {
      throw new BadRequestException(
        'All category IDs must belong to the business'
      );
    }

    await this.prisma.$transaction(
      dto.orders.map((order) =>
        this.prisma.menuCategory.update({
          where: {
            id: order.id
          },
          data: {
            sortOrder: order.sortOrder
          }
        })
      )
    );

    const updatedCategories = await this.prisma.menuCategory.findMany({
      where: {
        id: {
          in: ids
        },
        businessId
      },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }, { id: 'asc' }]
    });

    return updatedCategories.map((category) => this.mapCategory(category));
  }

  async updateCategory(
    currentUser: AuthenticatedUser,
    categoryId: string,
    dto: UpdateCategoryDto
  ) {
    const existingCategory = await this.prisma.menuCategory.findUnique({
      where: {
        id: categoryId
      },
      select: {
        businessId: true
      }
    });

    if (!existingCategory) {
      throw new NotFoundException('Category not found');
    }

    await this.businessAccessService.assertRole(
      existingCategory.businessId,
      currentUser.id,
      this.businessAccessService.menuManagerRoles
    );

    const category = await this.prisma.menuCategory.update({
      where: {
        id: categoryId
      },
      data: {
        nameAr: dto.nameAr,
        nameEn: dto.nameEn,
        sortOrder: dto.sortOrder,
        isActive: dto.isActive
      }
    });

    return this.mapCategory(category);
  }

  async deleteCategory(currentUser: AuthenticatedUser, categoryId: string) {
    const existingCategory = await this.prisma.menuCategory.findUnique({
      where: {
        id: categoryId
      },
      select: {
        businessId: true
      }
    });

    if (!existingCategory) {
      throw new NotFoundException('Category not found');
    }

    await this.businessAccessService.assertRole(
      existingCategory.businessId,
      currentUser.id,
      this.businessAccessService.menuManagerRoles
    );

    await this.prisma.menuCategory.update({
      where: {
        id: categoryId
      },
      data: {
        isActive: false
      }
    });

    return {
      deleted: true
    };
  }

  async createItem(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: CreateItemDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.businessAccessService.menuManagerRoles
    );
    await this.assertCategoryInBusiness(dto.categoryId, businessId);

    const item = await this.prisma.menuItem.create({
      data: {
        businessId,
        categoryId: dto.categoryId,
        nameAr: dto.nameAr,
        nameEn: dto.nameEn,
        descriptionAr: dto.descriptionAr,
        descriptionEn: dto.descriptionEn,
        price: dto.price,
        imageUrl: dto.imageUrl,
        isAvailable: dto.isAvailable ?? true,
        sortOrder: dto.sortOrder ?? 0
      }
    });

    return this.mapItem(item);
  }

  async getItems(
    currentUser: AuthenticatedUser,
    businessId: string,
    includeInactive = false
  ) {
    await this.businessAccessService.assertMembership(businessId, currentUser.id);

    const items = await this.prisma.menuItem.findMany({
      where: {
        businessId,
        ...(includeInactive ? {} : { isAvailable: true })
      },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }, { id: 'asc' }]
    });

    return items.map((item) => this.mapItem(item));
  }

  async reorderItems(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: ReorderMenuRecordsDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.businessAccessService.menuManagerRoles
    );
    this.assertUniqueOrderIds(dto.orders, 'item');

    const ids = dto.orders.map((order) => order.id);
    const items = await this.prisma.menuItem.findMany({
      where: {
        id: {
          in: ids
        }
      },
      select: {
        id: true,
        businessId: true
      }
    });

    if (
      items.length !== ids.length ||
      items.some((item) => item.businessId !== businessId)
    ) {
      throw new BadRequestException('All item IDs must belong to the business');
    }

    await this.prisma.$transaction(
      dto.orders.map((order) =>
        this.prisma.menuItem.update({
          where: {
            id: order.id
          },
          data: {
            sortOrder: order.sortOrder
          }
        })
      )
    );

    const updatedItems = await this.prisma.menuItem.findMany({
      where: {
        id: {
          in: ids
        },
        businessId
      },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }, { id: 'asc' }]
    });

    return updatedItems.map((item) => this.mapItem(item));
  }

  async updateItem(
    currentUser: AuthenticatedUser,
    itemId: string,
    dto: UpdateItemDto
  ) {
    const existingItem = await this.prisma.menuItem.findUnique({
      where: {
        id: itemId
      },
      select: {
        businessId: true
      }
    });

    if (!existingItem) {
      throw new NotFoundException('Item not found');
    }

    await this.businessAccessService.assertRole(
      existingItem.businessId,
      currentUser.id,
      this.businessAccessService.menuManagerRoles
    );

    if (dto.categoryId) {
      await this.assertCategoryInBusiness(dto.categoryId, existingItem.businessId);
    }

    const item = await this.prisma.menuItem.update({
      where: {
        id: itemId
      },
      data: {
        categoryId: dto.categoryId,
        nameAr: dto.nameAr,
        nameEn: dto.nameEn,
        descriptionAr: dto.descriptionAr,
        descriptionEn: dto.descriptionEn,
        price: dto.price,
        imageUrl: dto.imageUrl,
        isAvailable: dto.isAvailable,
        sortOrder: dto.sortOrder
      }
    });

    return this.mapItem(item);
  }

  async deleteItem(currentUser: AuthenticatedUser, itemId: string) {
    const existingItem = await this.prisma.menuItem.findUnique({
      where: {
        id: itemId
      },
      select: {
        businessId: true
      }
    });

    if (!existingItem) {
      throw new NotFoundException('Item not found');
    }

    await this.businessAccessService.assertRole(
      existingItem.businessId,
      currentUser.id,
      this.businessAccessService.menuManagerRoles
    );

    await this.prisma.menuItem.update({
      where: {
        id: itemId
      },
      data: {
        isAvailable: false
      }
    });

    return {
      deleted: true
    };
  }

  async getPublicMenu(slug: string) {
    const business = await this.prisma.business.findFirst({
      where: {
        slug,
        status: BusinessStatus.ACTIVE
      },
      select: {
        id: true,
        name: true,
        slug: true,
        type: true,
        logoUrl: true,
        coverUrl: true,
        currency: true,
        language: true,
        city: true,
        menuTemplateId: true,
        menuThemeOverrides: true,
        menuCategories: {
          where: {
            isActive: true
          },
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }, { id: 'asc' }],
          select: {
            id: true,
            nameAr: true,
            nameEn: true,
            sortOrder: true,
            items: {
              where: {
                isAvailable: true
              },
              orderBy: [
                { sortOrder: 'asc' },
                { createdAt: 'asc' },
                { id: 'asc' }
              ],
              select: {
                id: true,
                nameAr: true,
                nameEn: true,
                descriptionAr: true,
                descriptionEn: true,
                price: true,
                imageUrl: true,
                isAvailable: true,
                sortOrder: true
              }
            }
          }
        }
      }
    });

    if (!business) {
      throw new NotFoundException('Public menu not found');
    }

    return {
      business: {
        id: business.id,
        name: business.name,
        slug: business.slug,
        type: business.type,
        logoUrl: business.logoUrl,
        coverUrl: business.coverUrl,
        currency: business.currency,
        language: business.language,
        city: business.city,
        menuTemplateId: resolveMenuTemplateId(business.menuTemplateId),
        menuThemeOverrides: business.menuThemeOverrides ?? null
      },
      appearance: this.mapPublicMenuAppearance({
        menuTemplateId: business.menuTemplateId,
        menuThemeOverrides: business.menuThemeOverrides
      }),
      categories: business.menuCategories.map((category) => ({
        id: category.id,
        nameAr: category.nameAr,
        nameEn: category.nameEn,
        sortOrder: category.sortOrder,
        items: category.items.map((item) => ({
          id: item.id,
          nameAr: item.nameAr,
          nameEn: item.nameEn,
          descriptionAr: item.descriptionAr,
          descriptionEn: item.descriptionEn,
          price: item.price.toString(),
          imageUrl: item.imageUrl,
          isAvailable: item.isAvailable,
          sortOrder: item.sortOrder
        }))
      }))
    };
  }

  async getPublicItem(slug: string, itemId: string) {
    const item = await this.prisma.menuItem.findFirst({
      where: {
        id: itemId,
        isAvailable: true,
        business: {
          slug,
          status: BusinessStatus.ACTIVE
        },
        category: {
          isActive: true
        }
      },
      select: {
        id: true,
        nameAr: true,
        nameEn: true,
        descriptionAr: true,
        descriptionEn: true,
        price: true,
        imageUrl: true,
        isAvailable: true,
        sortOrder: true
      }
    });

    if (!item) {
      throw new NotFoundException('Public menu item not found');
    }

    return {
      id: item.id,
      nameAr: item.nameAr,
      nameEn: item.nameEn,
      descriptionAr: item.descriptionAr,
      descriptionEn: item.descriptionEn,
      price: item.price.toString(),
      imageUrl: item.imageUrl,
      isAvailable: item.isAvailable,
      sortOrder: item.sortOrder
    };
  }

  private async assertCategoryInBusiness(
    categoryId: string,
    businessId: string
  ) {
    const category = await this.prisma.menuCategory.findFirst({
      where: {
        id: categoryId,
        businessId
      },
      select: {
        id: true
      }
    });

    if (!category) {
      throw new NotFoundException('Category not found for business');
    }
  }

  private assertUniqueOrderIds(
    orders: ReorderMenuRecordsDto['orders'],
    recordLabel: string
  ) {
    const seenIds = new Set<string>();

    for (const order of orders) {
      if (seenIds.has(order.id)) {
        throw new BadRequestException(`Duplicate ${recordLabel} ID in orders`);
      }

      seenIds.add(order.id);
    }
  }

  private mapPublicMenuAppearance(appearance: {
    menuTemplateId: string | null;
    menuThemeOverrides: unknown;
  }) {
    const effectiveTemplateId = resolveMenuTemplateId(appearance.menuTemplateId);

    return {
      menuTemplateId: effectiveTemplateId,
      effectiveTemplateId,
      fallbackApplied:
        appearance.menuTemplateId === null ||
        appearance.menuTemplateId === undefined ||
        appearance.menuTemplateId !== effectiveTemplateId,
      menuThemeOverrides: appearance.menuThemeOverrides ?? null
    };
  }

  private mapCategory(category: MenuCategory) {
    return {
      id: category.id,
      businessId: category.businessId,
      nameAr: category.nameAr,
      nameEn: category.nameEn,
      sortOrder: category.sortOrder,
      isActive: category.isActive
    };
  }

  private mapItem(item: MenuItem) {
    return {
      id: item.id,
      businessId: item.businessId,
      categoryId: item.categoryId,
      nameAr: item.nameAr,
      nameEn: item.nameEn,
      descriptionAr: item.descriptionAr,
      descriptionEn: item.descriptionEn,
      price: item.price.toString(),
      imageUrl: item.imageUrl,
      isAvailable: item.isAvailable,
      sortOrder: item.sortOrder
    };
  }
}

import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiQuery,
  ApiTags
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { CreateCategoryDto } from './dto/create-category.dto';
import { CreateItemDto } from './dto/create-item.dto';
import { ReorderMenuRecordsDto } from './dto/reorder-menu-records.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { UpdateItemDto } from './dto/update-item.dto';
import { MenuService } from './menu.service';

@ApiTags('menu')
@ApiBearerAuth()
@UseGuards(ClerkAuthGuard)
@Controller()
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Post('businesses/:id/categories')
  @ApiCreatedResponse({ description: 'Category created.' })
  createCategory(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: CreateCategoryDto
  ) {
    return this.menuService.createCategory(currentUser, businessId, dto);
  }

  @Get('businesses/:id/categories')
  @ApiQuery({
    name: 'includeInactive',
    required: false,
    type: Boolean,
    description: 'Set true to include archived/inactive categories. Defaults to false.'
  })
  @ApiOkResponse({ description: 'Categories for a business.' })
  getCategories(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Query('includeInactive') includeInactive?: string
  ) {
    return this.menuService.getCategories(
      currentUser,
      businessId,
      includeInactive === 'true'
    );
  }

  @Patch('businesses/:id/categories/reorder')
  @ApiOkResponse({
    description:
      'Categories reordered. OWNER and MANAGER only; supports active and inactive categories.',
    schema: {
      example: [
        {
          id: 'cat_123',
          businessId: 'bus_123',
          nameAr: 'Hot Drinks',
          nameEn: null,
          sortOrder: 0,
          isActive: true
        },
        {
          id: 'cat_456',
          businessId: 'bus_123',
          nameAr: 'Desserts',
          nameEn: null,
          sortOrder: 1,
          isActive: false
        }
      ]
    }
  })
  reorderCategories(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: ReorderMenuRecordsDto
  ) {
    return this.menuService.reorderCategories(currentUser, businessId, dto);
  }

  @Patch('categories/:id')
  @ApiOkResponse({
    description:
      'Category updated. OWNER and MANAGER only. Restore an archived category by setting isActive to true.',
    schema: {
      example: {
        id: 'cat_123',
        businessId: 'bus_123',
        nameAr: 'Hot Drinks',
        nameEn: null,
        sortOrder: 0,
        isActive: true
      }
    }
  })
  updateCategory(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') categoryId: string,
    @Body() dto: UpdateCategoryDto
  ) {
    return this.menuService.updateCategory(currentUser, categoryId, dto);
  }

  @Delete('categories/:id')
  @ApiOkResponse({ description: 'Category archived.' })
  deleteCategory(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') categoryId: string
  ) {
    return this.menuService.deleteCategory(currentUser, categoryId);
  }

  @Post('businesses/:id/items')
  @ApiCreatedResponse({ description: 'Item created.' })
  createItem(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: CreateItemDto
  ) {
    return this.menuService.createItem(currentUser, businessId, dto);
  }

  @Get('businesses/:id/items')
  @ApiQuery({
    name: 'includeInactive',
    required: false,
    type: Boolean,
    description: 'Set true to include archived/unavailable items. Defaults to false.'
  })
  @ApiOkResponse({ description: 'Items for a business.' })
  getItems(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Query('includeInactive') includeInactive?: string
  ) {
    return this.menuService.getItems(
      currentUser,
      businessId,
      includeInactive === 'true'
    );
  }

  @Patch('businesses/:id/items/reorder')
  @ApiOkResponse({
    description:
      'Items reordered. OWNER and MANAGER only; supports available and unavailable items.',
    schema: {
      example: [
        {
          id: 'item_123',
          businessId: 'bus_123',
          categoryId: 'cat_123',
          nameAr: 'Turkish Coffee',
          nameEn: null,
          descriptionAr: 'Traditional strong coffee.',
          descriptionEn: null,
          price: '3000',
          imageUrl: null,
          isAvailable: true,
          sortOrder: 0
        },
        {
          id: 'item_456',
          businessId: 'bus_123',
          categoryId: 'cat_123',
          nameAr: 'Tamriya',
          nameEn: null,
          descriptionAr: null,
          descriptionEn: null,
          price: '2500',
          imageUrl: null,
          isAvailable: false,
          sortOrder: 1
        }
      ]
    }
  })
  reorderItems(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: ReorderMenuRecordsDto
  ) {
    return this.menuService.reorderItems(currentUser, businessId, dto);
  }

  @Patch('items/:id')
  @ApiOkResponse({
    description:
      'Item updated. OWNER and MANAGER only. Restore an archived/unavailable item by setting isAvailable to true.',
    schema: {
      example: {
        id: 'item_123',
        businessId: 'bus_123',
        categoryId: 'cat_123',
        nameAr: 'Turkish Coffee',
        nameEn: null,
        descriptionAr: 'Traditional strong coffee.',
        descriptionEn: null,
        price: '3000',
        imageUrl: null,
        isAvailable: true,
        sortOrder: 0
      }
    }
  })
  updateItem(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') itemId: string,
    @Body() dto: UpdateItemDto
  ) {
    return this.menuService.updateItem(currentUser, itemId, dto);
  }

  @Delete('items/:id')
  @ApiOkResponse({ description: 'Item archived.' })
  deleteItem(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') itemId: string
  ) {
    return this.menuService.deleteItem(currentUser, itemId);
  }
}

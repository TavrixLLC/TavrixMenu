import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiTags
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { CreateCategoryDto } from './dto/create-category.dto';
import { CreateItemDto } from './dto/create-item.dto';
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
  @ApiOkResponse({ description: 'Categories for a business.' })
  getCategories(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string
  ) {
    return this.menuService.getCategories(currentUser, businessId);
  }

  @Patch('categories/:id')
  @ApiOkResponse({ description: 'Category updated.' })
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
  @ApiOkResponse({ description: 'Items for a business.' })
  getItems(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string
  ) {
    return this.menuService.getItems(currentUser, businessId);
  }

  @Patch('items/:id')
  @ApiOkResponse({ description: 'Item updated.' })
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

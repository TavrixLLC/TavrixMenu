import { Controller, Get, Param } from '@nestjs/common';
import { ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { MenuService } from './menu.service';

@ApiTags('public menu')
@Controller('public/m')
export class PublicMenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get(':slug')
  @ApiOkResponse({
    description: 'Public active menu by business slug.',
    schema: {
      example: {
        business: {
          id: 'bus_123',
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          type: 'cafe',
          logoUrl: null,
          coverUrl: null,
          currency: 'IQD',
          language: 'ar',
          city: 'Baghdad',
          menuTemplateId: 'waflo-warm',
          menuThemeOverrides: null
        },
        categories: [
          {
            id: 'cat_123',
            nameAr: 'Hot Drinks',
            nameEn: null,
            sortOrder: 0,
            items: [
              {
                id: 'item_123',
                nameAr: 'Turkish Coffee',
                nameEn: null,
                descriptionAr: 'Traditional strong coffee.',
                descriptionEn: null,
                price: '3000',
                imageUrl: null,
                isAvailable: true,
                sortOrder: 0
              }
            ]
          }
        ]
      }
    }
  })
  getPublicMenu(@Param('slug') slug: string) {
    return this.menuService.getPublicMenu(slug);
  }

  @Get(':slug/items/:itemId')
  @ApiOkResponse({ description: 'Public available item by business slug.' })
  getPublicItem(
    @Param('slug') slug: string,
    @Param('itemId') itemId: string
  ) {
    return this.menuService.getPublicItem(slug, itemId);
  }
}

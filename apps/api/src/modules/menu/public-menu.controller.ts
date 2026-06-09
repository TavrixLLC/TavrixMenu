import { Controller, Get, Param } from '@nestjs/common';
import { ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { MenuService } from './menu.service';

@ApiTags('public menu')
@Controller('public/m')
export class PublicMenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get(':slug')
  @ApiOkResponse({ description: 'Public active menu by business slug.' })
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

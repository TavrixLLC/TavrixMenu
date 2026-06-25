import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { MenuTemplatesService } from './menu-templates.service';

const catalogExample = {
  templates: [
    {
      id: 'waflo-warm',
      displayName: 'Waflo Warm',
      description: 'Warm coral, cream, and green CSS template for most restaurant and cafe menus.',
      bestFor: 'General restaurants, cafes, bakeries, and casual dining',
      version: '1.0.0',
      status: 'enabled',
      enabled: true,
      isDefault: true,
      preview: {
        previewColors: ['#FF6B4A', '#FFF8F2', '#43A047'],
        previewLayout: 'warm-card-list',
        thumbnailUrl: null,
        mobilePreviewUrl: null,
        desktopPreviewUrl: null
      },
      supportedFeatures: {
        rtl: true,
        loyaltyBlock: true,
        itemImages: true,
        soldOutState: true,
        aiRecommendations: false,
        responsiveLayouts: true
      }
    }
  ]
};

@ApiTags('menu templates')
@Controller('menu-templates')
export class MenuTemplatesController {
  constructor(private readonly menuTemplatesService: MenuTemplatesService) {}

  @Get()
  @ApiOkResponse({
    description:
      'Enabled Waflo-managed public menu templates. The response excludes CSS source, development preview URLs, and merchant-sensitive data.',
    schema: {
      example: catalogExample
    }
  })
  getMenuTemplates() {
    return this.menuTemplatesService.getCatalog();
  }
}

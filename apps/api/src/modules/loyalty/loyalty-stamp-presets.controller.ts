import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { LoyaltyStampStyleService } from './loyalty-stamp-style.service';

@ApiTags('loyalty')
@ApiBearerAuth()
@UseGuards(ClerkAuthGuard)
@Controller('loyalty')
export class LoyaltyStampPresetsController {
  constructor(
    private readonly loyaltyStampStyleService: LoyaltyStampStyleService
  ) {}

  @Get('stamp-presets')
  @ApiOkResponse({
    description:
      'Available loyalty stamp preset shapes and layout options for authenticated business app users.',
    schema: {
      example: {
        presets: [
          { key: 'STAR', label: 'Star' },
          { key: 'COFFEE', label: 'Coffee' }
        ],
        styleTypes: ['PRESET'],
        layoutVariants: ['MODERN', 'COMPACT']
      }
    }
  })
  getStampPresets() {
    return this.loyaltyStampStyleService.getStampPresets();
  }
}

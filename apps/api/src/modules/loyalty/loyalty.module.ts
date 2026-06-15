import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { LoyaltyController } from './loyalty.controller';
import { LoyaltyStampPresetsController } from './loyalty-stamp-presets.controller';
import { LoyaltyStampStyleService } from './loyalty-stamp-style.service';
import { LoyaltyService } from './loyalty.service';
import { PublicLoyaltyController } from './public-loyalty.controller';
import { PublicLoyaltyService } from './public-loyalty.service';
import { StampImageRendererService } from './stamp-image-renderer.service';
import { StampImageStorageService } from './stamp-image-storage.service';

@Module({
  imports: [AuthModule, BusinessesModule],
  controllers: [
    LoyaltyController,
    LoyaltyStampPresetsController,
    PublicLoyaltyController
  ],
  providers: [
    LoyaltyService,
    LoyaltyStampStyleService,
    PublicLoyaltyService,
    StampImageRendererService,
    StampImageStorageService
  ],
  exports: [StampImageRendererService, StampImageStorageService]
})
export class LoyaltyModule {}

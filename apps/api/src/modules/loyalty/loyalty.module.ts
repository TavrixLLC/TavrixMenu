import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { LoyaltyController } from './loyalty.controller';
import { LoyaltyService } from './loyalty.service';
import { PublicLoyaltyController } from './public-loyalty.controller';
import { PublicLoyaltyService } from './public-loyalty.service';

@Module({
  imports: [AuthModule, BusinessesModule],
  controllers: [LoyaltyController, PublicLoyaltyController],
  providers: [LoyaltyService, PublicLoyaltyService]
})
export class LoyaltyModule {}

import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { LoyaltyController } from './loyalty.controller';
import { LoyaltyService } from './loyalty.service';

@Module({
  imports: [AuthModule, BusinessesModule],
  controllers: [LoyaltyController],
  providers: [LoyaltyService]
})
export class LoyaltyModule {}

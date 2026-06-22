import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BusinessAccessService } from './business-access.service';
import { BusinessesController } from './businesses.controller';
import { BusinessesService } from './businesses.service';

@Module({
  imports: [AuthModule],
  controllers: [BusinessesController],
  providers: [BusinessAccessService, BusinessesService],
  exports: [BusinessAccessService]
})
export class BusinessesModule {}

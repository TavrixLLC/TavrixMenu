import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { MenuController } from './menu.controller';
import { MenuService } from './menu.service';
import { PublicMenuController } from './public-menu.controller';

@Module({
  imports: [AuthModule, BusinessesModule],
  controllers: [MenuController, PublicMenuController],
  providers: [MenuService]
})
export class MenuModule {}

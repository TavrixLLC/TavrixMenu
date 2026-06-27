import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AdminModule } from './modules/admin/admin.module';
import { AppleWalletModule } from './modules/apple-wallet/apple-wallet.module';
import { AuthModule } from './modules/auth/auth.module';
import { BillingModule } from './modules/billing/billing.module';
import { BusinessesModule } from './modules/businesses/businesses.module';
import { HealthModule } from './modules/health/health.module';
import { GoogleWalletModule } from './modules/google-wallet/google-wallet.module';
import { LoyaltyModule } from './modules/loyalty/loyalty.module';
import { MediaModule } from './modules/media/media.module';
import { MenuModule } from './modules/menu/menu.module';
import { MenuTemplatesModule } from './modules/menu-templates/menu-templates.module';
import { UsersModule } from './modules/users/users.module';
import { PrismaModule } from './prisma/prisma.module';
import { validateEnvironment } from './env.validation';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validate: validateEnvironment
    }),
    PrismaModule,
    HealthModule,
    AuthModule,
    UsersModule,
    BusinessesModule,
    MenuTemplatesModule,
    MenuModule,
    MediaModule,
    LoyaltyModule,
    GoogleWalletModule,
    AppleWalletModule,
    BillingModule,
    AdminModule
  ]
})
export class AppModule {}

import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { ClerkTokenVerifierService } from './clerk-token-verifier.service';
import { ClerkAuthGuard } from './guards/clerk-auth.guard';
import { UserSyncService } from './user-sync.service';

@Module({
  controllers: [AuthController],
  providers: [ClerkAuthGuard, ClerkTokenVerifierService, UserSyncService],
  exports: [ClerkAuthGuard, ClerkTokenVerifierService, UserSyncService]
})
export class AuthModule {}

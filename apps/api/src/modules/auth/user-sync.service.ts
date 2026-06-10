import { Injectable } from '@nestjs/common';
import { UserStatus } from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface';
import { ClerkVerifiedUser } from './interfaces/clerk-verified-user.interface';

@Injectable()
export class UserSyncService {
  constructor(private readonly prisma: PrismaService) {}

  async syncUser(clerkUser: ClerkVerifiedUser): Promise<AuthenticatedUser> {
    const user = await this.prisma.user.upsert({
      where: {
        clerkUserId: clerkUser.clerkUserId
      },
      create: {
        clerkUserId: clerkUser.clerkUserId,
        email: clerkUser.email,
        name: clerkUser.name,
        phone: clerkUser.phone,
        status: UserStatus.ACTIVE
      },
      update: {
        email: clerkUser.email,
        name: clerkUser.name,
        phone: clerkUser.phone
      }
    });

    return {
      id: user.id,
      clerkUserId: user.clerkUserId ?? clerkUser.clerkUserId,
      name: user.name,
      email: user.email,
      phone: user.phone,
      status: user.status
    };
  }
}

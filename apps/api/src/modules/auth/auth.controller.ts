import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessUserStatus } from '../../generated/prisma';
import { CurrentUser } from './decorators/current-user.decorator';
import { ClerkAuthGuard } from './guards/clerk-auth.guard';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface';

@ApiTags('auth/me')
@ApiBearerAuth()
@Controller()
export class AuthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('me')
  @UseGuards(ClerkAuthGuard)
  @ApiOkResponse({ description: 'Current user and business memberships.' })
  async getMe(@CurrentUser() currentUser: AuthenticatedUser) {
    const memberships = await this.prisma.businessUser.findMany({
      where: {
        userId: currentUser.id,
        status: BusinessUserStatus.ACTIVE
      },
      include: {
        business: true
      },
      orderBy: {
        createdAt: 'asc'
      }
    });

    return {
      user: {
        id: currentUser.id,
        clerkUserId: currentUser.clerkUserId,
        name: currentUser.name,
        email: currentUser.email,
        phone: currentUser.phone,
        status: currentUser.status
      },
      businesses: memberships.map((membership) => ({
        id: membership.business.id,
        name: membership.business.name,
        slug: membership.business.slug,
        type: membership.business.type,
        role: membership.role
      }))
    };
  }
}

import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { PrismaService } from '../../prisma/prisma.service';
import { BusinessUserStatus } from '../../generated/prisma';
import { CurrentUser } from './decorators/current-user.decorator';
import { ClerkAuthGuard } from './guards/clerk-auth.guard';
import { AuthenticatedUser } from './interfaces/authenticated-user.interface';

type RecommendedNextStep =
  | 'CREATE_BUSINESS'
  | 'SELECT_BUSINESS'
  | 'OPEN_DASHBOARD';

@ApiTags('auth/me')
@ApiBearerAuth()
@Controller()
export class AuthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('me')
  @UseGuards(ClerkAuthGuard)
  @ApiOkResponse({
    description: 'Current user and business memberships.',
    schema: {
      example: {
        user: {
          id: 'usr_123',
          clerkUserId: 'user_tavrix_owner',
          name: 'Tavrix Owner',
          email: 'owner@tavrix.local',
          phone: null,
          status: 'ACTIVE',
          createdAt: '2026-06-10T00:00:00.000Z',
          updatedAt: '2026-06-10T00:00:00.000Z'
        },
        memberships: [
          {
            id: 'mem_123',
            role: 'OWNER',
            isActive: true,
            business: {
              id: 'bus_123',
              name: 'Tavrix Cafe',
              slug: 'tavrix-cafe',
              type: 'cafe',
              city: 'Baghdad',
              currency: 'IQD',
              language: 'ar',
              logoUrl: null,
              coverUrl: null
            }
          }
        ],
        onboarding: {
          hasBusiness: true,
          activeBusinessCount: 1,
          recommendedNextStep: 'OPEN_DASHBOARD'
        },
        businesses: [
          {
            id: 'bus_123',
            name: 'Tavrix Cafe',
            slug: 'tavrix-cafe',
            type: 'cafe',
            role: 'OWNER'
          }
        ]
      }
    }
  })
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
        status: currentUser.status,
        createdAt: currentUser.createdAt,
        updatedAt: currentUser.updatedAt
      },
      memberships: memberships.map((membership) => ({
        id: membership.id,
        role: membership.role,
        isActive: membership.status === BusinessUserStatus.ACTIVE,
        business: {
          id: membership.business.id,
          name: membership.business.name,
          slug: membership.business.slug,
          type: membership.business.type,
          city: membership.business.city,
          currency: membership.business.currency,
          language: membership.business.language,
          logoUrl: membership.business.logoUrl,
          coverUrl: membership.business.coverUrl
        }
      })),
      onboarding: {
        hasBusiness: memberships.length > 0,
        activeBusinessCount: memberships.length,
        recommendedNextStep: this.getRecommendedNextStep(memberships.length)
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

  private getRecommendedNextStep(
    activeBusinessCount: number
  ): RecommendedNextStep {
    if (activeBusinessCount === 0) {
      return 'CREATE_BUSINESS';
    }

    if (activeBusinessCount === 1) {
      return 'OPEN_DASHBOARD';
    }

    return 'SELECT_BUSINESS';
  }
}

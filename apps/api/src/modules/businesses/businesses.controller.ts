import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiTags
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessesService } from './businesses.service';
import { CreateBusinessDto } from './dto/create-business.dto';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateBusinessDto } from './dto/update-business.dto';
import { UpdateMenuAppearanceDto } from './dto/update-menu-appearance.dto';
import { UpdateMemberDto } from './dto/update-member.dto';

@ApiTags('businesses')
@ApiBearerAuth()
@UseGuards(ClerkAuthGuard)
@Controller('businesses')
export class BusinessesController {
  constructor(private readonly businessesService: BusinessesService) {}

  @Post()
  @ApiCreatedResponse({
    description: 'Business created and current user assigned OWNER membership.',
    schema: {
      example: {
        business: {
          id: 'bus_123',
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          type: 'cafe',
          logoUrl: null,
          coverUrl: null,
          currency: 'IQD',
          language: 'ar',
          city: 'Baghdad',
          status: 'ACTIVE'
        },
        currentMembership: {
          id: 'mem_123',
          role: 'OWNER',
          isActive: true
        },
        appContext: {
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
          },
          currentMembership: {
            id: 'mem_123',
            role: 'OWNER',
            isActive: true
          },
          permissions: {
            canManageBusiness: true,
            canManageMenu: true,
            canManageMembers: true,
            canViewMembers: true,
            canViewPublicLink: true,
            canManageAppearance: true
          },
          publicMenu: {
            slug: 'tavrix-cafe',
            path: '/m/tavrix-cafe',
            url: 'http://localhost:3001/m/tavrix-cafe',
            qrPayload: 'http://localhost:3001/m/tavrix-cafe'
          }
        }
      }
    }
  })
  createBusiness(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Body() dto: CreateBusinessDto
  ) {
    return this.businessesService.createBusiness(currentUser, dto);
  }

  @Get('me')
  @ApiOkResponse({
    description: 'Businesses for the current user.',
    schema: {
      example: [
        {
          id: 'bus_123',
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          type: 'cafe',
          logoUrl: null,
          coverUrl: null,
          currency: 'IQD',
          language: 'ar',
          city: 'Baghdad',
          status: 'ACTIVE',
          role: 'OWNER'
        }
      ]
    }
  })
  getMyBusinesses(@CurrentUser() currentUser: AuthenticatedUser) {
    return this.businessesService.getMyBusinesses(currentUser);
  }

  @Get(':id/app-context')
  @ApiOkResponse({
    description: 'Business app context for the Flutter business app.',
    schema: {
      example: {
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
        },
        currentMembership: {
          id: 'mem_123',
          role: 'OWNER',
          isActive: true
        },
        permissions: {
          canManageBusiness: true,
          canManageMenu: true,
          canManageMembers: true,
          canViewMembers: true,
          canViewPublicLink: true,
          canManageAppearance: true
        },
        publicMenu: {
          slug: 'tavrix-cafe',
          path: '/m/tavrix-cafe',
          url: 'http://localhost:3001/m/tavrix-cafe',
          qrPayload: 'http://localhost:3001/m/tavrix-cafe'
        }
      }
    }
  })
  getAppContext(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string
  ) {
    return this.businessesService.getAppContext(currentUser, businessId);
  }

  @Get(':id/dashboard-summary')
  @ApiOkResponse({
    description:
      'Owner workflow dashboard summary. OWNER, MANAGER, and STAFF can view when actively assigned to this business.',
    schema: {
      example: {
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
        },
        currentUser: {
          role: 'OWNER',
          permissions: {
            canManageBusiness: true,
            canManageMenu: true,
            canManageMembers: true,
            canViewMembers: true,
            canViewPublicLink: true,
            canManageAppearance: true
          }
        },
        counts: {
          activeCategories: 2,
          inactiveCategories: 0,
          activeItems: 3,
          inactiveItems: 0,
          availableItems: 3,
          unavailableItems: 0,
          activeMembers: 1
        },
        publicMenu: {
          path: '/m/tavrix-cafe',
          url: 'http://localhost:3001/m/tavrix-cafe',
          qrPayload: 'http://localhost:3001/m/tavrix-cafe'
        },
        onboardingHints: {
          hasCategories: true,
          hasItems: true,
          hasPublicMenuReady: true,
          recommendedNextStep: 'SHARE_PUBLIC_MENU'
        }
      }
    }
  })
  getDashboardSummary(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string
  ) {
    return this.businessesService.getDashboardSummary(currentUser, businessId);
  }

  @Get(':id/public-link')
  @ApiOkResponse({
    description: 'Public menu link and QR payload for a business.',
    schema: {
      example: {
        businessId: 'bus_123',
        slug: 'tavrix-cafe',
        publicMenuPath: '/m/tavrix-cafe',
        publicMenuUrl: 'http://localhost:3001/m/tavrix-cafe',
        qrPayload: 'http://localhost:3001/m/tavrix-cafe'
      }
    }
  })
  getPublicLink(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string
  ) {
    return this.businessesService.getPublicLink(currentUser, businessId);
  }

  @Get(':id/menu-appearance')
  @ApiOkResponse({
    description:
      'Public menu appearance settings for a business. OWNER, MANAGER, and STAFF can view when actively assigned.',
    schema: {
      example: {
        businessId: 'bus_123',
        menuTemplateId: 'waflo-warm',
        menuThemeOverrides: null
      }
    }
  })
  getMenuAppearance(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string
  ) {
    return this.businessesService.getMenuAppearance(currentUser, businessId);
  }

  @Patch(':id/menu-appearance')
  @ApiOkResponse({
    description:
      'Public menu appearance updated. OWNER only; STAFF cannot change templates.',
    schema: {
      example: {
        businessId: 'bus_123',
        menuTemplateId: 'coffeehouse-premium',
        menuThemeOverrides: null
      }
    }
  })
  updateMenuAppearance(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: UpdateMenuAppearanceDto
  ) {
    return this.businessesService.updateMenuAppearance(
      currentUser,
      businessId,
      dto
    );
  }

  @Get(':id/members')
  @ApiOkResponse({
    description: 'Active and inactive business members.',
    schema: {
      example: [
        {
          id: 'mem_123',
          userId: 'usr_123',
          clerkUserId: 'user_tavrix_owner',
          email: 'owner@tavrix.local',
          name: 'Tavrix Owner',
          phone: null,
          role: 'OWNER',
          isActive: true,
          createdAt: '2026-06-10T00:00:00.000Z',
          updatedAt: '2026-06-10T00:00:00.000Z'
        }
      ]
    }
  })
  getMembers(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string
  ) {
    return this.businessesService.getMembers(currentUser, businessId);
  }

  @Post(':id/members')
  @ApiCreatedResponse({ description: 'Business member created or reactivated.' })
  createMember(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: CreateMemberDto
  ) {
    return this.businessesService.createMember(currentUser, businessId, dto);
  }

  @Patch(':id/members/:memberId')
  @ApiOkResponse({ description: 'Business member updated.' })
  updateMember(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Param('memberId') memberId: string,
    @Body() dto: UpdateMemberDto
  ) {
    return this.businessesService.updateMember(
      currentUser,
      businessId,
      memberId,
      dto
    );
  }

  @Delete(':id/members/:memberId')
  @ApiOkResponse({ description: 'Business member deactivated.' })
  deleteMember(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Param('memberId') memberId: string
  ) {
    return this.businessesService.deleteMember(currentUser, businessId, memberId);
  }

  @Patch(':id')
  @ApiOkResponse({
    description:
      'Business profile updated. OWNER only. Supported fields: name, type, city, currency, language, logoUrl, coverUrl.'
  })
  updateBusiness(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: UpdateBusinessDto
  ) {
    return this.businessesService.updateBusiness(currentUser, businessId, dto);
  }
}

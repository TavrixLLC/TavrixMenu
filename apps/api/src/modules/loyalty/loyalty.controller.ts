import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiTags,
  ApiUnauthorizedResponse
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { AddStampsDto } from './dto/add-stamps.dto';
import { CreateLoyaltyProgramDto } from './dto/create-loyalty-program.dto';
import { EnrollLoyaltyCustomerDto } from './dto/enroll-loyalty-customer.dto';
import { GetLoyaltyMembershipsQueryDto } from './dto/get-loyalty-memberships-query.dto';
import { RedeemRewardDto } from './dto/redeem-reward.dto';
import { UpdateLoyaltyProgramDto } from './dto/update-loyalty-program.dto';
import { LoyaltyService } from './loyalty.service';

const cardStateExample = {
  stampCount: 3,
  stampGoal: 7,
  rewardReady: false,
  progressPercent: 42,
  rewardName: 'Free meal',
  programName: 'Abdullah Grill Rewards'
};

@ApiTags('loyalty')
@ApiBearerAuth()
@UseGuards(ClerkAuthGuard)
@Controller('businesses/:id/loyalty')
@ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token.' })
@ApiForbiddenResponse({
  description: 'Active business membership or required role is missing.'
})
export class LoyaltyController {
  constructor(private readonly loyaltyService: LoyaltyService) {}

  @Get('program')
  @ApiOkResponse({
    description:
      'Active stamp-card loyalty program for a business, or null. OWNER, MANAGER, and STAFF can view.',
    schema: {
      example: {
        id: 'loyalty_program_id',
        businessId: 'bus_123',
        name: 'Tavrix Cafe Stamp Card',
        description: 'Collect stamps on coffee visits.',
        stampGoal: 5,
        rewardName: 'Free coffee',
        rewardDescription: 'One free Turkish Coffee after 5 stamps.',
        isActive: true,
        cardColor: '#111827',
        accentColor: '#f59e0b',
        logoUrl: null,
        terms: 'Reward is valid for dine-in orders only.',
        createdAt: '2026-06-13T00:00:00.000Z',
        updatedAt: '2026-06-13T00:00:00.000Z'
      }
    }
  })
  getActiveProgram(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string
  ) {
    return this.loyaltyService.getActiveProgram(currentUser, businessId);
  }

  @Post('program')
  @ApiCreatedResponse({
    description:
      'Stamp-card loyalty program created. OWNER and MANAGER only. Sprint 5 allows one active program per business.',
    schema: {
      example: {
        id: 'loyalty_program_id',
        businessId: 'bus_123',
        name: 'Tavrix Cafe Stamp Card',
        stampGoal: 5,
        rewardName: 'Free coffee',
        isActive: true
      }
    }
  })
  @ApiConflictResponse({
    description: 'A duplicate active loyalty program already exists.'
  })
  createProgram(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: CreateLoyaltyProgramDto
  ) {
    return this.loyaltyService.createProgram(currentUser, businessId, dto);
  }

  @Patch('program/:programId')
  @ApiOkResponse({
    description:
      'Stamp-card loyalty program updated. OWNER and MANAGER only; program must belong to the business.',
    schema: {
      example: {
        id: 'loyalty_program_id',
        businessId: 'bus_123',
        name: 'Tavrix Cafe Stamp Card',
        stampGoal: 6,
        rewardName: 'Free coffee',
        isActive: true
      }
    }
  })
  @ApiConflictResponse({
    description: 'Another active loyalty program already exists.'
  })
  @ApiNotFoundResponse({ description: 'Loyalty program not found.' })
  updateProgram(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Param('programId') programId: string,
    @Body() dto: UpdateLoyaltyProgramDto
  ) {
    return this.loyaltyService.updateProgram(
      currentUser,
      businessId,
      programId,
      dto
    );
  }

  @Post('enroll')
  @ApiCreatedResponse({
    description:
      'Customer enrolled or existing membership returned. OWNER, MANAGER, and STAFF allowed. Requires phone or email.',
    schema: {
      example: {
        customer: {
          id: 'customer_id',
          phone: '+9647700000000',
          email: 'customer@example.com',
          name: 'Demo Customer'
        },
        membership: {
          id: 'membership_id',
          businessId: 'bus_123',
          loyaltyProgramId: 'loyalty_program_id',
          customerId: 'customer_id',
          stampCount: 0,
          rewardReady: false,
          totalStampsEarned: 0,
          totalRewardsRedeemed: 0,
          status: 'ACTIVE'
        },
        program: {
          id: 'loyalty_program_id',
          name: 'Tavrix Cafe Stamp Card',
          stampGoal: 5,
          rewardName: 'Free coffee'
        },
        cardState: cardStateExample
      }
    }
  })
  @ApiNotFoundResponse({ description: 'No active loyalty program found.' })
  enrollCustomer(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: EnrollLoyaltyCustomerDto
  ) {
    return this.loyaltyService.enrollCustomer(currentUser, businessId, dto);
  }

  @Get('memberships')
  @ApiOkResponse({
    description:
      'Loyalty memberships with customer and program summary. OWNER, MANAGER, and STAFF allowed.',
    schema: {
      example: [
        {
          id: 'membership_id',
          businessId: 'bus_123',
          loyaltyProgramId: 'loyalty_program_id',
          customerId: 'customer_id',
          stampCount: 3,
          rewardReady: false,
          status: 'ACTIVE',
          customer: {
            id: 'customer_id',
            phone: '+9647700000000',
            email: 'customer@example.com',
            name: 'Demo Customer'
          },
          program: {
            id: 'loyalty_program_id',
            name: 'Tavrix Cafe Stamp Card',
            stampGoal: 5,
            rewardName: 'Free coffee',
            isActive: true
          },
          cardState: cardStateExample
        }
      ]
    }
  })
  listMemberships(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Query() query: GetLoyaltyMembershipsQueryDto
  ) {
    return this.loyaltyService.listMemberships(currentUser, businessId, query);
  }

  @Get('memberships/:membershipId')
  @ApiOkResponse({
    description:
      'Full loyalty membership state with recent transactions. Must belong to the business.',
    schema: {
      example: {
        id: 'membership_id',
        stampCount: 3,
        rewardReady: false,
        customer: {
          id: 'customer_id',
          phone: '+9647700000000',
          email: 'customer@example.com',
          name: 'Demo Customer'
        },
        cardState: cardStateExample,
        transactions: [
          {
            id: 'txn_123',
            type: 'STAMP_ADDED',
            stampsDelta: 1,
            reason: 'Coffee purchase',
            createdAt: '2026-06-13T00:00:00.000Z'
          }
        ]
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Loyalty membership not found.' })
  getMembership(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Param('membershipId') membershipId: string
  ) {
    return this.loyaltyService.getMembership(
      currentUser,
      businessId,
      membershipId
    );
  }

  @Post('memberships/:membershipId/stamps')
  @ApiCreatedResponse({
    description:
      'Adds stamps and returns updated cardState. OWNER, MANAGER, and STAFF allowed.',
    schema: {
      example: {
        membership: {
          id: 'membership_id',
          stampCount: 4,
          rewardReady: false,
          totalStampsEarned: 4
        },
        cardState: {
          ...cardStateExample,
          stampCount: 4,
          progressPercent: 57
        }
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Loyalty membership not found.' })
  addStamps(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Param('membershipId') membershipId: string,
    @Body() dto: AddStampsDto
  ) {
    return this.loyaltyService.addStamps(
      currentUser,
      businessId,
      membershipId,
      dto
    );
  }

  @Post('memberships/:membershipId/redeem')
  @ApiCreatedResponse({
    description:
      'Redeems a ready reward, resets stampCount to 0, and returns updated cardState.',
    schema: {
      example: {
        membership: {
          id: 'membership_id',
          stampCount: 0,
          rewardReady: false,
          totalRewardsRedeemed: 1
        },
        cardState: {
          ...cardStateExample,
          stampCount: 0,
          rewardReady: false,
          progressPercent: 0
        }
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Loyalty membership not found.' })
  redeemReward(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Param('membershipId') membershipId: string,
    @Body() dto: RedeemRewardDto
  ) {
    return this.loyaltyService.redeemReward(
      currentUser,
      businessId,
      membershipId,
      dto
    );
  }

  @Get('memberships/:membershipId/transactions')
  @ApiOkResponse({
    description: 'Loyalty transactions newest first.',
    schema: {
      example: [
        {
          id: 'txn_123',
          businessId: 'bus_123',
          loyaltyProgramId: 'loyalty_program_id',
          membershipId: 'membership_id',
          customerId: 'customer_id',
          actorUserId: 'usr_123',
          type: 'STAMP_ADDED',
          stampsDelta: 1,
          reason: 'Coffee purchase',
          createdAt: '2026-06-13T00:00:00.000Z'
        }
      ]
    }
  })
  @ApiNotFoundResponse({ description: 'Loyalty membership not found.' })
  listTransactions(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Param('membershipId') membershipId: string
  ) {
    return this.loyaltyService.listTransactions(
      currentUser,
      businessId,
      membershipId
    );
  }
}

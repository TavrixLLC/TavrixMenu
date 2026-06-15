import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiTags
} from '@nestjs/swagger';
import { PublicLoyaltyCardTokenParamDto } from './dto/public-loyalty-card-token-param.dto';
import { PublicLoyaltyEnrollDto } from './dto/public-loyalty-enroll.dto';
import { PublicLoyaltyService } from './public-loyalty.service';

const publicCardStateExample = {
  stampCount: 3,
  stampGoal: 5,
  rewardReady: false,
  progressPercent: 60,
  rewardName: 'Free coffee',
  programName: 'Tavrix Cafe Stamp Card',
  totalStampsEarned: 3,
  totalRewardsRedeemed: 0
};

@ApiTags('public loyalty')
@Controller('public')
export class PublicLoyaltyController {
  constructor(private readonly publicLoyaltyService: PublicLoyaltyService) {}

  @Get('m/:slug/loyalty')
  @ApiOkResponse({
    description:
      'Public loyalty enrollment context for an active business with an active loyalty program.',
    schema: {
      example: {
        business: {
          id: 'bus_123',
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          type: 'cafe',
          city: 'Baghdad',
          logoUrl: null,
          coverUrl: null,
          currency: 'IQD',
          language: 'ar'
        },
        loyaltyProgram: {
          id: 'loyalty_program_id',
          name: 'Tavrix Cafe Stamp Card',
          description: 'Collect stamps on coffee visits.',
          stampGoal: 5,
          rewardName: 'Free coffee',
          rewardDescription: 'One free Turkish Coffee after 5 stamps.',
          cardColor: '#111827',
          accentColor: '#f59e0b',
          logoUrl: null,
          terms: 'Reward is valid for dine-in orders only.'
        },
        enrollment: {
          acceptsPhone: true,
          acceptsEmail: true,
          requiresOtp: false
        }
      }
    }
  })
  @ApiNotFoundResponse({
    description: 'Business is inactive/missing or has no active loyalty program.',
    schema: {
      example: {
        message: 'Public loyalty program not found',
        error: 'Not Found',
        statusCode: 404
      }
    }
  })
  getEnrollmentContext(@Param('slug') slug: string) {
    return this.publicLoyaltyService.getEnrollmentContext(slug);
  }

  @Post('m/:slug/loyalty/enroll')
  @ApiCreatedResponse({
    description:
      'Public no-OTP pilot enrollment. Reuses or creates a customer, activates membership, and returns a one-time plaintext card token.',
    schema: {
      example: {
        customer: {
          name: 'Demo Customer'
        },
        business: {
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          logoUrl: null,
          coverUrl: null
        },
        program: {
          name: 'Tavrix Cafe Stamp Card',
          stampGoal: 5,
          rewardName: 'Free coffee',
          rewardDescription: 'One free Turkish Coffee after 5 stamps.'
        },
        cardState: publicCardStateExample,
        cardAccess: {
          token: 'public_card_token',
          cardUrlPath: '/public/loyalty/cards/public_card_token'
        }
      }
    }
  })
  @ApiBadRequestResponse({
    description: 'Validation failed or phone/email is missing.',
    schema: {
      example: {
        message: 'Enrollment requires phone or email',
        error: 'Bad Request',
        statusCode: 400
      }
    }
  })
  @ApiConflictResponse({
    description: 'Phone and email belong to different customer records.',
    schema: {
      example: {
        message: 'Phone and email belong to different customers',
        error: 'Conflict',
        statusCode: 409
      }
    }
  })
  @ApiNotFoundResponse({
    description: 'Business is inactive/missing or has no active loyalty program.'
  })
  enrollCustomer(
    @Param('slug') slug: string,
    @Body() dto: PublicLoyaltyEnrollDto
  ) {
    return this.publicLoyaltyService.enrollCustomer(slug, dto);
  }

  @Get('loyalty/cards/:token')
  @ApiOkResponse({
    description:
      'Public web fallback loyalty card by token. Returns limited card state only; no raw phone/email or internal IDs.',
    schema: {
      example: {
        business: {
          name: 'Tavrix Cafe',
          slug: 'tavrix-cafe',
          logoUrl: null,
          coverUrl: null
        },
        program: {
          name: 'Tavrix Cafe Stamp Card',
          stampGoal: 5,
          rewardName: 'Free coffee',
          rewardDescription: 'One free Turkish Coffee after 5 stamps.',
          terms: 'Reward is valid for dine-in orders only.'
        },
        customer: {
          name: 'Demo Customer'
        },
        cardState: publicCardStateExample
      }
    }
  })
  @ApiBadRequestResponse({
    description: 'Token parameter failed validation.',
    schema: {
      example: {
        message: ['token must be longer than or equal to 32 characters'],
        error: 'Bad Request',
        statusCode: 400
      }
    }
  })
  @ApiNotFoundResponse({
    description: 'Invalid, inactive, or expired public card token.',
    schema: {
      example: {
        message: 'Loyalty card not found',
        error: 'Not Found',
        statusCode: 404
      }
    }
  })
  getPublicCard(@Param() params: PublicLoyaltyCardTokenParamDto) {
    return this.publicLoyaltyService.getPublicCard(params.token);
  }
}

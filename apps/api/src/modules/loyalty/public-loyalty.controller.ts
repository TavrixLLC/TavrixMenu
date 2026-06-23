import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiResponse,
  ApiTags
} from '@nestjs/swagger';
import { PublicLoyaltyCardTokenParamDto } from './dto/public-loyalty-card-token-param.dto';
import { PublicLoyaltyEnrollDto } from './dto/public-loyalty-enroll.dto';
import {
  CreatePublicLoyaltyTransferDto,
  RedeemPublicLoyaltyTransferDto
} from './dto/public-loyalty-transfer.dto';
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
      'Public no-OTP pilot join for a new identity. Returns card access only when both the normalized phone and optional email are unused.',
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
    description: 'Validation failed or the required Iraqi phone number is invalid.',
    schema: {
      example: {
        message:
          'phone must use Iraqi local 07xxxxxxxxx or international +9647xxxxxxxxx format',
        error: 'Bad Request',
        statusCode: 400
      }
    }
  })
  @ApiForbiddenResponse({
    description:
      'RECOVER requests and JOIN requests matching an existing phone or email require verified recovery. The response never contains card access or customer data.',
    schema: {
      example: {
        statusCode: 403,
        code: 'RECOVERY_REQUIRES_VERIFICATION',
        message: 'Recovery requires phone verification or staff help.'
      }
    }
  })
  @ApiNotFoundResponse({
    description: 'Business/program is inactive or missing.'
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

  @Post('loyalty/card-transfers')
  @ApiCreatedResponse({
    description:
      'Creates a dedicated five-minute, one-time transfer credential after validating the trusted browser card reference.',
    schema: {
      example: {
        transferToken: '<short-lived-transfer-code>',
        expiresAt: '2026-06-23T13:05:00.000Z'
      }
    }
  })
  @ApiNotFoundResponse({
    description: 'The trusted public card reference is invalid or inactive.'
  })
  @ApiResponse({
    status: HttpStatus.TOO_MANY_REQUESTS,
    description: 'Transfer creation rate limit reached for this membership.',
    schema: {
      example: {
        statusCode: 429,
        code: 'LOYALTY_TRANSFER_RATE_LIMITED',
        message: 'Please wait before creating another transfer code.'
      }
    }
  })
  createCardTransfer(@Body() dto: CreatePublicLoyaltyTransferDto) {
    return this.publicLoyaltyService.createCardTransfer(dto.cardToken);
  }

  @Post('loyalty/card-transfers/redeem')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({
    description:
      'Atomically consumes a valid transfer credential and returns an additional public card reference for the same membership without revoking existing device access.',
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
          token: '<new-public-card-reference>',
          cardUrlPath:
            '/public/loyalty/cards/<new-public-card-reference>'
        }
      }
    }
  })
  @ApiResponse({
    status: HttpStatus.GONE,
    description:
      'The transfer credential is invalid, expired, already used, or not scoped to an active card.',
    schema: {
      example: {
        statusCode: 410,
        code: 'LOYALTY_TRANSFER_UNAVAILABLE',
        message: 'This transfer code is invalid, expired, or already used.'
      }
    }
  })
  redeemCardTransfer(@Body() dto: RedeemPublicLoyaltyTransferDto) {
    return this.publicLoyaltyService.redeemCardTransfer(dto.transferToken);
  }
}

import { Body, Controller, Param, Post, UseGuards } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiTags,
  ApiUnauthorizedResponse
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { WalletScanDto } from './dto/wallet-scan.dto';
import { WalletScanService } from './wallet-scan.service';

@ApiTags('loyalty')
@ApiBearerAuth()
@UseGuards(ClerkAuthGuard)
@Controller('businesses/:businessId/loyalty/wallet-scan')
@ApiUnauthorizedResponse({
  description: 'Missing or invalid bearer token.',
  schema: {
    example: {
      statusCode: 401,
      message: 'Missing bearer token',
      error: 'Unauthorized'
    }
  }
})
@ApiForbiddenResponse({
  description:
    'Active OWNER, MANAGER, or STAFF membership is required, and the pass must belong to the requested business.',
  schema: {
    example: {
      statusCode: 403,
      message: 'Wallet pass belongs to another business',
      error: 'Forbidden'
    }
  }
})
export class WalletScanController {
  constructor(private readonly walletScanService: WalletScanService) {}

  @Post()
  @ApiOkResponse({
    description:
      'Validates an Apple Wallet or Google Wallet loyalty barcode token and returns safe staff scan data.',
    schema: {
      example: {
        membershipId: 'membership_id',
        customer: {
          name: 'Demo Customer',
          phone: '+9647700000000'
        },
        program: {
          name: 'Tavrix Cafe Stamp Card',
          stampGoal: 10,
          rewardName: 'Free coffee'
        },
        progress: {
          stamps: 3,
          goal: 10,
          canRedeem: false
        },
        walletPass: {
          platform: 'GOOGLE_WALLET',
          status: 'ACTIVE'
        }
      }
    }
  })
  @ApiBadRequestResponse({
    description: 'Malformed, invalid, inactive, or rotated wallet scan token.',
    schema: {
      example: {
        statusCode: 400,
        message: 'Invalid wallet scan token',
        error: 'Bad Request'
      }
    }
  })
  scanGoogleWalletPass(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('businessId') businessId: string,
    @Body() dto: WalletScanDto
  ) {
    return this.walletScanService.scanGoogleWalletPass(
      currentUser,
      businessId,
      dto
    );
  }
}

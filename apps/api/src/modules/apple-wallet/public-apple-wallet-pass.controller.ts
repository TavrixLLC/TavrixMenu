import {
  Controller,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  StreamableFile
} from '@nestjs/common';
import {
  ApiBadGatewayResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiProduces,
  ApiResponse,
  ApiTags
} from '@nestjs/swagger';
import { PublicLoyaltyCardTokenParamDto } from '../loyalty/dto/public-loyalty-card-token-param.dto';
import {
  APPLE_WALLET_PASS_CONTENT_TYPE,
  PublicAppleWalletPassService
} from './public-apple-wallet-pass.service';

@ApiTags('public loyalty')
@Controller('public/loyalty/cards/:token/apple-wallet')
export class PublicAppleWalletPassController {
  constructor(
    private readonly publicAppleWalletPassService: PublicAppleWalletPassService
  ) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  @ApiProduces(APPLE_WALLET_PASS_CONTENT_TYPE)
  @ApiOkResponse({
    description: 'Returns a signed Apple Wallet loyalty pass package.',
    headers: {
      'Content-Disposition': {
        description: 'Safe attachment filename for the generated pass.',
        schema: {
          type: 'string',
          example: 'attachment; filename="waflo-loyalty.pkpass"'
        }
      }
    },
    content: {
      [APPLE_WALLET_PASS_CONTENT_TYPE]: {
        schema: {
          type: 'string',
          format: 'binary'
        }
      }
    }
  })
  @ApiResponse({
    status: HttpStatus.SERVICE_UNAVAILABLE,
    description: 'Apple Wallet is disabled or signing is not configured.',
    content: {
      'application/json': {
        schema: {
          oneOf: [
            {
              example: {
                statusCode: 503,
                code: 'APPLE_WALLET_DISABLED',
                message: 'Apple Wallet is unavailable'
              }
            },
            {
              example: {
                statusCode: 503,
                code: 'APPLE_WALLET_NOT_CONFIGURED',
                message: 'Apple Wallet is unavailable'
              }
            }
          ]
        }
      }
    }
  })
  @ApiNotFoundResponse({
    description: 'The public loyalty card token is invalid or inactive.',
    content: {
      'application/json': {
        schema: {
          example: {
            statusCode: 404,
            code: 'PUBLIC_LOYALTY_CARD_NOT_FOUND',
            message: 'Loyalty card not found'
          }
        }
      }
    }
  })
  @ApiBadGatewayResponse({
    description: 'Apple Wallet signing failed.',
    content: {
      'application/json': {
        schema: {
          example: {
            statusCode: 502,
            code: 'APPLE_WALLET_SIGNING_FAILED',
            message: 'Apple Wallet pass generation failed'
          }
        }
      }
    }
  })
  async generateAppleWalletPass(
    @Param() params: PublicLoyaltyCardTokenParamDto
  ) {
    const result = await this.publicAppleWalletPassService.generatePublicPass(
      params.token
    );

    return new StreamableFile(result.pass, {
      type: APPLE_WALLET_PASS_CONTENT_TYPE,
      disposition: `attachment; filename="${result.fileName}"`,
      length: result.pass.length
    });
  }
}

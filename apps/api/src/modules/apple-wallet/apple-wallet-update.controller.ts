import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
  Res
} from '@nestjs/common';
import {
  ApiCreatedResponse,
  ApiHeader,
  ApiNoContentResponse,
  ApiOkResponse,
  ApiProduces,
  ApiResponse,
  ApiTags,
  ApiUnauthorizedResponse
} from '@nestjs/swagger';
import {
  APPLE_WALLET_PASS_CONTENT_TYPE,
  APPLE_WALLET_PASS_FILE_NAME
} from './public-apple-wallet-pass.service';
import { AppleWalletUpdateService } from './apple-wallet-update.service';
import {
  AppleWalletDeviceListPathDto,
  AppleWalletDeviceRegistrationPathDto,
  AppleWalletLogDto,
  AppleWalletPassPathDto,
  AppleWalletRegistrationDto,
  AppleWalletUpdatedPassesQueryDto
} from './dto/apple-wallet-update.dto';

type HttpResponse = {
  status(code: number): HttpResponse;
  send(body?: unknown): void;
  json(body: unknown): void;
  setHeader(name: string, value: string): void;
};

@ApiTags('apple wallet web service')
@Controller('apple-wallet/v1')
export class AppleWalletUpdateController {
  constructor(
    private readonly appleWalletUpdateService: AppleWalletUpdateService
  ) {}

  @Post(
    'devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber'
  )
  @ApiHeader({
    name: 'Authorization',
    required: true,
    description: 'ApplePass authentication token embedded in the signed pass.'
  })
  @ApiCreatedResponse({ description: 'Device registration created.' })
  @ApiOkResponse({ description: 'Existing device registration updated.' })
  @ApiUnauthorizedResponse({ description: 'Invalid pass authorization.' })
  async registerDevice(
    @Headers('authorization') authorization: string | undefined,
    @Param() params: AppleWalletDeviceRegistrationPathDto,
    @Body() body: AppleWalletRegistrationDto,
    @Res() response: HttpResponse
  ) {
    const result = await this.appleWalletUpdateService.registerDevice({
      authorization,
      ...params,
      pushToken: body.pushToken
    });

    response.status(result.created ? HttpStatus.CREATED : HttpStatus.OK).send();
  }

  @Get(
    'devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier'
  )
  @ApiOkResponse({
    description: 'Serial numbers for passes changed after the supplied tag.',
    schema: {
      example: {
        serialNumbers: ['waflo-apple-pass'],
        lastUpdated: '1781956800000'
      }
    }
  })
  @ApiNoContentResponse({ description: 'No registered passes changed.' })
  async listUpdatedPasses(
    @Param() params: AppleWalletDeviceListPathDto,
    @Query() query: AppleWalletUpdatedPassesQueryDto,
    @Res() response: HttpResponse
  ) {
    const result = await this.appleWalletUpdateService.listUpdatedPasses({
      ...params,
      passesUpdatedSince: query.passesUpdatedSince
    });

    if (!result) {
      response.status(HttpStatus.NO_CONTENT).send();
      return;
    }

    response.status(HttpStatus.OK).json(result);
  }

  @Get('passes/:passTypeIdentifier/:serialNumber')
  @ApiHeader({
    name: 'Authorization',
    required: true,
    description: 'ApplePass authentication token embedded in the signed pass.'
  })
  @ApiHeader({
    name: 'If-Modified-Since',
    required: false,
    description: 'Optional HTTP date for conditional pass delivery.'
  })
  @ApiProduces(APPLE_WALLET_PASS_CONTENT_TYPE)
  @ApiOkResponse({
    description: 'Latest signed Apple Wallet pass.',
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
    status: HttpStatus.NOT_MODIFIED,
    description: 'The pass has not changed since If-Modified-Since.'
  })
  @ApiUnauthorizedResponse({ description: 'Invalid pass authorization.' })
  async getUpdatedPass(
    @Headers('authorization') authorization: string | undefined,
    @Headers('if-modified-since') ifModifiedSince: string | undefined,
    @Param() params: AppleWalletPassPathDto,
    @Res() response: HttpResponse
  ) {
    const result = await this.appleWalletUpdateService.getUpdatedPass({
      authorization,
      ifModifiedSince,
      ...params
    });

    response.setHeader('Last-Modified', result.lastModified.toUTCString());

    if (result.status === 'NOT_MODIFIED') {
      response.status(HttpStatus.NOT_MODIFIED).send();
      return;
    }

    response.setHeader('Content-Type', APPLE_WALLET_PASS_CONTENT_TYPE);
    response.setHeader(
      'Content-Disposition',
      `attachment; filename="${APPLE_WALLET_PASS_FILE_NAME}"`
    );
    response.status(HttpStatus.OK).send(result.pass);
  }

  @Delete(
    'devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber'
  )
  @ApiHeader({
    name: 'Authorization',
    required: true,
    description: 'ApplePass authentication token embedded in the signed pass.'
  })
  @ApiOkResponse({ description: 'Device registration removed.' })
  @ApiUnauthorizedResponse({ description: 'Invalid pass authorization.' })
  async unregisterDevice(
    @Headers('authorization') authorization: string | undefined,
    @Param() params: AppleWalletDeviceRegistrationPathDto,
    @Res() response: HttpResponse
  ) {
    await this.appleWalletUpdateService.unregisterDevice({
      authorization,
      ...params
    });
    response.status(HttpStatus.OK).send();
  }

  @Post('log')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ description: 'Diagnostic messages accepted safely.' })
  acceptLogs(@Body() body: AppleWalletLogDto) {
    this.appleWalletUpdateService.acceptLogs(body.logs);
  }
}

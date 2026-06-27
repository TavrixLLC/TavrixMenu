import {
  BadRequestException,
  Body,
  Controller,
  Param,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiResponse,
  ApiTags,
  ApiUnauthorizedResponse
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { UploadMediaDto } from './dto/upload-media.dto';
import {
  MAX_MEDIA_UPLOAD_SIZE_BYTES,
  MEDIA_UPLOAD_PURPOSES
} from './media-upload.constants';
import { MediaUploadService, UploadedMediaFile } from './media-upload.service';

type RequestLike = {
  headers: Record<string, string | string[] | undefined>;
  protocol?: string;
};

@ApiTags('media')
@ApiBearerAuth()
@UseGuards(ClerkAuthGuard)
@Controller()
export class MediaController {
  constructor(private readonly mediaUploadService: MediaUploadService) {}

  @Post('businesses/:id/media/uploads')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        files: 1,
        fileSize: MAX_MEDIA_UPLOAD_SIZE_BYTES
      }
    })
  )
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      required: ['purpose', 'file'],
      properties: {
        purpose: {
          type: 'string',
          enum: MEDIA_UPLOAD_PURPOSES,
          example: 'MENU_ITEM_IMAGE'
        },
        file: {
          type: 'string',
          format: 'binary'
        }
      }
    }
  })
  @ApiCreatedResponse({
    description:
      'Image uploaded and normalized. Use the returned public URL with existing business or menu item update endpoints.',
    schema: {
      example: {
        url: 'https://api.waflo.app/uploads/business-media/menu-item-image/2026/06/image.webp',
        contentType: 'image/webp',
        sizeBytes: 123456,
        purpose: 'MENU_ITEM_IMAGE'
      }
    }
  })
  @ApiBadRequestResponse({ description: 'Missing, invalid, or unsupported image.' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token.' })
  @ApiForbiddenResponse({
    description: 'OWNER or MANAGER business membership required.'
  })
  @ApiResponse({ status: 413, description: 'Uploaded image exceeds size limit.' })
  upload(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: UploadMediaDto,
    @UploadedFile() file: UploadedMediaFile | undefined,
    @Req() request: RequestLike
  ) {
    return this.mediaUploadService.uploadImage({
      currentUser,
      businessId,
      purpose: dto.purpose,
      file,
      publicBaseUrl: getPublicBaseUrl(request)
    });
  }
}

function getPublicBaseUrl(request: RequestLike) {
  const protocol =
    readForwardedHeader(request.headers['x-forwarded-proto']) ||
    request.protocol ||
    'http';
  const host =
    readForwardedHeader(request.headers['x-forwarded-host']) ||
    readForwardedHeader(request.headers.host);

  if (!host) {
    throw new BadRequestException('Unable to determine public upload URL');
  }

  return `${protocol}://${host}`;
}

function readForwardedHeader(value: string | string[] | undefined) {
  const first = Array.isArray(value) ? value[0] : value;

  return first?.split(',')[0]?.trim();
}

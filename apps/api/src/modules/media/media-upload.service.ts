import {
  BadRequestException,
  Injectable,
  PayloadTooLargeException
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import sharp from 'sharp';
import { BusinessUserRole } from '../../generated/prisma';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessAccessService } from '../businesses/business-access.service';
import {
  MEDIA_UPLOAD_PURPOSE_CONFIG,
  MediaUploadPurpose
} from './media-upload.constants';
import { MediaStorageService } from './media-storage.service';

const allowedMimeTypes = new Set(['image/jpeg', 'image/png', 'image/webp']);
const allowedExtensions = new Set(['.jpg', '.jpeg', '.png', '.webp']);
const allowedSharpFormats = new Set(['jpeg', 'png', 'webp']);

export type UploadedMediaFile = {
  buffer?: Buffer;
  size?: number;
  mimetype?: string;
  originalname?: string;
};

@Injectable()
export class MediaUploadService {
  constructor(
    private readonly businessAccessService: BusinessAccessService,
    private readonly storageService: MediaStorageService
  ) {}

  async uploadImage({
    currentUser,
    businessId,
    purpose,
    file,
    publicBaseUrl
  }: {
    currentUser: AuthenticatedUser;
    businessId: string;
    purpose: MediaUploadPurpose;
    file: UploadedMediaFile | undefined;
    publicBaseUrl: string;
  }) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      [BusinessUserRole.OWNER, BusinessUserRole.MANAGER]
    );

    const config = MEDIA_UPLOAD_PURPOSE_CONFIG[purpose];

    if (!file?.buffer?.length) {
      throw new BadRequestException('Image file is required');
    }

    const sizeBytes = file.size ?? file.buffer.byteLength;

    if (sizeBytes > config.maxSizeBytes) {
      throw new PayloadTooLargeException(
        `${purpose} image must be ${formatBytes(config.maxSizeBytes)} or smaller`
      );
    }

    this.assertSafeClientHints(file);

    const metadata = await readImageMetadata(file.buffer);
    const format = metadata.format ?? '';

    if (!allowedSharpFormats.has(format)) {
      throw new BadRequestException('Unsupported image type');
    }

    const normalizedImage = await sharp(file.buffer, {
      failOn: 'error',
      limitInputPixels: 50_000_000
    })
      .rotate()
      .resize({
        width: config.maxWidth,
        height: config.maxHeight,
        fit: 'inside',
        withoutEnlargement: true
      })
      .webp({ quality: 84 })
      .toBuffer();

    const relativePath = buildUploadPath(config.pathSegment);
    await this.storageService.write(relativePath, normalizedImage);

    return {
      url: buildPublicUrl(publicBaseUrl, relativePath),
      contentType: 'image/webp',
      sizeBytes: normalizedImage.byteLength,
      purpose
    };
  }

  private assertSafeClientHints(file: UploadedMediaFile) {
    const mimeType = file.mimetype?.toLowerCase().trim();

    if (mimeType && !allowedMimeTypes.has(mimeType)) {
      throw new BadRequestException('Unsupported image type');
    }

    const extension = readExtension(file.originalname);

    if (extension && !allowedExtensions.has(extension)) {
      throw new BadRequestException('Unsupported image type');
    }
  }
}

async function readImageMetadata(buffer: Buffer) {
  try {
    return await sharp(buffer, {
      failOn: 'error',
      limitInputPixels: 50_000_000
    }).metadata();
  } catch {
    throw new BadRequestException('Invalid image file');
  }
}

function buildUploadPath(pathSegment: string) {
  const now = new Date();
  const year = String(now.getUTCFullYear());
  const month = String(now.getUTCMonth() + 1).padStart(2, '0');

  return [
    'business-media',
    pathSegment,
    year,
    month,
    `${randomUUID()}.webp`
  ].join('/');
}

function buildPublicUrl(publicBaseUrl: string, relativePath: string) {
  const base = publicBaseUrl.replace(/\/$/, '');
  const encodedPath = relativePath
    .split('/')
    .map((segment) => encodeURIComponent(segment))
    .join('/');

  return `${base}/uploads/${encodedPath}`;
}

function readExtension(originalName: string | undefined) {
  const trimmed = originalName?.trim().toLowerCase();

  if (!trimmed) {
    return '';
  }

  const dotIndex = trimmed.lastIndexOf('.');

  return dotIndex >= 0 ? trimmed.slice(dotIndex) : '';
}

function formatBytes(size: number) {
  return `${Math.floor(size / (1024 * 1024))}MB`;
}

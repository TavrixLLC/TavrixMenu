export enum MediaUploadPurpose {
  BUSINESS_LOGO = 'BUSINESS_LOGO',
  BUSINESS_COVER = 'BUSINESS_COVER',
  MENU_ITEM_IMAGE = 'MENU_ITEM_IMAGE'
}

export const MEDIA_UPLOAD_PURPOSES = Object.values(MediaUploadPurpose);

export const MAX_MEDIA_UPLOAD_SIZE_BYTES = 5 * 1024 * 1024;

export const MEDIA_UPLOAD_PURPOSE_CONFIG = {
  [MediaUploadPurpose.BUSINESS_LOGO]: {
    maxSizeBytes: 2 * 1024 * 1024,
    pathSegment: 'business-logo',
    maxWidth: 1024,
    maxHeight: 1024
  },
  [MediaUploadPurpose.BUSINESS_COVER]: {
    maxSizeBytes: MAX_MEDIA_UPLOAD_SIZE_BYTES,
    pathSegment: 'business-cover',
    maxWidth: 1920,
    maxHeight: 1080
  },
  [MediaUploadPurpose.MENU_ITEM_IMAGE]: {
    maxSizeBytes: MAX_MEDIA_UPLOAD_SIZE_BYTES,
    pathSegment: 'menu-item-image',
    maxWidth: 1600,
    maxHeight: 1200
  }
} as const satisfies Record<
  MediaUploadPurpose,
  {
    maxSizeBytes: number;
    pathSegment: string;
    maxWidth: number;
    maxHeight: number;
  }
>;

import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';
import { MediaUploadPurpose } from '../media-upload.constants';

export class UploadMediaDto {
  @ApiProperty({
    enum: MediaUploadPurpose,
    example: MediaUploadPurpose.MENU_ITEM_IMAGE,
    description:
      'Purpose of the uploaded image. Controls validation limits and storage path.'
  })
  @IsEnum(MediaUploadPurpose)
  purpose: MediaUploadPurpose;
}

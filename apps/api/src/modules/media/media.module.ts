import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { MediaController } from './media.controller';
import { MediaStorageService } from './media-storage.service';
import { MediaUploadService } from './media-upload.service';

@Module({
  imports: [AuthModule, BusinessesModule],
  controllers: [MediaController],
  providers: [MediaStorageService, MediaUploadService]
})
export class MediaModule {}

import { Injectable } from '@nestjs/common';
import { mkdir, writeFile } from 'fs/promises';
import { join } from 'path';
import {
  StampImageRendererService,
  StampImageRenderInput
} from './stamp-image-renderer.service';

export type StoreStampImageInput = StampImageRenderInput & {
  membershipId: string;
};

export type StoredStampImage = {
  fileName: string;
  relativePath: string;
  absolutePath: string;
  publicUrl: string;
};

@Injectable()
export class StampImageStorageService {
  private readonly outputRoot = join(
    process.cwd(),
    'public',
    'generated',
    'wallet-stamps'
  );

  constructor(private readonly renderer: StampImageRendererService) {}

  async renderAndStore(input: StoreStampImageInput): Promise<StoredStampImage> {
    const png = await this.renderer.renderPng(input);
    const styleHash = this.renderer.buildStyleHash(input);
    const fileName = `${this.safeSegment(input.membershipId)}-${styleHash}-${input.stampCount}-${input.stampGoal}.png`;
    const relativePath = `wallet-stamps/${fileName}`;
    const absolutePath = join(this.outputRoot, fileName);

    await mkdir(this.outputRoot, {
      recursive: true
    });
    await writeFile(absolutePath, png);

    return {
      fileName,
      relativePath,
      absolutePath,
      publicUrl: `/generated/${relativePath}`
    };
  }

  private safeSegment(value: string) {
    const normalized = value.trim();

    return normalized
      ? normalized.replace(/[^A-Za-z0-9._-]/g, '-')
      : 'membership';
  }
}

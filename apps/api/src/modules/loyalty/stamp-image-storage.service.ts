import { Injectable, Optional } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
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
  localPublicPath: string;
  publicUrl: string | null;
};

type StoreStampImageOptions = {
  publicBaseUrl?: string;
};

@Injectable()
export class StampImageStorageService {
  private readonly outputRoot = join(
    process.cwd(),
    'public',
    'generated',
    'wallet-stamps'
  );

  constructor(
    private readonly renderer: StampImageRendererService,
    @Optional() private readonly configService?: ConfigService
  ) {}

  async renderAndStore(
    input: StoreStampImageInput,
    options: StoreStampImageOptions = {}
  ): Promise<StoredStampImage> {
    const png = await this.renderer.renderPng(input);
    const styleHash = this.renderer.buildStyleHash(input);
    const fileName = `${this.safeSegment(input.membershipId)}-${styleHash}-${input.stampCount}-${input.stampGoal}.png`;
    const relativePath = `wallet-stamps/${fileName}`;
    const absolutePath = join(this.outputRoot, fileName);
    const localPublicPath = `/generated/${relativePath}`;
    const publicUrl = this.buildPublicUrl(
      relativePath,
      options.publicBaseUrl ?? this.configService?.get<string>(
        'WALLET_IMAGE_PUBLIC_BASE_URL'
      )
    );

    await mkdir(this.outputRoot, {
      recursive: true
    });
    await writeFile(absolutePath, png);

    return {
      fileName,
      relativePath,
      absolutePath,
      localPublicPath,
      publicUrl
    };
  }

  requirePublicUrl(storedImage: StoredStampImage) {
    if (!storedImage.publicUrl) {
      throw new Error(
        'WALLET_IMAGE_PUBLIC_BASE_URL is required to attach generated Wallet images'
      );
    }

    return storedImage.publicUrl;
  }

  private buildPublicUrl(relativePath: string, publicBaseUrl?: string) {
    const normalizedBaseUrl = publicBaseUrl?.trim();

    if (!normalizedBaseUrl) {
      return null;
    }

    let parsed: URL;

    try {
      parsed = new URL(normalizedBaseUrl);
    } catch {
      throw new Error('WALLET_IMAGE_PUBLIC_BASE_URL must be a valid HTTPS URL');
    }

    if (parsed.protocol !== 'https:') {
      throw new Error('WALLET_IMAGE_PUBLIC_BASE_URL must start with https://');
    }

    const baseUrl = parsed.toString().replace(/\/$/, '');
    const encodedPath = relativePath
      .split('/')
      .map((segment) => encodeURIComponent(segment))
      .join('/');

    return `${baseUrl}/${encodedPath}`;
  }

  private safeSegment(value: string) {
    const normalized = value.trim();

    return normalized
      ? normalized.replace(/[^A-Za-z0-9._-]/g, '-')
      : 'membership';
  }
}

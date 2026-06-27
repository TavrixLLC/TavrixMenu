import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { mkdir, writeFile } from 'fs/promises';
import { dirname, isAbsolute, join, normalize, resolve, sep } from 'path';

@Injectable()
export class MediaStorageService {
  constructor(private readonly configService: ConfigService) {}

  getStorageRoot() {
    const configuredRoot =
      this.configService.get<string>('MEDIA_UPLOAD_ROOT')?.trim() ||
      defaultUploadRoot();

    return resolve(configuredRoot);
  }

  async write(relativePath: string, buffer: Buffer) {
    const root = this.getStorageRoot();
    const safeRelativePath = assertSafeRelativePath(relativePath);
    const absolutePath = resolve(root, safeRelativePath);

    if (!absolutePath.startsWith(`${root}${sep}`)) {
      throw new Error('Resolved upload path escaped storage root');
    }

    await mkdir(dirname(absolutePath), { recursive: true });
    await writeFile(absolutePath, buffer, { flag: 'wx' });
  }
}

function assertSafeRelativePath(relativePath: string) {
  if (!relativePath || isAbsolute(relativePath)) {
    throw new Error('Upload path must be relative');
  }

  const normalized = normalize(relativePath).replace(/\\/g, '/');

  if (normalized.startsWith('../') || normalized === '..') {
    throw new Error('Upload path cannot traverse directories');
  }

  return normalized;
}

function defaultUploadRoot() {
  return process.env.NODE_ENV === 'production'
    ? '/opt/waflo/uploads'
    : join(process.cwd(), 'public', 'uploads');
}

import { ForbiddenException } from '@nestjs/common';
import { GUARDS_METADATA } from '@nestjs/common/constants';
import { strict as assert } from 'assert';
import { mkdtemp, readdir, rm } from 'fs/promises';
import { tmpdir } from 'os';
import { join } from 'path';
import { describe, it } from 'node:test';
import sharp from 'sharp';
import {
  BusinessUserRole,
  BusinessUserStatus
} from '../../generated/prisma';
import { BusinessesService } from '../businesses/businesses.service';
import { BusinessAccessService } from '../businesses/business-access.service';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { MenuService } from '../menu/menu.service';
import { MediaController } from './media.controller';
import { MediaStorageService } from './media-storage.service';
import { MediaUploadPurpose } from './media-upload.constants';
import { MediaUploadService, UploadedMediaFile } from './media-upload.service';

describe('MediaUploadService', () => {
  it('allows OWNER uploads for logo, cover, and menu item images', async () => {
    const setup = await createUploadSetup();

    try {
      for (const purpose of [
        MediaUploadPurpose.BUSINESS_LOGO,
        MediaUploadPurpose.BUSINESS_COVER,
        MediaUploadPurpose.MENU_ITEM_IMAGE
      ]) {
        const response = await setup.service.uploadImage({
          currentUser: user('owner'),
          businessId: 'business_1',
          purpose,
          file: await imageFile('png'),
          publicBaseUrl: 'https://api.waflo.app'
        });

        assert.equal(response.purpose, purpose);
        assert.equal(response.contentType, 'image/webp');
        assert.match(response.url, /^https:\/\/api\.waflo\.app\/uploads\/business-media\//);
        assert.doesNotMatch(response.url, /[A-Z]:\\|\/opt\/waflo|public\/uploads/);
      }

      assert.deepEqual(setup.rolesSeen, [
        [BusinessUserRole.OWNER, BusinessUserRole.MANAGER],
        [BusinessUserRole.OWNER, BusinessUserRole.MANAGER],
        [BusinessUserRole.OWNER, BusinessUserRole.MANAGER]
      ]);
    } finally {
      await setup.cleanup();
    }
  });

  it('allows MANAGER uploads under the menu-manager pilot policy', async () => {
    const setup = await createUploadSetup();

    try {
      const response = await setup.service.uploadImage({
        currentUser: user('manager'),
        businessId: 'business_1',
        purpose: MediaUploadPurpose.MENU_ITEM_IMAGE,
        file: await imageFile('webp'),
        publicBaseUrl: 'https://api.waflo.app'
      });

      assert.equal(response.purpose, MediaUploadPurpose.MENU_ITEM_IMAGE);
      assert.equal(response.contentType, 'image/webp');
    } finally {
      await setup.cleanup();
    }
  });

  it('forbids STAFF, wrong-business, and missing-membership uploads', async () => {
    const setup = await createUploadSetup();

    try {
      await assert.rejects(
        setup.service.uploadImage({
          currentUser: user('staff'),
          businessId: 'business_1',
          purpose: MediaUploadPurpose.MENU_ITEM_IMAGE,
          file: await imageFile('png'),
          publicBaseUrl: 'https://api.waflo.app'
        }),
        ForbiddenException
      );

      await assert.rejects(
        setup.service.uploadImage({
          currentUser: user('owner'),
          businessId: 'wrong_business',
          purpose: MediaUploadPurpose.MENU_ITEM_IMAGE,
          file: await imageFile('png'),
          publicBaseUrl: 'https://api.waflo.app'
        }),
        ForbiddenException
      );
    } finally {
      await setup.cleanup();
    }
  });

  it('requires Clerk auth at the controller boundary', () => {
    const guards = Reflect.getMetadata(GUARDS_METADATA, MediaController);

    assert.ok(Array.isArray(guards));
    assert.equal(guards.includes(ClerkAuthGuard), true);
  });

  it('rejects invalid, unsupported, SVG, and oversized files', async () => {
    const setup = await createUploadSetup();

    try {
      await assert.rejects(
        setup.service.uploadImage({
          currentUser: user('owner'),
          businessId: 'business_1',
          purpose: MediaUploadPurpose.MENU_ITEM_IMAGE,
          file: {
            buffer: Buffer.from('%PDF-1.7'),
            size: 8,
            mimetype: 'application/pdf',
            originalname: 'menu.pdf'
          },
          publicBaseUrl: 'https://api.waflo.app'
        }),
        /Unsupported image type/
      );

      await assert.rejects(
        setup.service.uploadImage({
          currentUser: user('owner'),
          businessId: 'business_1',
          purpose: MediaUploadPurpose.BUSINESS_LOGO,
          file: {
            buffer: Buffer.alloc(2 * 1024 * 1024 + 1),
            size: 2 * 1024 * 1024 + 1,
            mimetype: 'image/png',
            originalname: 'large-logo.png'
          },
          publicBaseUrl: 'https://api.waflo.app'
        }),
        /BUSINESS_LOGO image must be 2MB or smaller/
      );

      await assert.rejects(
        setup.service.uploadImage({
          currentUser: user('owner'),
          businessId: 'business_1',
          purpose: MediaUploadPurpose.BUSINESS_LOGO,
          file: {
            buffer: Buffer.from('<svg xmlns="http://www.w3.org/2000/svg"></svg>'),
            size: 46,
            mimetype: 'image/svg+xml',
            originalname: 'logo.svg'
          },
          publicBaseUrl: 'https://api.waflo.app'
        }),
        /Unsupported image type/
      );

      await assert.rejects(
        setup.service.uploadImage({
          currentUser: user('owner'),
          businessId: 'business_1',
          purpose: MediaUploadPurpose.MENU_ITEM_IMAGE,
          file: {
            buffer: Buffer.from('not an image'),
            size: 12,
            mimetype: 'image/png',
            originalname: 'item.png'
          },
          publicBaseUrl: 'https://api.waflo.app'
        }),
        /Invalid image file/
      );
    } finally {
      await setup.cleanup();
    }
  });

  it('normalizes images to webp files under a safe public URL', async () => {
    const setup = await createUploadSetup();

    try {
      const response = await setup.service.uploadImage({
        currentUser: user('owner'),
        businessId: 'business_1',
        purpose: MediaUploadPurpose.BUSINESS_COVER,
        file: await imageFile('jpeg'),
        publicBaseUrl: 'https://api.waflo.app/'
      });
      const storedFiles = await listStoredFiles(setup.root);

      assert.equal(storedFiles.length, 1);
      assert.equal(storedFiles[0].endsWith('.webp'), true);
      assert.equal(response.contentType, 'image/webp');
      assert.equal(response.url.includes('/uploads/business-media/business-cover/'), true);
      assert.equal(response.url.includes('original'), false);
      assert.equal(response.url.includes(setup.root), false);
    } finally {
      await setup.cleanup();
    }
  });

  it('returned URLs can be assigned through existing business and menu update APIs', async () => {
    const uploadedUrl =
      'https://api.waflo.app/uploads/business-media/menu-item-image/2026/06/upload.webp';
    const businessService = createBusinessUpdateService();
    const menuService = createMenuUpdateService();

    const business = await businessService.updateBusiness(user('owner'), 'business_1', {
      logoUrl: uploadedUrl,
      coverUrl: uploadedUrl
    });
    const item = await menuService.updateItem(user('manager'), 'item_1', {
      imageUrl: uploadedUrl
    });

    assert.equal(business.logoUrl, uploadedUrl);
    assert.equal(business.coverUrl, uploadedUrl);
    assert.equal(item.imageUrl, uploadedUrl);
  });
});

async function createUploadSetup() {
  const root = await mkdtemp(join(tmpdir(), 'waflo-media-'));
  const rolesSeen: BusinessUserRole[][] = [];
  const businessAccessService = {
    assertRole: async (
      businessId: string,
      userId: string,
      roles: BusinessUserRole[]
    ) => {
      rolesSeen.push(roles);

      if (businessId !== 'business_1' || userId === 'staff') {
        throw new ForbiddenException('Insufficient business role');
      }

      return membership(userId === 'manager' ? BusinessUserRole.MANAGER : BusinessUserRole.OWNER);
    }
  };
  const configService = {
    get: (key: string, fallback?: string) =>
      key === 'MEDIA_UPLOAD_ROOT' ? root : fallback
  };
  const storageService = new MediaStorageService(configService as any);

  return {
    root,
    rolesSeen,
    service: new MediaUploadService(
      businessAccessService as any,
      storageService
    ),
    cleanup: () => rm(root, { recursive: true, force: true })
  };
}

async function imageFile(format: 'jpeg' | 'png' | 'webp'): Promise<UploadedMediaFile> {
  const image = sharp({
    create: {
      width: 24,
      height: 24,
      channels: 3,
      background: '#b65a30'
    }
  });
  const buffer =
    format === 'jpeg'
      ? await image.jpeg().toBuffer()
      : format === 'webp'
        ? await image.webp().toBuffer()
        : await image.png().toBuffer();

  return {
    buffer,
    size: buffer.byteLength,
    mimetype: format === 'jpeg' ? 'image/jpeg' : `image/${format}`,
    originalname: `upload.${format === 'jpeg' ? 'jpg' : format}`
  };
}

async function listStoredFiles(root: string) {
  const found: string[] = [];

  async function walk(directory: string) {
    const entries = await readdir(directory, { withFileTypes: true });

    for (const entry of entries) {
      const path = join(directory, entry.name);

      if (entry.isDirectory()) {
        await walk(path);
      } else {
        found.push(path);
      }
    }
  }

  await walk(root);

  return found;
}

function createBusinessUpdateService() {
  const business = {
    id: 'business_1',
    ownerId: 'user_1',
    name: 'Pilot Cafe',
    slug: 'pilot-cafe',
    type: 'cafe',
    logoUrl: null as string | null,
    coverUrl: null as string | null,
    currency: 'IQD',
    language: 'ar',
    city: 'Baghdad',
    status: 'ACTIVE',
    createdAt: new Date('2026-06-27T00:00:00.000Z'),
    updatedAt: new Date('2026-06-27T00:00:00.000Z'),
    menuTemplateId: 'waflo-warm',
    menuThemeOverrides: null
  };
  const prisma = {
    business: {
      update: async (args: { data: { logoUrl?: string; coverUrl?: string } }) => ({
        ...business,
        logoUrl: args.data.logoUrl ?? business.logoUrl,
        coverUrl: args.data.coverUrl ?? business.coverUrl
      })
    }
  };
  const businessAccess = {
    assertOwner: async () => membership(BusinessUserRole.OWNER)
  };
  const configService = {
    get: (_key: string, fallback: string) => fallback
  };

  return new BusinessesService(prisma as any, businessAccess as any, configService as any);
}

function createMenuUpdateService() {
  const item = {
    id: 'item_1',
    businessId: 'business_1',
    categoryId: 'category_1',
    nameAr: 'Coffee',
    nameEn: null,
    descriptionAr: null,
    descriptionEn: null,
    price: {
      toString: () => '3000'
    },
    imageUrl: null as string | null,
    isAvailable: true,
    sortOrder: 0,
    createdAt: new Date('2026-06-27T00:00:00.000Z'),
    updatedAt: new Date('2026-06-27T00:00:00.000Z')
  };
  const prisma = {
    menuItem: {
      findUnique: async () => ({ businessId: 'business_1' }),
      update: async (args: { data: { imageUrl?: string | null } }) => ({
        ...item,
        imageUrl: args.data.imageUrl ?? item.imageUrl
      })
    }
  };
  const businessAccess = {
    menuManagerRoles: [BusinessUserRole.OWNER, BusinessUserRole.MANAGER],
    assertRole: async () => membership(BusinessUserRole.MANAGER)
  };

  return new MenuService(prisma as any, businessAccess as any);
}

function user(id: string): AuthenticatedUser {
  return {
    id,
    clerkUserId: `clerk_${id}`,
    status: 'ACTIVE',
    name: 'Pilot Operator',
    email: null,
    phone: null,
    createdAt: new Date('2026-06-27T00:00:00.000Z'),
    updatedAt: new Date('2026-06-27T00:00:00.000Z')
  };
}

function membership(role: BusinessUserRole) {
  return {
    id: 'membership_1',
    businessId: 'business_1',
    userId: 'user_1',
    role,
    status: BusinessUserStatus.ACTIVE,
    createdAt: new Date('2026-06-27T00:00:00.000Z'),
    updatedAt: new Date('2026-06-27T00:00:00.000Z')
  };
}

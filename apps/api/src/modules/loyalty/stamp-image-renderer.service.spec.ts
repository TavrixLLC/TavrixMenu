import { BadRequestException } from '@nestjs/common';
import { strict as assert } from 'assert';
import { existsSync, readFileSync, statSync } from 'fs';
import { resolve } from 'path';
import sharp from 'sharp';
import { describe, it } from 'node:test';
import {
  StampImageRendererService,
  StampImageRenderInput
} from './stamp-image-renderer.service';
import { StampImageStorageService } from './stamp-image-storage.service';

describe('StampImageRendererService', () => {
  it('generates a PNG buffer', async () => {
    const renderer = new StampImageRendererService();
    const buffer = await renderer.renderPng(baseInput());
    const metadata = await sharp(buffer).metadata();

    assert.equal(buffer.subarray(1, 4).toString('ascii'), 'PNG');
    assert.equal(metadata.format, 'png');
    assert.equal(metadata.width, 1200);
    assert.equal(metadata.height, 628);
  });

  it('stores a generated PNG file with deterministic naming', async () => {
    const renderer = new StampImageRendererService();
    const storage = new StampImageStorageService(renderer);
    const stored = await storage.renderAndStore({
      ...baseInput({
        presetKey: 'COOKIE',
        stampCount: 3,
        stampGoal: 10
      }),
      membershipId: 'membership/test'
    });

    assert.match(
      stored.relativePath,
      /^wallet-stamps\/membership-test-[a-f0-9]{16}-3-10\.png$/
    );
    assert.equal(stored.localPublicPath, `/generated/${stored.relativePath}`);
    assert.equal(stored.publicUrl, null);
    assert.equal(existsSync(stored.absolutePath), true);
    assert.ok(statSync(stored.absolutePath).size > 1000);
  });

  it('builds an HTTPS public URL when a wallet image base URL is configured', async () => {
    const renderer = new StampImageRendererService();
    const storage = new StampImageStorageService(renderer);
    const stored = await storage.renderAndStore(
      {
        ...baseInput(),
        membershipId: 'membership-url'
      },
      {
        publicBaseUrl: 'https://api.waflo.app/generated/'
      }
    );

    assert.equal(
      stored.publicUrl,
      `https://api.waflo.app/generated/${stored.relativePath}`
    );
  });

  it('handles 0 stamps and full stamps', async () => {
    const renderer = new StampImageRendererService();
    const empty = await renderer.renderPng(
      baseInput({
        stampCount: 0
      })
    );
    const full = await renderer.renderPng(
      baseInput({
        stampCount: 10
      })
    );

    assert.ok(empty.length > 1000);
    assert.ok(full.length > 1000);
    assert.notEqual(empty.equals(full), true);
  });

  it('uses stamp filled and empty colors in the SVG render path', () => {
    const renderer = new StampImageRendererService() as unknown as {
      renderSvg(input: StampImageRenderInput): string;
      normalizeInput(input: StampImageRenderInput): StampImageRenderInput;
    };
    const normalized = renderer.normalizeInput(
      baseInput({
        stampCount: 1,
        stampFilledColor: '#abcdef',
        stampEmptyColor: '#123456'
      })
    );
    const svg = renderer.renderSvg(normalized);

    assert.match(svg, /#abcdef/);
    assert.match(svg, /#123456/);
  });

  it('rejects invalid preset, colors, and stamp goals above 10', async () => {
    const renderer = new StampImageRendererService();

    await assert.rejects(
      () =>
        renderer.renderPng(
          baseInput({
            presetKey: 'MOON' as never
          })
        ),
      BadRequestException
    );
    await assert.rejects(
      () =>
        renderer.renderPng(
          baseInput({
            accentColor: 'gold'
          })
        ),
      BadRequestException
    );
    await assert.rejects(
      () =>
        renderer.renderPng(
          baseInput({
            stampEmptyColor: 'sand'
          })
        ),
      BadRequestException
    );
    await assert.rejects(
      () =>
        renderer.renderPng(
          baseInput({
            themePreset: 'NEON' as never
          })
        ),
      BadRequestException
    );
    await assert.rejects(
      () =>
        renderer.renderPng(
          baseInput({
            stampGoal: 11
          })
        ),
      BadRequestException
    );
  });

  it('rejects negative stamp counts', async () => {
    const renderer = new StampImageRendererService();

    await assert.rejects(
      () =>
        renderer.renderPng(
          baseInput({
            stampCount: -1
          })
        ),
      BadRequestException
    );
  });

  it('changes style hash when visual style changes', () => {
    const renderer = new StampImageRendererService();
    const baseHash = renderer.buildStyleHash(baseInput());
    const presetHash = renderer.buildStyleHash(
      baseInput({
        presetKey: 'HEART'
      })
    );
    const colorHash = renderer.buildStyleHash(
      baseInput({
        accentColor: '#22c55e'
      })
    );
    const layoutHash = renderer.buildStyleHash(
      baseInput({
        layoutVariant: 'COMPACT'
      })
    );
    const themeColorHashes = [
      renderer.buildStyleHash(baseInput({ imageBackgroundColor: '#0f172a' })),
      renderer.buildStyleHash(baseInput({ imageSurfaceColor: '#334155' })),
      renderer.buildStyleHash(baseInput({ imageAccentColor: '#22c55e' })),
      renderer.buildStyleHash(baseInput({ imageTextColor: '#f8fafc' })),
      renderer.buildStyleHash(baseInput({ stampFilledColor: '#fde047' })),
      renderer.buildStyleHash(baseInput({ stampEmptyColor: '#94a3b8' })),
      renderer.buildStyleHash(baseInput({ rewardBannerColor: '#4f46e5' }))
    ];

    assert.notEqual(baseHash, presetHash);
    assert.notEqual(baseHash, colorHash);
    assert.notEqual(baseHash, layoutHash);
    for (const themeHash of themeColorHashes) {
      assert.notEqual(baseHash, themeHash);
    }
  });

  it('keeps generated stamp images in an ignored directory', () => {
    const gitignore = readFileSync(
      resolve(process.cwd(), '..', '..', '.gitignore'),
      'utf8'
    );

    assert.match(gitignore, /apps\/api\/public\/generated\//);
  });
});

function baseInput(
  overrides: Partial<StampImageRenderInput> = {}
): StampImageRenderInput {
  return {
    businessName: 'Tavrix Cafe',
    programName: 'Coffee Rewards',
    rewardName: 'Free coffee',
    stampCount: 3,
    stampGoal: 10,
    presetKey: 'COFFEE',
    backgroundColor: '#111827',
    accentColor: '#f59e0b',
    textColor: '#ffffff',
    imageBackgroundColor: '#111827',
    imageSurfaceColor: '#1f2937',
    imageAccentColor: '#f59e0b',
    imageTextColor: '#ffffff',
    stampFilledColor: '#f59e0b',
    stampEmptyColor: '#d6d3d1',
    rewardBannerColor: '#92400e',
    themePreset: 'COFFEE',
    layoutVariant: 'MODERN',
    ...overrides
  };
}

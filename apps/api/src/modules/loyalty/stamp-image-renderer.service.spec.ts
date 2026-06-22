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
import {
  resolveWalletPassVisual,
  resolveWalletPassVisualTheme
} from './wallet-pass-visual.resolver';

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

  it('uses one content structure and deterministic font stack for Apple and Google images', () => {
    const renderer = new StampImageRendererService() as unknown as {
      renderSvg(
        input: StampImageRenderInput,
        target?: 'GOOGLE_HERO' | 'APPLE_STRIP'
      ): string;
      normalizeInput(input: StampImageRenderInput): StampImageRenderInput;
    };
    const normalized = renderer.normalizeInput(
      baseInput({
        businessName: 'Cafe & Co ☕',
        programName: 'Rewards ★',
        rewardName: 'Free coffee ☕'
      })
    );
    const googleSvg = renderer.renderSvg(normalized, 'GOOGLE_HERO');
    const appleSvg = renderer.renderSvg(normalized, 'APPLE_STRIP');

    for (const svg of [googleSvg, appleSvg]) {
      assert.match(svg, /Cafe &amp; Co ☕/);
      assert.match(svg, /Rewards ★/);
      assert.match(svg, /3 \/ 10/);
      assert.match(svg, /Reward: Free coffee ☕/);
      assert.match(svg, /Noto Sans/);
      assert.match(svg, /Noto Color Emoji/);
      assert.doesNotMatch(svg, /Inter|Arial/);
      assert.doesNotMatch(svg, /waflo_scan_v1|authenticationToken/);
    }
  });

  it('keeps the progress badge inside the hero image safe area', () => {
    const renderer = new StampImageRendererService() as unknown as {
      getLayout(variant: 'MODERN' | 'COMPACT'): {
        width: number;
        height: number;
        badgeRadius: number;
        badgeTopSafePadding: number;
        badgeRightSafePadding: number;
      };
      getProgressBadge(layout: {
        width: number;
        height: number;
        badgeRadius: number;
        badgeTopSafePadding: number;
        badgeRightSafePadding: number;
      }): {
        cx: number;
        cy: number;
        radius: number;
        labelY: number;
        valueY: number;
      };
    };

    for (const variant of ['MODERN', 'COMPACT'] as const) {
      const layout = renderer.getLayout(variant);
      const badge = renderer.getProgressBadge(layout);

      assert.ok(badge.cx - badge.radius >= 0);
      assert.ok(badge.cy - badge.radius >= layout.badgeTopSafePadding);
      assert.ok(
        layout.width - (badge.cx + badge.radius) >=
          layout.badgeRightSafePadding
      );
      assert.ok(badge.labelY > badge.cy - badge.radius);
      assert.ok(badge.valueY < badge.cy + badge.radius);
    }
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

  it('keeps safe-area badge placement out of the deterministic style hash', () => {
    const renderer = new StampImageRendererService();

    assert.equal(renderer.buildStyleHash(baseInput()), 'b8bb83b189cbaaee');
  });

  it('keeps generated stamp images in an ignored directory', () => {
    const gitignore = readFileSync(
      resolve(process.cwd(), '..', '..', '.gitignore'),
      'utf8'
    );

    assert.match(gitignore, /apps\/api\/public\/generated\//);
  });
});

describe('wallet pass visual resolver', () => {
  it('keeps native and generated colors in one custom theme', () => {
    const theme = resolveWalletPassVisualTheme({
      cardColor: '#123abc',
      accentColor: '#facc15',
      stampStyle: null
    });
    const visual = resolveWalletPassVisual({
      businessName: 'Tavrix Cafe',
      programName: 'Coffee Rewards',
      rewardName: 'Free coffee',
      stampCount: 3,
      stampGoal: 5,
      theme
    });

    assert.equal(visual.theme.walletBackgroundColor, '#123abc');
    assert.equal(visual.theme.imageBackgroundColor, '#123abc');
    assert.equal(visual.theme.imageAccentColor, '#facc15');
    assert.equal(visual.theme.stampFilledColor, '#facc15');
    assert.equal(visual.progressText, '3 / 5');
    assert.equal(visual.progressHeadline, '2 stamps to reward');
  });

  it('normalizes the legacy split default palette to the coherent default palette', () => {
    const theme = resolveWalletPassVisualTheme({
      cardColor: null,
      accentColor: null,
      stampStyle: {
        presetKey: 'STAR',
        backgroundColor: '#111827',
        accentColor: '#f59e0b',
        textColor: '#ffffff',
        walletBackgroundColor: '#2563eb',
        imageBackgroundColor: '#7c2d12',
        imageSurfaceColor: '#92400e',
        imageAccentColor: '#facc15',
        imageTextColor: '#ffffff',
        stampFilledColor: '#facc15',
        stampEmptyColor: '#d6d3d1',
        rewardBannerColor: '#a16207',
        themePreset: 'DEFAULT',
        layoutVariant: 'MODERN'
      }
    });

    assert.equal(theme.walletBackgroundColor, '#2563eb');
    assert.equal(theme.imageBackgroundColor, '#1d4ed8');
    assert.equal(theme.imageSurfaceColor, '#2563eb');
    assert.equal(theme.rewardBannerColor, '#1e40af');
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

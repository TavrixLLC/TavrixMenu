import { Injectable, Optional } from '@nestjs/common';
import sharp from 'sharp';
import {
  AppleWalletPassAssets,
  AppleWalletPassPayload,
  BuildAppleWalletPassInput
} from './apple-wallet.types';
import { StampImageRendererService } from '../loyalty/stamp-image-renderer.service';
import {
  resolveWalletPassVisual,
  WalletPassVisualTheme
} from '../loyalty/wallet-pass-visual.resolver';

const qrAltText = 'Scan at checkout';

@Injectable()
export class AppleWalletPassBuilderService {
  constructor(
    @Optional()
    private readonly stampImageRenderer = new StampImageRendererService()
  ) {}

  buildPayload(input: BuildAppleWalletPassInput): AppleWalletPassPayload {
    this.assertProgress(input.stampCount, input.stampGoal);

    const visual = this.resolveVisual(input);
    const applePalette = this.resolveApplePalette(visual.theme);
    const businessName = this.safeText(visual.businessName, 'Waflo', 24);
    const programName = this.safeText(visual.programName, 'Loyalty Card', 40);
    const rewardName = this.safeText(visual.rewardName, 'Reward', 42);
    const remaining = Math.max(input.stampGoal - input.stampCount, 0);
    const status =
      remaining === 0
        ? 'Ready to redeem'
        : `${remaining} ${remaining === 1 ? 'stamp' : 'stamps'} to reward`;
    const rewardDescription = this.safeText(
      input.rewardDescription,
      rewardName,
      140
    );
    const backgroundColor = this.toRgb(
      applePalette.background,
      applePalette.background
    );
    const foregroundColor = this.toRgb(
      applePalette.text,
      applePalette.text
    );
    const labelColor = this.toRgb(
      applePalette.label,
      applePalette.label
    );
    const barcode = {
      format: 'PKBarcodeFormatQR' as const,
      message: input.barcodeValue,
      messageEncoding: 'iso-8859-1' as const,
      altText: qrAltText
    };

    return {
      formatVersion: 1,
      passTypeIdentifier: input.passTypeIdentifier,
      serialNumber: input.serialNumber,
      teamIdentifier: input.teamIdentifier,
      organizationName: input.organizationName,
      description: this.safeText(
        `${businessName} ${programName} loyalty card`,
        'Waflo loyalty card',
        80
      ),
      logoText: businessName,
      foregroundColor,
      backgroundColor,
      labelColor,
      suppressStripShine: true,
      sharingProhibited: true,
      ...(input.webServiceURL && input.authenticationToken
        ? {
            webServiceURL: input.webServiceURL,
            authenticationToken: input.authenticationToken
          }
        : {}),
      storeCard: {
        headerFields: [
          {
            key: 'progress',
            label: 'STAMPS',
            value: `${Math.min(input.stampCount, input.stampGoal)} / ${input.stampGoal}`,
            textAlignment: 'PKTextAlignmentRight'
          }
        ],
        primaryFields: [],
        secondaryFields: [
          {
            key: 'reward',
            label: 'REWARD',
            value: rewardName
          }
        ],
        auxiliaryFields: [
          {
            key: 'status',
            label: 'STATUS',
            value: status
          }
        ],
        backFields: [
          ...this.buildBackFields({
            businessName,
            programName,
            programDescription: input.programDescription,
            rewardName,
            rewardDescription,
            terms: input.terms,
            stampGoal: input.stampGoal
          })
        ]
      },
      barcodes: [barcode]
    };
  }

  async buildAssets(
    input: BuildAppleWalletPassInput
  ): Promise<AppleWalletPassAssets> {
    this.assertProgress(input.stampCount, input.stampGoal);
    const visual = this.resolveVisual(input);
    const applePalette = this.resolveApplePalette(visual.theme);

    const icon = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="87" height="87" viewBox="0 0 87 87"><rect width="87" height="87" rx="18" fill="${applePalette.background}"/><path d="M19 24h10l7 35 8-25 8 25 7-35h10L58 66H48l-8-23-8 23H22z" fill="${applePalette.accent}"/></svg>`
    );
    const logo = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100"><rect width="100" height="100" rx="24" fill="${applePalette.surface}"/><path d="M18 22h13l8 43 10-31 10 31 9-43h14L68 79H55L48 54l-8 25H27z" fill="${applePalette.accent}"/></svg>`
    );

    const strip3x = await this.stampImageRenderer.renderAppleStripPng({
      businessName: this.safeText(
        visual.businessName,
        input.organizationName,
        64
      ),
      programName: this.safeText(visual.programName, 'Waflo Loyalty', 64),
      rewardName: this.safeText(
        visual.rewardName,
        input.rewardDescription ?? 'Reward',
        72
      ),
      stampCount: visual.stampCount,
      stampGoal: visual.stampGoal,
      presetKey: visual.theme.presetKey,
      backgroundColor: visual.theme.backgroundColor,
      accentColor: visual.theme.accentColor,
      textColor: visual.theme.textColor,
      imageBackgroundColor: applePalette.stripBackground,
      imageSurfaceColor: applePalette.surface,
      imageAccentColor: applePalette.accent,
      imageTextColor: applePalette.text,
      stampFilledColor: visual.theme.stampFilledColor,
      stampEmptyColor: visual.theme.stampEmptyColor,
      rewardBannerColor: applePalette.surface,
      themePreset: visual.theme.themePreset,
      layoutVariant: visual.theme.layoutVariant
    });

    const [
      icon1x,
      icon2x,
      icon3x,
      logo1x,
      logo2x,
      logo3x,
      strip1x,
      strip2x
    ] = await Promise.all([
      this.renderPng(icon, 29, 29),
      this.renderPng(icon, 58, 58),
      this.renderPng(icon, 87, 87),
      this.renderPng(logo, 50, 50),
      this.renderPng(logo, 100, 100),
      this.renderPng(logo, 150, 150),
      this.renderPng(strip3x, 375, 123),
      this.renderPng(strip3x, 750, 246)
    ]);

    return {
      'icon.png': icon1x,
      'icon@2x.png': icon2x,
      'icon@3x.png': icon3x,
      'logo.png': logo1x,
      'logo@2x.png': logo2x,
      'logo@3x.png': logo3x,
      'strip.png': strip1x,
      'strip@2x.png': strip2x,
      'strip@3x.png': strip3x
    };
  }

  private buildBackFields(input: {
    businessName: string;
    programName: string;
    programDescription?: string;
    rewardName: string;
    rewardDescription: string;
    terms?: string;
    stampGoal: number;
  }) {
    const overview = this.safeText(
      input.programDescription,
      `Collect ${input.stampGoal} stamps at ${input.businessName} to earn ${input.rewardName}.`,
      220
    );
    const fields = [
      {
        key: 'programDetails',
        label: input.programName.toUpperCase(),
        value: overview
      },
      {
        key: 'rewardDetails',
        label: 'REWARD DETAILS',
        value: input.rewardDescription
      }
    ];
    const terms = this.safeText(input.terms, '', 500);

    return terms
      ? [...fields, { key: 'terms', label: 'TERMS', value: terms }]
      : fields;
  }

  private resolveVisual(input: BuildAppleWalletPassInput) {
    return resolveWalletPassVisual({
      businessName: input.businessName,
      programName: input.programName,
      rewardName:
        input.rewardName ?? `Reward after ${input.stampGoal} stamps`,
      stampCount: input.stampCount,
      stampGoal: input.stampGoal,
      theme: input.theme
    });
  }

  private renderPng(source: Buffer, width: number, height: number) {
    return sharp(source).resize(width, height).png().toBuffer();
  }

  private resolveApplePalette(theme: WalletPassVisualTheme) {
    const background = this.mixHex(
      theme.walletBackgroundColor,
      '#000000',
      0.2
    );
    const stripBackground = this.mixHex(
      theme.imageBackgroundColor,
      '#000000',
      0.14
    );
    const surface = this.mixHex(
      theme.imageSurfaceColor,
      stripBackground,
      0.28
    );
    const text = this.readableText(background, theme.imageTextColor);

    return {
      background,
      stripBackground,
      surface,
      accent: theme.imageAccentColor,
      text,
      label: this.mixHex(text, background, 0.38)
    };
  }

  private readableText(background: string, preferred: string) {
    const candidates = [preferred, '#ffffff', '#111827'];
    return candidates.reduce((best, candidate) =>
      this.contrastRatio(background, candidate) >
      this.contrastRatio(background, best)
        ? candidate
        : best
    );
  }

  private contrastRatio(left: string, right: string) {
    const leftLuminance = this.relativeLuminance(left);
    const rightLuminance = this.relativeLuminance(right);
    const lighter = Math.max(leftLuminance, rightLuminance);
    const darker = Math.min(leftLuminance, rightLuminance);

    return (lighter + 0.05) / (darker + 0.05);
  }

  private relativeLuminance(value: string) {
    const channels = this.hexChannels(value).map((channel) => {
      const normalized = channel / 255;
      return normalized <= 0.03928
        ? normalized / 12.92
        : Math.pow((normalized + 0.055) / 1.055, 2.4);
    });

    return channels[0] * 0.2126 + channels[1] * 0.7152 + channels[2] * 0.0722;
  }

  private mixHex(base: string, overlay: string, amount: number) {
    const baseChannels = this.hexChannels(base);
    const overlayChannels = this.hexChannels(overlay);

    return `#${baseChannels
      .map((channel, index) =>
        Math.round(
          channel * (1 - amount) + overlayChannels[index] * amount
        )
          .toString(16)
          .padStart(2, '0')
      )
      .join('')}`;
  }

  private hexChannels(value: string) {
    const hex = this.normalizeHex(value, '#000000').slice(1);
    return [
      Number.parseInt(hex.slice(0, 2), 16),
      Number.parseInt(hex.slice(2, 4), 16),
      Number.parseInt(hex.slice(4, 6), 16)
    ];
  }

  private assertProgress(stampCount: number, stampGoal: number) {
    if (!Number.isInteger(stampCount) || stampCount < 0) {
      throw new Error('stampCount must be a non-negative integer');
    }

    if (!Number.isInteger(stampGoal) || stampGoal < 1 || stampGoal > 12) {
      throw new Error('stampGoal must be between 1 and 12');
    }
  }

  private safeText(value: string | undefined, fallback: string, max: number) {
    const normalized = (value ?? fallback)
      .replace(/[\u0000-\u001f\u007f]/g, ' ')
      .replace(/\p{Extended_Pictographic}/gu, ' ')
      .replace(/[\u200d\ufe0e\ufe0f]/g, '')
      .replace(/\s+/g, ' ')
      .trim();
    const characters = Array.from(normalized || fallback);

    return characters.slice(0, max).join('');
  }

  private normalizeHex(value: string | undefined, fallback: string) {
    const normalized = value?.trim();
    if (!normalized || !/^#(?:[0-9a-f]{3}|[0-9a-f]{6})$/i.test(normalized)) {
      return fallback;
    }

    if (normalized.length === 4) {
      return `#${normalized
        .slice(1)
        .split('')
        .map((character) => character.repeat(2))
        .join('')}`.toLowerCase();
    }

    return normalized.toLowerCase();
  }

  private toRgb(value: string | undefined, fallback: string) {
    const hex = this.normalizeHex(value, fallback).slice(1);
    return `rgb(${Number.parseInt(hex.slice(0, 2), 16)}, ${Number.parseInt(hex.slice(2, 4), 16)}, ${Number.parseInt(hex.slice(4, 6), 16)})`;
  }
}

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
  WalletPassVisualModel
} from '../loyalty/wallet-pass-visual.resolver';

const qrAltText = 'Scan loyalty card';

@Injectable()
export class AppleWalletPassBuilderService {
  constructor(
    @Optional()
    private readonly stampImageRenderer = new StampImageRendererService()
  ) {}

  buildPayload(input: BuildAppleWalletPassInput): AppleWalletPassPayload {
    this.assertProgress(input.stampCount, input.stampGoal);

    const visual = this.resolveVisual(input);
    const businessName = this.safeText(visual.businessName, 'Waflo', 36);
    const programName = this.safeText(visual.programName, 'Loyalty Card', 40);
    const rewardName = this.safeText(visual.rewardName, 'Reward', 42);
    const rewardDescription = this.safeText(
      input.rewardDescription,
      rewardName,
      140
    );
    const backgroundColor = this.toRgb(
      visual.theme.walletBackgroundColor,
      visual.theme.walletBackgroundColor
    );
    const foregroundColor = this.toRgb(
      visual.theme.imageTextColor,
      visual.theme.imageTextColor
    );
    const labelColor = this.toRgb(
      visual.theme.imageAccentColor,
      visual.theme.imageAccentColor
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
        headerFields: [],
        primaryFields: [],
        secondaryFields: [],
        auxiliaryFields: [],
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
    const theme = {
      background: visual.theme.imageBackgroundColor,
      accent: visual.theme.imageAccentColor
    };
    const icon = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="87" height="87" viewBox="0 0 87 87"><rect width="87" height="87" rx="18" fill="${theme.background}"/><path d="M19 24h10l7 35 8-25 8 25 7-35h10L58 66H48l-8-23-8 23H22z" fill="${theme.accent}"/></svg>`
    );
    const logo = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 87 87"><circle cx="43.5" cy="43.5" r="39" fill="${theme.accent}"/><path d="M19 24h10l7 35 8-25 8 25 7-35h10L58 66H48l-8-23-8 23H22z" fill="${theme.background}"/></svg>`
    );
    const [
      icon1x,
      icon2x,
      icon3x,
      logo1x,
      logo2x,
      logo3x,
      strip1x,
      strip2x,
      strip3x
    ] = await Promise.all([
      this.renderPng(icon, 29, 29),
      this.renderPng(icon, 58, 58),
      this.renderPng(icon, 87, 87),
      this.renderPng(logo, 50, 50),
      this.renderPng(logo, 100, 100),
      this.renderPng(logo, 150, 150),
      this.stampImageRenderer.renderPng(this.buildStampImageInput(visual), {
        target: 'APPLE_STRIP',
        width: 375,
        height: 123
      }),
      this.stampImageRenderer.renderPng(this.buildStampImageInput(visual), {
        target: 'APPLE_STRIP',
        width: 750,
        height: 246
      }),
      this.stampImageRenderer.renderPng(this.buildStampImageInput(visual), {
        target: 'APPLE_STRIP',
        width: 1125,
        height: 369
      })
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
      },
      {
        key: 'latestProgress',
        label: 'LATEST PROGRESS',
        value:
          'Open your Waflo web loyalty card to see current stamp and reward progress.'
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

  private buildStampImageInput(visual: WalletPassVisualModel) {
    return {
      businessName: visual.businessName,
      programName: visual.programName,
      rewardName: visual.rewardName,
      stampCount: visual.stampCount,
      stampGoal: visual.stampGoal,
      ...visual.theme
    };
  }

  private renderPng(source: Buffer, width: number, height: number) {
    return sharp(source).resize(width, height).png().toBuffer();
  }

  private assertProgress(stampCount: number, stampGoal: number) {
    if (!Number.isInteger(stampCount) || stampCount < 0) {
      throw new Error('stampCount must be a non-negative integer');
    }

    if (!Number.isInteger(stampGoal) || stampGoal <= 0) {
      throw new Error('stampGoal must be a positive integer');
    }
  }

  private safeText(value: string | undefined, fallback: string, max: number) {
    const normalized = value?.replace(/[\u0000-\u001f\u007f]/g, ' ').trim();
    return (normalized || fallback).slice(0, max);
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

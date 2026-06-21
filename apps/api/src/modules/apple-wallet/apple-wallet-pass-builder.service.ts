import { Injectable } from '@nestjs/common';
import sharp from 'sharp';
import {
  AppleWalletPassAssets,
  AppleWalletPassPayload,
  BuildAppleWalletPassInput
} from './apple-wallet.types';
import { DEFAULT_LOYALTY_STAMP_STYLE } from '../loyalty/loyalty-stamp-style.constants';

const qrAltText = 'Scan loyalty card';

@Injectable()
export class AppleWalletPassBuilderService {
  buildPayload(input: BuildAppleWalletPassInput): AppleWalletPassPayload {
    this.assertProgress(input.stampCount, input.stampGoal);

    const businessName = this.safeText(input.businessName, 'Waflo', 36);
    const programName = this.safeText(input.programName, 'Loyalty Card', 40);
    const rewardName = this.safeText(
      input.rewardName,
      `Reward after ${input.stampGoal} stamps`,
      42
    );
    const rewardDescription = this.safeText(
      input.rewardDescription,
      rewardName,
      140
    );
    const rewardReady = input.stampCount >= input.stampGoal;
    const stampsRemaining = Math.max(input.stampGoal - input.stampCount, 0);
    const backgroundColor = this.toRgb(
      input.theme?.walletBackgroundColor,
      DEFAULT_LOYALTY_STAMP_STYLE.walletBackgroundColor
    );
    const foregroundColor = this.toRgb(
      input.theme?.imageTextColor,
      DEFAULT_LOYALTY_STAMP_STYLE.imageTextColor
    );
    const labelColor = this.toRgb(
      input.theme?.imageAccentColor,
      DEFAULT_LOYALTY_STAMP_STYLE.imageAccentColor
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
            key: 'stamps',
            label: 'STAMPS',
            value: `${input.stampCount} / ${input.stampGoal}`,
            textAlignment: 'PKTextAlignmentRight'
          }
        ],
        primaryFields: [
          {
            key: 'rewardStatus',
            label: 'NEXT REWARD',
            value: rewardReady
              ? 'Reward ready'
              : `${stampsRemaining} ${stampsRemaining === 1 ? 'stamp' : 'stamps'} to go`
          }
        ],
        secondaryFields: [
          {
            key: 'reward',
            label: 'REWARD',
            value: rewardName
          }
        ],
        auxiliaryFields: [
          {
            key: 'program',
            label: 'PROGRAM',
            value: programName
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
    const theme = this.resolveTheme(input);
    const icon = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="87" height="87" viewBox="0 0 87 87"><rect width="87" height="87" rx="18" fill="${theme.background}"/><path d="M19 24h10l7 35 8-25 8 25 7-35h10L58 66H48l-8-23-8 23H22z" fill="${theme.accent}"/></svg>`
    );
    const logo = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="150" height="150" viewBox="0 0 87 87"><circle cx="43.5" cy="43.5" r="39" fill="${theme.accent}"/><path d="M19 24h10l7 35 8-25 8 25 7-35h10L58 66H48l-8-23-8 23H22z" fill="${theme.background}"/></svg>`
    );
    const strip = Buffer.from(this.buildStripSvg(input, theme));

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
      this.renderPng(strip, 375, 123),
      this.renderPng(strip, 750, 246),
      this.renderPng(strip, 1125, 369)
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

  private resolveTheme(input: BuildAppleWalletPassInput) {
    return {
      background: this.normalizeHex(
        input.theme?.imageBackgroundColor ??
          input.theme?.walletBackgroundColor,
        DEFAULT_LOYALTY_STAMP_STYLE.imageBackgroundColor
      ),
      surface: this.normalizeHex(
        input.theme?.imageSurfaceColor,
        DEFAULT_LOYALTY_STAMP_STYLE.imageSurfaceColor
      ),
      accent: this.normalizeHex(
        input.theme?.imageAccentColor,
        DEFAULT_LOYALTY_STAMP_STYLE.imageAccentColor
      ),
      text: this.normalizeHex(
        input.theme?.imageTextColor,
        DEFAULT_LOYALTY_STAMP_STYLE.imageTextColor
      ),
      filled: this.normalizeHex(
        input.theme?.stampFilledColor,
        DEFAULT_LOYALTY_STAMP_STYLE.stampFilledColor
      ),
      empty: this.normalizeHex(
        input.theme?.stampEmptyColor,
        DEFAULT_LOYALTY_STAMP_STYLE.stampEmptyColor
      )
    };
  }

  private buildStripSvg(
    input: BuildAppleWalletPassInput,
    theme: ReturnType<AppleWalletPassBuilderService['resolveTheme']>
  ) {
    const count = Math.min(input.stampCount, input.stampGoal);
    const markers = this.buildProgressMarkers(
      count,
      input.stampGoal,
      theme
    );

    return [
      '<svg xmlns="http://www.w3.org/2000/svg" width="750" height="246" viewBox="0 0 750 246">',
      '<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">',
      `<stop offset="0%" stop-color="${theme.background}"/><stop offset="100%" stop-color="${theme.surface}"/>`,
      '</linearGradient></defs>',
      '<rect width="750" height="246" fill="url(#bg)"/>',
      `<circle cx="690" cy="-35" r="190" fill="${theme.accent}" fill-opacity="0.08"/>`,
      `<circle cx="48" cy="268" r="155" fill="${theme.text}" fill-opacity="0.04"/>`,
      `<rect x="30" y="150" width="690" height="84" rx="42" fill="${theme.text}" fill-opacity="0.07"/>`,
      markers,
      '</svg>'
    ].join('');
  }

  private buildProgressMarkers(
    count: number,
    goal: number,
    theme: ReturnType<AppleWalletPassBuilderService['resolveTheme']>
  ) {
    if (goal > 12) {
      const width = 666;
      const progress = Math.round((Math.min(count, goal) / goal) * width);
      return `<rect x="42" y="176" width="${width}" height="32" rx="16" fill="${theme.empty}" fill-opacity="0.48"/><rect x="42" y="176" width="${progress}" height="32" rx="16" fill="${theme.filled}"/>`;
    }

    const gap = 12;
    const diameter = Math.min(44, (666 - gap * (goal - 1)) / goal);
    const radius = diameter / 2;
    const totalWidth = goal * diameter + (goal - 1) * gap;
    const startX = (750 - totalWidth) / 2 + radius;
    return Array.from({ length: goal }, (_, index) => {
      const x = startX + index * (diameter + gap);
      const fill = index < count ? theme.filled : theme.empty;
      const opacity = index < count ? 1 : 0.48;
      return `<circle cx="${x}" cy="192" r="${radius}" fill="${fill}" fill-opacity="${opacity}" stroke="${theme.text}" stroke-opacity="0.18" stroke-width="2"/>`;
    }).join('');
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

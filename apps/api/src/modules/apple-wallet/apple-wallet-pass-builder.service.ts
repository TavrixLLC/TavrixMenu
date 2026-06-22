import { Injectable } from '@nestjs/common';
import sharp from 'sharp';
import { DEFAULT_LOYALTY_STAMP_STYLE } from '../loyalty/loyalty-stamp-style.constants';
import { StampImageRendererService } from '../loyalty/stamp-image-renderer.service';
import {
  AppleWalletPassAssets,
  AppleWalletPassPayload,
  BuildAppleWalletPassInput
} from './apple-wallet.types';

const qrAltText = 'Scan to update loyalty';

@Injectable()
export class AppleWalletPassBuilderService {
  constructor(
    private readonly stampImageRenderer: StampImageRendererService
  ) {}

  buildPayload(input: BuildAppleWalletPassInput): AppleWalletPassPayload {
    this.assertProgress(input.stampCount, input.stampGoal);

    const businessName = this.safeText(
      input.businessName,
      input.organizationName,
      32
    );
    const programName = this.safeText(input.programName, 'Waflo Loyalty', 40);
    const rewardName = this.safeText(
      input.rewardName,
      `Reward after ${input.stampGoal} stamps`,
      48
    );
    const rewardDescription = this.safeText(
      input.rewardDescription,
      rewardName,
      80
    );
    const visualStyle =
      input.visualStyle ?? DEFAULT_LOYALTY_STAMP_STYLE;
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
      description: `${programName} loyalty pass`,
      logoText: businessName,
      foregroundColor: this.hexToRgbString(visualStyle.imageTextColor),
      backgroundColor: this.hexToRgbString(
        visualStyle.walletBackgroundColor
      ),
      labelColor: this.hexToRgbString(visualStyle.imageAccentColor),
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
          {
            key: 'reward',
            label: 'REWARD',
            value: rewardDescription
          },
          {
            key: 'howItWorks',
            label: 'HOW IT WORKS',
            value: 'Collect stamps and redeem the active loyalty reward.'
          }
        ]
      },
      barcodes: [barcode]
    };
  }

  async buildAssets(
    input: BuildAppleWalletPassInput
  ): Promise<AppleWalletPassAssets> {
    const visualStyle =
      input.visualStyle ?? DEFAULT_LOYALTY_STAMP_STYLE;
    const icon = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="87" height="87" viewBox="0 0 87 87"><rect width="87" height="87" rx="18" fill="${visualStyle.walletBackgroundColor}"/><path d="M19 24h10l7 35 8-25 8 25 7-35h10L58 66H48l-8-23-8 23H22z" fill="${visualStyle.imageAccentColor}"/></svg>`
    );
    const logo = Buffer.from(
      `<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100"><rect width="100" height="100" rx="24" fill="${visualStyle.imageSurfaceColor}"/><path d="M18 22h13l8 43 10-31 10 31 9-43h14L68 79H55L48 54l-8 25H27z" fill="${visualStyle.imageAccentColor}"/></svg>`
    );
    const strip3x = await this.stampImageRenderer.renderAppleStripPng({
      businessName: this.safeText(
        input.businessName,
        input.organizationName,
        64
      ),
      programName: this.safeText(input.programName, 'Waflo Loyalty', 64),
      rewardName: this.safeText(
        input.rewardName,
        input.rewardDescription ?? 'Reward',
        72
      ),
      stampCount: input.stampCount,
      stampGoal: input.stampGoal,
      presetKey: visualStyle.presetKey,
      backgroundColor: visualStyle.backgroundColor,
      accentColor: visualStyle.accentColor,
      textColor: visualStyle.textColor,
      imageBackgroundColor: visualStyle.imageBackgroundColor,
      imageSurfaceColor: visualStyle.imageSurfaceColor,
      imageAccentColor: visualStyle.imageAccentColor,
      imageTextColor: visualStyle.imageTextColor,
      stampFilledColor: visualStyle.stampFilledColor,
      stampEmptyColor: visualStyle.stampEmptyColor,
      rewardBannerColor: visualStyle.rewardBannerColor,
      themePreset: visualStyle.themePreset,
      layoutVariant: visualStyle.layoutVariant
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

  private renderPng(source: Buffer, width: number, height: number) {
    return sharp(source).resize(width, height).png().toBuffer();
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

  private hexToRgbString(value: string) {
    const normalized =
      value.length === 4
        ? `#${value[1]}${value[1]}${value[2]}${value[2]}${value[3]}${value[3]}`
        : value;
    const red = Number.parseInt(normalized.slice(1, 3), 16);
    const green = Number.parseInt(normalized.slice(3, 5), 16);
    const blue = Number.parseInt(normalized.slice(5, 7), 16);

    return `rgb(${red}, ${green}, ${blue})`;
  }
}

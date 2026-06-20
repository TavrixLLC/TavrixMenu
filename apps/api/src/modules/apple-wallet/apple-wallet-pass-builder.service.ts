import { Injectable } from '@nestjs/common';
import sharp from 'sharp';
import {
  AppleWalletPassAssets,
  AppleWalletPassPayload,
  BuildAppleWalletPassInput
} from './apple-wallet.types';

const qrAltText = 'Scan to update loyalty';

@Injectable()
export class AppleWalletPassBuilderService {
  buildPayload(input: BuildAppleWalletPassInput): AppleWalletPassPayload {
    this.assertProgress(input.stampCount, input.stampGoal);

    const programName = this.safeText(input.programName, 'Waflo Loyalty', 40);
    const rewardDescription = this.safeText(
      input.rewardDescription,
      `Reward after ${input.stampGoal} stamps`,
      80
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
      description: `${programName} loyalty pass`,
      logoText: programName,
      foregroundColor: 'rgb(255, 255, 255)',
      backgroundColor: 'rgb(124, 45, 18)',
      labelColor: 'rgb(253, 230, 138)',
      sharingProhibited: true,
      storeCard: {
        headerFields: [
          {
            key: 'stamps',
            label: 'STAMPS',
            value: `${input.stampCount}/${input.stampGoal}`
          }
        ],
        primaryFields: [
          {
            key: 'progress',
            label: 'LOYALTY PROGRESS',
            value: `${input.stampCount} of ${input.stampGoal} stamps`
          }
        ],
        secondaryFields: [
          {
            key: 'reward',
            label: 'REWARD',
            value: rewardDescription
          }
        ],
        auxiliaryFields: [
          {
            key: 'member',
            label: 'MEMBER',
            value: 'Loyalty member'
          }
        ],
        backFields: [
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

  async buildAssets(): Promise<AppleWalletPassAssets> {
    const icon = Buffer.from(
      '<svg xmlns="http://www.w3.org/2000/svg" width="87" height="87" viewBox="0 0 87 87"><rect width="87" height="87" rx="18" fill="#7c2d12"/><path d="M19 24h10l7 35 8-25 8 25 7-35h10L58 66H48l-8-23-8 23H22z" fill="#facc15"/></svg>'
    );
    const logo = Buffer.from(
      '<svg xmlns="http://www.w3.org/2000/svg" width="320" height="100" viewBox="0 0 320 100"><rect width="320" height="100" fill="none"/><text x="8" y="70" fill="#ffffff" font-family="Arial,sans-serif" font-size="64" font-weight="700">Waflo</text></svg>'
    );

    const [icon1x, icon2x, icon3x, logo1x, logo2x] = await Promise.all([
      this.renderPng(icon, 29, 29),
      this.renderPng(icon, 58, 58),
      this.renderPng(icon, 87, 87),
      this.renderPng(logo, 160, 50),
      this.renderPng(logo, 320, 100)
    ]);

    return {
      'icon.png': icon1x,
      'icon@2x.png': icon2x,
      'icon@3x.png': icon3x,
      'logo.png': logo1x,
      'logo@2x.png': logo2x
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
}

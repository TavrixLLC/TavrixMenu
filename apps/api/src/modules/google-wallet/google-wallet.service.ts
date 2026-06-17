import { Inject, Injectable, Optional } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createSign } from 'crypto';
import { readFileSync } from 'fs';
import { isAbsolute, resolve } from 'path';
import { StampImageStorageService } from '../loyalty/stamp-image-storage.service';
import {
  GOOGLE_WALLET_API_CLIENT,
  GoogleWalletApiClient,
  GoogleWalletApiError
} from './google-wallet-api.client';
import {
  BuildLoyaltyClassPayloadInput,
  BuildLoyaltyObjectPayloadInput,
  GenerateSaveJwtInput,
  GoogleWalletImage,
  GoogleWalletLocalizedString,
  GoogleWalletLoyaltyClassPayload,
  GoogleWalletLoyaltyObjectPayload
} from './google-wallet.types';

type ServiceAccountCredentials = {
  client_email: string;
  private_key: string;
};

type WalletResource = {
  id: string;
};

const defaultLogoUrl =
  'https://placehold.co/512x512/2463eb/ffffff.png?text=Waflo';

const smokeWalletTheme = {
  walletBackgroundColor: '#7c2d12',
  imageBackgroundColor: '#7c2d12',
  imageSurfaceColor: '#92400e',
  imageAccentColor: '#facc15',
  imageTextColor: '#ffffff',
  stampFilledColor: '#facc15',
  stampEmptyColor: '#d6d3d1',
  rewardBannerColor: '#a16207',
  themePreset: 'COFFEE'
} as const;

@Injectable()
export class GoogleWalletService {
  constructor(
    private readonly configService: ConfigService,
    @Inject(GOOGLE_WALLET_API_CLIENT)
    private readonly apiClient: GoogleWalletApiClient,
    @Optional()
    private readonly stampImageStorageService?: StampImageStorageService
  ) {}

  buildLoyaltyClassPayload(
    input: BuildLoyaltyClassPayloadInput
  ): GoogleWalletLoyaltyClassPayload {
    this.assertEnabled();

    const programName = input.programName?.trim() || 'Waflo Rewards';
    const issuerName = input.issuerName?.trim() || 'Waflo';
    const rewardDescription =
      input.rewardDescription?.trim() || 'Collect stamps toward your reward.';

    return {
      id: this.buildResourceId(input.classSuffix),
      issuerName,
      reviewStatus: 'UNDER_REVIEW',
      programName,
      programLogo: this.buildImage(
        input.logoUrl?.trim() || defaultLogoUrl,
        `${programName} logo`
      ),
      accountNameLabel: input.accountNameLabel?.trim() || 'Member',
      accountIdLabel: input.accountIdLabel?.trim() || 'Member ID',
      rewardsTierLabel: input.rewardsTierLabel?.trim() || 'Tier',
      rewardsTier: input.rewardsTier?.trim() || 'Member',
      hexBackgroundColor: this.normalizeHexColor(
        input.hexBackgroundColor?.trim() || '#2463eb'
      ),
      textModulesData: [
        {
          id: 'reward',
          header: 'Reward',
          body: rewardDescription
        }
      ]
    };
  }

  buildSmokeLoyaltyClassPayload(input: {
    classSuffix: string;
    logoUrl?: string;
  }) {
    return this.buildLoyaltyClassPayload({
      classSuffix: input.classSuffix,
      issuerName: 'Waflo',
      programName: 'Waflo',
      logoUrl: input.logoUrl,
      rewardDescription: 'Free reward after 10 stamps.',
      hexBackgroundColor: smokeWalletTheme.walletBackgroundColor
    });
  }

  buildLoyaltyObjectPayload(
    input: BuildLoyaltyObjectPayloadInput
  ): GoogleWalletLoyaltyObjectPayload {
    this.assertEnabled();
    this.assertNonNegativeInteger(input.stampCount, 'stampCount');
    this.assertPositiveInteger(input.stampGoal, 'stampGoal');

    const accountName = this.requireTrimmed(input.accountName, 'accountName');
    const accountId = this.requireTrimmed(input.accountId, 'accountId');
    const rewardName = this.requireTrimmed(input.rewardName, 'rewardName');
    const stampCount = Math.min(input.stampCount, input.stampGoal);
    const progressText =
      input.progressText?.trim() ||
      `${stampCount} of ${input.stampGoal} stamps collected`;

    const payload: GoogleWalletLoyaltyObjectPayload = {
      id: this.buildResourceId(input.objectSuffix),
      classId: this.buildResourceId(input.classSuffix),
      state: 'ACTIVE',
      accountName,
      accountId
    };

    if (input.includeBarcode !== false) {
      payload.barcode = {
        type: 'QR_CODE',
        value: input.barcodeValue?.trim() || accountId,
        alternateText: input.barcodeAlternateText?.trim() || accountId
      };
    }

    if (input.includeLoyaltyPoints !== false) {
      payload.loyaltyPoints = {
        label: 'Progress',
        balance: {
          string: `${stampCount}/${input.stampGoal}`
        }
      };
    }

    if (input.includeTextModules !== false) {
      payload.textModulesData = [
        {
          id: 'reward',
          header: 'Reward',
          body: rewardName
        },
        {
          id: 'progress',
          header: 'Progress',
          body: progressText
        }
      ];
    }

    if (input.heroImageUrl) {
      payload.heroImage = this.buildImage(
        input.heroImageUrl,
        input.heroImageDescription?.trim() ||
          `Stamp progress ${stampCount} of ${input.stampGoal}`,
        'heroImageUrl'
      );
    }

    return payload;
  }

  async buildSmokeLoyaltyObjectPayloadWithStampImage(input: {
    classSuffix: string;
    objectSuffix: string;
  }) {
    this.assertEnabled();

    const stampCount = 3;
    const stampGoal = 10;
    const stampImageStorageService = this.requireStampImageStorageService();
    const publicBaseUrl = this.getWalletImagePublicBaseUrl();
    const storedImage = await stampImageStorageService.renderAndStore(
      {
        membershipId: input.objectSuffix,
        businessName: 'Waflo',
        programName: 'Stamp Card',
        rewardName: 'Free reward after 10 stamps',
        stampCount,
        stampGoal,
        presetKey: 'COOKIE',
        backgroundColor: smokeWalletTheme.imageBackgroundColor,
        accentColor: smokeWalletTheme.imageAccentColor,
        textColor: smokeWalletTheme.imageTextColor,
        imageBackgroundColor: smokeWalletTheme.imageBackgroundColor,
        imageSurfaceColor: smokeWalletTheme.imageSurfaceColor,
        imageAccentColor: smokeWalletTheme.imageAccentColor,
        imageTextColor: smokeWalletTheme.imageTextColor,
        stampFilledColor: smokeWalletTheme.stampFilledColor,
        stampEmptyColor: smokeWalletTheme.stampEmptyColor,
        rewardBannerColor: smokeWalletTheme.rewardBannerColor,
        themePreset: smokeWalletTheme.themePreset,
        layoutVariant: 'MODERN'
      },
      {
        publicBaseUrl
      }
    );
    const heroImageUrl = stampImageStorageService.requirePublicUrl(storedImage);

    return this.buildLoyaltyObjectPayload({
      classSuffix: input.classSuffix,
      objectSuffix: input.objectSuffix,
      accountName: 'Waflo Member',
      accountId: 'WFLO-SMOKE-01',
      stampCount,
      stampGoal,
      rewardName: 'Free reward after 10 stamps',
      barcodeValue: 'WFLO-SMOKE-01',
      heroImageUrl,
      heroImageDescription: 'Waflo loyalty stamp progress image',
      progressText: '3 of 10 stamps collected',
      includeLoyaltyPoints: false,
      includeTextModules: false
    });
  }

  generateSaveJwt(input: GenerateSaveJwtInput) {
    this.assertEnabled();

    const credentials = this.loadCredentials();
    const payload: Record<string, unknown> = {
      loyaltyObjects: [input.loyaltyObject]
    };

    if (input.loyaltyClass) {
      payload.loyaltyClasses = [input.loyaltyClass];
    }

    return this.signJwt(
      {
        iss: credentials.client_email,
        aud: 'google',
        typ: 'savetowallet',
        iat: Math.floor(Date.now() / 1000),
        origins: this.getOrigins(),
        payload
      },
      credentials.private_key
    );
  }

  generateSaveUrl(input: GenerateSaveJwtInput) {
    return `https://pay.google.com/gp/v/save/${this.generateSaveJwt(input)}`;
  }

  async upsertLoyaltyClass(payload: GoogleWalletLoyaltyClassPayload) {
    this.assertEnabled();

    return this.upsertResource<GoogleWalletLoyaltyClassPayload>(
      'loyaltyClass',
      payload
    );
  }

  async upsertLoyaltyObject(payload: GoogleWalletLoyaltyObjectPayload) {
    this.assertEnabled();

    return this.upsertResource<GoogleWalletLoyaltyObjectPayload>(
      'loyaltyObject',
      payload
    );
  }

  isEnabled() {
    const value = this.configService.get<boolean | string>(
      'GOOGLE_WALLET_ENABLED'
    );

    return (
      value === true ||
      (typeof value === 'string' && value.toLowerCase() === 'true')
    );
  }

  private async upsertResource<TPayload extends WalletResource>(
    resourceName: 'loyaltyClass' | 'loyaltyObject',
    payload: TPayload
  ) {
    const resourcePath = `/${resourceName}/${encodeURIComponent(payload.id)}`;

    try {
      await this.apiClient.request('GET', resourcePath);
    } catch (error) {
      if (error instanceof GoogleWalletApiError && error.status === 404) {
        return this.apiClient.request<TPayload>(
          'POST',
          `/${resourceName}`,
          payload
        );
      }

      throw error;
    }

    return this.apiClient.request<TPayload>('PUT', resourcePath, payload);
  }

  private buildResourceId(suffix: string) {
    const normalizedSuffix = this.requireTrimmed(suffix, 'suffix');

    if (!/^[A-Za-z0-9._-]+$/.test(normalizedSuffix)) {
      throw new Error(
        'Google Wallet resource suffix may only contain letters, numbers, ".", "_", or "-"'
      );
    }

    return `${this.getIssuerId()}.${normalizedSuffix}`;
  }

  private buildImage(
    uri: string,
    description: string,
    fieldName = 'imageUrl'
  ): GoogleWalletImage {
    const normalizedUri = this.requireHttpsUrl(uri, fieldName);

    return {
      sourceUri: {
        uri: normalizedUri
      },
      contentDescription: this.localizedString(description)
    };
  }

  private localizedString(value: string): GoogleWalletLocalizedString {
    return {
      defaultValue: {
        language: 'en-US',
        value
      }
    };
  }

  private signJwt(payload: Record<string, unknown>, privateKey: string) {
    const header = {
      alg: 'RS256',
      typ: 'JWT'
    };
    const encodedHeader = this.base64Url(JSON.stringify(header));
    const encodedPayload = this.base64Url(JSON.stringify(payload));
    const signingInput = `${encodedHeader}.${encodedPayload}`;
    const signature = createSign('RSA-SHA256')
      .update(signingInput)
      .sign(privateKey);

    return `${signingInput}.${this.base64Url(signature)}`;
  }

  private loadCredentials(): ServiceAccountCredentials {
    const credentialsPath = this.getCredentialsPath();
    const rawCredentials = readFileSync(credentialsPath, 'utf8');
    const parsed = JSON.parse(rawCredentials) as Partial<ServiceAccountCredentials>;
    const clientEmail = parsed.client_email?.trim();
    const privateKey = parsed.private_key;

    if (!clientEmail || !privateKey) {
      throw new Error(
        'Google Wallet credentials must include client_email and private_key'
      );
    }

    return {
      client_email: clientEmail,
      private_key: privateKey
    };
  }

  private getCredentialsPath() {
    const configuredPath = this.getRequiredConfigString(
      'GOOGLE_WALLET_CREDENTIALS_PATH'
    );

    return isAbsolute(configuredPath)
      ? configuredPath
      : resolve(process.cwd(), configuredPath);
  }

  private getIssuerId() {
    return this.getRequiredConfigString('GOOGLE_WALLET_ISSUER_ID');
  }

  private getOrigins() {
    const value = this.configService.get<string[] | string>(
      'GOOGLE_WALLET_ORIGINS'
    );

    if (Array.isArray(value)) {
      return value;
    }

    if (typeof value === 'string' && value.trim()) {
      return value
        .split(',')
        .map((origin) => origin.trim())
        .filter(Boolean);
    }

    throw new Error('GOOGLE_WALLET_ORIGINS is required');
  }

  private getWalletImagePublicBaseUrl() {
    const value =
      this.configService.get<string>('WALLET_IMAGE_PUBLIC_BASE_URL')?.trim() ??
      '';

    if (!value) {
      throw new Error(
        'WALLET_IMAGE_PUBLIC_BASE_URL is required to attach generated Wallet images'
      );
    }

    if (!value.startsWith('https://')) {
      throw new Error('WALLET_IMAGE_PUBLIC_BASE_URL must start with https://');
    }

    return value;
  }

  private requireStampImageStorageService() {
    if (!this.stampImageStorageService) {
      throw new Error('StampImageStorageService is required for Wallet images');
    }

    return this.stampImageStorageService;
  }

  private getRequiredConfigString(key: string) {
    const value = this.configService.get<string>(key)?.trim() ?? '';

    if (!value) {
      throw new Error(`${key} is required`);
    }

    return value;
  }

  private assertEnabled() {
    if (!this.isEnabled()) {
      throw new Error('Google Wallet integration is disabled');
    }
  }

  private requireTrimmed(value: string, fieldName: string) {
    const normalized = value.trim();

    if (!normalized) {
      throw new Error(`${fieldName} is required`);
    }

    return normalized;
  }

  private requireHttpsUrl(value: string, fieldName: string) {
    let parsed: URL;

    try {
      parsed = new URL(value);
    } catch {
      throw new Error(`${fieldName} must be a valid HTTPS URL`);
    }

    if (parsed.protocol !== 'https:') {
      throw new Error(`${fieldName} must be a valid HTTPS URL`);
    }

    return parsed.toString();
  }

  private normalizeHexColor(value: string) {
    if (!/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(value)) {
      throw new Error('hexBackgroundColor must be #rgb or #rrggbb');
    }

    return value;
  }

  private assertNonNegativeInteger(value: number, fieldName: string) {
    if (!Number.isInteger(value) || value < 0) {
      throw new Error(`${fieldName} must be a non-negative integer`);
    }
  }

  private assertPositiveInteger(value: number, fieldName: string) {
    if (!Number.isInteger(value) || value <= 0) {
      throw new Error(`${fieldName} must be a positive integer`);
    }
  }

  private base64Url(value: string | Buffer) {
    return Buffer.from(value)
      .toString('base64')
      .replace(/=/g, '')
      .replace(/\+/g, '-')
      .replace(/\//g, '_');
  }
}

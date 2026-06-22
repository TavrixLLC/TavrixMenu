import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  APPLE_WALLET_APNS_TRANSPORT,
  AppleWalletApnsTransport
} from './apple-wallet-apns.transport';

export type AppleWalletApnsSendResult =
  | {
      status: 'SENT';
    }
  | {
      status: 'SKIPPED_DISABLED';
    }
  | {
      status: 'INVALID_TOKEN';
      error: string;
    }
  | {
      status: 'FAILED';
      error: string;
      retryable: boolean;
    };

@Injectable()
export class AppleWalletApnsClient {
  constructor(
    private readonly configService: ConfigService,
    @Inject(APPLE_WALLET_APNS_TRANSPORT)
    private readonly transport: AppleWalletApnsTransport
  ) {}

  isEnabled() {
    return this.configService.get<boolean>('APPLE_WALLET_APNS_ENABLED') === true;
  }

  isReady() {
    return (
      this.isEnabled() &&
      this.configService.get<boolean>('APPLE_WALLET_ENABLED') === true &&
      this.configValue('APPLE_WALLET_CERTIFICATE_PATH').length > 0 &&
      this.configValue('APPLE_WALLET_CERTIFICATE_PASSWORD', false).length > 0
    );
  }

  async sendPassUpdate(input: {
    pushToken: string;
    passTypeIdentifier: string;
  }): Promise<AppleWalletApnsSendResult> {
    if (!this.isEnabled()) {
      return {
        status: 'SKIPPED_DISABLED'
      };
    }

    if (!this.isReady()) {
      return {
        status: 'FAILED',
        error: 'Apple Wallet APNs credentials are unavailable',
        retryable: false
      };
    }

    const result = await this.transport.send({
      endpoint:
        this.configValue('APPLE_WALLET_APNS_ENVIRONMENT') === 'production'
          ? 'https://api.push.apple.com'
          : 'https://api.sandbox.push.apple.com',
      certificatePath: this.configValue('APPLE_WALLET_CERTIFICATE_PATH'),
      certificatePassword: this.configValue(
        'APPLE_WALLET_CERTIFICATE_PASSWORD',
        false
      ),
      pushToken: input.pushToken,
      passTypeIdentifier: input.passTypeIdentifier,
      timeoutMs:
        this.configService.get<number>('APPLE_WALLET_APNS_TIMEOUT_MS') ?? 10000,
      payload: '{}'
    });

    if (result.statusCode === 200) {
      return {
        status: 'SENT'
      };
    }

    const reason = this.sanitizeReason(result.reason);

    if (
      result.statusCode === 410 ||
      reason === 'BadDeviceToken' ||
      reason === 'DeviceTokenNotForTopic' ||
      reason === 'Unregistered'
    ) {
      return {
        status: 'INVALID_TOKEN',
        error: 'Apple Wallet APNs device token is invalid'
      };
    }

    return {
      status: 'FAILED',
      error: result.transportError
        ? 'Apple Wallet APNs transport failed'
        : `Apple Wallet APNs request failed${reason ? `: ${reason}` : ''}`,
      retryable:
        Boolean(result.transportError) ||
        [429, 500, 503].includes(result.statusCode)
    };
  }

  private sanitizeReason(reason?: string) {
    const normalized = reason?.trim() ?? '';
    return /^[A-Za-z][A-Za-z0-9]{0,63}$/.test(normalized)
      ? normalized
      : '';
  }

  private configValue(name: string, trim = true) {
    const configured = this.configService.get<string>(name) ?? '';
    return trim ? configured.trim() : configured;
  }
}

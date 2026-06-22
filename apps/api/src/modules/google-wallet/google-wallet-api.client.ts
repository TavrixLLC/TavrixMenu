import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleAuth } from 'google-auth-library';

export const GOOGLE_WALLET_API_CLIENT = Symbol('GOOGLE_WALLET_API_CLIENT');

export type GoogleWalletHttpMethod = 'GET' | 'POST' | 'PUT';

export interface GoogleWalletApiClient {
  request<TResponse>(
    method: GoogleWalletHttpMethod,
    path: string,
    body?: unknown
  ): Promise<TResponse>;
}

export class GoogleWalletApiError extends Error {
  constructor(
    readonly status: number,
    message: string
  ) {
    super(message);
  }
}

@Injectable()
export class GoogleWalletRestClient implements GoogleWalletApiClient {
  private static readonly baseUrl =
    'https://walletobjects.googleapis.com/walletobjects/v1';
  private static readonly issuerScope =
    'https://www.googleapis.com/auth/wallet_object.issuer';

  private auth?: GoogleAuth;

  constructor(private readonly configService: ConfigService) {}

  async request<TResponse>(
    method: GoogleWalletHttpMethod,
    path: string,
    body?: unknown
  ): Promise<TResponse> {
    const accessToken = await this.getAccessToken();
    const response = await fetch(`${GoogleWalletRestClient.baseUrl}${path}`, {
      method,
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: body === undefined ? undefined : JSON.stringify(body)
    });

    if (!response.ok) {
      throw new GoogleWalletApiError(
        response.status,
        await this.buildErrorMessage(response)
      );
    }

    const text = await response.text();

    return (text ? JSON.parse(text) : null) as TResponse;
  }

  private async getAccessToken() {
    const credentialsPath =
      this.configService.get<string>('GOOGLE_WALLET_CREDENTIALS_PATH')?.trim() ??
      '';

    if (!credentialsPath) {
      throw new Error('GOOGLE_WALLET_CREDENTIALS_PATH is required');
    }

    this.auth ??= new GoogleAuth({
      keyFile: credentialsPath,
      scopes: [GoogleWalletRestClient.issuerScope]
    });

    const client = await this.auth.getClient();
    const accessToken = await client.getAccessToken();
    const token =
      typeof accessToken === 'string' ? accessToken : accessToken?.token;

    if (!token) {
      throw new Error('Google Wallet access token was not returned');
    }

    return token;
  }

  private async buildErrorMessage(response: Response) {
    const text = await response.text();
    const trimmed = text.trim();
    const details = trimmed ? `: ${trimmed.slice(0, 1000)}` : '';

    return `Google Wallet API request failed with ${response.status}${details}`;
  }
}

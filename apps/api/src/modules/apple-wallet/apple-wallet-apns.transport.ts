import { Injectable } from '@nestjs/common';
import { connect } from 'http2';
import { readFileSync } from 'fs';
import { resolve } from 'path';

export const APPLE_WALLET_APNS_TRANSPORT = Symbol(
  'APPLE_WALLET_APNS_TRANSPORT'
);

export type AppleWalletApnsTransportInput = {
  endpoint: string;
  certificatePath: string;
  certificatePassword: string;
  pushToken: string;
  passTypeIdentifier: string;
  timeoutMs: number;
  payload: '{}';
};

export type AppleWalletApnsTransportResult = {
  statusCode: number;
  reason?: string;
  transportError?: 'TIMEOUT' | 'CONNECTION_FAILED';
};

export interface AppleWalletApnsTransport {
  send(
    input: AppleWalletApnsTransportInput
  ): Promise<AppleWalletApnsTransportResult>;
}

@Injectable()
export class NodeAppleWalletApnsTransport
  implements AppleWalletApnsTransport
{
  send(
    input: AppleWalletApnsTransportInput
  ): Promise<AppleWalletApnsTransportResult> {
    return new Promise((resolveResult) => {
      let settled = false;
      let statusCode = 0;
      let responseBody = '';
      let session: ReturnType<typeof connect> | null = null;

      const finish = (result: AppleWalletApnsTransportResult) => {
        if (settled) {
          return;
        }

        settled = true;
        clearTimeout(timeout);
        session?.destroy();
        resolveResult(result);
      };
      const timeout = setTimeout(() => {
        finish({
          statusCode: 0,
          transportError: 'TIMEOUT'
        });
      }, input.timeoutMs);

      try {
        session = connect(input.endpoint, {
          pfx: readFileSync(resolve(input.certificatePath)),
          passphrase: input.certificatePassword
        });
        session.once('error', () => {
          finish({
            statusCode: 0,
            transportError: 'CONNECTION_FAILED'
          });
        });

        const request = session.request({
          ':method': 'POST',
          ':path': `/3/device/${encodeURIComponent(input.pushToken)}`,
          'apns-topic': input.passTypeIdentifier,
          'apns-priority': '5',
          'apns-expiration': '0',
          'content-type': 'application/json'
        });

        request.setEncoding('utf8');
        request.on('response', (headers) => {
          statusCode = Number(headers[':status'] ?? 0);
        });
        request.on('data', (chunk: string) => {
          if (responseBody.length < 2048) {
            responseBody += chunk.slice(0, 2048 - responseBody.length);
          }
        });
        request.once('error', () => {
          finish({
            statusCode: 0,
            transportError: 'CONNECTION_FAILED'
          });
        });
        request.once('end', () => {
          finish({
            statusCode,
            reason: this.readReason(responseBody)
          });
        });
        request.end(input.payload);
      } catch {
        finish({
          statusCode: 0,
          transportError: 'CONNECTION_FAILED'
        });
      }
    });
  }

  private readReason(body: string) {
    try {
      const parsed = JSON.parse(body) as { reason?: unknown };
      return typeof parsed.reason === 'string' ? parsed.reason : undefined;
    } catch {
      return undefined;
    }
  }
}

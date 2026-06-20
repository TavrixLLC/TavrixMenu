import {
  BadGatewayException,
  BadRequestException,
  Injectable,
  Logger,
  ServiceUnavailableException,
  UnauthorizedException
} from '@nestjs/common';
import {
  WalletPassPlatform,
  WalletPassStatus
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AppleWalletService } from './apple-wallet.service';
import { AppleWalletUpdateAuthTokenService } from './apple-wallet-update-auth-token.service';

@Injectable()
export class AppleWalletUpdateService {
  private readonly logger = new Logger(AppleWalletUpdateService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly appleWalletService: AppleWalletService,
    private readonly updateAuthTokenService: AppleWalletUpdateAuthTokenService
  ) {}

  async registerDevice(input: {
    authorization?: string;
    deviceLibraryIdentifier: string;
    passTypeIdentifier: string;
    serialNumber: string;
    pushToken: string;
  }) {
    const { pass } = await this.findAuthorizedPass(input);
    const deviceHash = this.updateAuthTokenService.hashDeviceLibraryIdentifier(
      input.deviceLibraryIdentifier
    );
    const existing = await this.prisma.appleWalletDeviceRegistration.findUnique({
      where: {
        walletPassId_deviceLibraryIdentifierHash: {
          walletPassId: pass.id,
          deviceLibraryIdentifierHash: deviceHash
        }
      },
      select: {
        id: true
      }
    });

    await this.prisma.appleWalletDeviceRegistration.upsert({
      where: {
        walletPassId_deviceLibraryIdentifierHash: {
          walletPassId: pass.id,
          deviceLibraryIdentifierHash: deviceHash
        }
      },
      create: {
        walletPassId: pass.id,
        passTypeIdentifier: input.passTypeIdentifier,
        serialNumber: input.serialNumber,
        deviceLibraryIdentifierHash: deviceHash,
        deviceLibraryIdentifierLast4: this.last4(
          input.deviceLibraryIdentifier
        ),
        pushToken: input.pushToken,
        pushTokenLast4: this.last4(input.pushToken),
        unregisteredAt: null
      },
      update: {
        passTypeIdentifier: input.passTypeIdentifier,
        serialNumber: input.serialNumber,
        deviceLibraryIdentifierLast4: this.last4(
          input.deviceLibraryIdentifier
        ),
        pushToken: input.pushToken,
        pushTokenLast4: this.last4(input.pushToken),
        unregisteredAt: null
      }
    });

    return {
      created: !existing
    };
  }

  async listUpdatedPasses(input: {
    deviceLibraryIdentifier: string;
    passTypeIdentifier: string;
    passesUpdatedSince?: string;
  }) {
    this.assertUpdateServiceReady();
    const since = this.parseUpdateTag(input.passesUpdatedSince);
    const deviceHash = this.updateAuthTokenService.hashDeviceLibraryIdentifier(
      input.deviceLibraryIdentifier
    );
    const registrations =
      await this.prisma.appleWalletDeviceRegistration.findMany({
        where: {
          deviceLibraryIdentifierHash: deviceHash,
          passTypeIdentifier: input.passTypeIdentifier,
          unregisteredAt: null,
          walletPass: {
            platform: WalletPassPlatform.APPLE_WALLET,
            status: WalletPassStatus.ACTIVE
          }
        },
        include: {
          walletPass: {
            include: {
              membership: {
                include: {
                  loyaltyProgram: true
                }
              }
            }
          }
        }
      });
    const changed = registrations
      .map((registration) => ({
        serialNumber: registration.serialNumber,
        updatedAt: this.passChangeTime(registration.walletPass)
      }))
      .filter((entry) => since === null || entry.updatedAt.getTime() > since);

    if (changed.length === 0) {
      return null;
    }

    return {
      serialNumbers: [...new Set(changed.map((entry) => entry.serialNumber))],
      lastUpdated: String(
        Math.max(...changed.map((entry) => entry.updatedAt.getTime()))
      )
    };
  }

  async getUpdatedPass(input: {
    authorization?: string;
    passTypeIdentifier: string;
    serialNumber: string;
    ifModifiedSince?: string;
  }) {
    const { pass, rawToken } = await this.findAuthorizedPass(input);
    const lastModified = this.passChangeTime(pass);
    const conditionalDate = this.parseHttpDate(input.ifModifiedSince);

    if (
      conditionalDate &&
      Math.floor(conditionalDate.getTime() / 1000) >=
        Math.floor(lastModified.getTime() / 1000)
    ) {
      return {
        status: 'NOT_MODIFIED' as const,
        lastModified
      };
    }

    try {
      const generated = await this.appleWalletService.generatePass({
        serialNumber: input.serialNumber,
        programName: pass.membership.loyaltyProgram.name,
        stampCount: pass.membership.stampCount,
        stampGoal: pass.membership.loyaltyProgram.stampGoal,
        rewardDescription:
          pass.membership.loyaltyProgram.rewardDescription ??
          pass.membership.loyaltyProgram.rewardName,
        updateAuthenticationToken: rawToken,
        scanTokenPass: pass
      });

      await this.prisma.walletPass.update({
        where: {
          id: pass.id
        },
        data: {
          scanTokenHash: generated.scanTokenMetadata.scanTokenHash,
          scanTokenVersion: generated.scanTokenMetadata.scanTokenVersion,
          scanTokenIssuedAt: generated.scanTokenMetadata.scanTokenIssuedAt,
          scanTokenLast4: generated.scanTokenMetadata.scanTokenLast4,
          lastSyncedAt: new Date(),
          syncError: null
        }
      });

      return {
        status: 'UPDATED' as const,
        pass: generated.pass,
        lastModified
      };
    } catch {
      throw new BadGatewayException('Apple Wallet pass generation failed');
    }
  }

  async unregisterDevice(input: {
    authorization?: string;
    deviceLibraryIdentifier: string;
    passTypeIdentifier: string;
    serialNumber: string;
  }) {
    const { pass } = await this.findAuthorizedPass(input);
    const deviceHash = this.updateAuthTokenService.hashDeviceLibraryIdentifier(
      input.deviceLibraryIdentifier
    );

    await this.prisma.appleWalletDeviceRegistration.updateMany({
      where: {
        walletPassId: pass.id,
        deviceLibraryIdentifierHash: deviceHash,
        unregisteredAt: null
      },
      data: {
        pushToken: null,
        pushTokenLast4: null,
        unregisteredAt: new Date()
      }
    });
  }

  acceptLogs(logs: string[]) {
    for (const message of logs) {
      const sanitized = this.sanitizeLogMessage(message);

      if (sanitized) {
        this.logger.warn(sanitized);
      }
    }
  }

  private async findAuthorizedPass(input: {
    authorization?: string;
    passTypeIdentifier: string;
    serialNumber: string;
  }) {
    this.assertUpdateServiceReady();
    const rawToken = this.readAuthorizationToken(input.authorization);
    const pass = await this.prisma.walletPass.findFirst({
      where: {
        platform: WalletPassPlatform.APPLE_WALLET,
        applePassTypeIdentifier: input.passTypeIdentifier,
        appleSerialNumber: input.serialNumber,
        status: WalletPassStatus.ACTIVE
      },
      include: {
        membership: {
          include: {
            loyaltyProgram: true
          }
        }
      }
    });

    if (!pass || !this.updateAuthTokenService.verifyForPass(rawToken, pass)) {
      throw new UnauthorizedException('Invalid Apple pass authorization');
    }

    return {
      pass,
      rawToken
    };
  }

  private assertUpdateServiceReady() {
    if (
      this.appleWalletService.getReadiness() !== 'READY' ||
      this.appleWalletService.getUpdateWebServiceReadiness() !== 'READY'
    ) {
      throw new ServiceUnavailableException(
        'Apple Wallet update service is unavailable'
      );
    }
  }

  private readAuthorizationToken(header?: string) {
    const match = /^ApplePass ([^\s]{16,512})$/.exec(header?.trim() ?? '');

    if (!match) {
      throw new UnauthorizedException('Invalid Apple pass authorization');
    }

    return match[1];
  }

  private parseUpdateTag(value?: string) {
    if (value === undefined) {
      return null;
    }

    const parsed = Number(value);

    if (!Number.isSafeInteger(parsed) || parsed < 0) {
      throw new BadRequestException('Invalid Apple Wallet update tag');
    }

    return parsed;
  }

  private parseHttpDate(value?: string) {
    if (!value) {
      return null;
    }

    const timestamp = Date.parse(value);
    return Number.isNaN(timestamp) ? null : new Date(timestamp);
  }

  private passChangeTime(pass: {
    applePassUpdatedAt: Date | null;
    membership: {
      updatedAt: Date;
      loyaltyProgram: {
        updatedAt: Date;
      };
    };
  }) {
    return new Date(
      Math.max(
        pass.applePassUpdatedAt?.getTime() ?? 0,
        pass.membership.updatedAt.getTime(),
        pass.membership.loyaltyProgram.updatedAt.getTime()
      )
    );
  }

  private last4(value: string) {
    return value.trim().slice(-4);
  }

  private sanitizeLogMessage(value: string) {
    return value
      .replace(/ApplePass\s+\S+/gi, 'ApplePass [redacted]')
      .replace(/waflo_scan_v1\.\S+/gi, '[redacted-scan-token]')
      .replace(/waflo_apple_update_v1\.\S+/gi, '[redacted-update-token]')
      .replace(
        /(pushToken|authenticationToken)\s*[:=]\s*\S+/gi,
        '$1=[redacted]'
      )
      .replace(/eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g, '[redacted-jwt]')
      .replace(/[A-Za-z0-9_-]{64,}/g, '[redacted-value]')
      .replace(/[\u0000-\u001f\u007f]/g, ' ')
      .trim()
      .slice(0, 500);
  }
}

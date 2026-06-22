import {
  BadRequestException,
  ForbiddenException,
  Injectable
} from '@nestjs/common';
import {
  BusinessUserRole,
  LoyaltyMembershipStatus,
  Prisma,
  WalletPassPlatform,
  WalletPassStatus
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessAccessService } from '../businesses/business-access.service';
import { WalletScanDto } from './dto/wallet-scan.dto';
import { WalletScanTokenService } from './wallet-scan-token.service';

type ScannedWalletPass = Prisma.WalletPassGetPayload<{
  include: {
    membership: {
      include: {
        customer: true;
        loyaltyProgram: true;
      };
    };
  };
}>;

@Injectable()
export class WalletScanService {
  private readonly staffRoles = [
    BusinessUserRole.OWNER,
    BusinessUserRole.MANAGER,
    BusinessUserRole.STAFF
  ];
  private readonly supportedPlatforms = new Set([
    WalletPassPlatform.GOOGLE_WALLET,
    WalletPassPlatform.APPLE_WALLET
  ]);

  constructor(
    private readonly prisma: PrismaService,
    private readonly businessAccessService: BusinessAccessService,
    private readonly walletScanTokenService: WalletScanTokenService
  ) {}

  async scanGoogleWalletPass(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: WalletScanDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const parsedToken = this.walletScanTokenService.parse(dto.token);

    if (!parsedToken) {
      throw new BadRequestException('Invalid wallet scan token');
    }

    const pass = await this.prisma.walletPass.findUnique({
      where: {
        scanTokenHash: this.walletScanTokenService.hashToken(parsedToken.token)
      },
      include: {
        membership: {
          include: {
            customer: true,
            loyaltyProgram: true
          }
        }
      }
    });

    if (
      !pass ||
      !this.supportedPlatforms.has(pass.platform) ||
      pass.status !== WalletPassStatus.ACTIVE ||
      pass.membership.status !== LoyaltyMembershipStatus.ACTIVE ||
      !this.walletScanTokenService.verifyForPass(parsedToken.token, pass)
    ) {
      throw new BadRequestException('Invalid wallet scan token');
    }

    if (
      pass.businessId !== businessId ||
      pass.membership.businessId !== businessId
    ) {
      throw new ForbiddenException('Wallet pass belongs to another business');
    }

    return this.mapScanResponse(pass);
  }

  private mapScanResponse(pass: ScannedWalletPass) {
    const membership = pass.membership;
    const program = membership.loyaltyProgram;

    return {
      membershipId: membership.id,
      customer: {
        name: membership.customer.name,
        phone: membership.customer.phone
      },
      program: {
        name: program.name,
        stampGoal: program.stampGoal,
        rewardName: program.rewardName
      },
      progress: {
        stamps: membership.stampCount,
        goal: program.stampGoal,
        canRedeem:
          membership.rewardReady || membership.stampCount >= program.stampGoal
      },
      walletPass: {
        platform: pass.platform,
        status: pass.status
      }
    };
  }
}

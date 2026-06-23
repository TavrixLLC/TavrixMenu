import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import { createHash, randomBytes } from 'crypto';
import {
  Business,
  BusinessStatus,
  Customer,
  LoyaltyMembership,
  LoyaltyMembershipStatus,
  LoyaltyProgram,
  Prisma
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import {
  PublicLoyaltyEnrollDto,
  PublicLoyaltyEnrollmentIntent
} from './dto/public-loyalty-enroll.dto';

type PublicBusiness = Pick<
  Business,
  | 'id'
  | 'name'
  | 'slug'
  | 'type'
  | 'city'
  | 'logoUrl'
  | 'coverUrl'
  | 'currency'
  | 'language'
>;

type PublicMembership = LoyaltyMembership & {
  business: PublicBusiness;
  customer: Customer;
  loyaltyProgram: LoyaltyProgram;
};

export const PUBLIC_LOYALTY_RECOVERY_REQUIRED_CODE =
  'RECOVERY_REQUIRES_VERIFICATION';
export const PUBLIC_LOYALTY_RECOVERY_REQUIRED_MESSAGE =
  'Recovery requires phone verification or staff help.';
export const PUBLIC_LOYALTY_TRANSFER_TTL_MS = 5 * 60 * 1000;
export const PUBLIC_LOYALTY_TRANSFER_RATE_WINDOW_MS = 10 * 60 * 1000;
export const PUBLIC_LOYALTY_TRANSFER_RATE_LIMIT = 3;
export const PUBLIC_LOYALTY_TRANSFER_UNAVAILABLE_CODE =
  'LOYALTY_TRANSFER_UNAVAILABLE';
export const PUBLIC_LOYALTY_TRANSFER_RATE_LIMITED_CODE =
  'LOYALTY_TRANSFER_RATE_LIMITED';

export type PublicLoyaltyWalletMembership =
  Prisma.LoyaltyMembershipGetPayload<{
    include: {
      business: true;
      customer: true;
      loyaltyProgram: {
        include: {
          stampStyle: true;
        };
      };
    };
  }>;

@Injectable()
export class PublicLoyaltyService {
  constructor(private readonly prisma: PrismaService) {}

  async getEnrollmentContext(slug: string) {
    const { business, program } = await this.findActiveBusinessAndProgram(slug);

    return {
      business: this.mapBusinessContext(business),
      loyaltyProgram: this.mapProgramContext(program),
      enrollment: {
        acceptsPhone: true,
        acceptsEmail: true,
        requiresOtp: false
      }
    };
  }

  async enrollCustomer(slug: string, dto: PublicLoyaltyEnrollDto) {
    const phone = this.normalizeIraqiPhone(dto.phone);
    const email = this.normalizeNullableString(dto.email)?.toLowerCase() ?? null;
    const name = this.normalizeNullableString(dto.name);
    const intent = dto.intent ?? PublicLoyaltyEnrollmentIntent.JOIN;

    const { business, program } = await this.findActiveBusinessAndProgram(slug);

    if (intent === PublicLoyaltyEnrollmentIntent.RECOVER) {
      // TODO: Replace this only when the request carries server-verified OTP or staff proof.
      throw this.recoveryRequiresVerification();
    }

    const publicAccessToken = this.generatePublicAccessToken();
    const publicAccessTokenHash = this.hashPublicAccessToken(publicAccessToken);
    const issuedAt = new Date();

    let membership: PublicMembership;

    try {
      membership = await this.prisma.$transaction(async (transaction) => {
        const customer = await this.createNewCustomer(transaction, {
          phone,
          email,
          name
        });

        return transaction.loyaltyMembership.create({
          data: {
            businessId: business.id,
            loyaltyProgramId: program.id,
            customerId: customer.id,
            status: LoyaltyMembershipStatus.ACTIVE,
            publicAccessTokenHash,
            publicAccessTokenIssuedAt: issuedAt,
            publicAccessTokenLastViewedAt: null
          },
          include: {
            business: {
              select: this.publicBusinessSelect()
            },
            customer: true,
            loyaltyProgram: true
          }
        });
      });
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw this.recoveryRequiresVerification();
      }

      throw error;
    }

    return this.mapEnrollmentResponse(membership, publicAccessToken);
  }

  async createCardTransfer(cardToken: string) {
    const membership = await this.findMembershipByPublicCardToken(cardToken);
    const transferToken = this.generatePublicAccessToken();
    const tokenHash = this.hashPublicAccessToken(transferToken);
    const now = new Date();
    const expiresAt = new Date(now.getTime() + PUBLIC_LOYALTY_TRANSFER_TTL_MS);
    const rateWindowStart = new Date(
      now.getTime() - PUBLIC_LOYALTY_TRANSFER_RATE_WINDOW_MS
    );

    await this.prisma.$transaction(
      async (transaction) => {
        const recentTransfers = await transaction.loyaltyCardTransfer.count({
          where: {
            membershipId: membership.id,
            createdAt: {
              gte: rateWindowStart
            }
          }
        });

        if (recentTransfers >= PUBLIC_LOYALTY_TRANSFER_RATE_LIMIT) {
          throw this.transferRateLimited();
        }

        await transaction.loyaltyCardTransfer.create({
          data: {
            membershipId: membership.id,
            tokenHash,
            expiresAt
          }
        });
      },
      {
        isolationLevel: Prisma.TransactionIsolationLevel.Serializable
      }
    );

    return {
      transferToken,
      expiresAt: expiresAt.toISOString()
    };
  }

  async redeemCardTransfer(transferToken: string) {
    const normalizedTransferToken = this.normalizeTransferToken(transferToken);
    const tokenHash = this.hashPublicAccessToken(normalizedTransferToken);
    const newCardToken = this.generatePublicAccessToken();
    const newCardTokenHash = this.hashPublicAccessToken(newCardToken);
    const now = new Date();

    const membership = await this.prisma.$transaction(async (transaction) => {
      const transfer = await transaction.loyaltyCardTransfer.findUnique({
        where: {
          tokenHash
        },
        include: {
          membership: {
            include: {
              business: true,
              customer: true,
              loyaltyProgram: true
            }
          }
        }
      });

      if (
        !transfer ||
        transfer.usedAt ||
        transfer.expiresAt.getTime() <= now.getTime() ||
        transfer.membership.status !== LoyaltyMembershipStatus.ACTIVE ||
        transfer.membership.business.status !== BusinessStatus.ACTIVE ||
        !transfer.membership.loyaltyProgram.isActive
      ) {
        throw this.transferUnavailable();
      }

      const consumed = await transaction.loyaltyCardTransfer.updateMany({
        where: {
          id: transfer.id,
          usedAt: null,
          expiresAt: {
            gt: now
          }
        },
        data: {
          usedAt: now
        }
      });

      if (consumed.count !== 1) {
        throw this.transferUnavailable();
      }

      return transaction.loyaltyMembership.update({
        where: {
          id: transfer.membershipId
        },
        data: {
          publicAccessTokenHash: newCardTokenHash,
          publicAccessTokenIssuedAt: now,
          publicAccessTokenLastViewedAt: null
        },
        include: {
          business: {
            select: this.publicBusinessSelect()
          },
          customer: true,
          loyaltyProgram: true
        }
      });
    });

    return this.mapEnrollmentResponse(membership, newCardToken);
  }

  private async createNewCustomer(
    transaction: Prisma.TransactionClient,
    customerInput: {
      phone: string;
      email: string | null;
      name: string | null;
    }
  ) {
    const phoneCustomer = await this.findCustomerByPhone(
      transaction,
      customerInput.phone
    );
    const emailCustomer = customerInput.email
      ? await transaction.customer.findUnique({
          where: {
            email: customerInput.email
          },
          select: {
            id: true
          }
        })
      : null;

    if (phoneCustomer || emailCustomer) {
      throw this.recoveryRequiresVerification();
    }

    return transaction.customer.create({
      data: {
        phone: customerInput.phone,
        email: customerInput.email,
        name: customerInput.name
      }
    });
  }

  private recoveryRequiresVerification() {
    return new HttpException(
      {
        statusCode: HttpStatus.FORBIDDEN,
        code: PUBLIC_LOYALTY_RECOVERY_REQUIRED_CODE,
        message: PUBLIC_LOYALTY_RECOVERY_REQUIRED_MESSAGE
      },
      HttpStatus.FORBIDDEN
    );
  }

  private transferUnavailable() {
    return new HttpException(
      {
        statusCode: HttpStatus.GONE,
        code: PUBLIC_LOYALTY_TRANSFER_UNAVAILABLE_CODE,
        message: 'This transfer code is invalid, expired, or already used.'
      },
      HttpStatus.GONE
    );
  }

  private transferRateLimited() {
    return new HttpException(
      {
        statusCode: HttpStatus.TOO_MANY_REQUESTS,
        code: PUBLIC_LOYALTY_TRANSFER_RATE_LIMITED_CODE,
        message: 'Please wait before creating another transfer code.'
      },
      HttpStatus.TOO_MANY_REQUESTS
    );
  }

  private mapEnrollmentResponse(
    membership: PublicMembership,
    publicAccessToken: string
  ) {
    return {
      customer: {
        name: membership.customer.name
      },
      business: {
        name: membership.business.name,
        slug: membership.business.slug,
        logoUrl: membership.business.logoUrl,
        coverUrl: membership.business.coverUrl
      },
      program: {
        name: membership.loyaltyProgram.name,
        stampGoal: membership.loyaltyProgram.stampGoal,
        rewardName: membership.loyaltyProgram.rewardName,
        rewardDescription: membership.loyaltyProgram.rewardDescription
      },
      cardState: this.mapCardState(membership, membership.loyaltyProgram),
      cardAccess: {
        token: publicAccessToken,
        cardUrlPath: `/public/loyalty/cards/${publicAccessToken}`
      }
    };
  }

  async getPublicCard(token: string) {
    const membership = await this.findMembershipByPublicCardToken(token);

    return {
      business: {
        name: membership.business.name,
        slug: membership.business.slug,
        logoUrl: membership.business.logoUrl,
        coverUrl: membership.business.coverUrl
      },
      program: {
        name: membership.loyaltyProgram.name,
        stampGoal: membership.loyaltyProgram.stampGoal,
        rewardName: membership.loyaltyProgram.rewardName,
        rewardDescription: membership.loyaltyProgram.rewardDescription,
        terms: membership.loyaltyProgram.terms
      },
      customer: {
        name: membership.customer.name
      },
      cardState: this.mapCardState(membership, membership.loyaltyProgram)
    };
  }

  async findMembershipByPublicCardToken(
    token: string
  ): Promise<PublicLoyaltyWalletMembership> {
    const normalizedToken = this.normalizeRequiredToken(token);
    const publicAccessTokenHash = this.hashPublicAccessToken(normalizedToken);

    const existingMembership = await this.prisma.loyaltyMembership.findFirst({
      where: {
        publicAccessTokenHash,
        status: LoyaltyMembershipStatus.ACTIVE,
        business: {
          status: BusinessStatus.ACTIVE
        },
        loyaltyProgram: {
          isActive: true
        }
      },
      select: {
        id: true
      }
    });

    if (!existingMembership) {
      throw new NotFoundException('Loyalty card not found');
    }

    const membership = await this.prisma.loyaltyMembership.update({
      where: {
        id: existingMembership.id
      },
      data: {
        publicAccessTokenLastViewedAt: new Date()
      },
      include: {
        business: true,
        customer: true,
        loyaltyProgram: {
          include: {
            stampStyle: true
          }
        }
      }
    });

    return membership;
  }

  private async findActiveBusinessAndProgram(slug: string) {
    const business = await this.prisma.business.findFirst({
      where: {
        slug,
        status: BusinessStatus.ACTIVE
      },
      select: {
        ...this.publicBusinessSelect(),
        loyaltyPrograms: {
          where: {
            isActive: true
          },
          orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
          take: 1
        }
      }
    });

    if (!business || business.loyaltyPrograms.length === 0) {
      throw new NotFoundException('Public loyalty program not found');
    }

    const [program] = business.loyaltyPrograms;
    const { loyaltyPrograms: _loyaltyPrograms, ...publicBusiness } = business;

    return {
      business: publicBusiness,
      program
    };
  }

  private async findCustomerByPhone(
    transaction: Prisma.TransactionClient,
    canonicalPhone: string
  ) {
    return transaction.customer.findFirst({
      where: {
        phone: {
          in: this.getIraqiPhoneAliases(canonicalPhone)
        }
      },
      select: {
        id: true
      }
    });
  }

  private publicBusinessSelect() {
    return {
      id: true,
      name: true,
      slug: true,
      type: true,
      city: true,
      logoUrl: true,
      coverUrl: true,
      currency: true,
      language: true
    } satisfies Prisma.BusinessSelect;
  }

  private mapBusinessContext(business: PublicBusiness) {
    return {
      id: business.id,
      name: business.name,
      slug: business.slug,
      type: business.type,
      city: business.city,
      logoUrl: business.logoUrl,
      coverUrl: business.coverUrl,
      currency: business.currency,
      language: business.language
    };
  }

  private mapProgramContext(program: LoyaltyProgram) {
    return {
      id: program.id,
      name: program.name,
      description: program.description,
      stampGoal: program.stampGoal,
      rewardName: program.rewardName,
      rewardDescription: program.rewardDescription,
      cardColor: program.cardColor,
      accentColor: program.accentColor,
      logoUrl: program.logoUrl,
      terms: program.terms
    };
  }

  private mapCardState(
    membership: LoyaltyMembership,
    program: LoyaltyProgram
  ) {
    return {
      stampCount: membership.stampCount,
      stampGoal: program.stampGoal,
      rewardReady: membership.rewardReady,
      progressPercent: Math.min(
        Math.floor((membership.stampCount / program.stampGoal) * 100),
        100
      ),
      rewardName: program.rewardName,
      programName: program.name,
      totalStampsEarned: membership.totalStampsEarned,
      totalRewardsRedeemed: membership.totalRewardsRedeemed
    };
  }

  private normalizeNullableString(value: string | null | undefined) {
    if (value === undefined || value === null) {
      return null;
    }

    const normalized = value.trim();

    return normalized || null;
  }

  private normalizeIraqiPhone(value: string) {
    const normalized = value.trim();

    if (/^07\d{9}$/.test(normalized)) {
      return `+964${normalized.slice(1)}`;
    }

    if (/^\+9647\d{9}$/.test(normalized)) {
      return normalized;
    }

    throw new BadRequestException(
      'Phone must use Iraqi local or international format'
    );
  }

  private getIraqiPhoneAliases(canonicalPhone: string) {
    return [canonicalPhone, `0${canonicalPhone.slice(4)}`];
  }

  private normalizeRequiredToken(value: string) {
    const normalizedToken = value.trim();

    if (normalizedToken.length < 32 || normalizedToken.length > 128) {
      throw new NotFoundException('Loyalty card not found');
    }

    return normalizedToken;
  }

  private normalizeTransferToken(value: string) {
    const normalizedToken = value.trim();

    if (
      normalizedToken.startsWith('waflo_scan_v1.') ||
      normalizedToken.length < 32 ||
      normalizedToken.length > 128
    ) {
      throw this.transferUnavailable();
    }

    return normalizedToken;
  }

  private generatePublicAccessToken() {
    return randomBytes(32).toString('base64url');
  }

  private hashPublicAccessToken(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }
}

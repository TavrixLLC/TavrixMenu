import {
  BadRequestException,
  ConflictException,
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
import { PublicLoyaltyEnrollDto } from './dto/public-loyalty-enroll.dto';

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
    const phone = this.normalizeNullableString(dto.phone);
    const email = this.normalizeNullableString(dto.email)?.toLowerCase() ?? null;
    const name = this.normalizeNullableString(dto.name);

    if (!phone && !email) {
      throw new BadRequestException('Enrollment requires phone or email');
    }

    const { business, program } = await this.findActiveBusinessAndProgram(slug);
    const publicAccessToken = this.generatePublicAccessToken();
    const publicAccessTokenHash = this.hashPublicAccessToken(publicAccessToken);
    const issuedAt = new Date();

    const membership = await this.prisma.$transaction(async (transaction) => {
      const customer = await this.findOrCreateCustomer(transaction, {
        phone,
        email,
        name
      });

      return transaction.loyaltyMembership.upsert({
        where: {
          customerId_loyaltyProgramId: {
            customerId: customer.id,
            loyaltyProgramId: program.id
          }
        },
        create: {
          businessId: business.id,
          loyaltyProgramId: program.id,
          customerId: customer.id,
          status: LoyaltyMembershipStatus.ACTIVE,
          publicAccessTokenHash,
          publicAccessTokenIssuedAt: issuedAt,
          publicAccessTokenLastViewedAt: null
        },
        update: {
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

  private async findOrCreateCustomer(
    transaction: Prisma.TransactionClient,
    customerInput: {
      phone: string | null;
      email: string | null;
      name: string | null;
    }
  ) {
    const phoneCustomer = customerInput.phone
      ? await transaction.customer.findUnique({
          where: {
            phone: customerInput.phone
          }
        })
      : null;
    const emailCustomer = customerInput.email
      ? await transaction.customer.findUnique({
          where: {
            email: customerInput.email
          }
        })
      : null;

    if (phoneCustomer && emailCustomer && phoneCustomer.id !== emailCustomer.id) {
      throw new ConflictException('Phone and email belong to different customers');
    }

    const existingCustomer = phoneCustomer ?? emailCustomer;

    if (existingCustomer) {
      return transaction.customer.update({
        where: {
          id: existingCustomer.id
        },
        data: {
          phone: customerInput.phone ?? existingCustomer.phone,
          email: customerInput.email ?? existingCustomer.email,
          name: customerInput.name ?? existingCustomer.name
        }
      });
    }

    return transaction.customer.create({
      data: {
        phone: customerInput.phone,
        email: customerInput.email,
        name: customerInput.name
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

  private normalizeRequiredToken(value: string) {
    const normalizedToken = value.trim();

    if (normalizedToken.length < 32 || normalizedToken.length > 128) {
      throw new NotFoundException('Loyalty card not found');
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

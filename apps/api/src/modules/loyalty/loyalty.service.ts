import {
  BadRequestException,
  ConflictException,
  forwardRef,
  Inject,
  Injectable,
  NotFoundException,
  Optional
} from '@nestjs/common';
import {
  BusinessUserRole,
  Customer,
  LoyaltyMembership,
  LoyaltyMembershipStatus,
  LoyaltyProgram,
  LoyaltyTransaction,
  LoyaltyTransactionType,
  Prisma
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessAccessService } from '../businesses/business-access.service';
import { WalletPassService } from '../google-wallet/wallet-pass.service';
import { AddStampsDto } from './dto/add-stamps.dto';
import { CreateLoyaltyProgramDto } from './dto/create-loyalty-program.dto';
import { EnrollLoyaltyCustomerDto } from './dto/enroll-loyalty-customer.dto';
import { GetLoyaltyMembershipsQueryDto } from './dto/get-loyalty-memberships-query.dto';
import { RedeemRewardDto } from './dto/redeem-reward.dto';
import { UpdateLoyaltyProgramDto } from './dto/update-loyalty-program.dto';

type MembershipWithCustomerAndProgram = LoyaltyMembership & {
  customer: Customer;
  loyaltyProgram: LoyaltyProgram;
};

type MembershipWithDetails = MembershipWithCustomerAndProgram & {
  transactions: LoyaltyTransaction[];
};

@Injectable()
export class LoyaltyService {
  private readonly configRoles = [
    BusinessUserRole.OWNER,
    BusinessUserRole.MANAGER
  ];
  private readonly staffRoles = [
    BusinessUserRole.OWNER,
    BusinessUserRole.MANAGER,
    BusinessUserRole.STAFF
  ];

  constructor(
    private readonly prisma: PrismaService,
    private readonly businessAccessService: BusinessAccessService,
    @Optional()
    @Inject(forwardRef(() => WalletPassService))
    private readonly walletPassService?: WalletPassService
  ) {}

  async getActiveProgram(currentUser: AuthenticatedUser, businessId: string) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const program = await this.prisma.loyaltyProgram.findFirst({
      where: {
        businessId,
        isActive: true
      },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }]
    });

    return program ? this.mapProgram(program) : null;
  }

  async createProgram(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: CreateLoyaltyProgramDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.configRoles
    );

    const isActive = dto.isActive ?? true;

    if (isActive) {
      await this.assertNoOtherActiveProgram(businessId);
    }

    const program = await this.prisma.loyaltyProgram.create({
      data: {
        businessId,
        name: this.normalizeRequiredString(dto.name, 'name'),
        description: this.normalizeNullableString(dto.description),
        stampGoal: dto.stampGoal,
        rewardName: this.normalizeRequiredString(dto.rewardName, 'rewardName'),
        rewardDescription: this.normalizeNullableString(dto.rewardDescription),
        isActive,
        cardColor: this.normalizeNullableString(dto.cardColor),
        accentColor: this.normalizeNullableString(dto.accentColor),
        logoUrl: this.normalizeNullableString(dto.logoUrl),
        terms: this.normalizeNullableString(dto.terms)
      }
    });

    return this.mapProgram(program);
  }

  async updateProgram(
    currentUser: AuthenticatedUser,
    businessId: string,
    programId: string,
    dto: UpdateLoyaltyProgramDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.configRoles
    );

    const existingProgram = await this.prisma.loyaltyProgram.findFirst({
      where: {
        id: programId,
        businessId
      }
    });

    if (!existingProgram) {
      throw new NotFoundException('Loyalty program not found');
    }

    if (dto.isActive === true && !existingProgram.isActive) {
      await this.assertNoOtherActiveProgram(businessId, programId);
    }

    const program = await this.prisma.loyaltyProgram.update({
      where: {
        id: programId
      },
      data: {
        name:
          dto.name === undefined
            ? undefined
            : this.normalizeRequiredString(dto.name, 'name'),
        description:
          dto.description === undefined
            ? undefined
            : this.normalizeNullableString(dto.description),
        stampGoal: dto.stampGoal,
        rewardName:
          dto.rewardName === undefined
            ? undefined
            : this.normalizeRequiredString(dto.rewardName, 'rewardName'),
        rewardDescription:
          dto.rewardDescription === undefined
            ? undefined
            : this.normalizeNullableString(dto.rewardDescription),
        isActive: dto.isActive,
        cardColor:
          dto.cardColor === undefined
            ? undefined
            : this.normalizeNullableString(dto.cardColor),
        accentColor:
          dto.accentColor === undefined
            ? undefined
            : this.normalizeNullableString(dto.accentColor),
        logoUrl:
          dto.logoUrl === undefined
            ? undefined
            : this.normalizeNullableString(dto.logoUrl),
        terms:
          dto.terms === undefined
            ? undefined
            : this.normalizeNullableString(dto.terms)
      }
    });

    return this.mapProgram(program);
  }

  async enrollCustomer(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: EnrollLoyaltyCustomerDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const phone = this.normalizeNullableString(dto.phone);
    const email = this.normalizeNullableString(dto.email)?.toLowerCase() ?? null;
    const name = this.normalizeNullableString(dto.name);

    if (!phone && !email) {
      throw new BadRequestException('Enrollment requires phone or email');
    }

    const program = await this.resolveProgram(businessId, dto.programId);

    const result = await this.prisma.$transaction(async (transaction) => {
      const customer = await this.findOrCreateCustomer(transaction, {
        phone,
        email,
        name
      });

      const membership = await transaction.loyaltyMembership.upsert({
        where: {
          customerId_loyaltyProgramId: {
            customerId: customer.id,
            loyaltyProgramId: program.id
          }
        },
        create: {
          businessId,
          loyaltyProgramId: program.id,
          customerId: customer.id,
          status: LoyaltyMembershipStatus.ACTIVE
        },
        update: {
          status: LoyaltyMembershipStatus.ACTIVE
        },
        include: {
          customer: true,
          loyaltyProgram: true
        }
      });

      return membership;
    });

    return this.mapEnrollment(result);
  }

  async listMemberships(
    currentUser: AuthenticatedUser,
    businessId: string,
    query: GetLoyaltyMembershipsQueryDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const search = this.normalizeNullableString(query.search);
    const where: Prisma.LoyaltyMembershipWhereInput = {
      businessId,
      ...(query.status ? { status: query.status } : {}),
      ...(query.rewardReady === undefined
        ? {}
        : { rewardReady: query.rewardReady === 'true' }),
      ...(search
        ? {
            OR: [
              {
                customer: {
                  name: {
                    contains: search,
                    mode: 'insensitive'
                  }
                }
              },
              {
                customer: {
                  email: {
                    contains: search,
                    mode: 'insensitive'
                  }
                }
              },
              {
                customer: {
                  phone: {
                    contains: search,
                    mode: 'insensitive'
                  }
                }
              }
            ]
          }
        : {})
    };

    const memberships = await this.prisma.loyaltyMembership.findMany({
      where,
      include: {
        customer: true,
        loyaltyProgram: true
      },
      orderBy: [{ updatedAt: 'desc' }, { createdAt: 'desc' }, { id: 'asc' }]
    });

    return memberships.map((membership) => this.mapMembershipSummary(membership));
  }

  async getMembership(
    currentUser: AuthenticatedUser,
    businessId: string,
    membershipId: string
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const membership = await this.findMembershipDetails(businessId, membershipId);

    return this.mapMembershipDetails(membership);
  }

  async addStamps(
    currentUser: AuthenticatedUser,
    businessId: string,
    membershipId: string,
    dto: AddStampsDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const count = dto.count ?? 1;
    const reason = this.normalizeNullableString(dto.reason);

    const updatedMembership = await this.prisma.$transaction(async (transaction) => {
      const membership = await this.findMembershipWithProgramForUpdate(
        transaction,
        businessId,
        membershipId
      );

      if (membership.status !== LoyaltyMembershipStatus.ACTIVE) {
        throw new BadRequestException('Loyalty membership is inactive');
      }

      if (!membership.loyaltyProgram.isActive) {
        throw new BadRequestException('Loyalty program is inactive');
      }

      if (membership.rewardReady) {
        throw new BadRequestException('Reward is already ready to redeem');
      }

      const nextStampCount = Math.min(
        membership.stampCount + count,
        membership.loyaltyProgram.stampGoal
      );
      const appliedStampCount = nextStampCount - membership.stampCount;

      if (appliedStampCount <= 0) {
        throw new BadRequestException('Reward is already ready to redeem');
      }

      const rewardReady = nextStampCount >= membership.loyaltyProgram.stampGoal;
      const updated = await transaction.loyaltyMembership.update({
        where: {
          id: membership.id
        },
        data: {
          stampCount: nextStampCount,
          rewardReady,
          totalStampsEarned: {
            increment: appliedStampCount
          }
        },
        include: {
          customer: true,
          loyaltyProgram: true
        }
      });

      await transaction.loyaltyTransaction.create({
        data: {
          businessId,
          loyaltyProgramId: membership.loyaltyProgramId,
          membershipId: membership.id,
          customerId: membership.customerId,
          actorUserId: currentUser.id,
          type: LoyaltyTransactionType.STAMP_ADDED,
          stampsDelta: appliedStampCount,
          reason
        }
      });

      return updated;
    });

    await this.refreshWalletPassAfterMembershipChange(updatedMembership.id);

    return this.mapCardStateResponse(updatedMembership);
  }

  async redeemReward(
    currentUser: AuthenticatedUser,
    businessId: string,
    membershipId: string,
    dto: RedeemRewardDto
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    const reason = this.normalizeNullableString(dto.reason);
    const updatedMembership = await this.prisma.$transaction(async (transaction) => {
      const membership = await this.findMembershipWithProgramForUpdate(
        transaction,
        businessId,
        membershipId
      );

      if (membership.status !== LoyaltyMembershipStatus.ACTIVE) {
        throw new BadRequestException('Loyalty membership is inactive');
      }

      if (!membership.rewardReady) {
        throw new BadRequestException('Reward is not ready');
      }

      const redeemedStampCount = membership.stampCount;
      const updated = await transaction.loyaltyMembership.update({
        where: {
          id: membership.id
        },
        data: {
          stampCount: 0,
          rewardReady: false,
          totalRewardsRedeemed: {
            increment: 1
          }
        },
        include: {
          customer: true,
          loyaltyProgram: true
        }
      });

      await transaction.loyaltyTransaction.create({
        data: {
          businessId,
          loyaltyProgramId: membership.loyaltyProgramId,
          membershipId: membership.id,
          customerId: membership.customerId,
          actorUserId: currentUser.id,
          type: LoyaltyTransactionType.REWARD_REDEEMED,
          stampsDelta: -redeemedStampCount,
          reason
        }
      });

      return updated;
    });

    await this.refreshWalletPassAfterMembershipChange(updatedMembership.id);

    return this.mapCardStateResponse(updatedMembership);
  }

  async listTransactions(
    currentUser: AuthenticatedUser,
    businessId: string,
    membershipId: string
  ) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.staffRoles
    );

    await this.assertMembershipInBusiness(businessId, membershipId);

    const transactions = await this.prisma.loyaltyTransaction.findMany({
      where: {
        businessId,
        membershipId
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }]
    });

    return transactions.map((transaction) => this.mapTransaction(transaction));
  }

  private async assertNoOtherActiveProgram(
    businessId: string,
    excludedProgramId?: string
  ) {
    const existingActiveProgram = await this.prisma.loyaltyProgram.findFirst({
      where: {
        businessId,
        isActive: true,
        ...(excludedProgramId
          ? {
              id: {
                not: excludedProgramId
              }
            }
          : {})
      },
      select: {
        id: true
      }
    });

    if (existingActiveProgram) {
      throw new ConflictException(
        'An active loyalty program already exists for this business'
      );
    }
  }

  private async refreshWalletPassAfterMembershipChange(membershipId: string) {
    if (!this.walletPassService) {
      return;
    }

    try {
      await this.walletPassService.refreshGoogleWalletPassForMembership(
        membershipId
      );
    } catch {
      undefined;
    }
  }

  private async resolveProgram(businessId: string, programId?: string) {
    if (programId) {
      const program = await this.prisma.loyaltyProgram.findFirst({
        where: {
          id: programId,
          businessId
        }
      });

      if (!program) {
        throw new NotFoundException('Loyalty program not found');
      }

      if (!program.isActive) {
        throw new BadRequestException('Loyalty program is inactive');
      }

      return program;
    }

    const activePrograms = await this.prisma.loyaltyProgram.findMany({
      where: {
        businessId,
        isActive: true
      },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }]
    });

    if (activePrograms.length === 0) {
      throw new NotFoundException('No active loyalty program found');
    }

    if (activePrograms.length > 1) {
      throw new BadRequestException(
        'programId is required when multiple active loyalty programs exist'
      );
    }

    return activePrograms[0];
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

  private async findMembershipWithProgram(
    businessId: string,
    membershipId: string
  ) {
    const membership = await this.prisma.loyaltyMembership.findFirst({
      where: {
        id: membershipId,
        businessId
      },
      include: {
        customer: true,
        loyaltyProgram: true
      }
    });

    if (!membership) {
      throw new NotFoundException('Loyalty membership not found');
    }

    return membership;
  }

  private async findMembershipWithProgramForUpdate(
    transaction: Prisma.TransactionClient,
    businessId: string,
    membershipId: string
  ) {
    const lockedRows = await transaction.$queryRaw<Array<{ id: string }>>`
      SELECT id
      FROM "loyalty_memberships"
      WHERE id = ${membershipId}
        AND business_id = ${businessId}
      FOR UPDATE
    `;

    if (lockedRows.length === 0) {
      throw new NotFoundException('Loyalty membership not found');
    }

    const membership = await transaction.loyaltyMembership.findFirst({
      where: {
        id: membershipId,
        businessId
      },
      include: {
        customer: true,
        loyaltyProgram: true
      }
    });

    if (!membership) {
      throw new NotFoundException('Loyalty membership not found');
    }

    return membership;
  }

  private async findMembershipDetails(
    businessId: string,
    membershipId: string
  ) {
    const membership = await this.prisma.loyaltyMembership.findFirst({
      where: {
        id: membershipId,
        businessId
      },
      include: {
        customer: true,
        loyaltyProgram: true,
        transactions: {
          orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
          take: 10
        }
      }
    });

    if (!membership) {
      throw new NotFoundException('Loyalty membership not found');
    }

    return membership;
  }

  private async assertMembershipInBusiness(
    businessId: string,
    membershipId: string
  ) {
    const membership = await this.prisma.loyaltyMembership.findFirst({
      where: {
        id: membershipId,
        businessId
      },
      select: {
        id: true
      }
    });

    if (!membership) {
      throw new NotFoundException('Loyalty membership not found');
    }
  }

  private normalizeRequiredString(value: string, fieldName: string) {
    const normalized = value.trim();

    if (!normalized) {
      throw new BadRequestException(`${fieldName} cannot be empty`);
    }

    return normalized;
  }

  private normalizeNullableString(value: string | null | undefined) {
    if (value === undefined || value === null) {
      return null;
    }

    const normalized = value.trim();

    return normalized || null;
  }

  private mapProgram(program: LoyaltyProgram) {
    return {
      id: program.id,
      businessId: program.businessId,
      name: program.name,
      description: program.description,
      stampGoal: program.stampGoal,
      rewardName: program.rewardName,
      rewardDescription: program.rewardDescription,
      isActive: program.isActive,
      cardColor: program.cardColor,
      accentColor: program.accentColor,
      logoUrl: program.logoUrl,
      terms: program.terms,
      createdAt: program.createdAt,
      updatedAt: program.updatedAt
    };
  }

  private mapCustomer(customer: Customer) {
    return {
      id: customer.id,
      phone: customer.phone,
      email: customer.email,
      name: customer.name,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt
    };
  }

  private mapEnrollment(membership: MembershipWithCustomerAndProgram) {
    return {
      customer: this.mapCustomer(membership.customer),
      membership: this.mapMembershipBase(membership),
      program: this.mapProgram(membership.loyaltyProgram),
      cardState: this.mapCardState(membership, membership.loyaltyProgram)
    };
  }

  private mapMembershipSummary(membership: MembershipWithCustomerAndProgram) {
    return {
      ...this.mapMembershipBase(membership),
      customer: this.mapCustomer(membership.customer),
      program: {
        id: membership.loyaltyProgram.id,
        name: membership.loyaltyProgram.name,
        stampGoal: membership.loyaltyProgram.stampGoal,
        rewardName: membership.loyaltyProgram.rewardName,
        isActive: membership.loyaltyProgram.isActive
      },
      cardState: this.mapCardState(membership, membership.loyaltyProgram)
    };
  }

  private mapMembershipDetails(membership: MembershipWithDetails) {
    return {
      ...this.mapMembershipSummary(membership),
      transactions: membership.transactions.map((transaction) =>
        this.mapTransaction(transaction)
      )
    };
  }

  private mapMembershipBase(membership: LoyaltyMembership) {
    return {
      id: membership.id,
      businessId: membership.businessId,
      loyaltyProgramId: membership.loyaltyProgramId,
      customerId: membership.customerId,
      stampCount: membership.stampCount,
      rewardReady: membership.rewardReady,
      totalStampsEarned: membership.totalStampsEarned,
      totalRewardsRedeemed: membership.totalRewardsRedeemed,
      status: membership.status,
      createdAt: membership.createdAt,
      updatedAt: membership.updatedAt
    };
  }

  private mapCardStateResponse(membership: MembershipWithCustomerAndProgram) {
    return {
      membership: this.mapMembershipBase(membership),
      customer: this.mapCustomer(membership.customer),
      program: this.mapProgram(membership.loyaltyProgram),
      cardState: this.mapCardState(membership, membership.loyaltyProgram)
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
      programName: program.name
    };
  }

  private mapTransaction(transaction: LoyaltyTransaction) {
    return {
      id: transaction.id,
      businessId: transaction.businessId,
      loyaltyProgramId: transaction.loyaltyProgramId,
      membershipId: transaction.membershipId,
      customerId: transaction.customerId,
      actorUserId: transaction.actorUserId,
      type: transaction.type,
      stampsDelta: transaction.stampsDelta,
      reason: transaction.reason,
      createdAt: transaction.createdAt
    };
  }
}

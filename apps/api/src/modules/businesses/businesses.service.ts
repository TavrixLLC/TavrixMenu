import {
  ConflictException,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  Business,
  BusinessUserRole,
  BusinessUserStatus,
  Prisma,
  UserStatus
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessAccessService } from './business-access.service';
import { CreateBusinessDto } from './dto/create-business.dto';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateBusinessDto } from './dto/update-business.dto';
import { UpdateMemberDto } from './dto/update-member.dto';

type BusinessMemberRecord = Prisma.BusinessUserGetPayload<{
  include: {
    user: true;
  };
}>;

@Injectable()
export class BusinessesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly businessAccessService: BusinessAccessService,
    private readonly configService: ConfigService
  ) {}

  async createBusiness(currentUser: AuthenticatedUser, dto: CreateBusinessDto) {
    try {
      const business = await this.prisma.$transaction(async (transaction) => {
        const slug = await this.generateUniqueSlug(dto.name, transaction);
        const createdBusiness = await transaction.business.create({
          data: {
            ownerId: currentUser.id,
            name: dto.name,
            slug,
            type: dto.type,
            city: dto.city,
            currency: dto.currency ?? 'IQD',
            language: dto.language ?? 'ar'
          }
        });

        await transaction.businessUser.create({
          data: {
            businessId: createdBusiness.id,
            userId: currentUser.id,
            role: BusinessUserRole.OWNER
          }
        });

        return createdBusiness;
      });

      return this.mapBusiness(business);
    } catch (error) {
      if (this.isUniqueConstraintError(error)) {
        throw new ConflictException('Business slug already exists');
      }

      throw error;
    }
  }

  async getMyBusinesses(currentUser: AuthenticatedUser) {
    const memberships = await this.prisma.businessUser.findMany({
      where: {
        userId: currentUser.id,
        status: BusinessUserStatus.ACTIVE
      },
      include: {
        business: true
      },
      orderBy: {
        createdAt: 'asc'
      }
    });

    return memberships.map((membership) => ({
      ...this.mapBusiness(membership.business),
      role: membership.role
    }));
  }

  async updateBusiness(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: UpdateBusinessDto
  ) {
    await this.businessAccessService.assertOwner(businessId, currentUser.id);

    try {
      const business = await this.prisma.business.update({
        where: { id: businessId },
        data: {
          name: dto.name,
          type: dto.type,
          city: dto.city,
          currency: dto.currency,
          language: dto.language,
          logoUrl: dto.logoUrl,
          coverUrl: dto.coverUrl
        }
      });

      return this.mapBusiness(business);
    } catch (error) {
      if (this.isRecordNotFoundError(error)) {
        throw new NotFoundException('Business not found');
      }

      throw error;
    }
  }

  async getAppContext(currentUser: AuthenticatedUser, businessId: string) {
    const membership = await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.businessAccessService.appContextRoles
    );
    const business = await this.prisma.business.findUnique({
      where: {
        id: businessId
      },
      select: {
        id: true,
        name: true,
        slug: true,
        type: true,
        city: true,
        currency: true,
        language: true,
        logoUrl: true,
        coverUrl: true
      }
    });

    if (!business) {
      throw new NotFoundException('Business not found');
    }

    return {
      business,
      currentMembership: {
        id: membership.id,
        role: membership.role,
        isActive: membership.status === BusinessUserStatus.ACTIVE
      },
      permissions: this.businessAccessService.getPermissions(membership.role),
      publicMenu: this.mapPublicMenu(business.slug)
    };
  }

  async getPublicLink(currentUser: AuthenticatedUser, businessId: string) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.businessAccessService.appContextRoles
    );
    const business = await this.prisma.business.findUnique({
      where: {
        id: businessId
      },
      select: {
        id: true,
        slug: true
      }
    });

    if (!business) {
      throw new NotFoundException('Business not found');
    }

    const publicMenu = this.mapPublicMenu(business.slug);

    return {
      businessId: business.id,
      slug: business.slug,
      publicMenuPath: publicMenu.path,
      publicMenuUrl: publicMenu.url,
      qrPayload: publicMenu.qrPayload
    };
  }

  async getMembers(currentUser: AuthenticatedUser, businessId: string) {
    await this.businessAccessService.assertRole(
      businessId,
      currentUser.id,
      this.businessAccessService.memberViewerRoles
    );

    const memberships = await this.prisma.businessUser.findMany({
      where: {
        businessId
      },
      include: {
        user: true
      },
      orderBy: {
        createdAt: 'asc'
      }
    });

    return memberships.map((membership) => this.mapMember(membership));
  }

  async createMember(
    currentUser: AuthenticatedUser,
    businessId: string,
    dto: CreateMemberDto
  ) {
    await this.businessAccessService.assertOwner(businessId, currentUser.id);

    return this.prisma.$transaction(async (transaction) => {
      const user = await transaction.user.upsert({
        where: {
          clerkUserId: dto.clerkUserId
        },
        create: {
          clerkUserId: dto.clerkUserId,
          email: dto.email,
          name: dto.name,
          phone: dto.phone,
          status: UserStatus.ACTIVE
        },
        update: {
          email: dto.email,
          name: dto.name,
          phone: dto.phone
        }
      });

      const existingMembership = await transaction.businessUser.findUnique({
        where: {
          businessId_userId: {
            businessId,
            userId: user.id
          }
        },
        include: {
          user: true
        }
      });

      if (existingMembership?.status === BusinessUserStatus.ACTIVE) {
        throw new ConflictException('Business member already active');
      }

      if (existingMembership) {
        const reactivatedMembership = await transaction.businessUser.update({
          where: {
            id: existingMembership.id
          },
          data: {
            role: dto.role,
            status: BusinessUserStatus.ACTIVE
          },
          include: {
            user: true
          }
        });

        return this.mapMember(reactivatedMembership);
      }

      const membership = await transaction.businessUser.create({
        data: {
          businessId,
          userId: user.id,
          role: dto.role,
          status: BusinessUserStatus.ACTIVE
        },
        include: {
          user: true
        }
      });

      return this.mapMember(membership);
    });
  }

  async updateMember(
    currentUser: AuthenticatedUser,
    businessId: string,
    memberId: string,
    dto: UpdateMemberDto
  ) {
    await this.businessAccessService.assertOwner(businessId, currentUser.id);

    return this.prisma.$transaction(async (transaction) => {
      const existingMembership = await transaction.businessUser.findFirst({
        where: {
          id: memberId,
          businessId
        },
        include: {
          user: true
        }
      });

      if (!existingMembership) {
        throw new NotFoundException('Business member not found');
      }

      const nextRole = dto.role ?? existingMembership.role;
      const nextStatus =
        dto.isActive === undefined
          ? existingMembership.status
          : dto.isActive
            ? BusinessUserStatus.ACTIVE
            : BusinessUserStatus.DISABLED;
      const removesActiveOwner =
        existingMembership.role === BusinessUserRole.OWNER &&
        existingMembership.status === BusinessUserStatus.ACTIVE &&
        (nextRole !== BusinessUserRole.OWNER ||
          nextStatus !== BusinessUserStatus.ACTIVE);

      if (removesActiveOwner) {
        await this.businessAccessService.assertAnotherActiveOwnerExists(
          businessId,
          existingMembership.id,
          transaction
        );
      }

      const updatedMembership = await transaction.businessUser.update({
        where: {
          id: memberId
        },
        data: {
          role: dto.role,
          status: dto.isActive === undefined ? undefined : nextStatus
        },
        include: {
          user: true
        }
      });

      return this.mapMember(updatedMembership);
    });
  }

  async deleteMember(
    currentUser: AuthenticatedUser,
    businessId: string,
    memberId: string
  ) {
    await this.businessAccessService.assertOwner(businessId, currentUser.id);

    return this.prisma.$transaction(async (transaction) => {
      const existingMembership = await transaction.businessUser.findFirst({
        where: {
          id: memberId,
          businessId
        },
        include: {
          user: true
        }
      });

      if (!existingMembership) {
        throw new NotFoundException('Business member not found');
      }

      if (
        existingMembership.role === BusinessUserRole.OWNER &&
        existingMembership.status === BusinessUserStatus.ACTIVE
      ) {
        await this.businessAccessService.assertAnotherActiveOwnerExists(
          businessId,
          existingMembership.id,
          transaction
        );
      }

      const updatedMembership = await transaction.businessUser.update({
        where: {
          id: memberId
        },
        data: {
          status: BusinessUserStatus.DISABLED
        },
        include: {
          user: true
        }
      });

      return {
        deleted: true,
        member: this.mapMember(updatedMembership)
      };
    });
  }

  private async generateUniqueSlug(
    name: string,
    prisma: Prisma.TransactionClient | PrismaService
  ): Promise<string> {
    const baseSlug = this.slugify(name);
    let candidateSlug = baseSlug;
    let suffix = 2;

    while (
      await prisma.business.findUnique({
        where: {
          slug: candidateSlug
        },
        select: {
          id: true
        }
      })
    ) {
      candidateSlug = `${baseSlug}-${suffix}`;
      suffix += 1;
    }

    return candidateSlug;
  }

  private slugify(value: string): string {
    const slug = value
      .normalize('NFKD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');

    return slug || 'business';
  }

  private mapBusiness(business: Business) {
    return {
      id: business.id,
      name: business.name,
      slug: business.slug,
      type: business.type,
      logoUrl: business.logoUrl,
      coverUrl: business.coverUrl,
      currency: business.currency,
      language: business.language,
      city: business.city,
      status: business.status
    };
  }

  private mapPublicMenu(slug: string) {
    const path = `/m/${slug}`;
    const url = `${this.getCustomerWebBaseUrl()}${path}`;

    return {
      slug,
      path,
      url,
      qrPayload: url
    };
  }

  private getCustomerWebBaseUrl() {
    const configuredBaseUrl = this.configService.get<string>(
      'CUSTOMER_WEB_BASE_URL',
      'http://localhost:3001'
    );

    return configuredBaseUrl.replace(/\/+$/, '');
  }

  private mapMember(membership: BusinessMemberRecord) {
    return {
      id: membership.id,
      userId: membership.userId,
      clerkUserId: membership.user.clerkUserId,
      email: membership.user.email,
      name: membership.user.name,
      phone: membership.user.phone,
      role: membership.role,
      isActive: membership.status === BusinessUserStatus.ACTIVE,
      createdAt: membership.createdAt,
      updatedAt: membership.updatedAt
    };
  }

  private isUniqueConstraintError(error: unknown): boolean {
    return (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    );
  }

  private isRecordNotFoundError(error: unknown): boolean {
    return (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2025'
    );
  }
}

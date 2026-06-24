import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import {
  BusinessUser,
  BusinessUserRole,
  BusinessUserStatus,
  Prisma
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';

type BusinessPermissionSet = {
  canManageBusiness: boolean;
  canManageMenu: boolean;
  canManageMembers: boolean;
  canViewMembers: boolean;
  canViewPublicLink: boolean;
  canManageAppearance: boolean;
};

@Injectable()
export class BusinessAccessService {
  readonly appContextRoles = [
    BusinessUserRole.OWNER,
    BusinessUserRole.MANAGER,
    BusinessUserRole.STAFF
  ];
  readonly ownerRoles = [BusinessUserRole.OWNER];
  readonly menuManagerRoles = [BusinessUserRole.OWNER, BusinessUserRole.MANAGER];
  readonly memberViewerRoles = [BusinessUserRole.OWNER, BusinessUserRole.MANAGER];

  constructor(private readonly prisma: PrismaService) {}

  async assertMembership(
    businessId: string,
    userId: string
  ): Promise<BusinessUser> {
    const business = await this.prisma.business.findUnique({
      where: { id: businessId },
      select: { id: true }
    });

    if (!business) {
      throw new NotFoundException('Business not found');
    }

    const membership = await this.prisma.businessUser.findUnique({
      where: {
        businessId_userId: {
          businessId,
          userId
        }
      }
    });

    if (!membership || membership.status !== BusinessUserStatus.ACTIVE) {
      throw new ForbiddenException('Business membership required');
    }

    return membership;
  }

  async assertRole(
    businessId: string,
    userId: string,
    allowedRoles: BusinessUserRole[]
  ): Promise<BusinessUser> {
    const membership = await this.assertMembership(businessId, userId);

    if (!allowedRoles.includes(membership.role)) {
      throw new ForbiddenException('Insufficient business role');
    }

    return membership;
  }

  assertOwner(businessId: string, userId: string): Promise<BusinessUser> {
    return this.assertRole(businessId, userId, this.ownerRoles);
  }

  getPermissions(role: BusinessUserRole): BusinessPermissionSet {
    return {
      canManageBusiness: role === BusinessUserRole.OWNER,
      canManageMenu:
        role === BusinessUserRole.OWNER || role === BusinessUserRole.MANAGER,
      canManageMembers: role === BusinessUserRole.OWNER,
      canViewMembers:
        role === BusinessUserRole.OWNER || role === BusinessUserRole.MANAGER,
      canViewPublicLink: true,
      canManageAppearance: role === BusinessUserRole.OWNER
    };
  }

  async assertAnotherActiveOwnerExists(
    businessId: string,
    excludedMembershipId: string,
    prisma: Prisma.TransactionClient | PrismaService = this.prisma
  ) {
    const remainingActiveOwnerCount = await prisma.businessUser.count({
      where: {
        businessId,
        role: BusinessUserRole.OWNER,
        status: BusinessUserStatus.ACTIVE,
        NOT: {
          id: excludedMembershipId
        }
      }
    });

    if (remainingActiveOwnerCount === 0) {
      throw new BadRequestException('Cannot remove the last active OWNER');
    }
  }
}

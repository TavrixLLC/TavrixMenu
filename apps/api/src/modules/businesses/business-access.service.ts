import {
  ForbiddenException,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import {
  BusinessUser,
  BusinessUserRole,
  BusinessUserStatus
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class BusinessAccessService {
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
}

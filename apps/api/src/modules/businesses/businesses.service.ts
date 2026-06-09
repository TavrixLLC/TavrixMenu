import {
  ConflictException,
  Injectable,
  NotFoundException
} from '@nestjs/common';
import {
  Business,
  BusinessUserRole,
  BusinessUserStatus,
  Prisma
} from '../../generated/prisma';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessAccessService } from './business-access.service';
import { CreateBusinessDto } from './dto/create-business.dto';
import { UpdateBusinessDto } from './dto/update-business.dto';

@Injectable()
export class BusinessesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly businessAccessService: BusinessAccessService
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
    await this.businessAccessService.assertRole(businessId, currentUser.id, [
      BusinessUserRole.OWNER,
      BusinessUserRole.MANAGER
    ]);

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

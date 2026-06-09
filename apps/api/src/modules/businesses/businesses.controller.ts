import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiTags
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClerkAuthGuard } from '../auth/guards/clerk-auth.guard';
import { AuthenticatedUser } from '../auth/interfaces/authenticated-user.interface';
import { BusinessesService } from './businesses.service';
import { CreateBusinessDto } from './dto/create-business.dto';
import { UpdateBusinessDto } from './dto/update-business.dto';

@ApiTags('businesses')
@ApiBearerAuth()
@UseGuards(ClerkAuthGuard)
@Controller('businesses')
export class BusinessesController {
  constructor(private readonly businessesService: BusinessesService) {}

  @Post()
  @ApiCreatedResponse({ description: 'Business created.' })
  createBusiness(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Body() dto: CreateBusinessDto
  ) {
    return this.businessesService.createBusiness(currentUser, dto);
  }

  @Get('me')
  @ApiOkResponse({ description: 'Businesses for the current user.' })
  getMyBusinesses(@CurrentUser() currentUser: AuthenticatedUser) {
    return this.businessesService.getMyBusinesses(currentUser);
  }

  @Patch(':id')
  @ApiOkResponse({ description: 'Business updated.' })
  updateBusiness(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Param('id') businessId: string,
    @Body() dto: UpdateBusinessDto
  ) {
    return this.businessesService.updateBusiness(currentUser, businessId, dto);
  }
}

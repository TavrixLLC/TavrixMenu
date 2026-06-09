import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException
} from '@nestjs/common';
import { ClerkTokenVerifierService } from '../clerk-token-verifier.service';
import { AuthenticatedRequest } from '../interfaces/authenticated-request.interface';
import { UserSyncService } from '../user-sync.service';

@Injectable()
export class ClerkAuthGuard implements CanActivate {
  constructor(
    private readonly clerkTokenVerifier: ClerkTokenVerifierService,
    private readonly userSyncService: UserSyncService
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const authorizationHeader = this.readAuthorizationHeader(request);

    if (!authorizationHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing bearer token');
    }

    const token = authorizationHeader.slice('Bearer '.length).trim();

    if (!token) {
      throw new UnauthorizedException('Missing bearer token');
    }

    const verifiedUser = await this.clerkTokenVerifier.verifyToken(token);
    request.currentUser = await this.userSyncService.syncUser(verifiedUser);

    return true;
  }

  private readAuthorizationHeader(
    request: AuthenticatedRequest
  ): string | undefined {
    const header =
      request.headers.authorization ?? request.headers.Authorization;

    if (Array.isArray(header)) {
      return header[0];
    }

    return header;
  }
}

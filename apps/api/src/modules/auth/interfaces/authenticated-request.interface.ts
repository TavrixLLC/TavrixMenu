import { AuthenticatedUser } from './authenticated-user.interface';

export interface AuthenticatedRequest {
  headers: Record<string, string | string[] | undefined>;
  currentUser?: AuthenticatedUser;
}

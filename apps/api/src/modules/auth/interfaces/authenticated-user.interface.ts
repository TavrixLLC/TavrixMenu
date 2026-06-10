import { UserStatus } from '../../../generated/prisma';

export interface AuthenticatedUser {
  id: string;
  clerkUserId: string;
  name: string | null;
  email: string | null;
  phone: string | null;
  status: UserStatus;
}

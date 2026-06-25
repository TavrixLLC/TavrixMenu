import { proxyAppleWalletPass } from '../../../../../lib/apple-wallet-proxy';

type AppleWalletRouteContext = {
  params: Promise<{
    token: string;
  }>;
};

export const dynamic = 'force-dynamic';

export async function POST(
  _request: Request,
  context: AppleWalletRouteContext
) {
  const { token } = await context.params;

  return proxyAppleWalletPass({ token });
}

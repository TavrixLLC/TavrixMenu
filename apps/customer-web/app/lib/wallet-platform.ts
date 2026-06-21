export type WalletPlatform = 'ios' | 'android' | 'desktop';

type WalletPlatformInput = {
  userAgent: string;
  platform?: string;
  maxTouchPoints?: number;
};

export function detectWalletPlatform({
  userAgent,
  platform = '',
  maxTouchPoints = 0
}: WalletPlatformInput): WalletPlatform {
  if (/iPhone|iPad|iPod/i.test(userAgent)) {
    return 'ios';
  }

  // Newer iPads can identify as macOS while still supporting touch.
  if (/Mac/i.test(platform) && maxTouchPoints > 1) {
    return 'ios';
  }

  if (/Android/i.test(userAgent)) {
    return 'android';
  }

  return 'desktop';
}

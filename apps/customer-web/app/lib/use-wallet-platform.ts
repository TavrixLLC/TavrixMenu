'use client';

import { useEffect, useState } from 'react';
import { detectWalletPlatform, type WalletPlatform } from './wallet-platform';

export function useWalletPlatform() {
  const [platform, setPlatform] = useState<WalletPlatform | null>(null);

  useEffect(() => {
    setPlatform(
      detectWalletPlatform({
        userAgent: navigator.userAgent,
        platform: navigator.platform,
        maxTouchPoints: navigator.maxTouchPoints
      })
    );
  }, []);

  return platform;
}

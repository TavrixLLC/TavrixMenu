import {
  resolveWalletPassVisualTheme,
  WalletPassVisualThemeSource
} from '../loyalty/wallet-pass-visual.resolver';
import { AppleWalletPassTheme } from './apple-wallet.types';

export function resolveAppleWalletPassTheme(
  program: WalletPassVisualThemeSource
): AppleWalletPassTheme {
  return resolveWalletPassVisualTheme(program);
}

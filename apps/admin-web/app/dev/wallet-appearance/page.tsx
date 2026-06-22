import { notFound } from 'next/navigation';
import { WalletAppearanceDevPreview } from './WalletAppearanceDevPreview';

export const metadata = {
  title: 'Wallet Appearance Preview'
};

export default function WalletAppearancePreviewPage() {
  const enabled =
    process.env.NODE_ENV !== 'production' &&
    process.env.NEXT_PUBLIC_ENABLE_DEV_PREVIEWS === 'true';

  if (!enabled) {
    notFound();
  }

  return <WalletAppearanceDevPreview />;
}

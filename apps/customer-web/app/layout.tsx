import type { Metadata } from 'next';
import './globals.css';
import './styles/public-menu-contract.css';
import './styles/menu-templates/waflo-warm.css';
import './styles/menu-templates/coffeehouse-premium.css';
import './styles/menu-templates/street-bites.css';
import './styles/menu-templates/minimal-modern.css';

export const metadata: Metadata = {
  title: 'Tavrix Menu Customer Web',
  description: 'Public Tavrix Menu customer website foundation.'
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

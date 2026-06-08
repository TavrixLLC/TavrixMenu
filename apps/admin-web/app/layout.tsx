import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Tavrix Menu Admin',
  description: 'Internal Tavrix Menu service owner dashboard foundation.'
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  // ClerkProvider will wrap this layout when service-owner auth is enabled.
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

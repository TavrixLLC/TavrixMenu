import { ClerkProvider } from '@clerk/nextjs';
import type { Metadata } from 'next';
import './globals.css';
import { isClerkConfigured } from './lib/config';

export const metadata: Metadata = {
  title: 'Tavrix Menu Admin',
  description: 'Internal Tavrix Menu service owner dashboard foundation.'
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  const document = (
    <html lang="en">
      <body>{children}</body>
    </html>
  );

  if (!isClerkConfigured()) {
    return document;
  }

  return <ClerkProvider>{document}</ClerkProvider>;
}

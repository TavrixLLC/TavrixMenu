import type { Metadata } from 'next';
import './globals.css';

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

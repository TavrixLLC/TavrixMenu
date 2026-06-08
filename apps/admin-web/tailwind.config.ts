import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        panel: '#ffffff',
        ink: '#18181b',
        accent: '#2563eb'
      }
    }
  },
  plugins: []
};

export default config;

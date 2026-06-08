import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#171717',
        saffron: '#f6b23c',
        mint: '#3fbf8f'
      }
    }
  },
  plugins: []
};

export default config;

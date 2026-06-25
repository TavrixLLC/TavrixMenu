import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        coral: '#FF6B4A',
        coralDark: '#D94B2B',
        green: '#43A047',
        greenDark: '#2E7D32',
        cream: '#FFF8F2',
        surface: '#FFFFFF',
        ink: '#1F2933',
        muted: '#6B7280',
        borderSoft: '#F1E2D6',
        reward: '#F59E0B',
        danger: '#DC2626',
        saffron: '#F59E0B',
        mint: '#43A047'
      }
    }
  },
  plugins: []
};

export default config;

import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        panel: '#ffffff',
        ink: '#1F2933',
        muted: '#6B7280',
        accent: '#FF6B4A',
        accentDark: '#D94B2B',
        success: '#43A047',
        successDark: '#2E7D32',
        cream: '#FFF8F2',
        borderSoft: '#F1E2D6',
        reward: '#F59E0B',
        danger: '#DC2626'
      }
    }
  },
  plugins: []
};

export default config;

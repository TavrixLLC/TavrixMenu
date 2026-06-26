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
        danger: '#DC2626',
        waflo: {
          charcoal: '#1F2933',
          muted: '#64707D',
          coral: '#FF6B4A',
          coralDark: '#C9482A',
          coralSoft: '#FFF0EA',
          green: '#43A047',
          greenDark: '#256C2D',
          greenSoft: '#ECF8EF',
          cream: '#FFF8F2',
          white: '#FFFFFF',
          gold: '#F59E0B',
          goldDark: '#92400E',
          goldSoft: '#FFF7E6',
          red: '#DC2626',
          redSoft: '#FEF2F2',
          border: '#E8DED4'
        }
      },
      boxShadow: {
        subtle: '0 1px 2px rgba(31, 41, 51, 0.06), 0 1px 3px rgba(31, 41, 51, 0.08)',
        premium: '0 16px 40px rgba(31, 41, 51, 0.12)'
      },
      fontFamily: {
        sans: [
          'Inter',
          'ui-sans-serif',
          'system-ui',
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'sans-serif'
        ]
      }
    }
  },
  plugins: []
};

export default config;

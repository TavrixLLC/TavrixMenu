const DEFAULT_API_BASE_URL = 'http://localhost:3000';

export function getApiBaseUrl() {
  return (process.env.API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE_URL || DEFAULT_API_BASE_URL).replace(/\/+$/, '');
}

export function getPublicApiBaseUrl() {
  return (process.env.NEXT_PUBLIC_API_BASE_URL || DEFAULT_API_BASE_URL).replace(/\/+$/, '');
}

export function getAppEnv() {
  return process.env.APP_ENV || process.env.NODE_ENV || 'development';
}

export function isClerkConfigured() {
  return Boolean(process.env.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY?.trim());
}

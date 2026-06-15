type Environment = Record<string, string | undefined>;

const allowedNodeEnvironments = new Set(['development', 'test', 'production']);
const booleanValues = new Map([
  ['true', true],
  ['1', true],
  ['yes', true],
  ['false', false],
  ['0', false],
  ['no', false]
]);

export function validateEnvironment(config: Environment) {
  const nodeEnv = config.NODE_ENV ?? 'development';

  if (!allowedNodeEnvironments.has(nodeEnv)) {
    throw new Error('NODE_ENV must be development, test, or production');
  }

  const apiPort = Number(config.API_PORT ?? 3000);

  if (!Number.isInteger(apiPort) || apiPort <= 0) {
    throw new Error('API_PORT must be a positive integer');
  }

  if (nodeEnv !== 'development' && !config.CLERK_JWT_ISSUER) {
    throw new Error(
      'CLERK_JWT_ISSUER is required when NODE_ENV is test or production'
    );
  }

  const googleWalletEnabled = parseBoolean(
    config.GOOGLE_WALLET_ENABLED,
    false,
    'GOOGLE_WALLET_ENABLED'
  );
  const googleWalletOrigins = parseOrigins(config.GOOGLE_WALLET_ORIGINS);
  const googleWalletIssuerId = config.GOOGLE_WALLET_ISSUER_ID?.trim() ?? '';
  const googleWalletCredentialsPath =
    config.GOOGLE_WALLET_CREDENTIALS_PATH?.trim() ?? '';

  if (googleWalletEnabled) {
    if (!googleWalletIssuerId) {
      throw new Error(
        'GOOGLE_WALLET_ISSUER_ID is required when GOOGLE_WALLET_ENABLED=true'
      );
    }

    if (!/^\d+$/.test(googleWalletIssuerId)) {
      throw new Error('GOOGLE_WALLET_ISSUER_ID must contain only digits');
    }

    if (!googleWalletCredentialsPath) {
      throw new Error(
        'GOOGLE_WALLET_CREDENTIALS_PATH is required when GOOGLE_WALLET_ENABLED=true'
      );
    }

    if (googleWalletOrigins.length === 0) {
      throw new Error(
        'GOOGLE_WALLET_ORIGINS must include at least one origin when GOOGLE_WALLET_ENABLED=true'
      );
    }
  }

  return {
    ...config,
    NODE_ENV: nodeEnv,
    API_PORT: apiPort,
    CUSTOMER_WEB_BASE_URL:
      config.CUSTOMER_WEB_BASE_URL ?? 'http://localhost:3001',
    GOOGLE_WALLET_ENABLED: googleWalletEnabled,
    GOOGLE_WALLET_ISSUER_ID: googleWalletIssuerId,
    GOOGLE_WALLET_CREDENTIALS_PATH: googleWalletCredentialsPath,
    GOOGLE_WALLET_ORIGINS: googleWalletOrigins
  };
}

function parseBoolean(
  value: string | undefined,
  defaultValue: boolean,
  fieldName: string
) {
  if (value === undefined || value.trim() === '') {
    return defaultValue;
  }

  const parsed = booleanValues.get(value.trim().toLowerCase());

  if (parsed === undefined) {
    throw new Error(`${fieldName} must be true or false`);
  }

  return parsed;
}

function parseOrigins(value: string | undefined) {
  if (!value?.trim()) {
    return [];
  }

  const origins = value
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean)
    .map((origin) => {
      let parsed: URL;

      try {
        parsed = new URL(origin);
      } catch {
        throw new Error('GOOGLE_WALLET_ORIGINS must contain valid URLs');
      }

      if (!['http:', 'https:'].includes(parsed.protocol)) {
        throw new Error('GOOGLE_WALLET_ORIGINS must use http or https URLs');
      }

      return parsed.origin;
    });

  return [...new Set(origins)];
}

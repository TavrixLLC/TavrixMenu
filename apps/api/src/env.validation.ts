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
  const appleWalletEnabled = parseBoolean(
    config.APPLE_WALLET_ENABLED,
    false,
    'APPLE_WALLET_ENABLED'
  );
  const appleWalletTeamId = config.APPLE_WALLET_TEAM_ID?.trim() ?? '';
  const appleWalletPassTypeIdentifier =
    config.APPLE_WALLET_PASS_TYPE_IDENTIFIER?.trim() ?? '';
  const appleWalletOrganizationName =
    config.APPLE_WALLET_ORGANIZATION_NAME?.trim() ?? '';
  const appleWalletCertificatePath =
    config.APPLE_WALLET_CERTIFICATE_PATH?.trim() ?? '';
  const appleWalletCertificatePassword =
    config.APPLE_WALLET_CERTIFICATE_PASSWORD ?? '';
  const appleWalletWwdrCertificatePath =
    config.APPLE_WALLET_WWDR_CERTIFICATE_PATH?.trim() ?? '';
  const appleWalletWebServiceEnabled = parseBoolean(
    config.APPLE_WALLET_WEB_SERVICE_ENABLED,
    false,
    'APPLE_WALLET_WEB_SERVICE_ENABLED'
  );
  const appleWalletWebServiceBaseUrlInput =
    config.APPLE_WALLET_WEB_SERVICE_BASE_URL?.trim() ?? '';
  const appleWalletUpdateAuthTokenSecret =
    config.APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET?.trim() ?? '';
  const appleWalletApnsEnabled = parseBoolean(
    config.APPLE_WALLET_APNS_ENABLED,
    false,
    'APPLE_WALLET_APNS_ENABLED'
  );
  const appleWalletApnsEnvironment =
    config.APPLE_WALLET_APNS_ENVIRONMENT?.trim().toLowerCase() ||
    (nodeEnv === 'production' ? 'production' : 'sandbox');
  const appleWalletApnsTimeoutMs = Number(
    config.APPLE_WALLET_APNS_TIMEOUT_MS ?? 10000
  );
  const appleWalletWebServiceBaseUrl = appleWalletWebServiceEnabled
    ? normalizeAppleWalletWebServiceUrl(
        appleWalletWebServiceBaseUrlInput,
        nodeEnv
      )
    : appleWalletWebServiceBaseUrlInput;
  const walletImagePublicBaseUrl = normalizeOptionalHttpsUrl(
    config.WALLET_IMAGE_PUBLIC_BASE_URL,
    'WALLET_IMAGE_PUBLIC_BASE_URL'
  );
  const walletScanTokenSecret = config.WALLET_SCAN_TOKEN_SECRET?.trim() ?? '';

  if (!['sandbox', 'production'].includes(appleWalletApnsEnvironment)) {
    throw new Error(
      'APPLE_WALLET_APNS_ENVIRONMENT must be sandbox or production'
    );
  }

  if (
    !Number.isInteger(appleWalletApnsTimeoutMs) ||
    appleWalletApnsTimeoutMs < 100 ||
    appleWalletApnsTimeoutMs > 60000
  ) {
    throw new Error(
      'APPLE_WALLET_APNS_TIMEOUT_MS must be an integer between 100 and 60000'
    );
  }

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

  if (appleWalletEnabled) {
    requireAppleWalletValue(appleWalletTeamId, 'APPLE_WALLET_TEAM_ID');
    requireAppleWalletValue(
      appleWalletPassTypeIdentifier,
      'APPLE_WALLET_PASS_TYPE_IDENTIFIER'
    );
    requireAppleWalletValue(
      appleWalletOrganizationName,
      'APPLE_WALLET_ORGANIZATION_NAME'
    );
    requireAppleWalletValue(
      appleWalletCertificatePath,
      'APPLE_WALLET_CERTIFICATE_PATH'
    );
    requireAppleWalletValue(
      appleWalletCertificatePassword,
      'APPLE_WALLET_CERTIFICATE_PASSWORD'
    );
    requireAppleWalletValue(
      appleWalletWwdrCertificatePath,
      'APPLE_WALLET_WWDR_CERTIFICATE_PATH'
    );

    if (!/^[A-Z0-9]{10}$/.test(appleWalletTeamId)) {
      throw new Error('APPLE_WALLET_TEAM_ID must be a 10-character team ID');
    }

    if (!/^pass\.[A-Za-z0-9.-]+$/.test(appleWalletPassTypeIdentifier)) {
      throw new Error(
        'APPLE_WALLET_PASS_TYPE_IDENTIFIER must start with pass.'
      );
    }
  }

  if (
    (googleWalletEnabled || appleWalletEnabled) &&
    walletScanTokenSecret.length < 32
  ) {
    throw new Error(
      'WALLET_SCAN_TOKEN_SECRET must be at least 32 characters when a wallet integration is enabled'
    );
  }

  if (
    appleWalletWebServiceEnabled &&
    appleWalletUpdateAuthTokenSecret &&
    appleWalletUpdateAuthTokenSecret.length < 32
  ) {
    throw new Error(
      'APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET must be at least 32 characters'
    );
  }

  if (appleWalletApnsEnabled && nodeEnv !== 'development') {
    if (!appleWalletEnabled) {
      throw new Error(
        'APPLE_WALLET_ENABLED must be true when APNs is enabled outside development'
      );
    }

    if (appleWalletApnsEnvironment !== 'production') {
      throw new Error(
        'APPLE_WALLET_APNS_ENVIRONMENT must be production outside development'
      );
    }
  }

  return {
    ...config,
    NODE_ENV: nodeEnv,
    API_PORT: apiPort,
    MEDIA_UPLOAD_ROOT:
      config.MEDIA_UPLOAD_ROOT?.trim() ||
      (nodeEnv === 'production' ? '/opt/waflo/uploads' : 'public/uploads'),
    CUSTOMER_WEB_BASE_URL:
      config.CUSTOMER_WEB_BASE_URL ?? 'http://localhost:3001',
    GOOGLE_WALLET_ENABLED: googleWalletEnabled,
    GOOGLE_WALLET_ISSUER_ID: googleWalletIssuerId,
    GOOGLE_WALLET_CREDENTIALS_PATH: googleWalletCredentialsPath,
    GOOGLE_WALLET_ORIGINS: googleWalletOrigins,
    APPLE_WALLET_ENABLED: appleWalletEnabled,
    APPLE_WALLET_TEAM_ID: appleWalletTeamId,
    APPLE_WALLET_PASS_TYPE_IDENTIFIER: appleWalletPassTypeIdentifier,
    APPLE_WALLET_ORGANIZATION_NAME: appleWalletOrganizationName,
    APPLE_WALLET_CERTIFICATE_PATH: appleWalletCertificatePath,
    APPLE_WALLET_CERTIFICATE_PASSWORD: appleWalletCertificatePassword,
    APPLE_WALLET_WWDR_CERTIFICATE_PATH: appleWalletWwdrCertificatePath,
    APPLE_WALLET_WEB_SERVICE_ENABLED: appleWalletWebServiceEnabled,
    APPLE_WALLET_WEB_SERVICE_BASE_URL: appleWalletWebServiceBaseUrl,
    APPLE_WALLET_UPDATE_AUTH_TOKEN_SECRET:
      appleWalletUpdateAuthTokenSecret,
    APPLE_WALLET_APNS_ENABLED: appleWalletApnsEnabled,
    APPLE_WALLET_APNS_ENVIRONMENT: appleWalletApnsEnvironment,
    APPLE_WALLET_APNS_TIMEOUT_MS: appleWalletApnsTimeoutMs,
    WALLET_IMAGE_PUBLIC_BASE_URL: walletImagePublicBaseUrl,
    WALLET_SCAN_TOKEN_SECRET: walletScanTokenSecret
  };
}

function normalizeAppleWalletWebServiceUrl(value: string, nodeEnv: string) {
  if (!value) {
    return '';
  }

  let parsed: URL;

  try {
    parsed = new URL(value);
  } catch {
    throw new Error('APPLE_WALLET_WEB_SERVICE_BASE_URL must be a valid URL');
  }

  if (!['http:', 'https:'].includes(parsed.protocol)) {
    throw new Error(
      'APPLE_WALLET_WEB_SERVICE_BASE_URL must use http or https'
    );
  }

  if (nodeEnv === 'production') {
    if (parsed.protocol !== 'https:') {
      throw new Error(
        'APPLE_WALLET_WEB_SERVICE_BASE_URL must use HTTPS in production'
      );
    }

    if (isLocalOrPrivateHostname(parsed.hostname)) {
      throw new Error(
        'APPLE_WALLET_WEB_SERVICE_BASE_URL cannot use a local or private host in production'
      );
    }
  }

  const normalized = parsed.toString().replace(/\/$/, '');

  return normalized.replace(/\/v1$/i, '');
}

function isLocalOrPrivateHostname(value: string) {
  const hostname = value.toLowerCase().replace(/^\[|\]$/g, '');

  if (
    hostname === 'localhost' ||
    hostname.endsWith('.localhost') ||
    hostname.endsWith('.local') ||
    hostname === '::1' ||
    (hostname.includes(':') &&
      (hostname.startsWith('fc') ||
        hostname.startsWith('fd') ||
        hostname.startsWith('fe80:')))
  ) {
    return true;
  }

  const octets = hostname.split('.').map(Number);

  if (
    octets.length !== 4 ||
    octets.some((octet) => !Number.isInteger(octet) || octet < 0 || octet > 255)
  ) {
    return false;
  }

  return (
    octets[0] === 0 ||
    octets[0] === 10 ||
    octets[0] === 127 ||
    (octets[0] === 169 && octets[1] === 254) ||
    (octets[0] === 172 && octets[1] >= 16 && octets[1] <= 31) ||
    (octets[0] === 192 && octets[1] === 168)
  );
}

function requireAppleWalletValue(value: string, fieldName: string) {
  if (!value) {
    throw new Error(`${fieldName} is required when APPLE_WALLET_ENABLED=true`);
  }
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

function normalizeOptionalHttpsUrl(value: string | undefined, fieldName: string) {
  const normalized = value?.trim();

  if (!normalized) {
    return '';
  }

  let parsed: URL;

  try {
    parsed = new URL(normalized);
  } catch {
    throw new Error(`${fieldName} must be a valid HTTPS URL`);
  }

  if (parsed.protocol !== 'https:') {
    throw new Error(`${fieldName} must start with https://`);
  }

  return parsed.toString().replace(/\/$/, '');
}

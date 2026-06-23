const IRAQI_LOCAL_PHONE_PATTERN = /^07\d{9}$/;
const IRAQI_INTERNATIONAL_PHONE_PATTERN = /^\+9647\d{9}$/;
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

export function normalizeIraqiPhone(value: string): string | null {
  const compact = value.trim().replace(/[\s\-()]/g, '');

  if (IRAQI_LOCAL_PHONE_PATTERN.test(compact)) {
    return `+964${compact.slice(1)}`;
  }

  if (IRAQI_INTERNATIONAL_PHONE_PATTERN.test(compact)) {
    return compact;
  }

  return null;
}

export function validateIraqiPhone(value: string): string | null {
  if (!value.trim()) {
    return 'Enter your phone number.';
  }

  if (!normalizeIraqiPhone(value)) {
    return 'Enter an Iraqi number as 07xxxxxxxxx or +9647xxxxxxxxx.';
  }

  return null;
}

export function validateOptionalEmail(value: string): string | null {
  const normalized = value.trim();

  if (!normalized) {
    return null;
  }

  if (normalized.length > 200 || !EMAIL_PATTERN.test(normalized)) {
    return 'Enter a valid email address, or leave this field empty.';
  }

  return null;
}

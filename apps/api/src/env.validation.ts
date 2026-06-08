type Environment = Record<string, string | undefined>;

const allowedNodeEnvironments = new Set(['development', 'test', 'production']);

export function validateEnvironment(config: Environment) {
  const nodeEnv = config.NODE_ENV ?? 'development';

  if (!allowedNodeEnvironments.has(nodeEnv)) {
    throw new Error('NODE_ENV must be development, test, or production');
  }

  const apiPort = Number(config.API_PORT ?? 3000);

  if (!Number.isInteger(apiPort) || apiPort <= 0) {
    throw new Error('API_PORT must be a positive integer');
  }

  return {
    ...config,
    NODE_ENV: nodeEnv,
    API_PORT: apiPort
  };
}

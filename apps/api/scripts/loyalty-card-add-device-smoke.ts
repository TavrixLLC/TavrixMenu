type CardResponse = {
  cardState: {
    stampCount: number;
    stampGoal: number;
    rewardReady: boolean;
    totalStampsEarned: number;
    totalRewardsRedeemed: number;
  };
};

type TransferResponse = {
  transferToken: string;
};

type RedemptionResponse = {
  cardAccess: {
    token: string;
  };
};

async function main() {
  const apiBaseUrl = requireEnvironment('API_BASE_URL').replace(/\/+$/, '');
  const oldCardToken = requireEnvironment('LOYALTY_CARD_SMOKE_TOKEN');

  const oldBefore = await requestJson<CardResponse>(
    `${apiBaseUrl}/public/loyalty/cards/${encodeURIComponent(oldCardToken)}`
  );
  const transfer = await requestJson<TransferResponse>(
    `${apiBaseUrl}/public/loyalty/card-transfers`,
    {
      method: 'POST',
      body: {
        cardToken: oldCardToken
      }
    }
  );
  const redemption = await requestJson<RedemptionResponse>(
    `${apiBaseUrl}/public/loyalty/card-transfers/redeem`,
    {
      method: 'POST',
      body: {
        transferToken: transfer.transferToken
      }
    }
  );

  const [oldAfter, newAfter] = await Promise.all([
    requestJson<CardResponse>(
      `${apiBaseUrl}/public/loyalty/cards/${encodeURIComponent(oldCardToken)}`
    ),
    requestJson<CardResponse>(
      `${apiBaseUrl}/public/loyalty/cards/${encodeURIComponent(redemption.cardAccess.token)}`
    )
  ]);

  const beforeState = JSON.stringify(oldBefore.cardState);
  const oldState = JSON.stringify(oldAfter.cardState);
  const newState = JSON.stringify(newAfter.cardState);

  if (beforeState !== oldState || oldState !== newState) {
    throw new Error('CARD_STATE_MISMATCH_AFTER_TRANSFER');
  }

  console.log('OLD_DEVICE_STILL_VALID_AFTER_TRANSFER');
}

async function requestJson<T>(
  url: string,
  options: {
    method?: 'POST';
    body?: Record<string, string>;
  } = {}
) {
  const response = await fetch(url, {
    method: options.method ?? 'GET',
    headers: options.body
      ? {
          Accept: 'application/json',
          'Content-Type': 'application/json'
        }
      : {
          Accept: 'application/json'
        },
    body: options.body ? JSON.stringify(options.body) : undefined
  });

  if (!response.ok) {
    throw new Error(`HTTP_${response.status}`);
  }

  return (await response.json()) as T;
}

function requireEnvironment(name: string) {
  const value = process.env[name]?.trim();

  if (!value) {
    throw new Error(`MISSING_${name}`);
  }

  return value;
}

void main().catch((error: unknown) => {
  const message =
    error instanceof Error ? error.message : 'UNKNOWN_SMOKE_FAILURE';
  console.error(message);
  process.exitCode = 1;
});

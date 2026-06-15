export type GoogleWalletLocalizedString = {
  defaultValue: {
    language: string;
    value: string;
  };
};

export type GoogleWalletImage = {
  sourceUri: {
    uri: string;
  };
  contentDescription: GoogleWalletLocalizedString;
};

export type GoogleWalletLoyaltyClassPayload = {
  id: string;
  issuerName: string;
  reviewStatus: 'UNDER_REVIEW';
  programName: string;
  programLogo: GoogleWalletImage;
  accountNameLabel: string;
  accountIdLabel: string;
  rewardsTierLabel?: string;
  rewardsTier?: string;
  hexBackgroundColor?: string;
  textModulesData?: Array<{
    id: string;
    header: string;
    body: string;
  }>;
};

export type GoogleWalletLoyaltyObjectPayload = {
  id: string;
  classId: string;
  state: 'ACTIVE';
  accountName: string;
  accountId: string;
  loyaltyPoints: {
    label: string;
    balance: {
      int?: number;
      string?: string;
    };
  };
  barcode?: {
    type: 'QR_CODE' | 'CODE_128' | 'PDF_417' | 'AZTEC';
    value: string;
    alternateText?: string;
  };
  textModulesData?: Array<{
    id: string;
    header: string;
    body: string;
  }>;
};

export type GoogleWalletExistingLoyaltyObjectRef = {
  id: string;
  classId: string;
};

export type BuildLoyaltyClassPayloadInput = {
  classSuffix: string;
  issuerName?: string;
  programName?: string;
  logoUrl?: string;
  accountNameLabel?: string;
  accountIdLabel?: string;
  rewardsTierLabel?: string;
  rewardsTier?: string;
  rewardDescription?: string;
  hexBackgroundColor?: string;
};

export type BuildLoyaltyObjectPayloadInput = {
  classSuffix: string;
  objectSuffix: string;
  accountName: string;
  accountId: string;
  stampCount: number;
  stampGoal: number;
  rewardName: string;
  barcodeValue?: string;
};

export type GenerateSaveJwtInput = {
  loyaltyObject:
    | GoogleWalletLoyaltyObjectPayload
    | GoogleWalletExistingLoyaltyObjectRef;
  loyaltyClass?: GoogleWalletLoyaltyClassPayload;
};

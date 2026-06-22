import { WalletScanTokenPassFields } from '../google-wallet/wallet-scan-token.service';
import { WalletPassVisualTheme } from '../loyalty/wallet-pass-visual.resolver';

export type AppleWalletReadiness =
  | 'DISABLED'
  | 'NOT_CONFIGURED'
  | 'READY';

export type AppleWalletPassField = {
  key: string;
  label: string;
  value: string | number;
  textAlignment?: 'PKTextAlignmentLeft' | 'PKTextAlignmentRight';
};

export type AppleWalletBarcode = {
  format: 'PKBarcodeFormatQR';
  message: string;
  messageEncoding: 'iso-8859-1';
  altText: string;
};

export type AppleWalletPassPayload = {
  formatVersion: 1;
  passTypeIdentifier: string;
  serialNumber: string;
  teamIdentifier: string;
  organizationName: string;
  description: string;
  logoText: string;
  foregroundColor: string;
  backgroundColor: string;
  labelColor: string;
  suppressStripShine: true;
  sharingProhibited: true;
  webServiceURL?: string;
  authenticationToken?: string;
  storeCard: {
    headerFields: AppleWalletPassField[];
    primaryFields: AppleWalletPassField[];
    secondaryFields: AppleWalletPassField[];
    auxiliaryFields: AppleWalletPassField[];
    backFields: AppleWalletPassField[];
  };
  barcodes: AppleWalletBarcode[];
};

export type BuildAppleWalletPassInput = {
  passTypeIdentifier: string;
  serialNumber: string;
  teamIdentifier: string;
  organizationName: string;
  barcodeValue: string;
  businessName?: string;
  programName?: string;
  programDescription?: string;
  stampCount: number;
  stampGoal: number;
  rewardName?: string;
  rewardDescription?: string;
  terms?: string;
  theme?: AppleWalletPassTheme;
  webServiceURL?: string;
  authenticationToken?: string;
};

export type AppleWalletPassTheme = Partial<WalletPassVisualTheme>;

export type AppleWalletPassAssets = Record<string, Buffer>;

export type GenerateAppleWalletPassInput = Omit<
  BuildAppleWalletPassInput,
  'passTypeIdentifier' | 'teamIdentifier' | 'organizationName' | 'barcodeValue'
> & {
  scanTokenPass: WalletScanTokenPassFields;
  updateAuthenticationToken?: string;
};

export type AppleWalletPassMetadata = {
  passTypeIdentifier: string;
  serialNumber: string;
  fileSize: number;
};

export type AppleWalletPassGenerationResult = {
  pass: Buffer;
  metadata: AppleWalletPassMetadata;
  scanTokenMetadata: {
    scanTokenHash: string;
    scanTokenVersion: number;
    scanTokenIssuedAt: Date;
    scanTokenLast4: string;
  };
};

enum CustomerVerificationMethod { otp }

enum CustomerRecoveryPath { oldAndNewPhoneOtp, authorizedManualRecovery }

class CustomerAccountPresentationContract {
  const CustomerAccountPresentationContract({
    required this.businessId,
    required this.customerAccountId,
    this.phoneNormalized,
    this.emailNormalized,
    this.phoneVerifiedAt,
    this.emailVerifiedAt,
  });

  final String businessId;
  final String customerAccountId;
  final String? phoneNormalized;
  final String? emailNormalized;
  final DateTime? phoneVerifiedAt;
  final DateTime? emailVerifiedAt;
}

/// Backend assumptions approved for later implementation. Phase 1 performs no
/// persistence, recovery, merge, or audit mutation.
abstract final class CustomerIdentityPolicyContract {
  static const CustomerVerificationMethod verificationMethod =
      CustomerVerificationMethod.otp;
  static const bool uniquenessIsBusinessScoped = true;
  static const bool crossBusinessTransferAllowed = false;
  static const bool automaticContactMergeAllowed = false;
  static const bool normalPhoneChangeRequiresOldAndNewOtp = true;
  static const bool manualRecoveryRequiresAuthorizedOwnerOrManager = true;
  static const bool recoveryRequiresActorReasonAndTimestampAudit = true;
}

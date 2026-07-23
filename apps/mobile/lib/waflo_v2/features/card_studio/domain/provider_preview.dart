enum CardPreviewProvider { web, appleWallet, googleWallet }

class ProviderPreviewCapability {
  const ProviderPreviewCapability({
    required this.provider,
    required this.isAvailable,
    required this.isDeterministicPreview,
    required this.isRealDeviceVerified,
    required this.limitations,
  });

  final CardPreviewProvider provider;
  final bool isAvailable;
  final bool isDeterministicPreview;
  final bool isRealDeviceVerified;
  final List<String> limitations;
}

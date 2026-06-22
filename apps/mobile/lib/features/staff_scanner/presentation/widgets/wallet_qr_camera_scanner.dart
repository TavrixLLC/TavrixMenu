import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

class WalletQrCameraScanner extends StatefulWidget {
  const WalletQrCameraScanner({
    required this.onTokenDetected,
    required this.onCancel,
    super.key,
  });

  final ValueChanged<String> onTokenDetected;
  final VoidCallback onCancel;

  @override
  State<WalletQrCameraScanner> createState() => _WalletQrCameraScannerState();
}

class _WalletQrCameraScannerState extends State<WalletQrCameraScanner> {
  late final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _detectionLocked = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Camera wallet scan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Point the camera at the customer wallet QR code. The code is used only for this lookup.',
          ),
          const SizedBox(height: AppSpacing.md),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    key: const ValueKey('walletCameraPreview'),
                    controller: _controller,
                    onDetect: _handleCapture,
                    onDetectError: (_, _) {},
                    errorBuilder: (context, error) => _CameraErrorView(
                      errorCode: error.errorCode,
                      onRetry: _retryCamera,
                    ),
                    placeholderBuilder: (_) => const ColoredBox(
                      color: AppColors.textBlack,
                      child: Center(
                        child: CircularProgressIndicator(
                          key: ValueKey('walletCameraStarting'),
                        ),
                      ),
                    ),
                  ),
                  const IgnorePointer(child: _ScanFrameOverlay()),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            key: const ValueKey('walletCameraCancelButton'),
            label: 'Use manual entry',
            icon: Icons.keyboard_outlined,
            onPressed: widget.onCancel,
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_detectionLocked) {
      return;
    }

    String? value;
    for (final barcode in capture.barcodes) {
      final candidate = barcode.rawValue?.trim();
      if (candidate != null && candidate.isNotEmpty) {
        value = candidate;
        break;
      }
    }
    if (value == null) {
      return;
    }

    _detectionLocked = true;
    unawaited(_controller.stop());
    widget.onTokenDetected(value);
  }

  Future<void> _retryCamera() async {
    _detectionLocked = false;
    try {
      await _controller.start();
    } on MobileScannerException {
      // The scanner widget renders the safe permission/device error state.
    }
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.errorCode, required this.onRetry});

  final MobileScannerErrorCode errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final permissionDenied =
        errorCode == MobileScannerErrorCode.permissionDenied;
    final unsupported = errorCode == MobileScannerErrorCode.unsupported;
    final message = permissionDenied
        ? 'Camera permission was denied. Allow camera access in system settings, then try again.'
        : unsupported
        ? 'Camera scanning is not supported on this device. Use manual entry instead.'
        : 'The camera could not start. Try again or use manual entry.';

    return ColoredBox(
      key: ValueKey(
        permissionDenied ? 'walletCameraPermissionDenied' : 'walletCameraError',
      ),
      color: AppColors.ceramic,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              permissionDenied
                  ? Icons.no_photography_outlined
                  : Icons.camera_alt_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
            if (!unsupported) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Try camera again',
                icon: Icons.refresh,
                onPressed: onRetry,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanFrameOverlay extends StatelessWidget {
  const _ScanFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.72,
        heightFactor: 0.72,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

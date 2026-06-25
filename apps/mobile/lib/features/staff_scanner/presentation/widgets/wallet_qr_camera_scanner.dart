import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/waflo_status_badge.dart';

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
          Text('Camera scanner', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Point the frame at the customer wallet QR. The code is processed without displaying the raw token.',
          ),
          const SizedBox(height: AppSpacing.md),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AppColors.ink),
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
                      color: AppColors.ink,
                      child: Center(
                        child: CircularProgressIndicator(
                          key: ValueKey('walletCameraStarting'),
                        ),
                      ),
                    ),
                  ),
                  const IgnorePointer(child: _ScanFrameOverlay()),
                  const PositionedDirectional(
                    start: AppSpacing.md,
                    end: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: WafloStatusBadge(
                      label: 'Ready for secure scan',
                      icon: Icons.lock_outline,
                      color: AppColors.charcoalSoft,
                      foregroundColor: AppColors.surfaceWhite,
                    ),
                  ),
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
              color: AppColors.primaryCoralDark,
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
            border: Border.all(color: AppColors.surfaceWhite, width: 3),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
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
          Text(
            context.l10n.cameraScannerTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(context.l10n.cameraScannerSubtitle),
          const SizedBox(height: AppSpacing.md),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: MobileScanner(
                key: const ValueKey('walletCameraPreview'),
                controller: _controller,
                onDetect: _handleCapture,
                onDetectError: (_, _) {},
                errorBuilder: (context, error) => WalletCameraErrorView(
                  errorCode: error.errorCode,
                  onRetry: _retryCamera,
                  onOpenSettings: _openAppSettings,
                ),
                overlayBuilder: (_, _) => const WalletCameraActiveOverlay(),
                placeholderBuilder: (_) => const ColoredBox(
                  color: AppColors.ink,
                  child: Center(
                    child: CircularProgressIndicator(
                      key: ValueKey('walletCameraStarting'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            key: ValueKey('walletCameraCancelButton'),
            label: context.l10n.enterCodeManually,
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

  Future<void> _openAppSettings() async {
    final settingsUri = Uri.parse('app-settings:');
    if (await canLaunchUrl(settingsUri)) {
      await launchUrl(settingsUri);
    }
  }
}

@visibleForTesting
class WalletCameraErrorView extends StatelessWidget {
  const WalletCameraErrorView({
    required this.errorCode,
    required this.onRetry,
    required this.onOpenSettings,
    super.key,
  });

  final MobileScannerErrorCode errorCode;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final permissionDenied =
        errorCode == MobileScannerErrorCode.permissionDenied;
    final unsupported = errorCode == MobileScannerErrorCode.unsupported;
    final message = permissionDenied
        ? context.l10n.cameraPermissionDeniedBody
        : unsupported
        ? context.l10n.cameraUnsupportedBody
        : context.l10n.cameraStartFailedBody;

    return DecoratedBox(
      key: const ValueKey('walletCameraErrorState'),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.coralTint,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Icon(
                      permissionDenied
                          ? Icons.no_photography_outlined
                          : Icons.camera_alt_outlined,
                      key: ValueKey(
                        permissionDenied
                            ? 'walletCameraPermissionDenied'
                            : 'walletCameraError',
                      ),
                      color: AppColors.primaryCoralDark,
                      size: 32,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  permissionDenied
                      ? context.l10n.cameraPermissionDeniedTitle
                      : context.l10n.cameraUnavailableTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
                if (permissionDenied ||
                    (!unsupported && !permissionDenied)) ...[
                  SizedBox(height: AppSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (permissionDenied)
                        AppButton(
                          label: context.l10n.openSettings,
                          icon: Icons.settings_outlined,
                          onPressed: onOpenSettings,
                          expand: false,
                          variant: AppButtonVariant.secondary,
                        ),
                      if (!unsupported && !permissionDenied)
                        AppButton(
                          label: context.l10n.tryCameraAgain,
                          icon: Icons.refresh,
                          onPressed: onRetry,
                          expand: false,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class WalletCameraActiveOverlay extends StatelessWidget {
  const WalletCameraActiveOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(child: _ScanFrameOverlay()),
        PositionedDirectional(
          start: AppSpacing.md,
          end: AppSpacing.md,
          bottom: AppSpacing.md,
          child: WafloStatusBadge(
            key: ValueKey('walletCameraSecureScanBadge'),
            label: context.l10n.scannerReady,
            icon: Icons.lock_outline,
            color: AppColors.charcoalSoft,
            foregroundColor: AppColors.surfaceWhite,
          ),
        ),
      ],
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
          key: const ValueKey('walletCameraScanFrameOverlay'),
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

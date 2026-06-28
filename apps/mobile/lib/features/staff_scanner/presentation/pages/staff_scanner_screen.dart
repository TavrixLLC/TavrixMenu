import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/copy/pilot_arabic_copy.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/loyalty_progress_card.dart';
import '../../../../shared/widgets/scanner_action_panel.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/wallet_scan_result.dart';
import '../bloc/wallet_scan_cubit.dart';
import '../bloc/wallet_scan_state.dart';
import '../widgets/wallet_qr_camera_scanner.dart';

typedef WalletCameraScannerBuilder =
    Widget Function(
      ValueChanged<String> onTokenDetected,
      VoidCallback onCancel,
    );

class StaffScannerScreen extends StatefulWidget {
  const StaffScannerScreen({super.key, this.cameraScannerBuilder});

  final WalletCameraScannerBuilder? cameraScannerBuilder;

  @override
  State<StaffScannerScreen> createState() => _StaffScannerScreenState();
}

class _StaffScannerScreenState extends State<StaffScannerScreen> {
  final _tokenController = TextEditingController();
  String? _pendingCameraToken;
  bool _cameraOpen = false;
  bool _cameraSubmissionLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletScanCubit>().load();
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        title: PilotArabicCopy.staffScannerTitle,
        scrollable: true,
        child: BlocBuilder<WalletScanCubit, WalletScanState>(
          builder: (context, state) {
            if ((state.status == WalletScanStatus.initial ||
                    state.status == WalletScanStatus.loading) &&
                state.business == null) {
              return const LoadingView(
                message: PilotArabicCopy.staffScannerLoading,
              );
            }

            if (state.business == null) {
              return ErrorView(
                message:
                    state.errorMessage ??
                    PilotArabicCopy.staffScannerLoadFailed,
                onRetry: () => context.read<WalletScanCubit>().load(),
              );
            }

            final isScanning = state.status == WalletScanStatus.scanning;
            final safeErrorMessage = _safeErrorMessage(
              state.errorMessage,
              _pendingCameraToken ?? _tokenController.text,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: PilotArabicCopy.staffScannerSectionTitle,
                  subtitle: PilotArabicCopy.staffScannerSectionSubtitle,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_cameraOpen)
                  _buildCameraScanner()
                else if (_pendingCameraToken == null && state.result == null)
                  ScannerActionPanel(
                    businessName: state.business?.name,
                    isBusy: isScanning,
                    onScan: _openCamera,
                  ),
                if (_pendingCameraToken != null &&
                    state.status == WalletScanStatus.failure) ...[
                  const SizedBox(height: AppSpacing.md),
                  _CameraRetryCard(
                    onRetry: _cameraSubmissionLocked ? null : _retryCameraToken,
                    onRescan: _cameraSubmissionLocked ? null : _rescan,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: PilotArabicCopy.manualCodeTitle,
                  subtitle: PilotArabicCopy.manualCodeSubtitle,
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        key: const ValueKey('walletScanTokenField'),
                        controller: _tokenController,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofillHints: const <String>[],
                        textInputAction: TextInputAction.done,
                        onSubmitted: isScanning ? null : (_) => _scanManual(),
                        decoration: const InputDecoration(
                          labelText: PilotArabicCopy.loyaltyQrCode,
                          hintText: PilotArabicCopy.loyaltyQrHint,
                          prefixIcon: Icon(Icons.qr_code_2_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        key: const ValueKey('walletScanButton'),
                        label: isScanning
                            ? PilotArabicCopy.checkingCard
                            : PilotArabicCopy.checkCard,
                        icon: Icons.document_scanner_outlined,
                        onPressed: isScanning ? null : _scanManual,
                      ),
                      if (isScanning) ...[
                        const SizedBox(height: AppSpacing.md),
                        const LinearProgressIndicator(
                          key: ValueKey('walletScanLoading'),
                        ),
                      ],
                    ],
                  ),
                ),
                if (safeErrorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ErrorView(message: safeErrorMessage),
                ],
                if (state.result != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _WalletScanResultCard(
                    result: state.result!,
                    updatedStamps: state.updatedStamps,
                    updatedGoal: state.updatedGoal,
                    stampStatus: state.stampStatus,
                    stampErrorMessage: state.stampErrorMessage,
                    onAddStamp: isScanning
                        ? null
                        : () => _addStamp(state.stampStatus),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    key: const ValueKey('walletScanAnotherButton'),
                    label: PilotArabicCopy.scanAnotherCard,
                    icon: Icons.qr_code_scanner,
                    onPressed: isScanning ? null : _rescan,
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraScanner() {
    final builder = widget.cameraScannerBuilder;
    if (builder != null) {
      return builder(_handleCameraToken, _closeCamera);
    }
    return WalletQrCameraScanner(
      onTokenDetected: _handleCameraToken,
      onCancel: _closeCamera,
    );
  }

  void _openCamera() {
    if (_cameraSubmissionLocked ||
        context.read<WalletScanCubit>().state.status ==
            WalletScanStatus.scanning) {
      return;
    }
    setState(() {
      _cameraOpen = true;
    });
  }

  void _closeCamera() {
    if (!_cameraOpen) {
      return;
    }
    setState(() {
      _cameraOpen = false;
    });
  }

  Future<void> _scanManual() async {
    final token = _tokenController.text;
    if (_cameraOpen || _pendingCameraToken != null) {
      setState(() {
        _cameraOpen = false;
        _pendingCameraToken = null;
      });
    }
    final succeeded = await _submitToken(token);
    if (succeeded && mounted) {
      _tokenController.clear();
    }
  }

  Future<void> _handleCameraToken(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty ||
        _cameraSubmissionLocked ||
        context.read<WalletScanCubit>().state.status ==
            WalletScanStatus.scanning) {
      return;
    }

    setState(() {
      _cameraSubmissionLocked = true;
      _cameraOpen = false;
      _pendingCameraToken = cleanToken;
    });

    final succeeded = await _submitToken(cleanToken);
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraSubmissionLocked = false;
      if (succeeded) {
        _pendingCameraToken = null;
      }
    });
  }

  Future<void> _retryCameraToken() async {
    final token = _pendingCameraToken;
    if (token == null || _cameraSubmissionLocked) {
      return;
    }
    await _handleCameraToken(token);
  }

  Future<void> _rescan() async {
    if (_cameraSubmissionLocked) {
      return;
    }
    await context.read<WalletScanCubit>().load();
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingCameraToken = null;
      _cameraOpen = true;
    });
  }

  Future<bool> _submitToken(String token) async {
    FocusScope.of(context).unfocus();
    return context.read<WalletScanCubit>().scan(token);
  }

  void _addStamp(StampStatus currentStampStatus) {
    if (currentStampStatus == StampStatus.stamping) {
      return;
    }
    context.read<WalletScanCubit>().addStamp();
  }
}

class _CameraRetryCard extends StatelessWidget {
  const _CameraRetryCard({required this.onRetry, required this.onRescan});

  final VoidCallback? onRetry;
  final VoidCallback? onRescan;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: const ValueKey('walletCameraRetryCard'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PilotArabicCopy.cardNotAccepted,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(PilotArabicCopy.retryCapturedCard),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                key: const ValueKey('walletCameraRetryButton'),
                label: PilotArabicCopy.retry,
                icon: Icons.refresh,
                onPressed: onRetry,
                expand: false,
              ),
              AppButton(
                key: const ValueKey('walletCameraRescanButton'),
                label: PilotArabicCopy.scanAgain,
                icon: Icons.qr_code_scanner,
                onPressed: onRescan,
                expand: false,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? _safeErrorMessage(String? message, String sensitiveValue) {
  if (message == null) {
    return null;
  }
  final friendlyMessage = _staffScanErrorMessage(message);
  final token = sensitiveValue.trim();
  if (token.isEmpty) {
    return friendlyMessage;
  }
  return friendlyMessage.replaceAll(token, '[redacted]');
}

String _staffScanErrorMessage(String message) {
  final normalized = message.toLowerCase();
  if (normalized.contains('token') ||
      normalized.contains('invalid') ||
      normalized.contains('inactive') ||
      normalized.contains('expired')) {
    return PilotArabicCopy.invalidQr;
  }
  if (normalized.contains('business') ||
      normalized.contains('forbidden') ||
      normalized.contains('not allow') ||
      normalized.contains('denied')) {
    return PilotArabicCopy.wrongBusiness;
  }
  return message;
}

class _WalletScanResultCard extends StatelessWidget {
  const _WalletScanResultCard({
    required this.result,
    required this.stampStatus,
    required this.onAddStamp,
    this.updatedStamps,
    this.updatedGoal,
    this.stampErrorMessage,
  });

  final WalletScanResult result;
  final int? updatedStamps;
  final int? updatedGoal;
  final StampStatus stampStatus;
  final String? stampErrorMessage;
  final VoidCallback? onAddStamp;

  @override
  Widget build(BuildContext context) {
    final phoneHint = _maskedCustomerHint(result.customerPhone);
    final stamps = updatedStamps ?? result.stamps;
    final goal = updatedGoal ?? result.goal;

    final isStamping = stampStatus == StampStatus.stamping;
    final stampSucceeded = stampStatus == StampStatus.stampSuccess;

    return Column(
      key: const ValueKey('walletScanResult'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: PilotArabicCopy.cardFound,
          subtitle: PilotArabicCopy.cardFoundSubtitle,
        ),
        const SizedBox(height: AppSpacing.md),
        LoyaltyProgressCard(
          customerName: result.customerDisplayName,
          customerHint: phoneHint ?? PilotArabicCopy.privateCustomerDetails,
          programName: result.programName,
          rewardText: result.canRedeem
              ? '${result.rewardName} ${PilotArabicCopy.rewardReadySuffix}'
              : '${result.rewardName} ${PilotArabicCopy.rewardNotReadySuffix}',
          stamps: stamps,
          goal: goal,
          canRedeem: result.canRedeem,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                label: result.canRedeem
                    ? PilotArabicCopy.rewardAvailable
                    : PilotArabicCopy.readyToAddStamp,
                color: result.canRedeem
                    ? AppColors.greenLight
                    : AppColors.ceramic,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                stampSucceeded
                    ? PilotArabicCopy.stampRecorded
                    : result.canRedeem
                    ? PilotArabicCopy.rewardAvailableGuidance
                    : PilotArabicCopy.addOneStamp,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                key: const ValueKey('walletAddStampButton'),
                label: isStamping
                    ? PilotArabicCopy.addingStamp
                    : PilotArabicCopy.addStamp,
                icon: Icons.add_circle_outline,
                onPressed: (isStamping || stampSucceeded) ? null : onAddStamp,
              ),
              if (isStamping) ...[
                const SizedBox(height: AppSpacing.sm),
                const LinearProgressIndicator(
                  key: ValueKey('walletAddStampLoading'),
                ),
              ],
              if (stampSucceeded) ...[
                const SizedBox(height: AppSpacing.sm),
                _StampSuccessBanner(),
              ],
              if (stampStatus == StampStatus.stampFailure &&
                  stampErrorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                ErrorView(
                  key: const ValueKey('walletAddStampError'),
                  message: stampErrorMessage!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

String? _maskedCustomerHint(String? phone) {
  final trimmed = phone?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final visible = trimmed.length <= 3
      ? trimmed
      : trimmed.substring(trimmed.length - 3);
  return '${PilotArabicCopy.phoneEnding} $visible';
}

class _StampSuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('walletStampSuccessBanner'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.freshGreenDark.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.freshGreenDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(child: Text(PilotArabicCopy.stampSuccess)),
        ],
      ),
    );
  }
}

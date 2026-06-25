import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
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
    return AppScaffold(
      title: 'Wallet Scan',
      scrollable: true,
      child: BlocBuilder<WalletScanCubit, WalletScanState>(
        builder: (context, state) {
          if ((state.status == WalletScanStatus.initial ||
                  state.status == WalletScanStatus.loading) &&
              state.business == null) {
            return const LoadingView(message: 'Loading business access');
          }

          if (state.business == null) {
            return ErrorView(
              message:
                  state.errorMessage ?? 'Business access could not be loaded.',
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
                title: 'Staff wallet scan',
                subtitle:
                    'Scan the customer wallet QR code to look up loyalty progress and reward status.',
              ),
              const SizedBox(height: AppSpacing.md),
              if (_cameraOpen)
                _buildCameraScanner()
              else if (_pendingCameraToken == null && state.result == null)
                AppButton(
                  key: const ValueKey('walletOpenCameraButton'),
                  label: 'Scan with camera',
                  icon: Icons.qr_code_scanner,
                  onPressed: isScanning ? null : _openCamera,
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
                title: 'Manual entry',
                subtitle:
                    'Use manual entry when camera scanning is unavailable.',
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
                        labelText: 'QR token',
                        hintText: 'Paste wallet QR token',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: const ValueKey('walletScanButton'),
                      label: isScanning ? 'Scanning...' : 'Scan',
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
                  label: 'Scan another wallet',
                  icon: Icons.qr_code_scanner,
                  onPressed: isScanning ? null : _rescan,
                  variant: AppButtonVariant.secondary,
                ),
              ],
            ],
          );
        },
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
            'Camera scan was not accepted',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Retry the captured code or scan the customer wallet again.',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                key: const ValueKey('walletCameraRetryButton'),
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: onRetry,
                expand: false,
              ),
              AppButton(
                key: const ValueKey('walletCameraRescanButton'),
                label: 'Scan again',
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
  final token = sensitiveValue.trim();
  if (token.isEmpty) {
    return message;
  }
  return message.replaceAll(token, '[redacted]');
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
    final phone = result.customerPhone?.trim();
    final stamps = updatedStamps ?? result.stamps;
    final goal = updatedGoal ?? result.goal;
    final progress = goal > 0 ? (stamps / goal).clamp(0.0, 1.0) : 0.0;

    final isStamping = stampStatus == StampStatus.stamping;
    final stampSucceeded = stampStatus == StampStatus.stampSuccess;

    return Column(
      key: const ValueKey('walletScanResult'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Scan result',
          subtitle: 'Customer loyalty membership found.',
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                label: result.canRedeem ? 'Reward ready' : 'In progress',
                color: result.canRedeem
                    ? AppColors.greenLight
                    : AppColors.ceramic,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                result.customerDisplayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (phone != null && phone.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(phone),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                result.programName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                key: const ValueKey('walletStampProgressBar'),
                value: progress,
                color: AppColors.freshGreen,
                backgroundColor: AppColors.greenLight,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                key: const ValueKey('walletStampCount'),
                '$stamps of $goal stamps',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                result.canRedeem
                    ? '${result.rewardName} is ready to redeem.'
                    : '${result.rewardName} is not ready yet.',
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Add stamp action ──────────────────────────────────
              AppButton(
                key: const ValueKey('walletAddStampButton'),
                label: isStamping ? 'Adding stamp...' : 'Add stamp',
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
        border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.freshGreenDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('Stamp added successfully.'),
        ],
      ),
    );
  }
}

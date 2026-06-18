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

class StaffScannerScreen extends StatefulWidget {
  const StaffScannerScreen({super.key});

  @override
  State<StaffScannerScreen> createState() => _StaffScannerScreenState();
}

class _StaffScannerScreenState extends State<StaffScannerScreen> {
  final _tokenController = TextEditingController();

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Scan a wallet pass',
                subtitle:
                    'Paste the QR token from the customer wallet. Camera scanning is not enabled yet.',
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
                      onSubmitted: isScanning ? null : (_) => _scan(),
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
                      onPressed: isScanning ? null : _scan,
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
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorView(message: state.errorMessage!),
              ],
              if (state.result != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _WalletScanResultCard(result: state.result!),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _scan() async {
    FocusScope.of(context).unfocus();
    final succeeded = await context.read<WalletScanCubit>().scan(
      _tokenController.text,
    );
    if (succeeded && mounted) {
      _tokenController.clear();
    }
  }
}

class _WalletScanResultCard extends StatelessWidget {
  const _WalletScanResultCard({required this.result});

  final WalletScanResult result;

  @override
  Widget build(BuildContext context) {
    final phone = result.customerPhone?.trim();
    final progress = result.progressPercent / 100;

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
              LinearProgressIndicator(value: progress),
              const SizedBox(height: AppSpacing.xs),
              Text('${result.stamps} of ${result.goal} stamps'),
              const SizedBox(height: AppSpacing.md),
              Text(
                result.canRedeem
                    ? '${result.rewardName} is ready to redeem.'
                    : '${result.rewardName} is not ready yet.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

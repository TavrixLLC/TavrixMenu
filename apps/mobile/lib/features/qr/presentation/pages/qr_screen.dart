import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/qr_preview_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../bloc/qr_cubit.dart';
import '../bloc/qr_state.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QRCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'QR menu',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<QRCubit>().load(),
        ),
      ],
      scrollable: true,
      child: BlocBuilder<QRCubit, QRState>(
        builder: (context, state) {
          if (state.status == QRStatus.initial ||
              state.status == QRStatus.loading) {
            return const LoadingView(message: 'Preparing QR preview');
          }

          if (state.status == QRStatus.failure || state.publicLink == null) {
            return ErrorView(
              message: state.errorMessage ?? 'QR menu could not load.',
              onRetry: () => context.read<QRCubit>().load(),
            );
          }

          final publicLink = state.publicLink!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Public menu preview',
                subtitle:
                    'QR generation is a later integration. This screen uses the configured public link payload.',
              ),
              if (state.usedFallback) ...[
                const SizedBox(height: AppSpacing.sm),
                const StatusBadge(label: 'Fallback URL'),
              ],
              const SizedBox(height: AppSpacing.lg),
              QRPreviewCard(
                publicUrl: publicLink.publicMenuUrl,
                publicMenuPath: publicLink.publicMenuPath,
                qrPayload: publicLink.qrPayload,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Copy URL',
                icon: Icons.copy,
                variant: AppButtonVariant.secondary,
                onPressed: () async {
                  await QRPreviewCard.copyUrl(publicLink.publicMenuUrl);
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu URL copied')),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Share placeholder',
                icon: Icons.ios_share,
                variant: AppButtonVariant.ghost,
                onPressed: null,
              ),
            ],
          );
        },
      ),
    );
  }
}

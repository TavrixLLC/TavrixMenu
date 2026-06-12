import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/qr_preview_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../dashboard/presentation/bloc/dashboard_state.dart';

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
      final cubit = context.read<DashboardCubit>();
      if (cubit.state.status == DashboardStatus.initial) {
        cubit.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'QR menu',
      scrollable: true,
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.initial ||
              state.status == DashboardStatus.loading) {
            return const LoadingView(message: 'Preparing QR preview');
          }

          final canViewPublicLink =
              state.permissions?.canViewPublicLink ?? true;
          if (!canViewPublicLink) {
            return const EmptyState(
              title: 'Restricted access',
              message:
                  'Your business permissions do not allow public link access.',
              icon: Icons.lock_outline,
            );
          }

          final publicUrl =
              state.summary?.publicMenu.url ??
              state.business?.publicMenuUrl ??
              'https://menu.tavrix.com/your-business';
          final qrPayload = state.summary?.publicMenu.qrPayload ?? publicUrl;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Public menu preview',
                subtitle:
                    'Copy the public menu link or QR payload for sharing.',
              ),
              const SizedBox(height: AppSpacing.lg),
              QRPreviewCard(publicUrl: publicUrl, qrPayload: qrPayload),
            ],
          );
        },
      ),
    );
  }
}

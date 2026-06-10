import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
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

          if (state.status == DashboardStatus.failure) {
            return ErrorView(
              message: state.errorMessage ?? 'QR preview could not load.',
              onRetry: () => context.read<DashboardCubit>().load(),
            );
          }

          final business = state.business;
          if (business == null) {
            return const EmptyState(
              title: 'Business setup needed',
              message: 'Create a business profile before preparing QR menus.',
              icon: Icons.storefront,
            );
          }

          final publicUrl = context.read<AppConfig>().publicMenuUrlForSlug(
            business.slug,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Public menu preview',
                subtitle:
                    'QR generation is a later integration. Sprint 1 shows the URL concept only.',
              ),
              const SizedBox(height: AppSpacing.lg),
              QRPreviewCard(publicUrl: publicUrl),
            ],
          );
        },
      ),
    );
  }
}

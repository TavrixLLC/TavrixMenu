import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
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
      title: context.l10n.publicMenuQrTitle,
      scrollable: true,
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.initial ||
              state.status == DashboardStatus.loading) {
            return LoadingView(message: context.l10n.publicMenuQrLoading);
          }

          final canViewPublicLink =
              state.permissions?.canViewPublicLink ?? true;
          if (!canViewPublicLink) {
            return EmptyState(
              title: context.l10n.permissionUnavailable,
              message: context.l10n.publicMenuQrUnavailableBody,
              icon: Icons.lock_outline,
            );
          }

          final publicUrl =
              state.summary?.publicMenu.url ??
              state.business?.publicMenuUrl ??
              '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: context.l10n.previewCustomerMenu,
                subtitle: context.l10n.previewCustomerMenuBody,
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

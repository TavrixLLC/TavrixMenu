import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/v3/waflo_v3_tokens.dart';
import 'waflo_status_badge.dart';

/// Presentation-only identity header for an authoritative active workspace.
class WafloWorkspaceHeader extends StatelessWidget {
  const WafloWorkspaceHeader({
    required this.workspaceName,
    super.key,
    this.statusLabel,
    this.statusKind = WafloStatusKind.informational,
    this.statusWidget,
    this.avatarBytes,
    this.avatarFallbackInitial,
    this.onNotificationPressed,
    this.unreadCount,
    this.notificationSemanticLabel = 'الإشعارات',
  }) : assert(statusLabel == null || statusWidget == null),
       assert(unreadCount == null || unreadCount >= 0);

  final String workspaceName;
  final String? statusLabel;
  final WafloStatusKind statusKind;
  final Widget? statusWidget;
  final Uint8List? avatarBytes;
  final String? avatarFallbackInitial;
  final VoidCallback? onNotificationPressed;
  final int? unreadCount;
  final String notificationSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final status =
        statusWidget ??
        (statusLabel == null
            ? null
            : WafloStatusBadge(label: statusLabel!, status: statusKind));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        key: const ValueKey('waflo-workspace-header-surface'),
        decoration: BoxDecoration(
          color: WafloV3Colors.surface,
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloV3Radius.largeCard),
          ),
          border: Border.all(
            color: WafloV3Colors.primaryText.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: WafloV3Colors.primaryText.withValues(alpha: 0.05),
              blurRadius: WafloV3Spacing.space12,
              offset: const Offset(0, WafloV3Spacing.space4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: WafloV3Spacing.space12,
            vertical: WafloV3Spacing.space8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _WorkspaceAvatar(
                avatarBytes: avatarBytes,
                fallbackInitial: avatarFallbackInitial,
              ),
              const SizedBox(width: WafloV3Spacing.space8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspaceName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: WafloV3Colors.primaryText,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(height: WafloV3Spacing.space4),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: status,
                      ),
                    ],
                  ],
                ),
              ),
              if (onNotificationPressed != null) ...[
                const SizedBox(width: WafloV3Spacing.space4),
                _NotificationAction(
                  onPressed: onNotificationPressed!,
                  unreadCount: unreadCount,
                  semanticLabel: notificationSemanticLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceAvatar extends StatelessWidget {
  const _WorkspaceAvatar({this.avatarBytes, this.fallbackInitial});

  final Uint8List? avatarBytes;
  final String? fallbackInitial;

  @override
  Widget build(BuildContext context) {
    const size = 40.0;
    final fallback = _AvatarFallback(initial: fallbackInitial);

    return Semantics(
      label: 'صورة مساحة العمل',
      image: avatarBytes != null,
      excludeSemantics: true,
      child: ClipOval(
        child: SizedBox.square(
          key: const ValueKey('waflo-workspace-avatar'),
          dimension: size,
          child: avatarBytes == null
              ? fallback
              : Image.memory(
                  avatarBytes!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({this.initial});

  final String? initial;

  @override
  Widget build(BuildContext context) {
    final suppliedInitial = initial?.trim();

    return ColoredBox(
      key: const ValueKey('waflo-workspace-avatar-fallback'),
      color: WafloV3Colors.primary.withValues(alpha: 0.10),
      child: Center(
        child: suppliedInitial == null || suppliedInitial.isEmpty
            ? const Icon(
                Icons.storefront_outlined,
                color: WafloV3Colors.primary,
              )
            : Padding(
                padding: const EdgeInsetsDirectional.all(WafloV3Spacing.space8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    suppliedInitial,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: WafloV3Colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _NotificationAction extends StatelessWidget {
  const _NotificationAction({
    required this.onPressed,
    required this.semanticLabel,
    this.unreadCount,
  });

  final VoidCallback onPressed;
  final String semanticLabel;
  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    final visibleCount = unreadCount == null
        ? null
        : unreadCount! > 99
        ? '99+'
        : '$unreadCount';
    final accessibleLabel = unreadCount == null || unreadCount == 0
        ? semanticLabel
        : '$semanticLabel، $unreadCount غير مقروءة';

    return Semantics(
      key: const ValueKey('waflo-workspace-notification-action'),
      button: true,
      label: accessibleLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: WafloV3Spacing.minimumTouchTarget,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IconButton(
                onPressed: onPressed,
                tooltip: semanticLabel,
                icon: const Icon(Icons.notifications_none_rounded),
                color: WafloV3Colors.primaryText,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: WafloV3Spacing.minimumTouchTarget,
                  height: WafloV3Spacing.minimumTouchTarget,
                ),
              ),
            ),
            if (visibleCount != null && unreadCount! > 0)
              PositionedDirectional(
                top: 0,
                start: 0,
                child: ExcludeSemantics(
                  child: Container(
                    key: const ValueKey('waflo-workspace-notification-count'),
                    constraints: const BoxConstraints(
                      minWidth: WafloV3Spacing.space20,
                      minHeight: WafloV3Spacing.space20,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: WafloV3Spacing.space4,
                    ),
                    decoration: const BoxDecoration(
                      color: WafloV3Colors.primary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(WafloV3Radius.pill),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      visibleCount,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: WafloV3Colors.surface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

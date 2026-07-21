import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/v3/waflo_v3_theme.dart';
import '../../../core/theme/v3/waflo_v3_tokens.dart';
import 'waflo_bottom_navigation.dart';
import 'waflo_inline_error.dart';
import 'waflo_skeleton.dart';
import 'waflo_status_badge.dart';
import 'waflo_workspace_header.dart';

enum WafloWorkspaceIdentityState { loading, ready, unavailable }

/// Presentation-only access to the destination selection owned by
/// [WafloShellV3]. Top-level screen actions use this controller instead of
/// creating competing route-stack entries.
class WafloShellController {
  const WafloShellController._(this._selectDestination);

  final ValueChanged<WafloWorkspaceDestination> _selectDestination;

  void selectDestination(WafloWorkspaceDestination destination) {
    _selectDestination(destination);
  }
}

/// Canonical presentation shell for the five authenticated workspace screens.
///
/// Workspace and authentication state are supplied by the app composition
/// layer. This widget owns only local destination selection and presentation.
class WafloShellV3 extends StatefulWidget {
  const WafloShellV3({
    required this.workspaceLifecycleIdentity,
    required this.workspaceIdentityState,
    required this.home,
    required this.menu,
    required this.scanner,
    required this.loyalty,
    required this.settings,
    super.key,
    this.workspaceName,
    this.workspaceStatusLabel,
    this.workspaceStatusKind = WafloStatusKind.informational,
    this.workspaceAvatarBytes,
    this.workspaceAvatarFallbackInitial,
    this.onNotificationPressed,
    this.unreadCount,
    this.workspaceUnavailableMessage = 'تعذر عرض مساحة العمل الآن.',
    this.initialDestination = WafloWorkspaceDestination.home,
  }) : assert(
         workspaceIdentityState != WafloWorkspaceIdentityState.ready ||
             (workspaceName != null && workspaceName != ''),
       ),
       assert(
         workspaceIdentityState == WafloWorkspaceIdentityState.ready ||
             workspaceName == null,
       ),
       assert(unreadCount == null || unreadCount >= 0);

  final Object workspaceLifecycleIdentity;
  final WafloWorkspaceIdentityState workspaceIdentityState;
  final String? workspaceName;
  final String? workspaceStatusLabel;
  final WafloStatusKind workspaceStatusKind;
  final Uint8List? workspaceAvatarBytes;
  final String? workspaceAvatarFallbackInitial;
  final VoidCallback? onNotificationPressed;
  final int? unreadCount;
  final String workspaceUnavailableMessage;
  final WafloWorkspaceDestination initialDestination;
  final Widget home;
  final Widget menu;
  final Widget scanner;
  final Widget loyalty;
  final Widget settings;

  static WafloShellController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_WafloShellDestinationScope>()
        ?.controller;
  }

  @override
  State<WafloShellV3> createState() => _WafloShellV3State();
}

class _WafloShellV3State extends State<WafloShellV3> {
  late WafloWorkspaceDestination _selectedDestination =
      widget.initialDestination;
  late final WafloShellController _controller = WafloShellController._(
    _selectDestination,
  );

  @override
  void didUpdateWidget(covariant WafloShellV3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspaceLifecycleIdentity !=
        widget.workspaceLifecycleIdentity) {
      _selectedDestination = widget.initialDestination;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: WafloV3Theme.light(),
      child: Scaffold(
        key: const ValueKey('waflo-shell-v3'),
        backgroundColor: WafloV3Colors.background,
        body: Column(
          children: [
            SafeArea(
              key: const ValueKey('waflo-shell-v3-header-region'),
              bottom: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  WafloV3Spacing.standardPageMargin,
                  WafloV3Spacing.space4,
                  WafloV3Spacing.standardPageMargin,
                  WafloV3Spacing.space4,
                ),
                child: _buildWorkspaceIdentity(),
              ),
            ),
            Expanded(
              key: const ValueKey('waflo-shell-v3-body'),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: _WafloShellDestinationScope(
                  controller: _controller,
                  child: KeyedSubtree(
                    key: ValueKey(widget.workspaceLifecycleIdentity),
                    child: IndexedStack(
                      index: _selectedDestination.index,
                      children: [
                        widget.home,
                        widget.menu,
                        widget.scanner,
                        widget.loyalty,
                        widget.settings,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: WafloBottomNavigation(
          selectedDestination: _selectedDestination,
          disabledDestinations:
              widget.workspaceIdentityState == WafloWorkspaceIdentityState.ready
              ? const {}
              : WafloWorkspaceDestination.values.toSet(),
          onDestinationSelected: _selectDestination,
        ),
      ),
    );
  }

  void _selectDestination(WafloWorkspaceDestination destination) {
    if (widget.workspaceIdentityState != WafloWorkspaceIdentityState.ready ||
        destination == _selectedDestination) {
      return;
    }
    setState(() => _selectedDestination = destination);
  }

  Widget _buildWorkspaceIdentity() {
    return switch (widget.workspaceIdentityState) {
      WafloWorkspaceIdentityState.ready => WafloWorkspaceHeader(
        workspaceName: widget.workspaceName!,
        statusLabel: widget.workspaceStatusLabel,
        statusKind: widget.workspaceStatusKind,
        avatarBytes: widget.workspaceAvatarBytes,
        avatarFallbackInitial: widget.workspaceAvatarFallbackInitial,
        onNotificationPressed: widget.onNotificationPressed,
        unreadCount: widget.onNotificationPressed == null
            ? null
            : widget.unreadCount,
      ),
      WafloWorkspaceIdentityState.loading => const _WorkspaceLoadingHeader(),
      WafloWorkspaceIdentityState.unavailable => _WorkspaceUnavailableHeader(
        message: widget.workspaceUnavailableMessage,
      ),
    };
  }
}

class _WafloShellDestinationScope extends InheritedWidget {
  const _WafloShellDestinationScope({
    required this.controller,
    required super.child,
  });

  final WafloShellController controller;

  @override
  bool updateShouldNotify(_WafloShellDestinationScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

class _WorkspaceLoadingHeader extends StatelessWidget {
  const _WorkspaceLoadingHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: WafloV3Colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(WafloV3Radius.largeCard),
        ),
        border: Border.all(
          color: WafloV3Colors.primaryText.withValues(alpha: 0.08),
        ),
      ),
      child: const Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: WafloV3Spacing.space12,
          vertical: WafloV3Spacing.space8,
        ),
        child: Row(
          children: [
            WafloSkeleton(width: 40, height: 40, radius: WafloV3Radius.pill),
            SizedBox(width: WafloV3Spacing.space8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WafloSkeleton(width: 176, height: WafloV3Spacing.space16),
                  SizedBox(height: WafloV3Spacing.space4),
                  WafloSkeleton(width: 88, height: WafloV3Spacing.space12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceUnavailableHeader extends StatelessWidget {
  const _WorkspaceUnavailableHeader({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return WafloInlineError(message: message);
  }
}

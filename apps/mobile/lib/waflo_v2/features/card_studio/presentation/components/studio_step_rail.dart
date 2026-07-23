import 'package:flutter/material.dart';

import '../../../../core/localization/waflo_v2_strings.dart';
import '../../../../core/theme/waflo_colors.dart';
import '../../../../core/theme/waflo_radii.dart';
import '../../../../core/theme/waflo_spacing.dart';

class StudioStepRail extends StatefulWidget {
  const StudioStepRail({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<StudioStepRail> createState() => _StudioStepRailState();
}

class _StudioStepRailState extends State<StudioStepRail> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _stepKeys;

  @override
  void initState() {
    super.initState();
    _stepKeys = List<GlobalKey>.generate(
      widget.labels.length,
      (_) => GlobalKey(),
    );
    _revealSelectedStep();
  }

  @override
  void didUpdateWidget(StudioStepRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels.length != widget.labels.length) {
      _stepKeys = List<GlobalKey>.generate(
        widget.labels.length,
        (_) => GlobalKey(),
      );
    }
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.labels.length != widget.labels.length) {
      _revealSelectedStep();
    }
  }

  void _revealSelectedStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          widget.selectedIndex < 0 ||
          widget.selectedIndex >= _stepKeys.length) {
        return;
      }
      final selectedContext = _stepKeys[widget.selectedIndex].currentContext;
      if (selectedContext == null || !_scrollController.hasClients) return;
      final renderObject = selectedContext.findRenderObject();
      if (renderObject == null) return;
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      _scrollController.position.ensureVisible(
        renderObject,
        alignment: 0.5,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.stepProgress(
                  widget.selectedIndex + 1,
                  widget.labels.length,
                ),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: WafloSpacing.x2),
            const Icon(
              Icons.swipe_rounded,
              size: 20,
              color: WafloColors.textMuted,
            ),
            const SizedBox(width: WafloSpacing.x1),
            Flexible(
              child: Text(
                strings.scrollStepsHint,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: WafloSpacing.x2),
        SizedBox(
          key: const ValueKey('waflo-studio-horizontal-step-rail'),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chipWidth = (constraints.maxWidth - WafloSpacing.x8) / 3;
              return SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: WafloSpacing.x2,
                ),
                child: Row(
                  children: [
                    for (
                      var index = 0;
                      index < widget.labels.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(width: WafloSpacing.x2),
                      _StepChip(
                        key: _stepKeys[index],
                        testKey: ValueKey('waflo-studio-step-$index'),
                        index: index,
                        label: widget.labels[index],
                        selected: index == widget.selectedIndex,
                        width: chipWidth,
                        onTap: () => widget.onSelected(index),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.testKey,
    required this.index,
    required this.label,
    required this.selected,
    required this.width,
    required this.onTap,
    super.key,
  });

  final Key testKey;
  final int index;
  final String label;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = const BorderRadius.all(
      Radius.circular(WafloRadii.pill),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: '${index + 1}. $label',
      child: SizedBox(
        width: width,
        child: Material(
          key: testKey,
          color: selected
              ? WafloColors.informationContainer
              : WafloColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: selected ? WafloColors.actionPrimary : WafloColors.divider,
            ),
          ),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: WafloSpacing.x2,
                  vertical: WafloSpacing.x2,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}. $label',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? WafloColors.onInformationContainer
                          : WafloColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/loyalty_card_state.dart';
import '../../domain/entities/loyalty_stamp_style.dart';
import '../utils/loyalty_stamp_color.dart';

class LoyaltyStampStylePreview extends StatelessWidget {
  const LoyaltyStampStylePreview({
    required this.style,
    required this.cardState,
    required this.businessName,
    super.key,
  });

  final LoyaltyStampStyle style;
  final LoyaltyCardState cardState;
  final String businessName;

  @override
  Widget build(BuildContext context) {
    final layout = _HeroLayout.forVariant(style.layoutVariant);
    final data = LoyaltyHeroPreviewData.from(
      businessName: businessName,
      cardState: cardState,
    );
    final theme = ResolvedLoyaltyHeroTheme.fromStyle(style);

    return AspectRatio(
      key: const ValueKey('loyalty-hero-aspect'),
      aspectRatio: layout.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / layout.width;
          return ClipRRect(
            borderRadius: BorderRadius.circular(layout.radius * scale),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _HeroBackgroundPainter(layout: layout, theme: theme),
                ),
                _HeroHeader(layout: layout, theme: theme, data: data),
                _LoyaltyProgressBadge(layout: layout, theme: theme, data: data),
                _LoyaltyStampGridPreview(
                  layout: layout,
                  theme: theme,
                  data: data,
                  presetKey: style.presetKey,
                ),
                _LoyaltyRewardBannerPreview(
                  layout: layout,
                  theme: theme,
                  rewardName: data.rewardName,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LoyaltyHeroPreviewData {
  const LoyaltyHeroPreviewData({
    required this.businessName,
    required this.programName,
    required this.rewardName,
    required this.stampCount,
    required this.stampGoal,
  });

  factory LoyaltyHeroPreviewData.from({
    required String businessName,
    required LoyaltyCardState cardState,
  }) {
    final previewGoal = cardState.stampGoal.clamp(1, 10).toInt();
    final previewCount = cardState.stampCount.clamp(0, previewGoal).toInt();
    return LoyaltyHeroPreviewData(
      businessName: _truncate(_fallbackText(businessName, 'Waflo'), 64),
      programName: _truncate(
        _fallbackText(cardState.programName, 'Loyalty Card'),
        64,
      ),
      rewardName: _truncate(_fallbackText(cardState.rewardName, 'Reward'), 72),
      stampCount: previewCount,
      stampGoal: previewGoal,
    );
  }

  final String businessName;
  final String programName;
  final String rewardName;
  final int stampCount;
  final int stampGoal;
}

class ResolvedLoyaltyHeroTheme {
  const ResolvedLoyaltyHeroTheme({
    required this.imageBackgroundColor,
    required this.imageBackgroundEndColor,
    required this.imageSurfaceColor,
    required this.imageAccentColor,
    required this.imageTextColor,
    required this.stampFilledColor,
    required this.stampEmptyColor,
    required this.rewardBannerColor,
  });

  factory ResolvedLoyaltyHeroTheme.fromStyle(LoyaltyStampStyle style) {
    final background = loyaltyColorFromHex(
      style.backgroundColor,
      _defaultImageBackgroundColor,
    );
    final accent = loyaltyColorFromHex(
      style.accentColor,
      _defaultImageAccentColor,
    );
    final text = loyaltyColorFromHex(style.textColor, _defaultImageTextColor);
    final imageBackground = loyaltyColorFromHex(
      style.imageBackgroundColor,
      background,
    );
    final imageSurface = loyaltyColorFromHex(
      style.imageSurfaceColor,
      _defaultImageSurfaceColor,
    );
    final imageAccent = loyaltyColorFromHex(style.imageAccentColor, accent);
    final imageText = loyaltyColorFromHex(style.imageTextColor, text);

    return ResolvedLoyaltyHeroTheme(
      imageBackgroundColor: imageBackground,
      imageBackgroundEndColor: loyaltyMixWithBlack(imageBackground, 0.22),
      imageSurfaceColor: imageSurface,
      imageAccentColor: imageAccent,
      imageTextColor: imageText,
      stampFilledColor: loyaltyColorFromHex(
        style.stampFilledColor,
        imageAccent,
      ),
      stampEmptyColor: loyaltyColorFromHex(
        style.stampEmptyColor,
        _defaultStampEmptyColor,
      ),
      rewardBannerColor: loyaltyColorFromHex(
        style.rewardBannerColor,
        _defaultRewardBannerColor,
      ),
    );
  }

  final Color imageBackgroundColor;
  final Color imageBackgroundEndColor;
  final Color imageSurfaceColor;
  final Color imageAccentColor;
  final Color imageTextColor;
  final Color stampFilledColor;
  final Color stampEmptyColor;
  final Color rewardBannerColor;
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.layout,
    required this.theme,
    required this.data,
  });

  final _HeroLayout layout;
  final ResolvedLoyaltyHeroTheme theme;
  final LoyaltyHeroPreviewData data;

  @override
  Widget build(BuildContext context) {
    final compact = layout.variant == 'COMPACT';
    final subtitle = compact ? data.programName : data.businessName;
    final headline = compact ? data.businessName : data.programName;
    final reservedRight =
        layout.badgeRightSafePadding + layout.badgeRadius * 2 + layout.padding;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / layout.width;
        return Stack(
          children: [
            _PositionedBaselineText(
              textKey: const ValueKey('loyalty-hero-subtitle'),
              text: subtitle,
              left: layout.padding,
              right: reservedRight,
              baselineY: layout.subtitleY,
              fontSize: layout.subtitleSize,
              scale: scale,
              color: theme.imageTextColor.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
            _PositionedBaselineText(
              textKey: const ValueKey('loyalty-hero-headline'),
              text: headline,
              left: layout.padding,
              right: reservedRight,
              baselineY: layout.titleY,
              fontSize: layout.titleSize,
              scale: scale,
              color: theme.imageTextColor,
              fontWeight: FontWeight.w800,
            ),
          ],
        );
      },
    );
  }
}

class _LoyaltyProgressBadge extends StatelessWidget {
  const _LoyaltyProgressBadge({
    required this.layout,
    required this.theme,
    required this.data,
  });

  final _HeroLayout layout;
  final ResolvedLoyaltyHeroTheme theme;
  final LoyaltyHeroPreviewData data;

  @override
  Widget build(BuildContext context) {
    final badge = layout.progressBadge;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / layout.width;
        return Stack(
          children: [
            _PositionedBaselineText(
              textKey: const ValueKey('loyalty-progress-label'),
              text: 'stamps',
              left: badge.cx - badge.radius,
              width: badge.radius * 2,
              baselineY: badge.labelY,
              fontSize: layout.subtitleSize,
              scale: scale,
              color: theme.imageTextColor.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            _PositionedBaselineText(
              textKey: const ValueKey('loyalty-progress-value'),
              text: '${data.stampCount} / ${data.stampGoal}',
              left: badge.cx - badge.radius,
              width: badge.radius * 2,
              baselineY: badge.valueY,
              fontSize: layout.progressSize,
              scale: scale,
              color: theme.imageTextColor,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class _LoyaltyStampGridPreview extends StatelessWidget {
  const _LoyaltyStampGridPreview({
    required this.layout,
    required this.theme,
    required this.data,
    required this.presetKey,
  });

  final _HeroLayout layout;
  final ResolvedLoyaltyHeroTheme theme;
  final LoyaltyHeroPreviewData data;
  final String presetKey;

  @override
  Widget build(BuildContext context) {
    final columns = layout.variant == 'COMPACT' ? data.stampGoal : 5;
    final rows = (data.stampGoal / columns).ceil();
    final gridWidth =
        columns * layout.cellSize + (columns - 1) * layout.iconGap;
    final gridHeight = rows * layout.cellSize + (rows - 1) * layout.iconGap;
    final startX = (layout.width - gridWidth) / 2;
    final startY =
        layout.iconsY + math.max(0.0, (layout.iconBoxHeight - gridHeight) / 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / layout.width;
        return Stack(
          children: [
            Positioned(
              left: startX * scale,
              top: startY * scale,
              width: gridWidth * scale,
              height: gridHeight * scale,
              child: Stack(
                children: [
                  for (var index = 0; index < data.stampGoal; index++)
                    _StampCell(
                      index: index,
                      filled: index < data.stampCount,
                      presetKey: presetKey,
                      theme: theme,
                      cellSize: layout.cellSize * scale,
                      iconGap: layout.iconGap * scale,
                      column: index % columns,
                      row: index ~/ columns,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoyaltyRewardBannerPreview extends StatelessWidget {
  const _LoyaltyRewardBannerPreview({
    required this.layout,
    required this.theme,
    required this.rewardName,
  });

  final _HeroLayout layout;
  final ResolvedLoyaltyHeroTheme theme;
  final String rewardName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / layout.width;
        return Stack(
          children: [
            Positioned(
              left: layout.padding * scale,
              top: layout.rewardY * scale,
              width: (layout.width - layout.padding * 2) * scale,
              height: layout.rewardHeight * scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.rewardBannerColor.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(
                    layout.rewardHeight * scale / 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 28 * scale, right: 20 * scale),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Reward: $rewardName',
                      key: const ValueKey('loyalty-reward-banner-text'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.imageTextColor,
                        fontSize: layout.rewardSize * scale,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StampCell extends StatelessWidget {
  const _StampCell({
    required this.index,
    required this.filled,
    required this.presetKey,
    required this.theme,
    required this.cellSize,
    required this.iconGap,
    required this.column,
    required this.row,
  });

  final int index;
  final bool filled;
  final String presetKey;
  final ResolvedLoyaltyHeroTheme theme;
  final double cellSize;
  final double iconGap;
  final int column;
  final int row;

  @override
  Widget build(BuildContext context) {
    final iconSize = cellSize * 0.7;
    return Positioned(
      left: column * (cellSize + iconGap),
      top: row * (cellSize + iconGap),
      width: cellSize,
      height: cellSize,
      child: Semantics(
        label: filled
            ? 'filled stamp ${index + 1}'
            : 'empty stamp ${index + 1}',
        child: DecoratedBox(
          key: ValueKey(
            filled
                ? 'loyalty-stamp-cell-filled-$index'
                : 'loyalty-stamp-cell-empty-$index',
          ),
          decoration: BoxDecoration(
            color: theme.imageSurfaceColor.withValues(
              alpha: filled ? 0.92 : 0.48,
            ),
            borderRadius: BorderRadius.circular(cellSize * 0.26),
            border: Border.all(
              color: (filled ? theme.stampFilledColor : theme.stampEmptyColor)
                  .withValues(alpha: filled ? 0.52 : 0.44),
              width: math.max(1, 3 * cellSize / 112),
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.24),
                      offset: Offset(0, 10 * cellSize / 112),
                      blurRadius: 12 * cellSize / 112,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: LoyaltyStampIcon(
              presetKey: presetKey,
              filled: filled,
              fillColor: theme.stampFilledColor,
              strokeColor: filled
                  ? theme.stampFilledColor
                  : theme.stampEmptyColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class LoyaltyStampIcon extends StatelessWidget {
  const LoyaltyStampIcon({
    required this.presetKey,
    required this.filled,
    required this.fillColor,
    required this.strokeColor,
    required this.size,
    super.key,
  });

  final String presetKey;
  final bool filled;
  final Color fillColor;
  final Color strokeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: ValueKey('loyalty-stamp-icon-${presetKey.toUpperCase()}'),
      size: Size.square(size),
      painter: _StampIconPainter(
        presetKey: presetKey,
        filled: filled,
        fillColor: fillColor,
        strokeColor: strokeColor,
      ),
    );
  }
}

class _PositionedBaselineText extends StatelessWidget {
  const _PositionedBaselineText({
    required this.textKey,
    required this.text,
    required this.left,
    required this.baselineY,
    required this.fontSize,
    required this.scale,
    required this.color,
    required this.fontWeight,
    this.right,
    this.width,
    this.textAlign = TextAlign.start,
  });

  final Key textKey;
  final String text;
  final double left;
  final double? right;
  final double? width;
  final double baselineY;
  final double fontSize;
  final double scale;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final scaledFontSize = fontSize * scale;
    final top = (baselineY - fontSize * 0.9) * scale;

    return Positioned(
      left: left * scale,
      right: right == null ? null : right! * scale,
      top: top,
      width: width == null ? null : width! * scale,
      child: Text(
        text,
        key: textKey,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: TextStyle(
          color: color,
          fontSize: scaledFontSize,
          fontWeight: fontWeight,
          height: 1,
        ),
      ),
    );
  }
}

class _HeroBackgroundPainter extends CustomPainter {
  const _HeroBackgroundPainter({required this.layout, required this.theme});

  final _HeroLayout layout;
  final ResolvedLoyaltyHeroTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / layout.width;
    final rect = Offset.zero & size;
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [theme.imageBackgroundColor, theme.imageBackgroundEndColor],
      ).createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    final badge = layout.progressBadge;
    final accentPaint = Paint()
      ..color = theme.imageAccentColor.withValues(alpha: 0.18);
    canvas.drawCircle(
      Offset(badge.cx * scale, badge.cy * scale),
      badge.radius * scale,
      accentPaint,
    );

    final bottomCirclePaint = Paint()
      ..color = theme.imageTextColor.withValues(alpha: 0.08);
    canvas.drawCircle(
      Offset(76 * scale, (layout.height - 40) * scale),
      154 * scale,
      bottomCirclePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroBackgroundPainter oldDelegate) {
    return oldDelegate.layout != layout || oldDelegate.theme != theme;
  }
}

class _StampIconPainter extends CustomPainter {
  const _StampIconPainter({
    required this.presetKey,
    required this.filled,
    required this.fillColor,
    required this.strokeColor,
  });

  final String presetKey;
  final bool filled;
  final Color fillColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height).toDouble();
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = math.max(2.0, side * 0.09);
    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = filled ? fillColor : Colors.transparent
      ..style = PaintingStyle.fill;

    switch (presetKey.toUpperCase()) {
      case 'COOKIE':
        _drawCookie(canvas, center, side, fill, stroke);
        break;
      case 'COFFEE':
        _drawCoffee(canvas, center, side, fill, stroke);
        break;
      case 'BOWL':
        _drawBowl(canvas, center, side, fill, stroke);
        break;
      case 'BURGER':
        _drawBurger(canvas, center, side, fill, stroke);
        break;
      case 'PIZZA':
        _drawPizza(canvas, center, side, fill, stroke);
        break;
      case 'HEART':
        _drawHeart(canvas, center, side, fill, stroke);
        break;
      case 'CUPCAKE':
        _drawCupcake(canvas, center, side, fill, stroke);
        break;
      case 'STAR':
      default:
        _drawStar(canvas, center, side, fill, stroke);
        break;
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double side,
    Paint fill,
    Paint stroke,
  ) {
    final path = Path();
    for (var index = 0; index < 10; index++) {
      final angle = -math.pi / 2 + (index * math.pi) / 5;
      final radius = index.isEven ? side / 2 : side * 0.22;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawCookie(
    Canvas canvas,
    Offset center,
    double side,
    Paint fill,
    Paint stroke,
  ) {
    canvas.drawCircle(center, side / 2, fill);
    canvas.drawCircle(center, side / 2, stroke);
    if (!filled) {
      return;
    }
    final chipPaint = Paint()
      ..color = const Color(0xFF6B3F16)
      ..style = PaintingStyle.fill;
    for (final offset in const [
      Offset(-0.12, -0.16),
      Offset(0.14, -0.02),
      Offset(-0.2, 0.18),
      Offset(0.21, 0.24),
    ]) {
      canvas.drawCircle(
        Offset(center.dx + side * offset.dx, center.dy + side * offset.dy),
        side * 0.045,
        chipPaint,
      );
    }
  }

  void _drawCoffee(
    Canvas canvas,
    Offset center,
    double side,
    Paint fill,
    Paint stroke,
  ) {
    final x = center.dx - side * 0.36;
    final y = center.dy - side * 0.26;
    final w = side * 0.62;
    final h = side * 0.52;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(side * 0.12),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(side * 0.12),
      ),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(x + w, y + h * 0.18)
        ..cubicTo(
          x + w + side * 0.26,
          y + h * 0.12,
          x + w + side * 0.26,
          y + h * 0.78,
          x + w,
          y + h * 0.72,
        ),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(x + side * 0.1, y - side * 0.12)
        ..cubicTo(
          x + side * 0.1,
          y - side * 0.22,
          x + side * 0.24,
          y - side * 0.22,
          x + side * 0.24,
          y - side * 0.34,
        ),
      stroke,
    );
  }

  void _drawBowl(
    Canvas canvas,
    Offset center,
    double side,
    Paint fill,
    Paint stroke,
  ) {
    final x = center.dx - side * 0.5;
    final y = center.dy - side * 0.2;
    final bowl = Path()
      ..moveTo(x, y)
      ..lineTo(x + side, y)
      ..cubicTo(
        x + side * 0.86,
        y + side * 0.52,
        x + side * 0.66,
        y + side * 0.72,
        x + side * 0.5,
        y + side * 0.72,
      )
      ..cubicTo(
        x + side * 0.34,
        y + side * 0.72,
        x + side * 0.14,
        y + side * 0.52,
        x,
        y,
      )
      ..close();
    canvas.drawPath(bowl, fill);
    canvas.drawPath(bowl, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(x + side * 0.18, y - side * 0.17)
        ..cubicTo(
          x + side * 0.38,
          y - side * 0.32,
          x + side * 0.62,
          y - side * 0.32,
          x + side * 0.82,
          y - side * 0.17,
        ),
      stroke,
    );
  }

  void _drawBurger(
    Canvas canvas,
    Offset center,
    double side,
    Paint fill,
    Paint stroke,
  ) {
    final x = center.dx - side * 0.48;
    final y = center.dy - side * 0.36;
    final top = Path()
      ..moveTo(x + side * 0.08, y + side * 0.28)
      ..cubicTo(
        x + side * 0.18,
        y - side * 0.1,
        x + side * 0.82,
        y - side * 0.1,
        x + side * 0.92,
        y + side * 0.28,
      )
      ..close();
    canvas.drawPath(top, fill);
    canvas.drawPath(top, stroke);
    for (final line in [0.48, 0.68, 0.84]) {
      canvas.drawLine(
        Offset(x + side * (line == 0.84 ? 0.18 : 0.08), y + side * line),
        Offset(x + side * (line == 0.84 ? 0.82 : 0.92), y + side * line),
        stroke,
      );
    }
  }

  void _drawPizza(
    Canvas canvas,
    Offset center,
    double side,
    Paint fill,
    Paint stroke,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - side * 0.48)
      ..lineTo(center.dx + side * 0.42, center.dy + side * 0.4)
      ..lineTo(center.dx - side * 0.42, center.dy + side * 0.4)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    if (!filled) {
      return;
    }
    final toppingPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - side * 0.1, center.dy - side * 0.02),
      side * 0.05,
      toppingPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + side * 0.12, center.dy + side * 0.16),
      side * 0.045,
      toppingPaint,
    );
  }

  void _drawHeart(
    Canvas canvas,
    Offset center,
    double side,
    Paint fill,
    Paint stroke,
  ) {
    final unit = side / 100;
    final path = Path()
      ..moveTo(center.dx, center.dy + 34 * unit)
      ..cubicTo(
        center.dx - 54 * unit,
        center.dy - 10 * unit,
        center.dx - 40 * unit,
        center.dy - 52 * unit,
        center.dx - 7 * unit,
        center.dy - 32 * unit,
      )
      ..cubicTo(
        center.dx + 26 * unit,
        center.dy - 52 * unit,
        center.dx + 54 * unit,
        center.dy - 10 * unit,
        center.dx,
        center.dy + 34 * unit,
      )
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawCupcake(
    Canvas canvas,
    Offset center,
    double side,
    Paint fill,
    Paint stroke,
  ) {
    final x = center.dx - side * 0.42;
    final y = center.dy - side * 0.44;
    final top = Path()
      ..moveTo(x + side * 0.12, y + side * 0.36)
      ..cubicTo(
        x + side * 0.12,
        y + side * 0.06,
        x + side * 0.88,
        y + side * 0.06,
        x + side * 0.88,
        y + side * 0.36,
      );
    canvas.drawPath(top, stroke);
    final base = Path()
      ..moveTo(x + side * 0.18, y + side * 0.42)
      ..lineTo(x + side * 0.82, y + side * 0.42)
      ..lineTo(x + side * 0.72, y + side * 0.88)
      ..lineTo(x + side * 0.28, y + side * 0.88)
      ..close();
    canvas.drawPath(base, fill);
    canvas.drawPath(base, stroke);
  }

  @override
  bool shouldRepaint(covariant _StampIconPainter oldDelegate) {
    return oldDelegate.presetKey != presetKey ||
        oldDelegate.filled != filled ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}

class _HeroLayout {
  const _HeroLayout({
    required this.variant,
    required this.width,
    required this.height,
    required this.radius,
    required this.padding,
    required this.subtitleY,
    required this.titleY,
    required this.subtitleSize,
    required this.titleSize,
    required this.progressSize,
    required this.badgeRadius,
    required this.badgeTopSafePadding,
    required this.badgeRightSafePadding,
    required this.badgeLabelOffset,
    required this.badgeValueOffset,
    required this.iconsY,
    required this.iconBoxHeight,
    required this.cellSize,
    required this.iconGap,
    required this.rewardY,
    required this.rewardHeight,
    required this.rewardTextY,
    required this.rewardSize,
  });

  factory _HeroLayout.forVariant(String variant) {
    if (variant.toUpperCase() == 'COMPACT') {
      return compact;
    }
    return modern;
  }

  static const modern = _HeroLayout(
    variant: 'MODERN',
    width: 1200,
    height: 628,
    radius: 48,
    padding: 72,
    subtitleY: 82,
    titleY: 148,
    subtitleSize: 28,
    titleSize: 56,
    progressSize: 56,
    badgeRadius: 124,
    badgeTopSafePadding: 32,
    badgeRightSafePadding: 40,
    badgeLabelOffset: -48,
    badgeValueOffset: 28,
    iconsY: 206,
    iconBoxHeight: 260,
    cellSize: 112,
    iconGap: 20,
    rewardY: 520,
    rewardHeight: 58,
    rewardTextY: 558,
    rewardSize: 28,
  );

  static const compact = _HeroLayout(
    variant: 'COMPACT',
    width: 1032,
    height: 336,
    radius: 36,
    padding: 48,
    subtitleY: 54,
    titleY: 102,
    subtitleSize: 22,
    titleSize: 40,
    progressSize: 40,
    badgeRadius: 80,
    badgeTopSafePadding: 18,
    badgeRightSafePadding: 24,
    badgeLabelOffset: -26,
    badgeValueOffset: 28,
    iconsY: 128,
    iconBoxHeight: 116,
    cellSize: 88,
    iconGap: 8,
    rewardY: 264,
    rewardHeight: 44,
    rewardTextY: 294,
    rewardSize: 22,
  );

  final String variant;
  final double width;
  final double height;
  final double radius;
  final double padding;
  final double subtitleY;
  final double titleY;
  final double subtitleSize;
  final double titleSize;
  final double progressSize;
  final double badgeRadius;
  final double badgeTopSafePadding;
  final double badgeRightSafePadding;
  final double badgeLabelOffset;
  final double badgeValueOffset;
  final double iconsY;
  final double iconBoxHeight;
  final double cellSize;
  final double iconGap;
  final double rewardY;
  final double rewardHeight;
  final double rewardTextY;
  final double rewardSize;

  double get aspectRatio => width / height;

  _ProgressBadgeLayout get progressBadge {
    final cx = width - badgeRightSafePadding - badgeRadius;
    final cy = badgeTopSafePadding + badgeRadius;
    return _ProgressBadgeLayout(
      cx: cx,
      cy: cy,
      radius: badgeRadius,
      labelY: cy + badgeLabelOffset,
      valueY: cy + badgeValueOffset,
    );
  }
}

class _ProgressBadgeLayout {
  const _ProgressBadgeLayout({
    required this.cx,
    required this.cy,
    required this.radius,
    required this.labelY,
    required this.valueY,
  });

  final double cx;
  final double cy;
  final double radius;
  final double labelY;
  final double valueY;
}

String _fallbackText(String value, String fallback) {
  final clean = value.trim();
  return clean.isEmpty ? fallback : clean;
}

String _truncate(String value, int maxLength) {
  if (value.length <= maxLength) {
    return value;
  }
  return '${value.substring(0, maxLength - 3)}...';
}

const _defaultImageBackgroundColor = Color(0xFF7C2D12);
const _defaultImageSurfaceColor = Color(0xFF92400E);
const _defaultImageAccentColor = Color(0xFFFACC15);
const _defaultImageTextColor = Color(0xFFFFFFFF);
const _defaultStampEmptyColor = Color(0xFFD6D3D1);
const _defaultRewardBannerColor = Color(0xFFA16207);

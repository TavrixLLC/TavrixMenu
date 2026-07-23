import 'dart:math' as math;

import 'card_design.dart';
import 'provider_preview.dart';

enum CardDesignValidationSeverity { error, warning }

class CardDesignValidationIssue {
  const CardDesignValidationIssue({
    required this.code,
    required this.severity,
    required this.field,
  });

  final String code;
  final CardDesignValidationSeverity severity;
  final String field;
}

class CardSurfaceContrastResult {
  const CardSurfaceContrastResult({
    required this.surface,
    required this.foreground,
    required this.ratio,
    required this.usesPreferredForeground,
  });

  final HexColorValue surface;
  final HexColorValue foreground;
  final double ratio;
  final bool usesPreferredForeground;

  bool get isAccessibleForNormalText => ratio >= 4.5;
}

class CardDesignValidationResult {
  const CardDesignValidationResult(this.issues);

  final List<CardDesignValidationIssue> issues;

  bool get passesSafetyChecks => issues.every(
    (issue) => issue.severity != CardDesignValidationSeverity.error,
  );
}

abstract final class CardDesignValidator {
  static final HexColorValue _warmInk = HexColorValue('#241916');
  static final HexColorValue _white = HexColorValue('#FFFFFF');

  static CardDesignValidationResult validate({
    required CardDesignDraft design,
    required List<ProviderPreviewCapability> providers,
  }) {
    final issues = <CardDesignValidationIssue>[];
    if (design.businessId.trim().isEmpty) {
      issues.add(_error('business_required', 'businessId'));
    }
    if (design.programId.trim().isEmpty) {
      issues.add(_error('program_required', 'programId'));
    }
    if (contrastRatio(design.backgroundColor, design.textColor) < 4.5) {
      issues.add(_error('text_contrast', 'textColor'));
    }
    for (final role in <String, HexColorValue>{
      'primaryColor': design.primaryColor,
      'secondaryColor': design.secondaryColor,
      'accentColor': design.accentColor,
    }.entries) {
      final resolved = foregroundForSurface(
        role.value,
        preferred: design.textColor,
      );
      if (!resolved.isAccessibleForNormalText) {
        issues.add(_error('surface_foreground_contrast', role.key));
      }
    }
    if (!design.copy.isComplete) {
      issues.add(_error('copy_incomplete', 'copy'));
    }
    for (final media in [design.logo, design.cover, design.rewardMedia]) {
      if (!media.isPublishable) {
        issues.add(_error('media_not_confirmed', 'media'));
        break;
      }
    }
    for (final provider in providers) {
      if (!provider.isAvailable) {
        issues.add(
          const CardDesignValidationIssue(
            code: 'provider_preview_unavailable',
            severity: CardDesignValidationSeverity.warning,
            field: 'provider',
          ),
        );
      }
    }
    return CardDesignValidationResult(List.unmodifiable(issues));
  }

  /// Chooses the highest-contrast accessible foreground. The merchant text
  /// color is respected when safe; official Warm Ink and white are bounded
  /// fallbacks. This keeps Coral on Warm Ink instead of inaccessible white.
  static CardSurfaceContrastResult foregroundForSurface(
    HexColorValue surface, {
    required HexColorValue preferred,
  }) {
    final candidates = <HexColorValue>[
      preferred,
      if (preferred != _warmInk) _warmInk,
      if (preferred != _white) _white,
    ];
    var selected = candidates.first;
    var selectedRatio = contrastRatio(surface, selected);
    for (final candidate in candidates.skip(1)) {
      final ratio = contrastRatio(surface, candidate);
      if (ratio > selectedRatio) {
        selected = candidate;
        selectedRatio = ratio;
      }
    }
    return CardSurfaceContrastResult(
      surface: surface,
      foreground: selected,
      ratio: selectedRatio,
      usesPreferredForeground: selected == preferred,
    );
  }

  static double contrastRatio(
    HexColorValue foreground,
    HexColorValue background,
  ) {
    final foregroundLuminance = _relativeLuminance(foreground.rgb);
    final backgroundLuminance = _relativeLuminance(background.rgb);
    final lighter = foregroundLuminance > backgroundLuminance
        ? foregroundLuminance
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance
        ? backgroundLuminance
        : foregroundLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(int rgb) {
    final channels = [(rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF]
        .map((channel) {
          final normalized = channel / 255;
          return normalized <= 0.04045
              ? normalized / 12.92
              : _pow((normalized + 0.055) / 1.055, 2.4);
        })
        .toList(growable: false);
    return (0.2126 * channels[0]) +
        (0.7152 * channels[1]) +
        (0.0722 * channels[2]);
  }

  static double _pow(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }

  static CardDesignValidationIssue _error(String code, String field) {
    return CardDesignValidationIssue(
      code: code,
      severity: CardDesignValidationSeverity.error,
      field: field,
    );
  }
}

import 'card_design.dart';

enum VisualThemeStatus { draft, scheduled, active, expired }

enum VisualThemeOccasion {
  ramadan,
  eid,
  newYear,
  birthday,
  blackFriday,
  businessAnniversary,
  custom,
}

class VisualThemeOverrides {
  const VisualThemeOverrides({
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.textColor,
    this.logoAssetId,
    this.coverAssetId,
    this.rewardAssetId,
  });

  final HexColorValue? primaryColor;
  final HexColorValue? secondaryColor;
  final HexColorValue? backgroundColor;
  final HexColorValue? textColor;
  final String? logoAssetId;
  final String? coverAssetId;
  final String? rewardAssetId;
}

class VisualThemeContract {
  const VisualThemeContract({
    required this.id,
    required this.businessId,
    required this.name,
    required this.occasion,
    required this.status,
    required this.timezone,
    required this.startAt,
    required this.endAt,
    required this.fallbackCardDesignRevisionId,
    required this.overrides,
  });

  final String id;
  final String businessId;
  final String name;
  final VisualThemeOccasion occasion;
  final VisualThemeStatus status;
  final String timezone;
  final DateTime startAt;
  final DateTime endAt;
  final String fallbackCardDesignRevisionId;
  final VisualThemeOverrides overrides;

  bool get hasValidWindow => startAt.isBefore(endAt);
}

enum ResolvedDesignOrigin { baseDesign, visualTheme }

class ResolvedDesignReference {
  const ResolvedDesignReference({
    required this.origin,
    required this.designRevisionId,
    this.visualThemeId,
  });

  final ResolvedDesignOrigin origin;
  final String designRevisionId;
  final String? visualThemeId;

  factory ResolvedDesignReference.fallback(VisualThemeContract theme) {
    return ResolvedDesignReference(
      origin: ResolvedDesignOrigin.baseDesign,
      designRevisionId: theme.fallbackCardDesignRevisionId,
    );
  }
}

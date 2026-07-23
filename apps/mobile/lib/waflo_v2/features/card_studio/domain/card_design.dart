enum CardDesignStatus { draft, published, archived }

enum CardMediaState { empty, localPreview, serverConfirmed }

enum StampVisualShape { circle, roundedSquare, star, customIcon }

enum CardVisualShape { roundedRectangle, softRectangle }

enum CardVisualIcon { coffee, star, gift, service, custom }

class CardDesignCopy {
  const CardDesignCopy({
    required this.joinHeadline,
    required this.joinBody,
    required this.rewardLabel,
  });

  final String joinHeadline;
  final String joinBody;
  final String rewardLabel;

  bool get isComplete =>
      joinHeadline.trim().isNotEmpty &&
      joinBody.trim().isNotEmpty &&
      rewardLabel.trim().isNotEmpty;
}

class HexColorValue {
  const HexColorValue._(this.value);

  factory HexColorValue(String input) {
    final normalized = input.trim().toUpperCase();
    final withHash = normalized.startsWith('#') ? normalized : '#$normalized';
    if (!RegExp(r'^#[0-9A-F]{6}$').hasMatch(withHash)) {
      throw FormatException('Expected a six-digit RGB hex color.', input);
    }
    return HexColorValue._(withHash);
  }

  final String value;

  int get rgb => int.parse(value.substring(1), radix: 16);

  @override
  bool operator ==(Object other) {
    return other is HexColorValue && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class CardMediaReference {
  const CardMediaReference({
    required this.state,
    this.assetId,
    this.localReviewLabel,
  });

  final CardMediaState state;
  final String? assetId;
  final String? localReviewLabel;

  bool get isPublishable =>
      state == CardMediaState.empty ||
      (state == CardMediaState.serverConfirmed && assetId != null);
}

class CardDesignDraft {
  const CardDesignDraft({
    required this.id,
    required this.businessId,
    required this.programId,
    required this.revision,
    required this.status,
    required this.businessDisplayName,
    required this.programDisplayName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    required this.cardShape,
    required this.stampShape,
    required this.stampIcon,
    required this.rewardIcon,
    required this.copy,
    required this.logo,
    required this.cover,
    required this.rewardMedia,
    this.reusableSourceDesignId,
  });

  final String id;
  final String businessId;
  final String programId;
  final int revision;
  final CardDesignStatus status;
  final String businessDisplayName;
  final String programDisplayName;
  final HexColorValue primaryColor;
  final HexColorValue secondaryColor;
  final HexColorValue accentColor;
  final HexColorValue backgroundColor;
  final HexColorValue textColor;
  final CardVisualShape cardShape;
  final StampVisualShape stampShape;
  final CardVisualIcon stampIcon;
  final CardVisualIcon rewardIcon;
  final CardDesignCopy copy;
  final CardMediaReference logo;
  final CardMediaReference cover;
  final CardMediaReference rewardMedia;
  final String? reusableSourceDesignId;
}

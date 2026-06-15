import 'package:equatable/equatable.dart';

class LoyaltyProgramRequest extends Equatable {
  const LoyaltyProgramRequest({
    required this.name,
    required this.stampGoal,
    required this.rewardName,
    this.description,
    this.rewardDescription,
    this.isActive = true,
    this.cardColor,
    this.accentColor,
    this.logoUrl,
    this.terms,
  });

  final String name;
  final int stampGoal;
  final String rewardName;
  final String? description;
  final String? rewardDescription;
  final bool isActive;
  final String? cardColor;
  final String? accentColor;
  final String? logoUrl;
  final String? terms;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'stampGoal': stampGoal,
      'rewardName': rewardName.trim(),
      'isActive': isActive,
      if (_clean(description) != null) 'description': _clean(description),
      if (_clean(rewardDescription) != null)
        'rewardDescription': _clean(rewardDescription),
      if (_clean(cardColor) != null) 'cardColor': _clean(cardColor),
      if (_clean(accentColor) != null) 'accentColor': _clean(accentColor),
      if (_clean(logoUrl) != null) 'logoUrl': _clean(logoUrl),
      if (_clean(terms) != null) 'terms': _clean(terms),
    };
  }

  @override
  List<Object?> get props => [
    name,
    stampGoal,
    rewardName,
    description,
    rewardDescription,
    isActive,
    cardColor,
    accentColor,
    logoUrl,
    terms,
  ];
}

class UpdateLoyaltyStampStyleRequest extends Equatable {
  const UpdateLoyaltyStampStyleRequest({
    this.styleType = 'PRESET',
    this.presetKey,
    this.themePreset,
    this.colorMode,
    this.backgroundColor,
    this.accentColor,
    this.textColor,
    this.walletBackgroundColor,
    this.imageBackgroundColor,
    this.imageSurfaceColor,
    this.imageAccentColor,
    this.imageTextColor,
    this.stampFilledColor,
    this.stampEmptyColor,
    this.rewardBannerColor,
    this.layoutVariant,
  });

  final String styleType;
  final String? presetKey;
  final String? themePreset;
  final String? colorMode;
  final String? backgroundColor;
  final String? accentColor;
  final String? textColor;
  final String? walletBackgroundColor;
  final String? imageBackgroundColor;
  final String? imageSurfaceColor;
  final String? imageAccentColor;
  final String? imageTextColor;
  final String? stampFilledColor;
  final String? stampEmptyColor;
  final String? rewardBannerColor;
  final String? layoutVariant;

  Map<String, dynamic> toJson() {
    return {
      'styleType': styleType.trim().isEmpty ? 'PRESET' : styleType.trim(),
      if (_clean(presetKey) != null) 'presetKey': _clean(presetKey),
      if (_clean(themePreset) != null) 'themePreset': _clean(themePreset),
      if (_clean(colorMode) != null) 'colorMode': _clean(colorMode),
      if (_clean(backgroundColor) != null)
        'backgroundColor': _clean(backgroundColor),
      if (_clean(accentColor) != null) 'accentColor': _clean(accentColor),
      if (_clean(textColor) != null) 'textColor': _clean(textColor),
      if (_clean(walletBackgroundColor) != null)
        'walletBackgroundColor': _clean(walletBackgroundColor),
      if (_clean(imageBackgroundColor) != null)
        'imageBackgroundColor': _clean(imageBackgroundColor),
      if (_clean(imageSurfaceColor) != null)
        'imageSurfaceColor': _clean(imageSurfaceColor),
      if (_clean(imageAccentColor) != null)
        'imageAccentColor': _clean(imageAccentColor),
      if (_clean(imageTextColor) != null)
        'imageTextColor': _clean(imageTextColor),
      if (_clean(stampFilledColor) != null)
        'stampFilledColor': _clean(stampFilledColor),
      if (_clean(stampEmptyColor) != null)
        'stampEmptyColor': _clean(stampEmptyColor),
      if (_clean(rewardBannerColor) != null)
        'rewardBannerColor': _clean(rewardBannerColor),
      if (_clean(layoutVariant) != null) 'layoutVariant': _clean(layoutVariant),
    };
  }

  @override
  List<Object?> get props => [
    styleType,
    presetKey,
    themePreset,
    colorMode,
    backgroundColor,
    accentColor,
    textColor,
    walletBackgroundColor,
    imageBackgroundColor,
    imageSurfaceColor,
    imageAccentColor,
    imageTextColor,
    stampFilledColor,
    stampEmptyColor,
    rewardBannerColor,
    layoutVariant,
  ];
}

class EnrollLoyaltyCustomerRequest extends Equatable {
  const EnrollLoyaltyCustomerRequest({
    this.phone,
    this.email,
    this.name,
    this.programId,
  });

  final String? phone;
  final String? email;
  final String? name;
  final String? programId;

  bool get hasRequiredContact {
    return (_clean(phone)?.isNotEmpty ?? false) ||
        (_clean(email)?.isNotEmpty ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      if (_clean(phone) != null) 'phone': _clean(phone),
      if (_clean(email) != null) 'email': _clean(email),
      if (_clean(name) != null) 'name': _clean(name),
      if (_clean(programId) != null) 'programId': _clean(programId),
    };
  }

  @override
  List<Object?> get props => [phone, email, name, programId];
}

class AddStampsRequest extends Equatable {
  const AddStampsRequest({this.count = 1, this.reason});

  final int count;
  final String? reason;

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      if (_clean(reason) != null) 'reason': _clean(reason),
    };
  }

  @override
  List<Object?> get props => [count, reason];
}

class RedeemRewardRequest extends Equatable {
  const RedeemRewardRequest({this.reason});

  final String? reason;

  Map<String, dynamic> toJson() {
    return {if (_clean(reason) != null) 'reason': _clean(reason)};
  }

  @override
  List<Object?> get props => [reason];
}

String? _clean(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

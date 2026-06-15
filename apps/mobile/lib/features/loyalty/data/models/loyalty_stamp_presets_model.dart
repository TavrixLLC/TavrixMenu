import '../../domain/entities/loyalty_stamp_style.dart';
import 'loyalty_json.dart';

class LoyaltyStampPresetModel extends LoyaltyStampPreset {
  const LoyaltyStampPresetModel({required super.key, required super.label});

  factory LoyaltyStampPresetModel.fromJson(Map<String, dynamic> json) {
    final key = loyaltyString(json['key']) ?? '';
    return LoyaltyStampPresetModel(
      key: key,
      label: loyaltyString(json['label']) ?? key,
    );
  }

  LoyaltyStampPreset toEntity() {
    return LoyaltyStampPreset(key: key, label: label);
  }
}

class LoyaltyStampPresetsModel extends LoyaltyStampPresets {
  const LoyaltyStampPresetsModel({
    super.presets,
    super.styleTypes,
    super.layoutVariants,
  });

  factory LoyaltyStampPresetsModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyStampPresetsModel(
      presets: loyaltyObjectList(
        json['presets'],
      ).map(LoyaltyStampPresetModel.fromJson).toList(growable: false),
      styleTypes: _stringList(json['styleTypes'] ?? json['style_types']),
      layoutVariants: _stringList(
        json['layoutVariants'] ?? json['layout_variants'],
      ),
    );
  }

  LoyaltyStampPresets toEntity() {
    return LoyaltyStampPresets(
      presets: presets,
      styleTypes: styleTypes.isEmpty ? const ['PRESET'] : styleTypes,
      layoutVariants: layoutVariants.isEmpty
          ? const ['MODERN', 'COMPACT']
          : layoutVariants,
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .map(loyaltyString)
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

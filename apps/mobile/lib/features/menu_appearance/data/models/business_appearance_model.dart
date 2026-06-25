import '../../domain/entities/business_appearance.dart';

class BusinessAppearanceModel extends BusinessAppearance {
  const BusinessAppearanceModel({
    required super.businessId,
    required super.menuTemplateId,
    super.menuThemeOverrides,
  });

  factory BusinessAppearanceModel.fromJson(
    Map<String, dynamic> json, {
    required String businessId,
  }) {
    final appearance =
        _asObject(json['appearance']) ??
        _asObject(json['data']) ??
        _asObject(json['businessAppearance']) ??
        json;

    return BusinessAppearanceModel(
      businessId:
          _string(appearance['businessId']) ??
          _string(appearance['business_id']) ??
          businessId,
      menuTemplateId:
          _string(appearance['menuTemplateId']) ??
          _string(appearance['menu_template_id']) ??
          'waflo-warm',
      menuThemeOverrides:
          _asObject(
            appearance['menuThemeOverrides'] ??
                appearance['menu_theme_overrides'],
          ) ??
          const <String, dynamic>{},
    );
  }

  BusinessAppearance toEntity() {
    return BusinessAppearance(
      businessId: businessId,
      menuTemplateId: menuTemplateId,
      menuThemeOverrides: menuThemeOverrides,
    );
  }
}

Map<String, dynamic>? _asObject(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

String? _string(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

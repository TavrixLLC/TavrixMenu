import '../../domain/entities/menu_template.dart';

class MenuTemplateModel extends MenuTemplate {
  const MenuTemplateModel({
    required super.id,
    required super.displayName,
    required super.description,
    super.bestFor,
    super.previewColors,
    super.layoutLabel,
    super.supportedFeatures,
    super.version,
    super.status,
  });

  factory MenuTemplateModel.fromJson(Map<String, dynamic> json) {
    final preview =
        _asObject(json['previewMetadata']) ?? _asObject(json['preview']);
    final themeTokens =
        _asObject(json['themeTokens']) ?? _asObject(json['theme_tokens']);
    final id = _string(json['id']) ?? '';

    return MenuTemplateModel(
      id: id,
      displayName:
          _string(json['displayName']) ??
          _string(json['display_name']) ??
          _fallbackName(id),
      description: _string(json['description']) ?? '',
      bestFor: _stringList(json['bestFor'] ?? json['best_for']),
      previewColors: _previewColors(preview: preview, themeTokens: themeTokens),
      layoutLabel:
          _string(preview?['layout']) ??
          _string(json['layoutVariant']) ??
          _string(json['layout_variant']),
      supportedFeatures: _stringList(
        json['supportedFeatures'] ?? json['supported_features'],
      ),
      version: _string(json['version']),
      status: _string(json['status']) ?? 'enabled',
    );
  }

  MenuTemplate toEntity() {
    return MenuTemplate(
      id: id,
      displayName: displayName,
      description: description,
      bestFor: bestFor,
      previewColors: previewColors,
      layoutLabel: layoutLabel,
      supportedFeatures: supportedFeatures,
      version: version,
      status: status,
    );
  }
}

List<String> _previewColors({
  required Map<String, dynamic>? preview,
  required Map<String, dynamic>? themeTokens,
}) {
  final raw =
      preview?['colors'] ??
      preview?['swatches'] ??
      themeTokens?['colors'] ??
      themeTokens?['palette'] ??
      themeTokens;
  final values = raw is Map ? raw.values : raw;
  return _stringList(values)
      .where((value) => value.trim().startsWith('#'))
      .take(5)
      .toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value == null) {
    return const [];
  }
  if (value is List) {
    return value
        .map(_string)
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  final item = _string(value)?.trim();
  return item == null || item.isEmpty ? const [] : [item];
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

String _fallbackName(String id) {
  final words = id
      .split(RegExp(r'[-_\s]+'))
      .where((word) => word.trim().isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}');
  return words.isEmpty ? 'Menu template' : words.join(' ');
}

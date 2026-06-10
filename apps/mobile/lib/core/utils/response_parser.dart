import '../errors/exceptions.dart';

Map<String, dynamic> asJsonObject(dynamic data, {String context = 'response'}) {
  try {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {
    throw ServerException('Invalid $context format.');
  }

  throw ServerException('Invalid $context format.');
}

Map<String, dynamic> asNestedJsonObject(
  dynamic data, {
  required String context,
  required List<String> keys,
}) {
  final json = asJsonObject(data, context: context);

  for (final key in keys) {
    final nested = json[key];
    if (nested != null) {
      return asJsonObject(nested, context: context);
    }
  }

  return json;
}

List<dynamic> asJsonList(dynamic data, {String context = 'response'}) {
  try {
    if (data is List) {
      return data;
    }
  } catch (_) {
    throw ServerException('Invalid $context format.');
  }

  throw ServerException('Invalid $context format.');
}

List<Map<String, dynamic>> asJsonObjectList(
  dynamic data, {
  String context = 'response',
}) {
  final list = asJsonList(data, context: context);

  try {
    return list
        .map((item) => asJsonObject(item, context: '$context item'))
        .toList();
  } on ServerException {
    rethrow;
  } on ValidationException {
    rethrow;
  } catch (_) {
    throw ServerException('Invalid $context format.');
  }
}

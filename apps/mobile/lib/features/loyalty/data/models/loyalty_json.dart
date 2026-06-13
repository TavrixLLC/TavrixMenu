Map<String, dynamic>? loyaltyObject(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

List<Map<String, dynamic>> loyaltyObjectList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(loyaltyObject)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

String? loyaltyString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

int? loyaltyInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

bool? loyaltyBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return bool.tryParse(value);
  }
  return null;
}

String? loyaltyDateString(Object? value) {
  if (value is DateTime) {
    return value.toIso8601String();
  }
  return loyaltyString(value);
}

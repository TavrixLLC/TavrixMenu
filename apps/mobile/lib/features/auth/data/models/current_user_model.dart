import '../../../business_setup/data/models/business_model.dart';
import '../../domain/entities/current_user.dart';

class CurrentUserModel extends CurrentUser {
  const CurrentUserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.businesses,
  });

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    final responseJson = _unwrapData(json);
    final userJson = _jsonObject(responseJson['user']) ?? responseJson;
    final businesses = _businessesFrom(responseJson['businesses']);
    final firstBusinessRole = businesses.isEmpty ? null : businesses.first.role;

    return CurrentUserModel(
      id: _stringValue(userJson['id']) ?? '',
      email: _stringValue(userJson['email']) ?? '',
      fullName:
          _stringValue(userJson['full_name']) ??
          _stringValue(userJson['fullName']) ??
          _stringValue(userJson['name']) ??
          '',
      role:
          _stringValue(userJson['role']) ??
          _stringValue(firstBusinessRole) ??
          'owner',
      businesses: businesses,
    );
  }

  CurrentUser toEntity() {
    return CurrentUser(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
      businesses: businesses,
    );
  }

  static Map<String, dynamic> _unwrapData(Map<String, dynamic> json) {
    final data = _jsonObject(json['data']);
    return data ?? json;
  }

  static Map<String, dynamic>? _jsonObject(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static List<BusinessModel> _businessesFrom(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return [
      for (final item in value)
        if (_jsonObject(item) case final json?) BusinessModel.fromJson(json),
    ];
  }

  static String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }
}

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/response_parser.dart';
import '../../../business_setup/data/models/business_model.dart';
import '../../../business_setup/domain/entities/business.dart';
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
    final userJson = _userJson(json);
    final businesses = _businessesFromJson(json);

    return CurrentUserModel(
      id: userJson['id'] as String? ?? '',
      email: userJson['email'] as String? ?? '',
      fullName:
          userJson['full_name'] as String? ??
          userJson['fullName'] as String? ??
          userJson['name'] as String? ??
          '',
      role:
          userJson['role'] as String? ??
          (businesses.isEmpty ? 'OWNER' : businesses.first.role),
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

  static Map<String, dynamic> _userJson(Map<String, dynamic> json) {
    final nestedUser = json['user'];
    if (nestedUser == null) {
      return json;
    }

    return asJsonObject(nestedUser, context: 'current user');
  }

  static List<Business> _businessesFromJson(Map<String, dynamic> json) {
    final data = json['businesses'];
    if (data == null) {
      return const [];
    }

    try {
      return asJsonObjectList(
        data,
        context: 'current user businesses',
      ).map(BusinessModel.fromJson).map((model) => model.toEntity()).toList();
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid current user businesses response.');
    }
  }
}

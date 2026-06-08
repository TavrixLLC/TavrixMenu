import '../../domain/entities/current_user.dart';

class CurrentUserModel extends CurrentUser {
  const CurrentUserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
  });

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName:
          json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'owner',
    );
  }

  CurrentUser toEntity() {
    return CurrentUser(id: id, email: email, fullName: fullName, role: role);
  }
}

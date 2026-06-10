import 'package:equatable/equatable.dart';

class CurrentUser extends Equatable {
  const CurrentUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;

  @override
  List<Object?> get props => [id, email, fullName, role];
}

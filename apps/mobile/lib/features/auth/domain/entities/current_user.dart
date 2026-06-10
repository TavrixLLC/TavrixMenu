import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';

class CurrentUser extends Equatable {
  const CurrentUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.businesses = const [],
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final List<Business> businesses;

  @override
  List<Object?> get props => [id, email, fullName, role, businesses];
}

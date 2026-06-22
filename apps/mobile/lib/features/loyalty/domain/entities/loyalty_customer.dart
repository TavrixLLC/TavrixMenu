import 'package:equatable/equatable.dart';

class LoyaltyCustomer extends Equatable {
  const LoyaltyCustomer({required this.id, this.phone, this.email, this.name});

  final String id;
  final String? phone;
  final String? email;
  final String? name;

  String get displayName {
    final cleanName = name?.trim();
    if (cleanName != null && cleanName.isNotEmpty) {
      return cleanName;
    }

    final cleanPhone = phone?.trim();
    if (cleanPhone != null && cleanPhone.isNotEmpty) {
      return cleanPhone;
    }

    final cleanEmail = email?.trim();
    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return cleanEmail;
    }

    return 'Loyalty customer';
  }

  @override
  List<Object?> get props => [id, phone, email, name];
}

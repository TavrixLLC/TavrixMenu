import '../../domain/entities/loyalty_customer.dart';
import 'loyalty_json.dart';

class LoyaltyCustomerModel extends LoyaltyCustomer {
  const LoyaltyCustomerModel({
    required super.id,
    super.phone,
    super.email,
    super.name,
  });

  factory LoyaltyCustomerModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyCustomerModel(
      id: loyaltyString(json['id']) ?? '',
      phone: loyaltyString(json['phone']),
      email: loyaltyString(json['email']),
      name: loyaltyString(json['name']),
    );
  }

  LoyaltyCustomer toEntity() {
    return LoyaltyCustomer(id: id, phone: phone, email: email, name: name);
  }
}

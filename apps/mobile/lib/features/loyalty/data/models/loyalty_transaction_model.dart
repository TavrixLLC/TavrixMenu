import '../../domain/entities/loyalty_transaction.dart';
import 'loyalty_json.dart';

class LoyaltyTransactionModel extends LoyaltyTransaction {
  const LoyaltyTransactionModel({
    required super.id,
    required super.type,
    super.businessId,
    super.loyaltyProgramId,
    super.membershipId,
    super.customerId,
    super.actorUserId,
    super.stampsDelta,
    super.reason,
    super.createdAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: loyaltyString(json['id']) ?? '',
      businessId:
          loyaltyString(json['businessId']) ??
          loyaltyString(json['business_id']),
      loyaltyProgramId:
          loyaltyString(json['loyaltyProgramId']) ??
          loyaltyString(json['loyalty_program_id']),
      membershipId:
          loyaltyString(json['membershipId']) ??
          loyaltyString(json['membership_id']),
      customerId:
          loyaltyString(json['customerId']) ??
          loyaltyString(json['customer_id']),
      actorUserId:
          loyaltyString(json['actorUserId']) ??
          loyaltyString(json['actor_user_id']),
      type: loyaltyString(json['type']) ?? 'UNKNOWN',
      stampsDelta:
          loyaltyInt(json['stampsDelta']) ??
          loyaltyInt(json['stamps_delta']) ??
          0,
      reason: loyaltyString(json['reason']),
      createdAt: loyaltyDateString(json['createdAt'] ?? json['created_at']),
    );
  }

  LoyaltyTransaction toEntity() {
    return LoyaltyTransaction(
      id: id,
      businessId: businessId,
      loyaltyProgramId: loyaltyProgramId,
      membershipId: membershipId,
      customerId: customerId,
      actorUserId: actorUserId,
      type: type,
      stampsDelta: stampsDelta,
      reason: reason,
      createdAt: createdAt,
    );
  }
}

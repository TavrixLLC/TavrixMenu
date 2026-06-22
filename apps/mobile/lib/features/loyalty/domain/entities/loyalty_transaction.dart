import 'package:equatable/equatable.dart';

class LoyaltyTransaction extends Equatable {
  const LoyaltyTransaction({
    required this.id,
    required this.type,
    this.businessId,
    this.loyaltyProgramId,
    this.membershipId,
    this.customerId,
    this.actorUserId,
    this.stampsDelta = 0,
    this.reason,
    this.createdAt,
  });

  final String id;
  final String? businessId;
  final String? loyaltyProgramId;
  final String? membershipId;
  final String? customerId;
  final String? actorUserId;
  final String type;
  final int stampsDelta;
  final String? reason;
  final String? createdAt;

  @override
  List<Object?> get props => [
    id,
    businessId,
    loyaltyProgramId,
    membershipId,
    customerId,
    actorUserId,
    type,
    stampsDelta,
    reason,
    createdAt,
  ];
}

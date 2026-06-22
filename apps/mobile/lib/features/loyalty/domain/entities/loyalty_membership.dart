import 'package:equatable/equatable.dart';

import 'loyalty_card_state.dart';
import 'loyalty_customer.dart';
import 'loyalty_program.dart';
import 'loyalty_transaction.dart';

class LoyaltyMembership extends Equatable {
  const LoyaltyMembership({
    required this.id,
    this.businessId,
    this.loyaltyProgramId,
    this.customerId,
    this.stampCount = 0,
    this.rewardReady = false,
    this.totalStampsEarned = 0,
    this.totalRewardsRedeemed = 0,
    this.status = 'ACTIVE',
    this.customer,
    this.program,
    this.cardState,
    this.transactions = const [],
  });

  final String id;
  final String? businessId;
  final String? loyaltyProgramId;
  final String? customerId;
  final int stampCount;
  final bool rewardReady;
  final int totalStampsEarned;
  final int totalRewardsRedeemed;
  final String status;
  final LoyaltyCustomer? customer;
  final LoyaltyProgram? program;
  final LoyaltyCardState? cardState;
  final List<LoyaltyTransaction> transactions;

  LoyaltyCardState get effectiveCardState {
    final state = cardState;
    if (state != null) {
      return state;
    }

    final goal = program?.stampGoal ?? 0;
    final percent = goal <= 0 ? 0 : ((stampCount / goal) * 100).round();
    return LoyaltyCardState(
      stampCount: stampCount,
      stampGoal: goal,
      rewardReady: rewardReady,
      progressPercent: percent,
      rewardName: program?.rewardName ?? 'Reward',
      programName: program?.name ?? 'Loyalty program',
    );
  }

  LoyaltyMembership copyWith({
    String? id,
    String? businessId,
    String? loyaltyProgramId,
    String? customerId,
    int? stampCount,
    bool? rewardReady,
    int? totalStampsEarned,
    int? totalRewardsRedeemed,
    String? status,
    LoyaltyCustomer? customer,
    LoyaltyProgram? program,
    LoyaltyCardState? cardState,
    List<LoyaltyTransaction>? transactions,
  }) {
    return LoyaltyMembership(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      loyaltyProgramId: loyaltyProgramId ?? this.loyaltyProgramId,
      customerId: customerId ?? this.customerId,
      stampCount: stampCount ?? this.stampCount,
      rewardReady: rewardReady ?? this.rewardReady,
      totalStampsEarned: totalStampsEarned ?? this.totalStampsEarned,
      totalRewardsRedeemed: totalRewardsRedeemed ?? this.totalRewardsRedeemed,
      status: status ?? this.status,
      customer: customer ?? this.customer,
      program: program ?? this.program,
      cardState: cardState ?? this.cardState,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    loyaltyProgramId,
    customerId,
    stampCount,
    rewardReady,
    totalStampsEarned,
    totalRewardsRedeemed,
    status,
    customer,
    program,
    cardState,
    transactions,
  ];
}

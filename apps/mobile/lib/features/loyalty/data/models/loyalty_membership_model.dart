import '../../domain/entities/loyalty_membership.dart';
import 'loyalty_card_state_model.dart';
import 'loyalty_customer_model.dart';
import 'loyalty_json.dart';
import 'loyalty_program_model.dart';
import 'loyalty_transaction_model.dart';

class LoyaltyMembershipModel extends LoyaltyMembership {
  const LoyaltyMembershipModel({
    required super.id,
    super.businessId,
    super.loyaltyProgramId,
    super.customerId,
    super.stampCount,
    super.rewardReady,
    super.totalStampsEarned,
    super.totalRewardsRedeemed,
    super.status,
    super.customer,
    super.program,
    super.cardState,
    super.transactions,
  });

  factory LoyaltyMembershipModel.fromJson(Map<String, dynamic> json) {
    final cardStateJson =
        loyaltyObject(json['cardState']) ?? loyaltyObject(json['card_state']);
    final customerJson = loyaltyObject(json['customer']);
    final programJson = loyaltyObject(json['program']);
    final transactionJson =
        json['transactions'] ??
        json['recentTransactions'] ??
        json['recent_transactions'];

    return LoyaltyMembershipModel(
      id: loyaltyString(json['id']) ?? '',
      businessId:
          loyaltyString(json['businessId']) ??
          loyaltyString(json['business_id']),
      loyaltyProgramId:
          loyaltyString(json['loyaltyProgramId']) ??
          loyaltyString(json['loyalty_program_id']),
      customerId:
          loyaltyString(json['customerId']) ??
          loyaltyString(json['customer_id']),
      stampCount:
          loyaltyInt(json['stampCount']) ??
          loyaltyInt(json['stamp_count']) ??
          (cardStateJson == null
              ? 0
              : loyaltyInt(cardStateJson['stampCount']) ??
                    loyaltyInt(cardStateJson['stamp_count']) ??
                    0),
      rewardReady:
          loyaltyBool(json['rewardReady']) ??
          loyaltyBool(json['reward_ready']) ??
          (cardStateJson == null
              ? false
              : loyaltyBool(cardStateJson['rewardReady']) ??
                    loyaltyBool(cardStateJson['reward_ready']) ??
                    false),
      totalStampsEarned:
          loyaltyInt(json['totalStampsEarned']) ??
          loyaltyInt(json['total_stamps_earned']) ??
          0,
      totalRewardsRedeemed:
          loyaltyInt(json['totalRewardsRedeemed']) ??
          loyaltyInt(json['total_rewards_redeemed']) ??
          0,
      status: loyaltyString(json['status']) ?? 'ACTIVE',
      customer: customerJson == null
          ? null
          : LoyaltyCustomerModel.fromJson(customerJson).toEntity(),
      program: programJson == null
          ? null
          : LoyaltyProgramModel.fromJson(programJson).toEntity(),
      cardState: cardStateJson == null
          ? null
          : LoyaltyCardStateModel.fromJson(cardStateJson).toEntity(),
      transactions: loyaltyObjectList(transactionJson)
          .map((json) => LoyaltyTransactionModel.fromJson(json).toEntity())
          .toList(),
    );
  }

  LoyaltyMembership toEntity() {
    return LoyaltyMembership(
      id: id,
      businessId: businessId,
      loyaltyProgramId: loyaltyProgramId,
      customerId: customerId,
      stampCount: stampCount,
      rewardReady: rewardReady,
      totalStampsEarned: totalStampsEarned,
      totalRewardsRedeemed: totalRewardsRedeemed,
      status: status,
      customer: customer,
      program: program,
      cardState: cardState,
      transactions: transactions,
    );
  }
}

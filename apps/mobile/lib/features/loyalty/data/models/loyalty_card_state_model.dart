import '../../domain/entities/loyalty_card_state.dart';
import 'loyalty_json.dart';

class LoyaltyCardStateModel extends LoyaltyCardState {
  const LoyaltyCardStateModel({
    required super.stampCount,
    required super.stampGoal,
    required super.rewardReady,
    required super.progressPercent,
    required super.rewardName,
    required super.programName,
  });

  factory LoyaltyCardStateModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyCardStateModel(
      stampCount:
          loyaltyInt(json['stampCount']) ??
          loyaltyInt(json['stamp_count']) ??
          0,
      stampGoal:
          loyaltyInt(json['stampGoal']) ?? loyaltyInt(json['stamp_goal']) ?? 0,
      rewardReady:
          loyaltyBool(json['rewardReady']) ??
          loyaltyBool(json['reward_ready']) ??
          false,
      progressPercent:
          loyaltyInt(json['progressPercent']) ??
          loyaltyInt(json['progress_percent']) ??
          0,
      rewardName:
          loyaltyString(json['rewardName']) ??
          loyaltyString(json['reward_name']) ??
          'Reward',
      programName:
          loyaltyString(json['programName']) ??
          loyaltyString(json['program_name']) ??
          'Loyalty program',
    );
  }

  LoyaltyCardState toEntity() {
    return LoyaltyCardState(
      stampCount: stampCount,
      stampGoal: stampGoal,
      rewardReady: rewardReady,
      progressPercent: progressPercent,
      rewardName: rewardName,
      programName: programName,
    );
  }
}

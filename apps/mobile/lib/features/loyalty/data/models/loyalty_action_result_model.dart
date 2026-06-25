import '../../domain/entities/loyalty_action_result.dart';
import 'loyalty_card_state_model.dart';
import 'loyalty_json.dart';
import 'loyalty_membership_model.dart';

class LoyaltyActionResultModel extends LoyaltyActionResult {
  const LoyaltyActionResultModel({
    required super.membership,
    required super.cardState,
  });

  factory LoyaltyActionResultModel.fromJson(Map<String, dynamic> json) {
    final cardState = LoyaltyCardStateModel.fromJson(
      loyaltyObject(json['cardState']) ??
          loyaltyObject(json['card_state']) ??
          const <String, dynamic>{},
    ).toEntity();
    final membership = LoyaltyMembershipModel.fromJson(
      loyaltyObject(json['membership']) ?? const <String, dynamic>{},
    ).toEntity().copyWith(cardState: cardState);

    return LoyaltyActionResultModel(
      membership: membership,
      cardState: cardState,
    );
  }

  LoyaltyActionResult toEntity() {
    return LoyaltyActionResult(membership: membership, cardState: cardState);
  }
}

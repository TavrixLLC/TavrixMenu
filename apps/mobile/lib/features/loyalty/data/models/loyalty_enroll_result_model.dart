import '../../domain/entities/loyalty_enroll_result.dart';
import 'loyalty_card_state_model.dart';
import 'loyalty_customer_model.dart';
import 'loyalty_json.dart';
import 'loyalty_membership_model.dart';
import 'loyalty_program_model.dart';

class LoyaltyEnrollResultModel extends LoyaltyEnrollResult {
  const LoyaltyEnrollResultModel({
    required super.customer,
    required super.membership,
    required super.program,
    required super.cardState,
  });

  factory LoyaltyEnrollResultModel.fromJson(Map<String, dynamic> json) {
    final customer = LoyaltyCustomerModel.fromJson(
      loyaltyObject(json['customer']) ?? const <String, dynamic>{},
    ).toEntity();
    final program = LoyaltyProgramModel.fromJson(
      loyaltyObject(json['program']) ?? const <String, dynamic>{},
    ).toEntity();
    final cardState = LoyaltyCardStateModel.fromJson(
      loyaltyObject(json['cardState']) ??
          loyaltyObject(json['card_state']) ??
          const <String, dynamic>{},
    ).toEntity();
    final membership =
        LoyaltyMembershipModel.fromJson(
          loyaltyObject(json['membership']) ?? const <String, dynamic>{},
        ).toEntity().copyWith(
          customer: customer,
          program: program,
          cardState: cardState,
        );

    return LoyaltyEnrollResultModel(
      customer: customer,
      membership: membership,
      program: program,
      cardState: cardState,
    );
  }

  LoyaltyEnrollResult toEntity() {
    return LoyaltyEnrollResult(
      customer: customer,
      membership: membership,
      program: program,
      cardState: cardState,
    );
  }
}

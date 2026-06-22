import 'package:equatable/equatable.dart';

import 'loyalty_card_state.dart';
import 'loyalty_membership.dart';

class LoyaltyActionResult extends Equatable {
  const LoyaltyActionResult({
    required this.membership,
    required this.cardState,
  });

  final LoyaltyMembership membership;
  final LoyaltyCardState cardState;

  @override
  List<Object?> get props => [membership, cardState];
}

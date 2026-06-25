import 'package:equatable/equatable.dart';

import 'loyalty_card_state.dart';
import 'loyalty_customer.dart';
import 'loyalty_membership.dart';
import 'loyalty_program.dart';

class LoyaltyEnrollResult extends Equatable {
  const LoyaltyEnrollResult({
    required this.customer,
    required this.membership,
    required this.program,
    required this.cardState,
  });

  final LoyaltyCustomer customer;
  final LoyaltyMembership membership;
  final LoyaltyProgram program;
  final LoyaltyCardState cardState;

  @override
  List<Object?> get props => [customer, membership, program, cardState];
}

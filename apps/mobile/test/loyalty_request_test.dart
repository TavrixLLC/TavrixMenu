import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_requests.dart';

void main() {
  test(
    'enroll request sends phone, email, name, and programId when present',
    () {
      final request = EnrollLoyaltyCustomerRequest(
        phone: ' +9647700000000 ',
        email: ' customer@example.com ',
        name: ' Demo Customer ',
        programId: ' loyalty_program_id ',
      );

      expect(request.hasRequiredContact, isTrue);
      expect(request.toJson(), {
        'phone': '+9647700000000',
        'email': 'customer@example.com',
        'name': 'Demo Customer',
        'programId': 'loyalty_program_id',
      });
    },
  );

  test('add stamps request sends count and optional reason', () {
    expect(
      const AddStampsRequest(count: 2, reason: ' Coffee purchase ').toJson(),
      {'count': 2, 'reason': 'Coffee purchase'},
    );
    expect(const AddStampsRequest().toJson(), {'count': 1});
  });

  test('redeem reward request omits blank reason', () {
    expect(
      const RedeemRewardRequest(reason: ' Free coffee redeemed ').toJson(),
      {'reason': 'Free coffee redeemed'},
    );
    expect(const RedeemRewardRequest(reason: ' ').toJson(), isEmpty);
  });

  test('program request keeps stamp-card fields only', () {
    final request = LoyaltyProgramRequest(
      name: ' Tavrix Cafe Stamp Card ',
      stampGoal: 5,
      rewardName: ' Free coffee ',
      description: ' Collect stamps ',
      rewardDescription: ' One free coffee ',
      terms: ' Dine-in only ',
    );

    expect(request.toJson(), {
      'name': 'Tavrix Cafe Stamp Card',
      'stampGoal': 5,
      'rewardName': 'Free coffee',
      'isActive': true,
      'description': 'Collect stamps',
      'rewardDescription': 'One free coffee',
      'terms': 'Dine-in only',
    });
  });
}

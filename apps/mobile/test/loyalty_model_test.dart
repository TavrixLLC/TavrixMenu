import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/data/models/loyalty_membership_model.dart';
import 'package:tavrix_menu_mobile/features/loyalty/data/models/loyalty_program_model.dart';
import 'package:tavrix_menu_mobile/features/loyalty/data/models/loyalty_stamp_presets_model.dart';
import 'package:tavrix_menu_mobile/features/loyalty/data/models/loyalty_stamp_style_model.dart';
import 'package:tavrix_menu_mobile/features/loyalty/data/models/loyalty_transaction_model.dart';

void main() {
  test('parses Sprint 5 loyalty program response', () {
    final model = LoyaltyProgramModel.fromJson({
      'id': 'loyalty_program_id',
      'businessId': 'bus_123',
      'name': 'Tavrix Cafe Stamp Card',
      'description': 'Collect stamps on coffee visits.',
      'stampGoal': 5,
      'rewardName': 'Free coffee',
      'rewardDescription': 'One free coffee after 5 stamps.',
      'isActive': true,
      'cardColor': '#111827',
      'accentColor': '#f59e0b',
      'logoUrl': null,
      'terms': 'Dine-in only.',
      'createdAt': '2026-06-13T00:00:00.000Z',
    });

    expect(model.id, 'loyalty_program_id');
    expect(model.businessId, 'bus_123');
    expect(model.stampGoal, 5);
    expect(model.rewardName, 'Free coffee');
    expect(model.cardColor, '#111827');
    expect(model.isActive, isTrue);
  });

  test('parses loyalty membership with customer, program, and card state', () {
    final model = LoyaltyMembershipModel.fromJson({
      'id': 'membership_id',
      'businessId': 'bus_123',
      'loyaltyProgramId': 'loyalty_program_id',
      'customerId': 'customer_id',
      'stampCount': 3,
      'rewardReady': false,
      'status': 'ACTIVE',
      'customer': {
        'id': 'customer_id',
        'phone': '+9647700000000',
        'email': 'customer@example.com',
        'name': 'Demo Customer',
      },
      'program': {
        'id': 'loyalty_program_id',
        'name': 'Tavrix Cafe Stamp Card',
        'stampGoal': 5,
        'rewardName': 'Free coffee',
      },
      'cardState': {
        'stampCount': 3,
        'stampGoal': 5,
        'rewardReady': false,
        'progressPercent': 60,
        'rewardName': 'Free coffee',
        'programName': 'Tavrix Cafe Stamp Card',
      },
    });

    expect(model.customer?.name, 'Demo Customer');
    expect(model.program?.stampGoal, 5);
    expect(model.cardState?.progressPercent, 60);
    expect(model.effectiveCardState.rewardReady, isFalse);
  });

  test('parses known and unknown loyalty transactions safely', () {
    final known = LoyaltyTransactionModel.fromJson({
      'id': 'txn_123',
      'type': 'STAMP_ADDED',
      'stampsDelta': 1,
      'reason': 'Coffee purchase',
      'createdAt': '2026-06-13T00:00:00.000Z',
    });
    final unknown = LoyaltyTransactionModel.fromJson({
      'id': 'txn_unknown',
      'type': 'CUSTOM_EVENT',
      'stampsDelta': 0,
    });

    expect(known.type, 'STAMP_ADDED');
    expect(known.stampsDelta, 1);
    expect(unknown.type, 'CUSTOM_EVENT');
    expect(unknown.stampsDelta, 0);
  });

  test('parses Sprint 8 stamp presets response', () {
    final model = LoyaltyStampPresetsModel.fromJson({
      'presets': [
        {'key': 'STAR', 'label': 'Star'},
        {'key': 'COFFEE', 'label': 'Coffee'},
      ],
      'styleTypes': ['PRESET'],
      'layoutVariants': ['MODERN', 'COMPACT'],
    });

    expect(model.presets, hasLength(2));
    expect(model.presets.last.key, 'COFFEE');
    expect(model.styleTypes, ['PRESET']);
    expect(model.layoutVariants, ['MODERN', 'COMPACT']);
  });

  test('parses Sprint 8 stamp style response with nullable fields', () {
    final model = LoyaltyStampStyleModel.fromJson({
      'id': 'stamp_style_id',
      'loyaltyProgramId': 'loyalty_program_id',
      'styleType': 'PRESET',
      'presetKey': 'STAR',
      'backgroundColor': '#111827',
      'accentColor': '#f59e0b',
      'textColor': '#ffffff',
      'layoutVariant': 'MODERN',
      'isDefault': false,
      'createdAt': '2026-06-15T00:00:00.000Z',
      'updatedAt': '2026-06-15T00:00:00.000Z',
    });

    expect(model.id, 'stamp_style_id');
    expect(model.loyaltyProgramId, 'loyalty_program_id');
    expect(model.presetKey, 'STAR');
    expect(model.backgroundColor, '#111827');
    expect(model.isDefault, isFalse);

    final sparse = LoyaltyStampStyleModel.fromJson({'id': null});
    expect(sparse.id, '');
    expect(sparse.styleType, 'PRESET');
    expect(sparse.presetKey, 'STAR');
    expect(sparse.layoutVariant, 'MODERN');
  });
}

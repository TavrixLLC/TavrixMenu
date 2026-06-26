import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/auth/data/models/current_user_model.dart';

void main() {
  test('parses Sprint 3 /me response with memberships and onboarding', () {
    final model = CurrentUserModel.fromJson({
      'user': {
        'id': 'usr_123',
        'clerkUserId': 'user_tavrix_owner',
        'name': 'Tavrix Owner',
        'email': 'owner@tavrix.local',
        'phone': null,
        'status': 'ACTIVE',
        'createdAt': '2026-06-10T00:00:00.000Z',
        'updatedAt': DateTime.utc(2026, 6, 10),
      },
      'memberships': [
        {
          'id': 'mem_123',
          'role': 'OWNER',
          'isActive': true,
          'business': {
            'id': 'bus_123',
            'name': 'Tavrix Cafe',
            'slug': 'tavrix-cafe',
            'type': 'cafe',
            'city': 'Baghdad',
            'currency': 'IQD',
            'language': 'ar',
            'logoUrl': null,
            'coverUrl': null,
          },
        },
      ],
      'onboarding': {
        'hasBusiness': true,
        'activeBusinessCount': 1,
        'recommendedNextStep': 'OPEN_DASHBOARD',
      },
      'businesses': [
        {
          'id': 'bus_123',
          'name': 'Tavrix Cafe',
          'slug': 'tavrix-cafe',
          'type': 'cafe',
          'role': 'OWNER',
        },
      ],
    });

    expect(model.id, 'usr_123');
    expect(model.clerkUserId, 'user_tavrix_owner');
    expect(model.fullName, 'Tavrix Owner');
    expect(model.role, 'OWNER');
    expect(model.createdAt, '2026-06-10T00:00:00.000Z');
    expect(model.updatedAt, '2026-06-10T00:00:00.000Z');
    expect(model.memberships.single.business.city, 'Baghdad');
    expect(model.businesses.single.slug, 'tavrix-cafe');
    expect(model.hasBusiness, isTrue);
    expect(model.primaryBusinessId, 'bus_123');
  });

  test('parses backwards-compatible top-level /me response safely', () {
    final model = CurrentUserModel.fromJson({
      'id': 'usr_legacy',
      'email': 'owner@tavrix.local',
      'fullName': 'Legacy Owner',
      'role': 'OWNER',
      'businesses': <Map<String, dynamic>>[],
    });

    expect(model.id, 'usr_legacy');
    expect(model.fullName, 'Legacy Owner');
    expect(model.hasBusiness, isFalse);
  });

  test('missing role data falls back to neutral operator role', () {
    final model = CurrentUserModel.fromJson({
      'user': {'id': 'usr_unknown'},
      'businesses': [
        {'id': 'bus_123', 'name': 'Tavrix Cafe'},
      ],
    });

    expect(model.role, 'BUSINESS_OPERATOR');
    expect(model.businesses.single.role, 'BUSINESS_OPERATOR');
    expect(model.role, isNot('STAFF'));
  });

  test('parses authenticated owner with no business for setup routing', () {
    final model = CurrentUserModel.fromJson({
      'user': {
        'id': 'usr_new_owner',
        'name': 'New Owner',
        'email': 'new-owner@tavrix.local',
      },
      'memberships': <Map<String, dynamic>>[],
      'businesses': <Map<String, dynamic>>[],
      'role': 'OWNER',
      'onboarding': {
        'hasBusiness': false,
        'activeBusinessCount': 0,
        'recommendedNextStep': 'CREATE_BUSINESS',
      },
    });

    expect(model.role, 'OWNER');
    expect(model.memberships, isEmpty);
    expect(model.businesses, isEmpty);
    expect(model.hasBusiness, isFalse);
    expect(model.onboarding.activeBusinessCount, 0);
    expect(model.onboarding.recommendedNextStep, 'CREATE_BUSINESS');
    expect(model.primaryBusinessId, isNull);
  });
}

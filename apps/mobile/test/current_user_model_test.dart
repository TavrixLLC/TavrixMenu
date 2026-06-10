import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/auth/data/models/current_user_model.dart';

void main() {
  test('parses /me envelope with businesses', () {
    final user = CurrentUserModel.fromJson(const {
      'user': {
        'id': 'user-1',
        'clerkUserId': 'dev_tavrix_owner',
        'name': 'Tavrix Demo Owner',
        'email': 'owner@tavrix.local',
        'phone': null,
        'status': 'ACTIVE',
      },
      'businesses': [
        {
          'id': 'business-1',
          'name': 'Tavrix Cafe',
          'slug': 'tavrix-cafe',
          'type': 'cafe',
          'role': 'OWNER',
        },
      ],
    });

    expect(user.fullName, 'Tavrix Demo Owner');
    expect(user.email, 'owner@tavrix.local');
    expect(user.businesses, hasLength(1));
    expect(user.businesses.first.name, 'Tavrix Cafe');
    expect(user.businesses.first.slug, 'tavrix-cafe');
    expect(user.businesses.first.type, 'cafe');
    expect(user.businesses.first.role, 'OWNER');
  });
}

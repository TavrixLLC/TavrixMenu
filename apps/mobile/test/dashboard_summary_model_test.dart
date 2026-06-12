import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/dashboard/data/models/dashboard_summary_model.dart';

void main() {
  test('parses Sprint 4 dashboard summary response', () {
    final model = DashboardSummaryModel.fromJson({
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
      'currentUser': {
        'role': 'OWNER',
        'permissions': {
          'canManageBusiness': true,
          'canManageMenu': true,
          'canManageMembers': true,
          'canViewMembers': true,
          'canViewPublicLink': true,
        },
      },
      'counts': {
        'activeCategories': 2,
        'inactiveCategories': 1,
        'activeItems': 3,
        'inactiveItems': 1,
        'availableItems': 3,
        'unavailableItems': 1,
        'activeMembers': 1,
      },
      'publicMenu': {
        'path': '/m/tavrix-cafe',
        'url': 'http://localhost:3001/m/tavrix-cafe',
        'qrPayload': 'http://localhost:3001/m/tavrix-cafe',
      },
      'onboardingHints': {
        'hasCategories': true,
        'hasItems': true,
        'hasPublicMenuReady': true,
        'recommendedNextStep': 'SHARE_PUBLIC_MENU',
      },
    });

    expect(model.business.id, 'bus_123');
    expect(model.business.publicMenuUrl, 'http://localhost:3001/m/tavrix-cafe');
    expect(model.currentUser.role, 'OWNER');
    expect(model.permissions.canManageMenu, isTrue);
    expect(model.counts.activeCategories, 2);
    expect(model.counts.unavailableItems, 1);
    expect(model.publicMenu.qrPayload, 'http://localhost:3001/m/tavrix-cafe');
    expect(model.onboardingHints.recommendedNextStep, 'SHARE_PUBLIC_MENU');
  });
}

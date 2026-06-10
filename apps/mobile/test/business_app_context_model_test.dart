import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/business_setup/data/models/business_app_context_model.dart';
import 'package:tavrix_menu_mobile/features/business_setup/data/models/public_link_model.dart';

void main() {
  test('parses business app-context response', () {
    final context = BusinessAppContextModel.fromResponse(const {
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
      'currentMembership': {'id': 'mem_123', 'role': 'OWNER', 'isActive': true},
      'permissions': {
        'canManageBusiness': true,
        'canManageMenu': true,
        'canManageMembers': true,
        'canViewMembers': true,
        'canViewPublicLink': true,
      },
      'publicMenu': {
        'slug': 'tavrix-cafe',
        'path': '/m/tavrix-cafe',
        'url': 'http://localhost:3001/m/tavrix-cafe',
        'qrPayload': 'http://localhost:3001/m/tavrix-cafe',
      },
    });

    expect(context.business.name, 'Tavrix Cafe');
    expect(context.business.role, 'OWNER');
    expect(context.currentMembership.role, 'OWNER');
    expect(context.permissions.canManageMenu, isTrue);
    expect(context.publicMenu.publicMenuPath, '/m/tavrix-cafe');
    expect(context.publicMenu.qrPayload, 'http://localhost:3001/m/tavrix-cafe');
  });

  test('parses public-link response', () {
    final publicLink = PublicLinkModel.fromResponse(const {
      'businessId': 'bus_123',
      'slug': 'tavrix-cafe',
      'publicMenuPath': '/m/tavrix-cafe',
      'publicMenuUrl': 'http://localhost:3001/m/tavrix-cafe',
      'qrPayload': 'http://localhost:3001/m/tavrix-cafe',
    });

    expect(publicLink.businessId, 'bus_123');
    expect(publicLink.slug, 'tavrix-cafe');
    expect(publicLink.publicMenuUrl, 'http://localhost:3001/m/tavrix-cafe');
    expect(publicLink.qrPayload, publicLink.publicMenuUrl);
  });
}

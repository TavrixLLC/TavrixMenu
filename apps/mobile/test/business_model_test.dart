import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/business_setup/data/models/business_model.dart';

void main() {
  test('parses create business response appContext when present', () {
    final model = BusinessModel.fromJson({
      'business': {
        'id': 'bus_123',
        'name': 'Tavrix Cafe',
        'slug': 'tavrix-cafe',
        'type': 'cafe',
        'currency': 'IQD',
        'language': 'ar',
        'city': 'Baghdad',
        'status': 'ACTIVE',
      },
      'currentMembership': {'id': 'mem_123', 'role': 'OWNER', 'isActive': true},
      'appContext': {
        'business': {
          'id': 'bus_123',
          'name': 'Tavrix Cafe',
          'slug': 'tavrix-cafe',
          'type': 'cafe',
          'city': 'Baghdad',
          'currency': 'IQD',
          'language': 'ar',
        },
        'publicMenu': {
          'slug': 'tavrix-cafe',
          'path': '/m/tavrix-cafe',
          'url': 'http://localhost:3001/m/tavrix-cafe',
          'qrPayload': 'http://localhost:3001/m/tavrix-cafe',
        },
      },
    });

    expect(model.id, 'bus_123');
    expect(model.slug, 'tavrix-cafe');
    expect(model.city, 'Baghdad');
    expect(model.currency, 'IQD');
    expect(model.language, 'ar');
    expect(model.publicMenuUrl, 'http://localhost:3001/m/tavrix-cafe');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/menu_category.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_state.dart';

void main() {
  test(
    'uses permissions to disable menu management and filter archive view',
    () {
      const state = MenuState(
        status: MenuStatus.success,
        permissions: BusinessPermissions(canManageMenu: false),
        showArchived: true,
        categories: [
          MenuCategory(
            id: 'cat_active',
            businessId: 'bus_123',
            name: 'Active',
            sortOrder: 0,
          ),
          MenuCategory(
            id: 'cat_archived',
            businessId: 'bus_123',
            name: 'Archived',
            sortOrder: 1,
            isActive: false,
          ),
        ],
        items: [
          MenuItem(
            id: 'item_active',
            businessId: 'bus_123',
            categoryId: 'cat_active',
            name: 'Coffee',
            description: '',
            priceCents: 3000,
            isAvailable: true,
            sortOrder: 0,
          ),
          MenuItem(
            id: 'item_hidden',
            businessId: 'bus_123',
            categoryId: 'cat_active',
            name: 'Hidden coffee',
            description: '',
            priceCents: 3000,
            isAvailable: false,
            sortOrder: 1,
          ),
        ],
      );

      expect(state.canManageMenu, isFalse);
      expect(state.visibleCategories.single.id, 'cat_archived');
      expect(state.visibleItems.single.id, 'item_hidden');
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/menu_category.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/menu_item.dart';
import 'package:tavrix_menu_mobile/features/menu/presentation/bloc/menu_state.dart';

void main() {
  test('missing permissions fail closed', () {
    const state = MenuState(status: MenuStatus.success);

    expect(state.canManageMenu, isFalse);
  });

  test('selected category exposes available and unavailable owner records', () {
    const state = MenuState(
      status: MenuStatus.success,
      business: _business,
      permissions: BusinessPermissions(canManageMenu: true),
      selectedCategoryId: 'cat_active',
      categories: [
        MenuCategory(
          id: 'cat_active',
          businessId: 'bus_123',
          name: 'القهوة',
          sortOrder: 0,
        ),
        MenuCategory(
          id: 'cat_other_business',
          businessId: 'bus_other',
          name: 'من مطعم آخر',
          sortOrder: 1,
        ),
      ],
      items: [
        MenuItem(
          id: 'item_active',
          businessId: 'bus_123',
          categoryId: 'cat_active',
          name: 'قهوة',
          description: '',
          priceCents: 3000,
          isAvailable: true,
          sortOrder: 0,
        ),
        MenuItem(
          id: 'item_unavailable',
          businessId: 'bus_123',
          categoryId: 'cat_active',
          name: 'قهوة غير متوفرة',
          description: '',
          priceCents: 3500,
          isAvailable: false,
          sortOrder: 1,
        ),
        MenuItem(
          id: 'item_other_business',
          businessId: 'bus_other',
          categoryId: 'cat_active',
          name: 'لا يظهر',
          description: '',
          priceCents: 1,
          isAvailable: true,
          sortOrder: 2,
        ),
      ],
    );

    expect(state.selectedCategoryItems.map((item) => item.id), [
      'item_active',
      'item_unavailable',
    ]);
  });

  test('search empty is derived without changing the real product list', () {
    const state = MenuState(
      status: MenuStatus.success,
      business: _business,
      permissions: BusinessPermissions.owner(),
      selectedCategoryId: 'cat_active',
      searchQuery: 'شاي',
      categories: [
        MenuCategory(
          id: 'cat_active',
          businessId: 'bus_123',
          name: 'القهوة',
          sortOrder: 0,
        ),
      ],
      items: [
        MenuItem(
          id: 'item_active',
          businessId: 'bus_123',
          categoryId: 'cat_active',
          name: 'قهوة',
          description: '',
          priceCents: 3000,
          isAvailable: true,
          sortOrder: 0,
        ),
      ],
    );

    expect(state.selectedCategoryItems, hasLength(1));
    expect(state.filteredSelectedCategoryItems, isEmpty);
  });
}

const _business = Business(
  id: 'bus_123',
  name: 'QA Restaurant',
  slug: 'qa-restaurant',
  publicMenuUrl: 'https://menu.example.test/m/qa-restaurant',
  currency: 'IQD',
  permissions: BusinessPermissions.owner(),
);

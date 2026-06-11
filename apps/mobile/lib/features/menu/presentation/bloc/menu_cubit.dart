import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../domain/usecases/create_menu_category.dart';
import '../../domain/usecases/create_menu_item.dart';
import '../../domain/usecases/get_menu_categories.dart';
import '../../domain/usecases/get_menu_items.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit({
    required GetMyBusiness getMyBusiness,
    required GetMenuCategories getMenuCategories,
    required GetMenuItems getMenuItems,
    required CreateMenuCategory createMenuCategory,
    required CreateMenuItem createMenuItem,
  }) : _getMyBusiness = getMyBusiness,
       _getMenuCategories = getMenuCategories,
       _getMenuItems = getMenuItems,
       _createMenuCategory = createMenuCategory,
       _createMenuItem = createMenuItem,
       super(const MenuState.initial());

  final GetMyBusiness _getMyBusiness;
  final GetMenuCategories _getMenuCategories;
  final GetMenuItems _getMenuItems;
  final CreateMenuCategory _createMenuCategory;
  final CreateMenuItem _createMenuItem;

  Future<void> load() async {
    emit(state.copyWith(status: MenuStatus.loading, clearError: true));

    final businessResult = await _getMyBusiness();
    await businessResult.fold(
      (failure) async => emit(
        MenuState(
          status: MenuStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) async {
        final categoriesResult = await _getMenuCategories(business.id);
        await categoriesResult.fold(
          (failure) async => emit(
            MenuState(
              status: MenuStatus.failure,
              business: business,
              errorMessage: failureMessage(failure),
            ),
          ),
          (categories) async {
            final itemsResult = await _getMenuItems(business.id);
            itemsResult.fold(
              (failure) => emit(
                MenuState(
                  status: MenuStatus.failure,
                  business: business,
                  categories: categories,
                  errorMessage: failureMessage(failure),
                ),
              ),
              (items) => emit(
                MenuState(
                  status: MenuStatus.success,
                  business: business,
                  categories: categories,
                  items: items,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addCategory(String name) async {
    final business = state.business;
    final cleanName = name.trim();
    if (business == null || cleanName.isEmpty) {
      return;
    }

    final result = await _createMenuCategory(
      businessId: business.id,
      name: cleanName,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MenuStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (category) => emit(
        state.copyWith(
          status: MenuStatus.success,
          categories: [...state.categories, category],
        ),
      ),
    );
  }

  Future<void> addItem({
    required String name,
    required String description,
    required int priceCents,
  }) async {
    final business = state.business;
    if (business == null || state.categories.isEmpty || name.trim().isEmpty) {
      return;
    }

    final result = await _createMenuItem(
      businessId: business.id,
      categoryId: state.categories.first.id,
      name: name.trim(),
      description: description.trim(),
      priceCents: priceCents,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MenuStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (item) => emit(
        state.copyWith(
          status: MenuStatus.success,
          items: [...state.items, item],
        ),
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/usecases/create_menu_category.dart';
import '../../domain/usecases/create_menu_item.dart';
import '../../domain/usecases/delete_menu_item.dart';
import '../../domain/usecases/get_menu_categories.dart';
import '../../domain/usecases/get_menu_items.dart';
import '../../domain/usecases/update_menu_item.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit({
    required GetMyBusinesses getMyBusinesses,
    required GetMenuCategories getMenuCategories,
    required GetMenuItems getMenuItems,
    required CreateMenuCategory createMenuCategory,
    required CreateMenuItem createMenuItem,
    required UpdateMenuItem updateMenuItem,
    required DeleteMenuItem deleteMenuItem,
  }) : _getMyBusinesses = getMyBusinesses,
       _getMenuCategories = getMenuCategories,
       _getMenuItems = getMenuItems,
       _createMenuCategory = createMenuCategory,
       _createMenuItem = createMenuItem,
       _updateMenuItem = updateMenuItem,
       _deleteMenuItem = deleteMenuItem,
       super(const MenuState.initial());

  final GetMyBusinesses _getMyBusinesses;
  final GetMenuCategories _getMenuCategories;
  final GetMenuItems _getMenuItems;
  final CreateMenuCategory _createMenuCategory;
  final CreateMenuItem _createMenuItem;
  final UpdateMenuItem _updateMenuItem;
  final DeleteMenuItem _deleteMenuItem;

  Future<void> load() async {
    emit(state.copyWith(status: MenuStatus.loading, clearError: true));

    final businessesResult = await _getMyBusinesses();
    await businessesResult.fold(
      (failure) async => emit(
        MenuState(
          status: MenuStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (businesses) async {
        if (businesses.isEmpty) {
          emit(const MenuState(status: MenuStatus.success));
          return;
        }

        final business = businesses.first;
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
          status: state.business == null ? MenuStatus.failure : state.status,
          errorMessage: failureMessage(failure),
        ),
      ),
      (category) => emit(
        state.copyWith(
          status: MenuStatus.success,
          categories: [...state.categories, category],
          clearError: true,
        ),
      ),
    );
  }

  Future<void> addItem({
    String? categoryId,
    required String name,
    required String description,
    required String price,
  }) async {
    final business = state.business;
    final cleanPrice = price.trim();
    if (business == null ||
        state.categories.isEmpty ||
        name.trim().isEmpty ||
        cleanPrice.isEmpty) {
      return;
    }

    final cleanCategoryId = categoryId ?? state.categories.first.id;
    final result = await _createMenuItem(
      businessId: business.id,
      categoryId: cleanCategoryId,
      name: name.trim(),
      description: description.trim(),
      price: cleanPrice,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MenuStatus.success,
          errorMessage: failureMessage(failure),
        ),
      ),
      (item) => emit(
        state.copyWith(
          status: MenuStatus.success,
          items: [...state.items, item],
          clearError: true,
        ),
      ),
    );
  }

  Future<void> updateItem({
    required MenuItem item,
    required String name,
    required String description,
    required String price,
    required bool isAvailable,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      emit(
        state.copyWith(
          status: MenuStatus.success,
          errorMessage: 'Item name is required.',
        ),
      );
      return;
    }

    final result = await _updateMenuItem(
      id: item.id,
      name: cleanName,
      description: description.trim(),
      price: price.trim(),
      isAvailable: isAvailable,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MenuStatus.success,
          errorMessage: failureMessage(failure),
        ),
      ),
      (_) {
        final updated = MenuItem(
          id: item.id,
          businessId: item.businessId,
          categoryId: item.categoryId,
          name: cleanName,
          description: description.trim(),
          price: price.trim(),
          isAvailable: isAvailable,
        );
        emit(
          state.copyWith(
            status: MenuStatus.success,
            items: [
              for (final existing in state.items)
                if (existing.id == item.id) updated else existing,
            ],
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> deleteItem(String id) async {
    final result = await _deleteMenuItem(id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MenuStatus.success,
          errorMessage: failureMessage(failure),
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: MenuStatus.success,
          items: state.items.where((item) => item.id != id).toList(),
          clearError: true,
        ),
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/usecases/create_menu_category.dart';
import '../../domain/usecases/create_menu_item.dart';
import '../../domain/usecases/delete_menu_category.dart';
import '../../domain/usecases/delete_menu_item.dart';
import '../../domain/usecases/get_menu_categories.dart';
import '../../domain/usecases/get_menu_items.dart';
import '../../domain/usecases/update_menu_category.dart';
import '../../domain/usecases/update_menu_item.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit({
    required GetMyBusiness getMyBusiness,
    required GetMenuCategories getMenuCategories,
    required GetMenuItems getMenuItems,
    required CreateMenuCategory createMenuCategory,
    required CreateMenuItem createMenuItem,
    required UpdateMenuCategory updateMenuCategory,
    required DeleteMenuCategory deleteMenuCategory,
    required UpdateMenuItem updateMenuItem,
    required DeleteMenuItem deleteMenuItem,
  }) : _getMyBusiness = getMyBusiness,
       _getMenuCategories = getMenuCategories,
       _getMenuItems = getMenuItems,
       _createMenuCategory = createMenuCategory,
       _createMenuItem = createMenuItem,
       _updateMenuCategory = updateMenuCategory,
       _deleteMenuCategory = deleteMenuCategory,
       _updateMenuItem = updateMenuItem,
       _deleteMenuItem = deleteMenuItem,
       super(const MenuState.initial());

  final GetMyBusiness _getMyBusiness;
  final GetMenuCategories _getMenuCategories;
  final GetMenuItems _getMenuItems;
  final CreateMenuCategory _createMenuCategory;
  final CreateMenuItem _createMenuItem;
  final UpdateMenuCategory _updateMenuCategory;
  final DeleteMenuCategory _deleteMenuCategory;
  final UpdateMenuItem _updateMenuItem;
  final DeleteMenuItem _deleteMenuItem;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: MenuStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final businessResult = await _getMyBusiness();
    await businessResult.fold(
      (failure) async => emit(
        MenuState(
          status: MenuStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) async {
        if (business == null) {
          emit(const MenuState(status: MenuStatus.success));
          return;
        }

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
                  categories: _sortCategories(categories),
                  errorMessage: failureMessage(failure),
                ),
              ),
              (items) => emit(
                MenuState(
                  status: MenuStatus.success,
                  business: business,
                  categories: _sortCategories(categories),
                  items: _sortItems(items),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addCategory({
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final business = state.business;
    final cleanNameAr = nameAr.trim();
    if (business == null) {
      _emitOperationError(
        'Business setup is required before editing the menu.',
      );
      return;
    }
    if (cleanNameAr.isEmpty) {
      _emitOperationError('Arabic category name is required.');
      return;
    }

    _emitSubmitting();
    final result = await _createMenuCategory(
      businessId: business.id,
      nameAr: cleanNameAr,
      nameEn: _cleanOptional(nameEn),
      sortOrder: sortOrder,
      isActive: isActive,
    );
    result.fold(
      (failure) => _emitOperationError(failureMessage(failure)),
      (category) => emit(
        state.copyWith(
          status: MenuStatus.success,
          categories: _sortCategories([...state.categories, category]),
          isSubmitting: false,
          successMessage: 'Category saved.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> updateCategory({
    required String id,
    required String nameAr,
    String? nameEn,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final cleanNameAr = nameAr.trim();
    if (cleanNameAr.isEmpty) {
      _emitOperationError('Arabic category name is required.');
      return;
    }

    _emitSubmitting();
    final result = await _updateMenuCategory(
      id: id,
      nameAr: cleanNameAr,
      nameEn: _cleanOptional(nameEn),
      sortOrder: sortOrder,
      isActive: isActive,
    );
    result.fold((failure) => _emitOperationError(failureMessage(failure)), (
      category,
    ) {
      final categories = state.categories
          .map((existing) => existing.id == id ? category : existing)
          .toList();
      emit(
        state.copyWith(
          status: MenuStatus.success,
          categories: _sortCategories(categories),
          isSubmitting: false,
          successMessage: 'Category updated.',
          clearError: true,
        ),
      );
    });
  }

  Future<void> deleteCategory(String id) async {
    _emitSubmitting();
    final result = await _deleteMenuCategory(id);
    result.fold(
      (failure) => _emitOperationError(failureMessage(failure)),
      (_) => emit(
        state.copyWith(
          status: MenuStatus.success,
          categories: state.categories
              .where((category) => category.id != id)
              .toList(),
          items: state.items.where((item) => item.categoryId != id).toList(),
          isSubmitting: false,
          successMessage: 'Category deleted.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> addItem({
    required String categoryId,
    required String nameAr,
    required String price,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    bool isAvailable = true,
    int sortOrder = 0,
  }) async {
    final business = state.business;
    final validationMessage = _validateItem(
      businessId: business?.id,
      categoryId: categoryId,
      nameAr: nameAr,
      price: price,
    );
    if (validationMessage != null) {
      _emitOperationError(validationMessage);
      return;
    }

    _emitSubmitting();
    final result = await _createMenuItem(
      businessId: business!.id,
      categoryId: categoryId,
      nameAr: nameAr.trim(),
      nameEn: _cleanOptional(nameEn),
      descriptionAr: _cleanOptional(descriptionAr),
      descriptionEn: _cleanOptional(descriptionEn),
      price: price.trim(),
      imageUrl: _cleanOptional(imageUrl),
      isAvailable: isAvailable,
      sortOrder: sortOrder,
    );
    result.fold(
      (failure) => _emitOperationError(failureMessage(failure)),
      (item) => emit(
        state.copyWith(
          status: MenuStatus.success,
          items: _sortItems([...state.items, item]),
          isSubmitting: false,
          successMessage: 'Menu item saved.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> updateItem({
    required String id,
    required String categoryId,
    required String nameAr,
    required String price,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    bool isAvailable = true,
    int sortOrder = 0,
  }) async {
    final validationMessage = _validateItem(
      businessId: state.business?.id,
      categoryId: categoryId,
      nameAr: nameAr,
      price: price,
    );
    if (validationMessage != null) {
      _emitOperationError(validationMessage);
      return;
    }

    _emitSubmitting();
    final result = await _updateMenuItem(
      id: id,
      categoryId: categoryId,
      nameAr: nameAr.trim(),
      nameEn: _cleanOptional(nameEn),
      descriptionAr: _cleanOptional(descriptionAr),
      descriptionEn: _cleanOptional(descriptionEn),
      price: price.trim(),
      imageUrl: _cleanOptional(imageUrl),
      isAvailable: isAvailable,
      sortOrder: sortOrder,
    );
    result.fold((failure) => _emitOperationError(failureMessage(failure)), (
      item,
    ) {
      final items = state.items
          .map((existing) => existing.id == id ? item : existing)
          .toList();
      emit(
        state.copyWith(
          status: MenuStatus.success,
          items: _sortItems(items),
          isSubmitting: false,
          successMessage: 'Menu item updated.',
          clearError: true,
        ),
      );
    });
  }

  Future<void> deleteItem(String id) async {
    _emitSubmitting();
    final result = await _deleteMenuItem(id);
    result.fold(
      (failure) => _emitOperationError(failureMessage(failure)),
      (_) => emit(
        state.copyWith(
          status: MenuStatus.success,
          items: state.items.where((item) => item.id != id).toList(),
          isSubmitting: false,
          successMessage: 'Menu item deleted.',
          clearError: true,
        ),
      ),
    );
  }

  void _emitSubmitting() {
    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );
  }

  void _emitOperationError(String message) {
    emit(
      state.copyWith(
        status: state.status == MenuStatus.initial
            ? MenuStatus.success
            : state.status,
        errorMessage: message,
        isSubmitting: false,
        clearSuccess: true,
      ),
    );
  }

  String? _validateItem({
    required String? businessId,
    required String categoryId,
    required String nameAr,
    required String price,
  }) {
    if (businessId == null) {
      return 'Business setup is required before editing the menu.';
    }
    if (categoryId.trim().isEmpty) {
      return 'Choose a category for this menu item.';
    }
    if (nameAr.trim().isEmpty) {
      return 'Arabic item name is required.';
    }
    if (price.trim().isEmpty) {
      return 'Price is required.';
    }
    return null;
  }

  String? _cleanOptional(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  static List<MenuCategory> _sortCategories(List<MenuCategory> categories) {
    return [...categories]..sort((a, b) {
      final order = a.sortOrder.compareTo(b.sortOrder);
      return order == 0 ? a.displayName.compareTo(b.displayName) : order;
    });
  }

  static List<MenuItem> _sortItems(List<MenuItem> items) {
    return [...items]..sort((a, b) {
      final order = a.sortOrder.compareTo(b.sortOrder);
      return order == 0 ? a.displayName.compareTo(b.displayName) : order;
    });
  }
}

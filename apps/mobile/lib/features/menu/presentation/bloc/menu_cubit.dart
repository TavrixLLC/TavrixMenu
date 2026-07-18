import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../../dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/reorder_menu_record.dart';
import '../../domain/usecases/create_menu_category.dart';
import '../../domain/usecases/create_menu_item.dart';
import '../../domain/usecases/delete_menu_category.dart';
import '../../domain/usecases/delete_menu_item.dart';
import '../../domain/usecases/get_menu_categories.dart';
import '../../domain/usecases/get_menu_items.dart';
import '../../domain/usecases/reorder_menu_categories.dart';
import '../../domain/usecases/reorder_menu_items.dart';
import '../../domain/usecases/restore_menu_category.dart';
import '../../domain/usecases/restore_menu_item.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit({
    required GetMyBusiness getMyBusiness,
    required GetMenuCategories getMenuCategories,
    required GetMenuItems getMenuItems,
    required CreateMenuCategory createMenuCategory,
    required CreateMenuItem createMenuItem,
    required DeleteMenuCategory deleteMenuCategory,
    required RestoreMenuCategory restoreMenuCategory,
    required DeleteMenuItem deleteMenuItem,
    required RestoreMenuItem restoreMenuItem,
    required ReorderMenuCategories reorderMenuCategories,
    required ReorderMenuItems reorderMenuItems,
    required GetDashboardSummary getDashboardSummary,
  }) : _getMyBusiness = getMyBusiness,
       _getMenuCategories = getMenuCategories,
       _getMenuItems = getMenuItems,
       _createMenuCategory = createMenuCategory,
       _createMenuItem = createMenuItem,
       _deleteMenuCategory = deleteMenuCategory,
       _restoreMenuCategory = restoreMenuCategory,
       _deleteMenuItem = deleteMenuItem,
       _restoreMenuItem = restoreMenuItem,
       _reorderMenuCategories = reorderMenuCategories,
       _reorderMenuItems = reorderMenuItems,
       _getDashboardSummary = getDashboardSummary,
       super(const MenuState.initial());

  final GetMyBusiness _getMyBusiness;
  final GetMenuCategories _getMenuCategories;
  final GetMenuItems _getMenuItems;
  final CreateMenuCategory _createMenuCategory;
  final CreateMenuItem _createMenuItem;
  final DeleteMenuCategory _deleteMenuCategory;
  final RestoreMenuCategory _restoreMenuCategory;
  final DeleteMenuItem _deleteMenuItem;
  final RestoreMenuItem _restoreMenuItem;
  final ReorderMenuCategories _reorderMenuCategories;
  final ReorderMenuItems _reorderMenuItems;
  final GetDashboardSummary _getDashboardSummary;
  int _sessionGeneration = 0;

  void reset() {
    _sessionGeneration++;
    emit(const MenuState.initial());
  }

  Future<void> load({bool? showArchived}) async {
    final generation = _sessionGeneration;
    final archived = showArchived ?? state.showArchived;
    emit(
      state.copyWith(
        status: MenuStatus.loading,
        showArchived: archived,
        clearError: true,
        clearSummaryError: true,
      ),
    );

    final businessResult = await _getMyBusiness();
    if (!_isCurrent(generation)) {
      return;
    }
    await businessResult.fold(
      (failure) async => _emitIfCurrent(
        generation,
        MenuState(
          status: MenuStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) async {
        var resolvedBusiness = business;
        var permissions = business.permissions;
        String? summaryErrorMessage;

        if (business.id.trim().isNotEmpty) {
          final summaryResult = await _getDashboardSummary(business.id);
          if (!_isCurrent(generation)) {
            return;
          }
          summaryResult.fold(
            (failure) => summaryErrorMessage = failureMessage(failure),
            (summary) {
              resolvedBusiness = summary.business;
              permissions = summary.currentUser.permissionsAvailable
                  ? summary.permissions
                  : summary.business.permissions ?? permissions;
            },
          );
        }

        final categoriesResult = await _getMenuCategories(
          resolvedBusiness.id,
          includeInactive: archived,
        );
        if (!_isCurrent(generation)) {
          return;
        }
        await categoriesResult.fold(
          (failure) async => _emitIfCurrent(
            generation,
            MenuState(
              status: MenuStatus.failure,
              business: resolvedBusiness,
              permissions: permissions,
              showArchived: archived,
              summaryErrorMessage: summaryErrorMessage,
              errorMessage: failureMessage(failure),
            ),
          ),
          (categories) async {
            final itemsResult = await _getMenuItems(
              resolvedBusiness.id,
              includeInactive: archived,
            );
            if (!_isCurrent(generation)) {
              return;
            }
            itemsResult.fold(
              (failure) => _emitIfCurrent(
                generation,
                MenuState(
                  status: MenuStatus.failure,
                  business: resolvedBusiness,
                  categories: categories,
                  permissions: permissions,
                  showArchived: archived,
                  summaryErrorMessage: summaryErrorMessage,
                  errorMessage: failureMessage(failure),
                ),
              ),
              (items) => _emitIfCurrent(
                generation,
                MenuState(
                  status: MenuStatus.success,
                  business: resolvedBusiness,
                  categories: categories,
                  items: items,
                  permissions: permissions,
                  showArchived: archived,
                  summaryErrorMessage: summaryErrorMessage,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> setArchivedView(bool showArchived) {
    return load(showArchived: showArchived);
  }

  Future<void> addCategory(String name) async {
    final business = state.business;
    final cleanName = name.trim();
    if (business == null || cleanName.isEmpty) {
      return;
    }
    if (!_ensureCanManageMenu()) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    final result = await _createMenuCategory(
      businessId: businessId,
      name: cleanName,
    );
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (_) async => load(showArchived: state.showArchived),
    );
  }

  Future<void> addItem({
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
  }) async {
    final business = state.business;
    final cleanCategoryId = categoryId.trim();
    final category = state.categories
        .where(
          (category) => category.isActive && category.id == cleanCategoryId,
        )
        .firstOrNull;
    if (business == null || category == null || name.trim().isEmpty) {
      if (category == null) {
        _emitOperationFailure('Choose an active category for this item.');
      }
      return;
    }
    if (!_ensureCanManageMenu()) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    final result = await _createMenuItem(
      businessId: businessId,
      categoryId: category.id,
      name: name.trim(),
      description: description.trim(),
      priceCents: priceCents,
    );
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (_) async => load(showArchived: state.showArchived),
    );
  }

  Future<void> archiveCategory(String id) async {
    final business = state.business;
    if (business == null) {
      return;
    }
    if (!_ensureCanManageMenu()) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    final result = await _deleteMenuCategory(id);
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (_) async => load(showArchived: state.showArchived),
    );
  }

  Future<void> restoreCategory(String id) async {
    final business = state.business;
    if (business == null) {
      return;
    }
    if (!_ensureCanManageMenu()) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    final result = await _restoreMenuCategory(id);
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (_) async => load(showArchived: state.showArchived),
    );
  }

  Future<void> archiveItem(String id) async {
    final business = state.business;
    if (business == null) {
      return;
    }
    if (!_ensureCanManageMenu()) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    final result = await _deleteMenuItem(id);
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (_) async => load(showArchived: state.showArchived),
    );
  }

  Future<void> restoreItem(String id) async {
    final business = state.business;
    if (business == null) {
      return;
    }
    if (!_ensureCanManageMenu()) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    final result = await _restoreMenuItem(id);
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (_) async => load(showArchived: state.showArchived),
    );
  }

  Future<void> reorderCategories(List<MenuCategory> categories) async {
    final business = state.business;
    if (business == null || categories.length < 2 || !_ensureCanManageMenu()) {
      return;
    }

    final orders = [
      for (var index = 0; index < categories.length; index++)
        ReorderMenuRecord(id: categories[index].id, sortOrder: index),
    ];
    final generation = _sessionGeneration;
    final businessId = business.id;
    final result = await _reorderMenuCategories(
      businessId: businessId,
      orders: orders,
    );
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (_) async => load(showArchived: state.showArchived),
    );
  }

  Future<void> reorderItems(List<MenuItem> items) async {
    final business = state.business;
    if (business == null || items.length < 2 || !_ensureCanManageMenu()) {
      return;
    }

    final orders = [
      for (var index = 0; index < items.length; index++)
        ReorderMenuRecord(id: items[index].id, sortOrder: index),
    ];
    final generation = _sessionGeneration;
    final businessId = business.id;
    final result = await _reorderMenuItems(
      businessId: businessId,
      orders: orders,
    );
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (_) async => load(showArchived: state.showArchived),
    );
  }

  bool _ensureCanManageMenu() {
    if (state.canManageMenu) {
      return true;
    }

    emit(
      state.copyWith(
        status: MenuStatus.success,
        errorMessage:
            'You do not have permission to manage this menu. Ask the owner for access.',
      ),
    );
    return false;
  }

  void _emitOperationFailure(String message) {
    emit(state.copyWith(status: MenuStatus.success, errorMessage: message));
  }

  bool _isCurrent(int generation) {
    return !isClosed && generation == _sessionGeneration;
  }

  bool _isCurrentBusiness(int generation, String businessId) {
    return _isCurrent(generation) && state.business?.id == businessId;
  }

  void _emitIfCurrent(int generation, MenuState nextState) {
    if (_isCurrent(generation)) {
      emit(nextState);
    }
  }
}

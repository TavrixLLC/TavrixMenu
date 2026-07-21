import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> load({String? preferredCategoryId}) async {
    final generation = _sessionGeneration;
    final previousBusinessId = state.business?.id;
    final previousCategoryId = state.selectedCategoryId;
    emit(
      state.copyWith(
        status: MenuStatus.loading,
        clearError: true,
        clearSummaryError: true,
      ),
    );

    final businessResult = await _getMyBusiness();
    if (!_isCurrent(generation)) return;
    await businessResult.fold(
      (_) async => _emitIfCurrent(
        generation,
        const MenuState(
          status: MenuStatus.failure,
          errorMessage: 'تعذّر تحديد مساحة العمل. حاول مرة ثانية.',
        ),
      ),
      (business) async {
        var resolvedBusiness = business;
        var permissions = business.permissions;
        var publicMenuReady = false;
        String? summaryErrorMessage;

        if (business.id.trim().isEmpty) {
          _emitIfCurrent(
            generation,
            const MenuState(
              status: MenuStatus.failure,
              errorMessage: 'مساحة العمل غير جاهزة لإدارة المنيو.',
            ),
          );
          return;
        }

        final summaryResult = await _getDashboardSummary(business.id);
        if (!_isCurrent(generation)) return;
        summaryResult.fold(
          (_) => summaryErrorMessage = 'تعذّر التحقق من جاهزية منيو الزبائن.',
          (summary) {
            if (summary.business.id != business.id) return;
            resolvedBusiness = summary.business;
            permissions = summary.currentUser.permissionsAvailable
                ? summary.permissions
                : permissions;
            publicMenuReady = summary.onboardingHints.hasPublicMenuReady;
          },
        );

        final categoriesResult = await _getMenuCategories(resolvedBusiness.id);
        if (!_isCurrent(generation)) return;
        await categoriesResult.fold(
          (_) async => _emitIfCurrent(
            generation,
            MenuState(
              status: MenuStatus.failure,
              business: resolvedBusiness,
              permissions: permissions,
              summaryErrorMessage: summaryErrorMessage,
              errorMessage: 'تعذّر تحميل أقسام المنيو. حاول مرة ثانية.',
            ),
          ),
          (categories) async {
            final scopedCategories = categories
                .where((category) => category.businessId == resolvedBusiness.id)
                .toList();
            final itemsResult = await _getMenuItems(
              resolvedBusiness.id,
              includeInactive: true,
            );
            if (!_isCurrent(generation)) return;
            itemsResult.fold(
              (_) => _emitIfCurrent(
                generation,
                MenuState(
                  status: MenuStatus.failure,
                  business: resolvedBusiness,
                  categories: scopedCategories,
                  permissions: permissions,
                  summaryErrorMessage: summaryErrorMessage,
                  errorMessage: 'تعذّر تحميل منتجات المنيو. حاول مرة ثانية.',
                ),
              ),
              (items) {
                final scopedItems = items
                    .where((item) => item.businessId == resolvedBusiness.id)
                    .toList();
                final selection = _resolveSelection(
                  categories: scopedCategories,
                  preferredCategoryId: preferredCategoryId,
                  previousCategoryId: previousBusinessId == resolvedBusiness.id
                      ? previousCategoryId
                      : null,
                );
                _emitIfCurrent(
                  generation,
                  MenuState(
                    status: MenuStatus.success,
                    business: resolvedBusiness,
                    categories: scopedCategories,
                    items: scopedItems,
                    permissions: permissions,
                    selectedCategoryId: selection,
                    publicMenuReady: publicMenuReady,
                    summaryErrorMessage: summaryErrorMessage,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void selectCategory(String categoryId) {
    final category = _activeCategory(categoryId);
    if (category == null || state.status != MenuStatus.success) return;
    emit(
      state.copyWith(
        selectedCategoryId: category.id,
        searchQuery: '',
        clearError: true,
      ),
    );
  }

  void setSearchQuery(String value) {
    if (state.status != MenuStatus.success) return;
    emit(state.copyWith(searchQuery: value));
  }

  Future<MenuCategory?> addCategory(String name) async {
    final business = state.business;
    final cleanName = name.trim();
    if (business == null ||
        cleanName.isEmpty ||
        state.isCategoryMutationPending) {
      return null;
    }
    if (!_ensureCanManageMenu()) return null;

    final generation = _sessionGeneration;
    final businessId = business.id;
    emit(
      state.copyWith(
        status: MenuStatus.mutating,
        isCategoryMutationPending: true,
        clearError: true,
      ),
    );
    final result = await _createMenuCategory(
      businessId: businessId,
      name: cleanName,
    );
    if (!_isCurrentBusiness(generation, businessId)) return null;

    return result.fold(
      (_) {
        emit(
          state.copyWith(
            status: MenuStatus.success,
            isCategoryMutationPending: false,
            errorMessage: 'تعذّرت إضافة القسم. الاسم محفوظ، حاول مرة ثانية.',
          ),
        );
        return null;
      },
      (created) {
        if (created.businessId != businessId ||
            created.id.trim().isEmpty ||
            !created.isActive) {
          emit(
            state.copyWith(
              status: MenuStatus.success,
              isCategoryMutationPending: false,
              errorMessage: 'لم نتمكن من تأكيد القسم الجديد.',
            ),
          );
          return null;
        }
        final merged = _replaceCategory(state.categories, created);
        emit(
          state.copyWith(
            status: MenuStatus.success,
            categories: merged,
            selectedCategoryId: created.id,
            searchQuery: '',
            isCategoryMutationPending: false,
            clearError: true,
          ),
        );
        return created;
      },
    );
  }

  Future<MenuItem?> addItem({
    required String categoryId,
    required String name,
    required String description,
    required int priceCents,
    bool isAvailable = true,
  }) async {
    final business = state.business;
    final category = _activeCategory(categoryId);
    if (business == null ||
        category == null ||
        name.trim().isEmpty ||
        priceCents <= 0 ||
        state.isProductMutationPending) {
      return null;
    }
    if (!_ensureCanManageMenu()) return null;

    final generation = _sessionGeneration;
    final businessId = business.id;
    emit(
      state.copyWith(
        status: MenuStatus.mutating,
        isProductMutationPending: true,
        clearError: true,
      ),
    );
    final result = await _createMenuItem(
      businessId: businessId,
      categoryId: category.id,
      name: name.trim(),
      description: description.trim(),
      priceCents: priceCents,
      isAvailable: isAvailable,
    );
    if (!_isCurrentBusiness(generation, businessId)) return null;

    return result.fold(
      (_) {
        emit(
          state.copyWith(
            status: MenuStatus.success,
            isProductMutationPending: false,
            errorMessage:
                'تعذّرت إضافة المنتج. بياناتك محفوظة، حاول مرة ثانية.',
          ),
        );
        return null;
      },
      (created) {
        if (created.businessId != businessId ||
            created.categoryId != category.id ||
            created.id.trim().isEmpty) {
          emit(
            state.copyWith(
              status: MenuStatus.success,
              isProductMutationPending: false,
              errorMessage: 'لم نتمكن من تأكيد المنتج الجديد.',
            ),
          );
          return null;
        }
        emit(
          state.copyWith(
            status: MenuStatus.success,
            items: _replaceItem(state.items, created),
            selectedCategoryId: category.id,
            searchQuery: '',
            isProductMutationPending: false,
            clearError: true,
          ),
        );
        return created;
      },
    );
  }

  Future<void> setItemAvailability(MenuItem item, bool isAvailable) async {
    final business = state.business;
    final confirmed = state.items
        .where(
          (candidate) =>
              candidate.id == item.id &&
              candidate.businessId == business?.id &&
              _activeCategory(candidate.categoryId) != null,
        )
        .firstOrNull;
    if (business == null ||
        confirmed == null ||
        confirmed.isAvailable == isAvailable ||
        state.pendingAvailabilityItemIds.contains(item.id) ||
        !_ensureCanManageMenu()) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    emit(
      state.copyWith(
        status: MenuStatus.mutating,
        pendingAvailabilityItemIds: {
          ...state.pendingAvailabilityItemIds,
          item.id,
        },
        clearError: true,
      ),
    );
    final result = isAvailable
        ? await _restoreMenuItem(item.id)
        : await _deleteMenuItem(item.id);
    if (!_isCurrentBusiness(generation, businessId)) return;

    result.fold(
      (_) {
        emit(
          state.copyWith(
            status: MenuStatus.success,
            pendingAvailabilityItemIds: _withoutPending(item.id),
            errorMessage:
                'تعذّر تحديث توفر المنتج. بقيت الحالة المؤكدة كما هي.',
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            status: MenuStatus.success,
            items: state.items
                .map(
                  (candidate) => candidate.id == item.id
                      ? candidate.copyWith(isAvailable: isAvailable)
                      : candidate,
                )
                .toList(),
            pendingAvailabilityItemIds: _withoutPending(item.id),
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> archiveCategory(String id) async {
    if (!_validCategoryMutation(id)) return;
    await _runSimpleMutation(() => _deleteMenuCategory(id));
  }

  Future<void> restoreCategory(String id) async {
    if (state.business == null || !_ensureCanManageMenu()) return;
    await _runSimpleMutation(() => _restoreMenuCategory(id));
  }

  Future<void> archiveItem(String id) async {
    final item = state.items
        .where((candidate) => candidate.id == id)
        .firstOrNull;
    if (item != null) await setItemAvailability(item, false);
  }

  Future<void> restoreItem(String id) async {
    final item = state.items
        .where((candidate) => candidate.id == id)
        .firstOrNull;
    if (item != null) await setItemAvailability(item, true);
  }

  Future<void> reorderCategories(List<MenuCategory> categories) async {
    final business = state.business;
    if (business == null ||
        categories.length < 2 ||
        categories.any((category) => category.businessId != business.id) ||
        !_ensureCanManageMenu()) {
      return;
    }
    final orders = [
      for (var index = 0; index < categories.length; index++)
        ReorderMenuRecord(id: categories[index].id, sortOrder: index),
    ];
    await _runSimpleMutation(
      () => _reorderMenuCategories(businessId: business.id, orders: orders),
    );
  }

  Future<void> reorderItems(List<MenuItem> items) async {
    final business = state.business;
    if (business == null ||
        items.length < 2 ||
        items.any((item) => item.businessId != business.id) ||
        !_ensureCanManageMenu()) {
      return;
    }
    final orders = [
      for (var index = 0; index < items.length; index++)
        ReorderMenuRecord(id: items[index].id, sortOrder: index),
    ];
    await _runSimpleMutation(
      () => _reorderMenuItems(businessId: business.id, orders: orders),
    );
  }

  Future<void> _runSimpleMutation(Future<Object> Function() action) async {
    final generation = _sessionGeneration;
    final businessId = state.business?.id;
    if (businessId == null) return;
    await action();
    if (_isCurrentBusiness(generation, businessId)) {
      await load(preferredCategoryId: state.selectedCategoryId);
    }
  }

  bool _validCategoryMutation(String id) {
    return _activeCategory(id) != null && _ensureCanManageMenu();
  }

  MenuCategory? _activeCategory(String categoryId) {
    final businessId = state.business?.id;
    return state.categories
        .where(
          (category) =>
              category.id == categoryId.trim() &&
              category.businessId == businessId &&
              category.isActive,
        )
        .firstOrNull;
  }

  bool _ensureCanManageMenu() {
    if (state.canManageMenu) return true;
    if (state.status == MenuStatus.success) {
      emit(
        state.copyWith(errorMessage: 'صلاحيتك الحالية لا تسمح بتعديل المنيو.'),
      );
    }
    return false;
  }

  Set<String> _withoutPending(String itemId) {
    return {...state.pendingAvailabilityItemIds}..remove(itemId);
  }

  bool _isCurrent(int generation) {
    return !isClosed && generation == _sessionGeneration;
  }

  bool _isCurrentBusiness(int generation, String businessId) {
    return _isCurrent(generation) && state.business?.id == businessId;
  }

  void _emitIfCurrent(int generation, MenuState nextState) {
    if (_isCurrent(generation)) emit(nextState);
  }
}

String? _resolveSelection({
  required List<MenuCategory> categories,
  required String? preferredCategoryId,
  required String? previousCategoryId,
}) {
  final active = categories.where((category) => category.isActive).toList()
    ..sort((left, right) {
      final order = left.sortOrder.compareTo(right.sortOrder);
      return order != 0 ? order : left.id.compareTo(right.id);
    });
  if (active.isEmpty) return null;
  for (final candidate in [preferredCategoryId, previousCategoryId]) {
    if (candidate != null &&
        active.any((category) => category.id == candidate)) {
      return candidate;
    }
  }
  return active.first.id;
}

List<MenuCategory> _replaceCategory(
  List<MenuCategory> categories,
  MenuCategory replacement,
) {
  final without = categories
      .where((category) => category.id != replacement.id)
      .toList();
  return [...without, replacement];
}

List<MenuItem> _replaceItem(List<MenuItem> items, MenuItem replacement) {
  final without = items.where((item) => item.id != replacement.id).toList();
  return [...without, replacement];
}

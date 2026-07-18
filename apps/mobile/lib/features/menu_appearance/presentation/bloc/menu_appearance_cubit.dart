import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/copy/pilot_arabic_copy.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../domain/entities/menu_template.dart';
import '../../domain/usecases/get_business_appearance.dart';
import '../../domain/usecases/get_menu_template_catalog.dart';
import '../../domain/usecases/update_business_appearance.dart';
import 'menu_appearance_state.dart';

class MenuAppearanceCubit extends Cubit<MenuAppearanceState> {
  MenuAppearanceCubit({
    required GetMyBusiness getMyBusiness,
    required GetMenuTemplateCatalog getMenuTemplateCatalog,
    required GetBusinessAppearance getBusinessAppearance,
    required UpdateBusinessAppearance updateBusinessAppearance,
  }) : _getMyBusiness = getMyBusiness,
       _getMenuTemplateCatalog = getMenuTemplateCatalog,
       _getBusinessAppearance = getBusinessAppearance,
       _updateBusinessAppearance = updateBusinessAppearance,
       super(const MenuAppearanceState.initial());

  final GetMyBusiness _getMyBusiness;
  final GetMenuTemplateCatalog _getMenuTemplateCatalog;
  final GetBusinessAppearance _getBusinessAppearance;
  final UpdateBusinessAppearance _updateBusinessAppearance;
  int _sessionGeneration = 0;

  void reset() {
    _sessionGeneration++;
    emit(const MenuAppearanceState.initial());
  }

  Future<void> load() async {
    final generation = _sessionGeneration;
    emit(
      state.copyWith(
        status: MenuAppearanceStatus.loading,
        isSaving: false,
        saveForbidden: false,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final businessResult = await _getMyBusiness();
    if (!_isCurrent(generation)) {
      return;
    }
    await businessResult.fold(
      (failure) async => _emitIfCurrent(
        generation,
        MenuAppearanceState(
          status: MenuAppearanceStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) async {
        if (business.id.trim().isEmpty) {
          _emitIfCurrent(
            generation,
            const MenuAppearanceState(
              status: MenuAppearanceStatus.failure,
              errorMessage: PilotArabicCopy.businessProfileMissingBody,
            ),
          );
          return;
        }

        final templatesResult = await _getMenuTemplateCatalog();
        if (!_isCurrent(generation)) {
          return;
        }
        await templatesResult.fold(
          (failure) async => _emitIfCurrent(
            generation,
            MenuAppearanceState(
              status: MenuAppearanceStatus.failure,
              business: business,
              errorMessage: failureMessage(failure),
            ),
          ),
          (templates) async {
            final enabledTemplates = templates
                .where((template) => template.isEnabled)
                .toList(growable: false);
            final appearanceResult = await _getBusinessAppearance(business.id);
            if (!_isCurrent(generation)) {
              return;
            }
            appearanceResult.fold(
              (failure) => _emitIfCurrent(
                generation,
                MenuAppearanceState(
                  status: MenuAppearanceStatus.failure,
                  business: business,
                  templates: enabledTemplates,
                  errorMessage: failureMessage(failure),
                ),
              ),
              (appearance) {
                final resolvedTemplateId = _resolveTemplateId(
                  appearance.menuTemplateId,
                  enabledTemplates,
                );
                _emitIfCurrent(
                  generation,
                  MenuAppearanceState(
                    status: MenuAppearanceStatus.success,
                    business: business,
                    templates: enabledTemplates,
                    currentTemplateId: resolvedTemplateId,
                    draftTemplateId: resolvedTemplateId,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void selectTemplate(String templateId) {
    if (!state.templates.any((template) => template.id == templateId)) {
      emit(
        state.copyWith(
          status: MenuAppearanceStatus.success,
          errorMessage: PilotArabicCopy.menuAppearanceEmpty,
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: MenuAppearanceStatus.success,
        draftTemplateId: templateId,
        saveForbidden: false,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> save() async {
    final business = state.business;
    if (business == null || !state.hasDraftChange) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    emit(
      state.copyWith(
        status: MenuAppearanceStatus.success,
        isSaving: true,
        saveForbidden: false,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _updateBusinessAppearance(
      businessId: businessId,
      menuTemplateId: state.draftTemplateId,
    );
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }
    result.fold(
      (failure) => _emitIfCurrent(
        generation,
        state.copyWith(
          status: MenuAppearanceStatus.success,
          isSaving: false,
          saveForbidden: failure is ForbiddenFailure,
          errorMessage: _saveFailureMessage(failure),
        ),
      ),
      (appearance) {
        final resolvedTemplateId = _resolveTemplateId(
          appearance.menuTemplateId,
          state.templates,
        );
        _emitIfCurrent(
          generation,
          state.copyWith(
            status: MenuAppearanceStatus.success,
            currentTemplateId: resolvedTemplateId,
            draftTemplateId: resolvedTemplateId,
            isSaving: false,
            saveForbidden: false,
            successMessage: PilotArabicCopy.menuAppearanceSaved,
            clearError: true,
          ),
        );
      },
    );
  }

  String _resolveTemplateId(String candidate, List<MenuTemplate> templates) {
    if (templates.any((template) => template.id == candidate)) {
      return candidate;
    }
    if (templates.any((template) => template.id == 'waflo-warm')) {
      return 'waflo-warm';
    }
    return templates.isEmpty ? 'waflo-warm' : templates.first.id;
  }

  String _saveFailureMessage(Failure failure) {
    if (failure is ForbiddenFailure) {
      return PilotArabicCopy.menuAppearancePermission;
    }
    if (failure is ValidationFailure) {
      return failure.message ?? 'Choose an available menu template.';
    }
    return failureMessage(failure);
  }

  bool _isCurrent(int generation) {
    return !isClosed && generation == _sessionGeneration;
  }

  bool _isCurrentBusiness(int generation, String businessId) {
    return _isCurrent(generation) && state.business?.id == businessId;
  }

  void _emitIfCurrent(int generation, MenuAppearanceState nextState) {
    if (_isCurrent(generation)) {
      emit(nextState);
    }
  }
}

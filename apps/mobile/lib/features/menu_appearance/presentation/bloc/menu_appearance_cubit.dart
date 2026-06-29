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

  Future<void> load() async {
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
    await businessResult.fold(
      (failure) async => emit(
        MenuAppearanceState(
          status: MenuAppearanceStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) async {
        if (business.id.trim().isEmpty) {
          emit(
            const MenuAppearanceState(
              status: MenuAppearanceStatus.failure,
              errorMessage: PilotArabicCopy.businessProfileMissingBody,
            ),
          );
          return;
        }

        final templatesResult = await _getMenuTemplateCatalog();
        await templatesResult.fold(
          (failure) async => emit(
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
            appearanceResult.fold(
              (failure) => emit(
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
                emit(
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
      businessId: business.id,
      menuTemplateId: state.draftTemplateId,
    );
    result.fold(
      (failure) => emit(
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
        emit(
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
}

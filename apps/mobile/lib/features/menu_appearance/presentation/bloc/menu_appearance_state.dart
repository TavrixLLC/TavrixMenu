import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/menu_template.dart';

enum MenuAppearanceStatus { initial, loading, success, failure }

class MenuAppearanceState extends Equatable {
  const MenuAppearanceState({
    required this.status,
    this.business,
    this.templates = const [],
    this.currentTemplateId = 'waflo-warm',
    this.draftTemplateId = 'waflo-warm',
    this.isSaving = false,
    this.saveForbidden = false,
    this.errorMessage,
    this.successMessage,
  });

  const MenuAppearanceState.initial()
    : this(status: MenuAppearanceStatus.initial);

  final MenuAppearanceStatus status;
  final Business? business;
  final List<MenuTemplate> templates;
  final String currentTemplateId;
  final String draftTemplateId;
  final bool isSaving;
  final bool saveForbidden;
  final String? errorMessage;
  final String? successMessage;

  bool get hasTemplates => templates.isNotEmpty;

  bool get hasDraftChange =>
      draftTemplateId.trim().isNotEmpty &&
      draftTemplateId != currentTemplateId &&
      templates.any((template) => template.id == draftTemplateId);

  bool get canManageAppearance =>
      business?.permissions?.canManageAppearance ?? true;

  bool get canSave =>
      canManageAppearance && hasDraftChange && !isSaving && !saveForbidden;

  MenuTemplate? get currentTemplate => _templateById(currentTemplateId);

  MenuTemplate? get draftTemplate => _templateById(draftTemplateId);

  MenuTemplate? _templateById(String id) {
    for (final template in templates) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  MenuAppearanceState copyWith({
    MenuAppearanceStatus? status,
    Business? business,
    List<MenuTemplate>? templates,
    String? currentTemplateId,
    String? draftTemplateId,
    bool? isSaving,
    bool? saveForbidden,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearBusiness = false,
  }) {
    return MenuAppearanceState(
      status: status ?? this.status,
      business: clearBusiness ? null : business ?? this.business,
      templates: templates ?? this.templates,
      currentTemplateId: currentTemplateId ?? this.currentTemplateId,
      draftTemplateId: draftTemplateId ?? this.draftTemplateId,
      isSaving: isSaving ?? this.isSaving,
      saveForbidden: saveForbidden ?? this.saveForbidden,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    business,
    templates,
    currentTemplateId,
    draftTemplateId,
    isSaving,
    saveForbidden,
    errorMessage,
    successMessage,
  ];
}

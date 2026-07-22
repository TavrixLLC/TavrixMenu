import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_locale.dart';
import 'app_locale_repository.dart';

enum AppLocaleStatus { restoring, selectionRequired, ready }

class AppLocaleState extends Equatable {
  const AppLocaleState({
    required this.status,
    this.locale,
    this.isSaving = false,
    this.persistenceFailed = false,
  });

  const AppLocaleState.restoring() : this(status: AppLocaleStatus.restoring);

  final AppLocaleStatus status;
  final AppLocale? locale;
  final bool isSaving;
  final bool persistenceFailed;

  bool get hasConfirmedChoice =>
      status == AppLocaleStatus.ready && locale != null;

  AppLocaleState copyWith({
    AppLocaleStatus? status,
    AppLocale? locale,
    bool? isSaving,
    bool? persistenceFailed,
  }) {
    return AppLocaleState(
      status: status ?? this.status,
      locale: locale ?? this.locale,
      isSaving: isSaving ?? this.isSaving,
      persistenceFailed: persistenceFailed ?? this.persistenceFailed,
    );
  }

  @override
  List<Object?> get props => [status, locale, isSaving, persistenceFailed];
}

class AppLocaleController extends Cubit<AppLocaleState> {
  AppLocaleController(this._repository)
    : super(const AppLocaleState.restoring());

  final AppLocaleRepository _repository;

  Future<void> restore() async {
    try {
      final locale = await _repository.read();
      emit(
        locale == null
            ? const AppLocaleState(status: AppLocaleStatus.selectionRequired)
            : AppLocaleState(status: AppLocaleStatus.ready, locale: locale),
      );
    } catch (_) {
      emit(const AppLocaleState(status: AppLocaleStatus.selectionRequired));
    }
  }

  Future<bool> select(AppLocale locale) async {
    if (state.isSaving) {
      return false;
    }
    emit(state.copyWith(isSaving: true, persistenceFailed: false));
    try {
      final persisted = await _repository.write(locale);
      if (!persisted) {
        _emitPersistenceFailure();
        return false;
      }
      emit(AppLocaleState(status: AppLocaleStatus.ready, locale: locale));
      return true;
    } catch (_) {
      _emitPersistenceFailure();
      return false;
    }
  }

  void _emitPersistenceFailure() {
    final confirmedLocale = state.locale;
    emit(
      AppLocaleState(
        status: confirmedLocale == null
            ? AppLocaleStatus.selectionRequired
            : AppLocaleStatus.ready,
        locale: confirmedLocale,
        persistenceFailed: true,
      ),
    );
  }
}

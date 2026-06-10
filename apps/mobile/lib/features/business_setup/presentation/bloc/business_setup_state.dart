import 'package:equatable/equatable.dart';

import '../../domain/entities/business.dart';

enum BusinessSetupStatus { initial, loading, success, failure }

class BusinessSetupState extends Equatable {
  const BusinessSetupState({
    required this.status,
    this.business,
    this.errorMessage,
  });

  const BusinessSetupState.initial()
    : this(status: BusinessSetupStatus.initial);

  final BusinessSetupStatus status;
  final Business? business;
  final String? errorMessage;

  BusinessSetupState copyWith({
    BusinessSetupStatus? status,
    Business? business,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BusinessSetupState(
      status: status ?? this.status,
      business: business ?? this.business,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, business, errorMessage];
}

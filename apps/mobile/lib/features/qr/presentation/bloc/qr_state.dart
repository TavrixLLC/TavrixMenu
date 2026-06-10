import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';
import '../../../business_setup/domain/entities/public_link.dart';

enum QRStatus { initial, loading, success, failure }

class QRState extends Equatable {
  const QRState({
    required this.status,
    this.business,
    this.publicLink,
    this.errorMessage,
    this.usedFallback = false,
  });

  const QRState.initial() : this(status: QRStatus.initial);

  final QRStatus status;
  final Business? business;
  final PublicLink? publicLink;
  final String? errorMessage;
  final bool usedFallback;

  @override
  List<Object?> get props => [
    status,
    business,
    publicLink,
    errorMessage,
    usedFallback,
  ];
}

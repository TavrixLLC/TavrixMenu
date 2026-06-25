import 'package:equatable/equatable.dart';

class BusinessAppearance extends Equatable {
  const BusinessAppearance({
    required this.businessId,
    required this.menuTemplateId,
    this.menuThemeOverrides = const {},
  });

  final String businessId;
  final String menuTemplateId;
  final Map<String, dynamic> menuThemeOverrides;

  @override
  List<Object?> get props => [businessId, menuTemplateId, menuThemeOverrides];
}

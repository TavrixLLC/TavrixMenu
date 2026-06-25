import 'package:equatable/equatable.dart';

class MenuTemplate extends Equatable {
  const MenuTemplate({
    required this.id,
    required this.displayName,
    required this.description,
    this.bestFor = const [],
    this.previewColors = const [],
    this.layoutLabel,
    this.supportedFeatures = const [],
    this.version,
    this.status = 'enabled',
  });

  final String id;
  final String displayName;
  final String description;
  final List<String> bestFor;
  final List<String> previewColors;
  final String? layoutLabel;
  final List<String> supportedFeatures;
  final String? version;
  final String status;

  bool get isEnabled => status.trim().toLowerCase() != 'disabled';

  @override
  List<Object?> get props => [
    id,
    displayName,
    description,
    bestFor,
    previewColors,
    layoutLabel,
    supportedFeatures,
    version,
    status,
  ];
}

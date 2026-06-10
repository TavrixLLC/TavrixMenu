import 'package:equatable/equatable.dart';

class Business extends Equatable {
  const Business({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.role,
    required this.publicMenuUrl,
    this.city,
    this.currency = 'IQD',
    this.language = 'ar',
  });

  final String id;
  final String name;
  final String slug;
  final String type;
  final String role;
  final String publicMenuUrl;
  final String? city;
  final String currency;
  final String language;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    type,
    role,
    publicMenuUrl,
    city,
    currency,
    language,
  ];
}

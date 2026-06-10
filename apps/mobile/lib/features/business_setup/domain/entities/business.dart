import 'package:equatable/equatable.dart';

class Business extends Equatable {
  const Business({
    required this.id,
    required this.name,
    required this.slug,
    required this.publicMenuUrl,
    this.type = 'cafe',
    this.city,
    this.currency = 'IQD',
    this.language = 'ar',
    this.role,
  });

  final String id;
  final String name;
  final String slug;
  final String publicMenuUrl;
  final String type;
  final String? city;
  final String currency;
  final String language;
  final String? role;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    publicMenuUrl,
    type,
    city,
    currency,
    language,
    role,
  ];
}

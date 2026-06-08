import 'package:equatable/equatable.dart';

class Business extends Equatable {
  const Business({
    required this.id,
    required this.name,
    required this.slug,
    required this.publicMenuUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String publicMenuUrl;

  @override
  List<Object?> get props => [id, name, slug, publicMenuUrl];
}

import 'package:equatable/equatable.dart';

class PublicLink extends Equatable {
  const PublicLink({
    required this.businessId,
    required this.slug,
    required this.publicMenuPath,
    required this.publicMenuUrl,
    required this.qrPayload,
  });

  final String businessId;
  final String slug;
  final String publicMenuPath;
  final String publicMenuUrl;
  final String qrPayload;

  @override
  List<Object?> get props => [
    businessId,
    slug,
    publicMenuPath,
    publicMenuUrl,
    qrPayload,
  ];
}

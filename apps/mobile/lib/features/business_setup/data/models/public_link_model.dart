import '../../../../core/utils/response_parser.dart';
import '../../domain/entities/public_link.dart';

class PublicLinkModel extends PublicLink {
  const PublicLinkModel({
    required super.businessId,
    required super.slug,
    required super.publicMenuPath,
    required super.publicMenuUrl,
    required super.qrPayload,
  });

  factory PublicLinkModel.fromJson(Map<String, dynamic> json) {
    return PublicLinkModel(
      businessId: json['businessId'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      publicMenuPath:
          json['publicMenuPath'] as String? ??
          json['path'] as String? ??
          _pathFromSlug(json['slug'] as String? ?? ''),
      publicMenuUrl:
          json['publicMenuUrl'] as String? ?? json['url'] as String? ?? '',
      qrPayload: json['qrPayload'] as String? ?? '',
    );
  }

  factory PublicLinkModel.fromResponse(dynamic data) {
    final json = asJsonObject(data, context: 'public link response');
    final nested = json['data'] ?? json['publicLink'] ?? json['publicMenu'];
    return PublicLinkModel.fromJson(
      nested == null
          ? json
          : asJsonObject(nested, context: 'public link response'),
    );
  }

  factory PublicLinkModel.fromPublicMenuJson({
    required String businessId,
    required Map<String, dynamic> json,
  }) {
    return PublicLinkModel.fromJson({'businessId': businessId, ...json});
  }

  PublicLink toEntity() {
    return PublicLink(
      businessId: businessId,
      slug: slug,
      publicMenuPath: publicMenuPath,
      publicMenuUrl: publicMenuUrl,
      qrPayload: qrPayload,
    );
  }

  static String _pathFromSlug(String slug) {
    return slug.isEmpty ? '' : '/m/$slug';
  }
}

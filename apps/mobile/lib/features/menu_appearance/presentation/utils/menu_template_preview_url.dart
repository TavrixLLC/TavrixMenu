import '../../../business_setup/domain/entities/business.dart';

const unavailablePreviewMessage =
    'المعاينة تحتاج رابط منيو عام جاهز لهذا المطعم.';

Uri? buildMenuTemplatePreviewUri({
  required Business? business,
  required String templateId,
  required String customerWebBaseUrl,
}) {
  final currentBusiness = business;
  if (currentBusiness == null) {
    return null;
  }

  final slug = currentBusiness.slug.trim();
  if (slug.isEmpty || templateId.trim().isEmpty) {
    return null;
  }

  final base = _previewBase(
    configuredBaseUrl: customerWebBaseUrl,
    publicMenuUrl: currentBusiness.publicMenuUrl,
  );
  if (base == null) {
    return null;
  }

  return Uri.parse(
    '$base/m/${Uri.encodeComponent(slug)}',
  ).replace(queryParameters: {'previewTemplateId': templateId});
}

String? _previewBase({
  required String configuredBaseUrl,
  required String publicMenuUrl,
}) {
  final configured = _absoluteOriginOrBase(configuredBaseUrl);
  if (configured != null) {
    return configured;
  }

  final publicMenuOrigin = _absoluteOriginOrBase(publicMenuUrl);
  return publicMenuOrigin;
}

String? _absoluteOriginOrBase(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    return null;
  }

  return '${uri.scheme}://${uri.authority}';
}

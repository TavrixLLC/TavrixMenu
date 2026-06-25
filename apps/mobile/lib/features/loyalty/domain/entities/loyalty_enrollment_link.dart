class LoyaltyEnrollmentLink {
  const LoyaltyEnrollmentLink._();

  static String? build({
    required String businessSlug,
    required String customerWebBaseUrl,
    String? publicMenuUrl,
  }) {
    final path = pathForSlug(businessSlug);
    if (path == null) {
      return null;
    }

    final baseUrl =
        _normalizedBaseUrl(customerWebBaseUrl) ??
        _originFromUrl(publicMenuUrl ?? '');
    if (baseUrl == null) {
      return path;
    }

    return '$baseUrl$path';
  }

  static String? pathForSlug(String businessSlug) {
    final slug = businessSlug.trim();
    if (slug.isEmpty) {
      return null;
    }

    return '/m/${Uri.encodeComponent(slug)}/loyalty';
  }

  static String? _normalizedBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  static String? _originFromUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }

    return '${uri.scheme}://${uri.authority}';
  }
}

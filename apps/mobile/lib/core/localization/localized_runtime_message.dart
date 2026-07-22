import '../../l10n/generated/app_localizations.dart';

String localizedRuntimeMessage(
  AppLocalizations localizations,
  String? message, {
  String? fallback,
}) {
  final normalized = message?.trim().toLowerCase() ?? '';
  if (normalized.isEmpty) {
    return fallback ?? localizations.genericErrorBody;
  }
  if (normalized.contains('network') ||
      normalized.contains('connection') ||
      normalized.contains('offline') ||
      normalized.contains('socket')) {
    return localizations.authTemporaryErrorBody;
  }
  if (normalized.contains('permission') ||
      normalized.contains('forbidden') ||
      normalized.contains('unauthorized')) {
    return localizations.permissionUnavailable;
  }
  return fallback ?? localizations.genericErrorBody;
}

class VisualThemeAssignmentContract {
  VisualThemeAssignmentContract({
    required this.businessId,
    required this.visualThemeId,
    required Iterable<String> programIds,
  }) : programIds = Set.unmodifiable(programIds);

  final String businessId;
  final String visualThemeId;
  final Set<String> programIds;

  bool get isValid =>
      businessId.trim().isNotEmpty &&
      visualThemeId.trim().isNotEmpty &&
      programIds.isNotEmpty &&
      programIds.every((id) => id.trim().isNotEmpty);
}

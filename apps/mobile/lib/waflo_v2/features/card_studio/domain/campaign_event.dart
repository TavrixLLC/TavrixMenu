enum CampaignEventStatus {
  draft,
  scheduled,
  active,
  paused,
  completed,
  cancelled,
}

class CampaignEventContract {
  const CampaignEventContract({
    required this.id,
    required this.businessId,
    required this.name,
    required this.status,
    this.visualThemeId,
  });

  final String id;
  final String businessId;
  final String name;
  final CampaignEventStatus status;
  final String? visualThemeId;
}

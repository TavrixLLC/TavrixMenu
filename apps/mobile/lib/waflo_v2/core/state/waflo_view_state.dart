enum WafloViewStateKind {
  initial,
  loading,
  refreshing,
  empty,
  error,
  offline,
  forbidden,
  stale,
  submitting,
  confirmed,
  draft,
  disabled,
}

class WafloViewState {
  const WafloViewState({required this.kind, this.safeTimestamp});

  final WafloViewStateKind kind;
  final DateTime? safeTimestamp;

  bool get isBusy =>
      kind == WafloViewStateKind.loading ||
      kind == WafloViewStateKind.refreshing ||
      kind == WafloViewStateKind.submitting;

  bool get permitsValueMutation => kind == WafloViewStateKind.confirmed;
}

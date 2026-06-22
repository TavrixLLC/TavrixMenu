import 'package:equatable/equatable.dart';

class LoyaltyCardState extends Equatable {
  const LoyaltyCardState({
    required this.stampCount,
    required this.stampGoal,
    required this.rewardReady,
    required this.progressPercent,
    required this.rewardName,
    required this.programName,
  });

  final int stampCount;
  final int stampGoal;
  final bool rewardReady;
  final int progressPercent;
  final String rewardName;
  final String programName;

  double get progressRatio {
    final ratio = progressPercent / 100;
    return ratio.clamp(0, 1).toDouble();
  }

  LoyaltyCardState copyWith({
    int? stampCount,
    int? stampGoal,
    bool? rewardReady,
    int? progressPercent,
    String? rewardName,
    String? programName,
  }) {
    return LoyaltyCardState(
      stampCount: stampCount ?? this.stampCount,
      stampGoal: stampGoal ?? this.stampGoal,
      rewardReady: rewardReady ?? this.rewardReady,
      progressPercent: progressPercent ?? this.progressPercent,
      rewardName: rewardName ?? this.rewardName,
      programName: programName ?? this.programName,
    );
  }

  @override
  List<Object?> get props => [
    stampCount,
    stampGoal,
    rewardReady,
    progressPercent,
    rewardName,
    programName,
  ];
}

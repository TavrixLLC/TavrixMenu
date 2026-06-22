import 'package:equatable/equatable.dart';

class WalletScanResult extends Equatable {
  const WalletScanResult({
    required this.membershipId,
    required this.programName,
    required this.rewardName,
    required this.stamps,
    required this.goal,
    required this.canRedeem,
    this.customerName,
    this.customerPhone,
  });

  final String membershipId;
  final String? customerName;
  final String? customerPhone;
  final String programName;
  final String rewardName;
  final int stamps;
  final int goal;
  final bool canRedeem;

  String get customerDisplayName {
    final name = customerName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Loyalty customer';
  }

  int get progressPercent {
    if (goal <= 0) {
      return 0;
    }
    return ((stamps / goal) * 100).round().clamp(0, 100).toInt();
  }

  @override
  List<Object?> get props => [
    membershipId,
    customerName,
    customerPhone,
    programName,
    rewardName,
    stamps,
    goal,
    canRedeem,
  ];
}

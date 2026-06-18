import '../../../../core/utils/response_parser.dart';
import '../../domain/entities/wallet_scan_result.dart';

class WalletScanResultModel extends WalletScanResult {
  const WalletScanResultModel({
    required super.membershipId,
    required super.programName,
    required super.rewardName,
    required super.stamps,
    required super.goal,
    required super.canRedeem,
    super.customerName,
    super.customerPhone,
  });

  factory WalletScanResultModel.fromJson(Map<String, dynamic> json) {
    final customer = asJsonObject(
      json['customer'],
      context: 'wallet scan customer',
    );
    final program = asJsonObject(
      json['program'],
      context: 'wallet scan program',
    );
    final progress = asJsonObject(
      json['progress'],
      context: 'wallet scan progress',
    );

    return WalletScanResultModel(
      membershipId: _string(json['membershipId']),
      customerName: _optionalString(customer['name']),
      customerPhone: _optionalString(customer['phone']),
      programName: _optionalString(program['name']) ?? 'Loyalty program',
      rewardName: _optionalString(program['rewardName']) ?? 'Reward',
      stamps: _int(progress['stamps']),
      goal: _int(progress['goal'] ?? program['stampGoal']),
      canRedeem: _bool(progress['canRedeem']),
    );
  }

  WalletScanResult toEntity() {
    return WalletScanResult(
      membershipId: membershipId,
      customerName: customerName,
      customerPhone: customerPhone,
      programName: programName,
      rewardName: rewardName,
      stamps: stamps,
      goal: goal,
      canRedeem: canRedeem,
    );
  }
}

String _string(Object? value) => _optionalString(value) ?? '';

String? _optionalString(Object? value) {
  if (value is! String) {
    return null;
  }
  final clean = value.trim();
  return clean.isEmpty ? null : clean;
}

int _int(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _bool(Object? value) {
  if (value is bool) {
    return value;
  }
  return value?.toString().toLowerCase() == 'true';
}

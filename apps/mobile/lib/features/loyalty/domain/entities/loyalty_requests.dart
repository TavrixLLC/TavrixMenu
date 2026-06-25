import 'package:equatable/equatable.dart';

class LoyaltyProgramRequest extends Equatable {
  const LoyaltyProgramRequest({
    required this.name,
    required this.stampGoal,
    required this.rewardName,
    this.description,
    this.rewardDescription,
    this.isActive = true,
    this.cardColor,
    this.accentColor,
    this.logoUrl,
    this.terms,
  });

  final String name;
  final int stampGoal;
  final String rewardName;
  final String? description;
  final String? rewardDescription;
  final bool isActive;
  final String? cardColor;
  final String? accentColor;
  final String? logoUrl;
  final String? terms;

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'stampGoal': stampGoal,
      'rewardName': rewardName.trim(),
      'isActive': isActive,
      if (_clean(description) != null) 'description': _clean(description),
      if (_clean(rewardDescription) != null)
        'rewardDescription': _clean(rewardDescription),
      if (_clean(cardColor) != null) 'cardColor': _clean(cardColor),
      if (_clean(accentColor) != null) 'accentColor': _clean(accentColor),
      if (_clean(logoUrl) != null) 'logoUrl': _clean(logoUrl),
      if (_clean(terms) != null) 'terms': _clean(terms),
    };
  }

  @override
  List<Object?> get props => [
    name,
    stampGoal,
    rewardName,
    description,
    rewardDescription,
    isActive,
    cardColor,
    accentColor,
    logoUrl,
    terms,
  ];
}

class EnrollLoyaltyCustomerRequest extends Equatable {
  const EnrollLoyaltyCustomerRequest({
    this.phone,
    this.email,
    this.name,
    this.programId,
  });

  final String? phone;
  final String? email;
  final String? name;
  final String? programId;

  bool get hasRequiredContact {
    return (_clean(phone)?.isNotEmpty ?? false) ||
        (_clean(email)?.isNotEmpty ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      if (_clean(phone) != null) 'phone': _clean(phone),
      if (_clean(email) != null) 'email': _clean(email),
      if (_clean(name) != null) 'name': _clean(name),
      if (_clean(programId) != null) 'programId': _clean(programId),
    };
  }

  @override
  List<Object?> get props => [phone, email, name, programId];
}

class AddStampsRequest extends Equatable {
  const AddStampsRequest({this.count = 1, this.reason});

  final int count;
  final String? reason;

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      if (_clean(reason) != null) 'reason': _clean(reason),
    };
  }

  @override
  List<Object?> get props => [count, reason];
}

class RedeemRewardRequest extends Equatable {
  const RedeemRewardRequest({this.reason});

  final String? reason;

  Map<String, dynamic> toJson() {
    return {if (_clean(reason) != null) 'reason': _clean(reason)};
  }

  @override
  List<Object?> get props => [reason];
}

String? _clean(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

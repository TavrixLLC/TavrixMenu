import 'package:equatable/equatable.dart';

class LoyaltyProgram extends Equatable {
  const LoyaltyProgram({
    required this.id,
    required this.businessId,
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
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String businessId;
  final String name;
  final String? description;
  final int stampGoal;
  final String rewardName;
  final String? rewardDescription;
  final bool isActive;
  final String? cardColor;
  final String? accentColor;
  final String? logoUrl;
  final String? terms;
  final String? createdAt;
  final String? updatedAt;

  LoyaltyProgram copyWith({
    String? id,
    String? businessId,
    String? name,
    String? description,
    int? stampGoal,
    String? rewardName,
    String? rewardDescription,
    bool? isActive,
    String? cardColor,
    String? accentColor,
    String? logoUrl,
    String? terms,
    String? createdAt,
    String? updatedAt,
  }) {
    return LoyaltyProgram(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      stampGoal: stampGoal ?? this.stampGoal,
      rewardName: rewardName ?? this.rewardName,
      rewardDescription: rewardDescription ?? this.rewardDescription,
      isActive: isActive ?? this.isActive,
      cardColor: cardColor ?? this.cardColor,
      accentColor: accentColor ?? this.accentColor,
      logoUrl: logoUrl ?? this.logoUrl,
      terms: terms ?? this.terms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    name,
    description,
    stampGoal,
    rewardName,
    rewardDescription,
    isActive,
    cardColor,
    accentColor,
    logoUrl,
    terms,
    createdAt,
    updatedAt,
  ];
}

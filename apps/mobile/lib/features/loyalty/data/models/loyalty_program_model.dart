import '../../domain/entities/loyalty_program.dart';
import 'loyalty_json.dart';

class LoyaltyProgramModel extends LoyaltyProgram {
  const LoyaltyProgramModel({
    required super.id,
    required super.businessId,
    required super.name,
    required super.stampGoal,
    required super.rewardName,
    super.description,
    super.rewardDescription,
    super.isActive,
    super.cardColor,
    super.accentColor,
    super.logoUrl,
    super.terms,
    super.createdAt,
    super.updatedAt,
  });

  factory LoyaltyProgramModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramModel(
      id: loyaltyString(json['id']) ?? '',
      businessId:
          loyaltyString(json['businessId']) ??
          loyaltyString(json['business_id']) ??
          '',
      name: loyaltyString(json['name']) ?? '',
      description: loyaltyString(json['description']),
      stampGoal:
          loyaltyInt(json['stampGoal']) ?? loyaltyInt(json['stamp_goal']) ?? 0,
      rewardName:
          loyaltyString(json['rewardName']) ??
          loyaltyString(json['reward_name']) ??
          '',
      rewardDescription:
          loyaltyString(json['rewardDescription']) ??
          loyaltyString(json['reward_description']),
      isActive:
          loyaltyBool(json['isActive']) ??
          loyaltyBool(json['is_active']) ??
          true,
      cardColor:
          loyaltyString(json['cardColor']) ?? loyaltyString(json['card_color']),
      accentColor:
          loyaltyString(json['accentColor']) ??
          loyaltyString(json['accent_color']),
      logoUrl:
          loyaltyString(json['logoUrl']) ?? loyaltyString(json['logo_url']),
      terms: loyaltyString(json['terms']),
      createdAt: loyaltyDateString(json['createdAt'] ?? json['created_at']),
      updatedAt: loyaltyDateString(json['updatedAt'] ?? json['updated_at']),
    );
  }

  LoyaltyProgram toEntity() {
    return LoyaltyProgram(
      id: id,
      businessId: businessId,
      name: name,
      description: description,
      stampGoal: stampGoal,
      rewardName: rewardName,
      rewardDescription: rewardDescription,
      isActive: isActive,
      cardColor: cardColor,
      accentColor: accentColor,
      logoUrl: logoUrl,
      terms: terms,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

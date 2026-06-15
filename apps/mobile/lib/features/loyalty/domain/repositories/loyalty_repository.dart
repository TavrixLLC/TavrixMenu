import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/loyalty_action_result.dart';
import '../entities/loyalty_enroll_result.dart';
import '../entities/loyalty_membership.dart';
import '../entities/loyalty_program.dart';
import '../entities/loyalty_requests.dart';
import '../entities/loyalty_stamp_style.dart';
import '../entities/loyalty_transaction.dart';

abstract class LoyaltyRepository {
  Future<Either<Failure, LoyaltyProgram?>> getActiveProgram(String businessId);

  Future<Either<Failure, LoyaltyStampPresets>> getStampPresets();

  Future<Either<Failure, LoyaltyStampStyle?>> getStampStyle(String businessId);

  Future<Either<Failure, LoyaltyStampStyle>> updateStampStyle({
    required String businessId,
    required UpdateLoyaltyStampStyleRequest request,
  });

  Future<Either<Failure, LoyaltyProgram>> createProgram({
    required String businessId,
    required LoyaltyProgramRequest request,
  });

  Future<Either<Failure, LoyaltyProgram>> updateProgram({
    required String businessId,
    required String programId,
    required LoyaltyProgramRequest request,
  });

  Future<Either<Failure, LoyaltyEnrollResult>> enrollCustomer({
    required String businessId,
    required EnrollLoyaltyCustomerRequest request,
  });

  Future<Either<Failure, List<LoyaltyMembership>>> listMemberships({
    required String businessId,
    String? search,
    String? status,
    bool? rewardReady,
  });

  Future<Either<Failure, LoyaltyMembership>> getMembership({
    required String businessId,
    required String membershipId,
  });

  Future<Either<Failure, LoyaltyActionResult>> addStamps({
    required String businessId,
    required String membershipId,
    required AddStampsRequest request,
  });

  Future<Either<Failure, LoyaltyActionResult>> redeemReward({
    required String businessId,
    required String membershipId,
    required RedeemRewardRequest request,
  });

  Future<Either<Failure, List<LoyaltyTransaction>>> listTransactions({
    required String businessId,
    required String membershipId,
  });
}

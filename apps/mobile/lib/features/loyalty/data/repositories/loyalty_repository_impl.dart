import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../domain/entities/loyalty_action_result.dart';
import '../../domain/entities/loyalty_card_state.dart';
import '../../domain/entities/loyalty_customer.dart';
import '../../domain/entities/loyalty_enroll_result.dart';
import '../../domain/entities/loyalty_membership.dart';
import '../../domain/entities/loyalty_program.dart';
import '../../domain/entities/loyalty_requests.dart';
import '../../domain/entities/loyalty_transaction.dart';
import '../../domain/repositories/loyalty_repository.dart';
import '../datasources/loyalty_remote_data_source.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  LoyaltyRepositoryImpl({
    required LoyaltyRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required bool devFallbackEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _devFallbackEnabled = devFallbackEnabled {
    _program = const LoyaltyProgram(
      id: 'dev-loyalty-program',
      businessId: 'dev-business',
      name: 'Tavrix Demo Stamp Card',
      description: 'Collect a stamp on each visit.',
      stampGoal: 5,
      rewardName: 'Free coffee',
      rewardDescription: 'Redeem one free house coffee.',
      terms: 'Demo loyalty data for development.',
    );
    _customers = const [
      LoyaltyCustomer(
        id: 'dev-customer-1',
        phone: '+9647700000000',
        email: 'customer@example.com',
        name: 'Demo Customer',
      ),
    ];
    _memberships = const [
      LoyaltyMembership(
        id: 'dev-membership-1',
        businessId: 'dev-business',
        loyaltyProgramId: 'dev-loyalty-program',
        customerId: 'dev-customer-1',
        stampCount: 3,
        totalStampsEarned: 3,
        status: 'ACTIVE',
      ),
    ];
    _transactions = const [
      LoyaltyTransaction(
        id: 'dev-transaction-1',
        businessId: 'dev-business',
        loyaltyProgramId: 'dev-loyalty-program',
        membershipId: 'dev-membership-1',
        customerId: 'dev-customer-1',
        type: 'STAMP_ADDED',
        stampsDelta: 1,
        reason: 'Demo coffee purchase',
        createdAt: '2026-06-13T00:00:00.000Z',
      ),
    ];
  }

  final LoyaltyRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final bool _devFallbackEnabled;
  late LoyaltyProgram? _program;
  late List<LoyaltyCustomer> _customers;
  late List<LoyaltyMembership> _memberships;
  late List<LoyaltyTransaction> _transactions;

  bool get _useDevData =>
      !_remoteDataSource.canCallBackend && _devFallbackEnabled;

  @override
  Future<Either<Failure, LoyaltyProgram?>> getActiveProgram(String businessId) {
    return runSafe(() async {
      if (_useDevData) {
        return _program?.isActive == true ? _program : null;
      }

      final model = await _remoteDataSource.getActiveProgram(businessId);
      return model?.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, LoyaltyProgram>> createProgram({
    required String businessId,
    required LoyaltyProgramRequest request,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        _program = LoyaltyProgram(
          id: 'dev-loyalty-program',
          businessId: businessId,
          name: request.name.trim(),
          description: _clean(request.description),
          stampGoal: request.stampGoal,
          rewardName: request.rewardName.trim(),
          rewardDescription: _clean(request.rewardDescription),
          isActive: request.isActive,
          cardColor: _clean(request.cardColor),
          accentColor: _clean(request.accentColor),
          logoUrl: _clean(request.logoUrl),
          terms: _clean(request.terms),
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        return _program!;
      }

      final model = await _remoteDataSource.createProgram(
        businessId: businessId,
        request: request,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, LoyaltyProgram>> updateProgram({
    required String businessId,
    required String programId,
    required LoyaltyProgramRequest request,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final existing = _program;
        if (existing == null || existing.id != programId) {
          throw const NotFoundException();
        }

        _program = existing.copyWith(
          businessId: businessId,
          name: request.name.trim(),
          description: _clean(request.description),
          stampGoal: request.stampGoal,
          rewardName: request.rewardName.trim(),
          rewardDescription: _clean(request.rewardDescription),
          isActive: request.isActive,
          cardColor: _clean(request.cardColor),
          accentColor: _clean(request.accentColor),
          logoUrl: _clean(request.logoUrl),
          terms: _clean(request.terms),
          updatedAt: DateTime.now().toIso8601String(),
        );
        return _program!;
      }

      final model = await _remoteDataSource.updateProgram(
        businessId: businessId,
        programId: programId,
        request: request,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, LoyaltyEnrollResult>> enrollCustomer({
    required String businessId,
    required EnrollLoyaltyCustomerRequest request,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final program = _program;
        if (program == null || !program.isActive) {
          throw const NotFoundException();
        }
        if (!request.hasRequiredContact) {
          throw const ValidationException('Enter a phone number or email.');
        }

        var customer = _findCustomer(
          phone: request.phone,
          email: request.email,
        );
        if (customer == null) {
          customer = LoyaltyCustomer(
            id: 'dev-customer-${_customers.length + 1}',
            phone: _clean(request.phone),
            email: _clean(request.email),
            name: _clean(request.name),
          );
          _customers = [..._customers, customer];
        }

        var membership = _memberships
            .where(
              (candidate) =>
                  candidate.customerId == customer!.id &&
                  candidate.loyaltyProgramId == program.id,
            )
            .firstOrNull;
        if (membership == null) {
          membership = LoyaltyMembership(
            id: 'dev-membership-${_memberships.length + 1}',
            businessId: businessId,
            loyaltyProgramId: program.id,
            customerId: customer.id,
            status: 'ACTIVE',
          );
          _memberships = [..._memberships, membership];
        }

        final hydrated = _hydrateMembership(membership);
        return LoyaltyEnrollResult(
          customer: customer,
          membership: hydrated,
          program: program,
          cardState: hydrated.effectiveCardState,
        );
      }

      final model = await _remoteDataSource.enrollCustomer(
        businessId: businessId,
        request: request,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, List<LoyaltyMembership>>> listMemberships({
    required String businessId,
    String? search,
    String? status,
    bool? rewardReady,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final cleanSearch = _clean(search)?.toLowerCase();
        final cleanStatus = _clean(status)?.toUpperCase();
        var results = _memberships
            .where((membership) => membership.businessId == businessId)
            .map(_hydrateMembership)
            .toList();

        if (cleanSearch != null) {
          results = results.where((membership) {
            final customer = membership.customer;
            final haystack = [
              customer?.name,
              customer?.phone,
              customer?.email,
            ].whereType<String>().join(' ').toLowerCase();
            return haystack.contains(cleanSearch);
          }).toList();
        }
        if (cleanStatus != null) {
          results = results
              .where(
                (membership) => membership.status.toUpperCase() == cleanStatus,
              )
              .toList();
        }
        if (rewardReady != null) {
          results = results
              .where(
                (membership) =>
                    membership.effectiveCardState.rewardReady == rewardReady,
              )
              .toList();
        }

        return results;
      }

      final models = await _remoteDataSource.listMemberships(
        businessId: businessId,
        search: search,
        status: status,
        rewardReady: rewardReady,
      );
      return models.map((model) => model.toEntity()).toList();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, LoyaltyMembership>> getMembership({
    required String businessId,
    required String membershipId,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final membership = _memberships
            .where(
              (candidate) =>
                  candidate.businessId == businessId &&
                  candidate.id == membershipId,
            )
            .firstOrNull;
        if (membership == null) {
          throw const NotFoundException();
        }
        return _hydrateMembership(membership);
      }

      final model = await _remoteDataSource.getMembership(
        businessId: businessId,
        membershipId: membershipId,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, LoyaltyActionResult>> addStamps({
    required String businessId,
    required String membershipId,
    required AddStampsRequest request,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        if (request.count < 1 || request.count > 10) {
          throw const ValidationException('Stamp count must be from 1 to 10.');
        }

        final membership = _membershipOrThrow(
          businessId: businessId,
          membershipId: membershipId,
        );
        final goal =
            _program?.stampGoal ?? membership.effectiveCardState.stampGoal;
        final nextCount = membership.stampCount + request.count;
        final stampCount = goal > 0 && nextCount > goal ? goal : nextCount;
        final rewardReady = goal > 0 && stampCount >= goal;
        final updated = membership.copyWith(
          stampCount: stampCount,
          rewardReady: rewardReady,
          totalStampsEarned: membership.totalStampsEarned + request.count,
        );
        _replaceMembership(updated);
        _addTransaction(
          LoyaltyTransaction(
            id: 'dev-transaction-${_transactions.length + 1}',
            businessId: businessId,
            loyaltyProgramId: membership.loyaltyProgramId,
            membershipId: membership.id,
            customerId: membership.customerId,
            type: 'STAMP_ADDED',
            stampsDelta: request.count,
            reason: _clean(request.reason),
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final hydrated = _hydrateMembership(updated);
        return LoyaltyActionResult(
          membership: hydrated,
          cardState: hydrated.effectiveCardState,
        );
      }

      final model = await _remoteDataSource.addStamps(
        businessId: businessId,
        membershipId: membershipId,
        request: request,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, LoyaltyActionResult>> redeemReward({
    required String businessId,
    required String membershipId,
    required RedeemRewardRequest request,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        final membership = _membershipOrThrow(
          businessId: businessId,
          membershipId: membershipId,
        );
        final hydrated = _hydrateMembership(membership);
        if (!hydrated.effectiveCardState.rewardReady) {
          throw const ValidationException('Reward is not ready yet.');
        }

        final updated = membership.copyWith(
          stampCount: 0,
          rewardReady: false,
          totalRewardsRedeemed: membership.totalRewardsRedeemed + 1,
        );
        _replaceMembership(updated);
        _addTransaction(
          LoyaltyTransaction(
            id: 'dev-transaction-${_transactions.length + 1}',
            businessId: businessId,
            loyaltyProgramId: membership.loyaltyProgramId,
            membershipId: membership.id,
            customerId: membership.customerId,
            type: 'REWARD_REDEEMED',
            stampsDelta: -membership.stampCount,
            reason: _clean(request.reason),
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

        final refreshed = _hydrateMembership(updated);
        return LoyaltyActionResult(
          membership: refreshed,
          cardState: refreshed.effectiveCardState,
        );
      }

      final model = await _remoteDataSource.redeemReward(
        businessId: businessId,
        membershipId: membershipId,
        request: request,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, List<LoyaltyTransaction>>> listTransactions({
    required String businessId,
    required String membershipId,
  }) {
    return runSafe(() async {
      if (_useDevData) {
        return _transactions
            .where(
              (transaction) =>
                  transaction.businessId == businessId &&
                  transaction.membershipId == membershipId,
            )
            .toList();
      }

      final models = await _remoteDataSource.listTransactions(
        businessId: businessId,
        membershipId: membershipId,
      );
      return models.map((model) => model.toEntity()).toList();
    }, _networkInfo);
  }

  LoyaltyMembership _membershipOrThrow({
    required String businessId,
    required String membershipId,
  }) {
    final membership = _memberships
        .where(
          (candidate) =>
              candidate.businessId == businessId &&
              candidate.id == membershipId,
        )
        .firstOrNull;
    if (membership == null) {
      throw const NotFoundException();
    }
    return membership;
  }

  LoyaltyCustomer? _findCustomer({String? phone, String? email}) {
    final cleanPhone = _clean(phone);
    final cleanEmail = _clean(email)?.toLowerCase();
    return _customers.where((customer) {
      final phoneMatches =
          cleanPhone != null && customer.phone?.trim() == cleanPhone;
      final emailMatches =
          cleanEmail != null &&
          customer.email?.trim().toLowerCase() == cleanEmail;
      return phoneMatches || emailMatches;
    }).firstOrNull;
  }

  LoyaltyMembership _hydrateMembership(LoyaltyMembership membership) {
    final customer = _customers
        .where((candidate) => candidate.id == membership.customerId)
        .firstOrNull;
    final program = _program?.id == membership.loyaltyProgramId
        ? _program
        : membership.program;
    final base = membership.copyWith(customer: customer, program: program);
    return base.copyWith(
      cardState: _cardStateFor(base),
      transactions: _transactions
          .where((transaction) => transaction.membershipId == membership.id)
          .toList(),
    );
  }

  LoyaltyCardState _cardStateFor(LoyaltyMembership membership) {
    final program = membership.program ?? _program;
    final goal = program?.stampGoal ?? 0;
    final rewardReady =
        membership.rewardReady || (goal > 0 && membership.stampCount >= goal);
    final percent = goal <= 0
        ? 0
        : ((membership.stampCount / goal) * 100).round().clamp(0, 100).toInt();
    return LoyaltyCardState(
      stampCount: membership.stampCount,
      stampGoal: goal,
      rewardReady: rewardReady,
      progressPercent: percent,
      rewardName: program?.rewardName ?? 'Reward',
      programName: program?.name ?? 'Loyalty program',
    );
  }

  void _replaceMembership(LoyaltyMembership membership) {
    _memberships = _memberships
        .map(
          (candidate) => candidate.id == membership.id ? membership : candidate,
        )
        .toList();
  }

  void _addTransaction(LoyaltyTransaction transaction) {
    _transactions = [transaction, ..._transactions];
  }
}

String? _clean(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

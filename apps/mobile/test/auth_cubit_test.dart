import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/auth/auth_session_controller.dart';
import 'package:tavrix_menu_mobile/core/auth/clerk_token_provider.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/repositories/me_repository.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_state.dart';

void main() {
  test('onboarding.hasBusiness false keeps user on setup path', () async {
    final cubit = _authCubit(
      const CurrentUser(
        id: 'usr_empty',
        email: 'owner@tavrix.local',
        fullName: 'New Owner',
        role: 'OWNER',
        onboarding: CurrentUserOnboarding(hasBusiness: false),
      ),
    );

    await cubit.signInWithClerk();

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.shouldOpenDashboard, isFalse);

    await cubit.close();
  });

  test('onboarding.hasBusiness true opens dashboard path', () async {
    final cubit = _authCubit(
      const CurrentUser(
        id: 'usr_owner',
        email: 'owner@tavrix.local',
        fullName: 'Tavrix Owner',
        role: 'OWNER',
        onboarding: CurrentUserOnboarding(
          hasBusiness: true,
          activeBusinessCount: 1,
        ),
      ),
    );

    await cubit.signInWithClerk();

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.shouldOpenDashboard, isTrue);

    await cubit.close();
  });

  test(
    'active business membership opens dashboard even without setup flag',
    () async {
      final cubit = _authCubit(
        const CurrentUser(
          id: 'usr_member',
          email: 'operator@tavrix.local',
          fullName: 'Workspace Member',
          role: 'BUSINESS_OPERATOR',
          onboarding: CurrentUserOnboarding(hasBusiness: false),
          memberships: [
            CurrentUserMembership(
              id: 'mem_123',
              role: 'BUSINESS_OPERATOR',
              isActive: true,
              business: CurrentUserMembershipBusiness(
                id: 'bus_123',
                name: 'Tavrix Cafe',
                slug: 'tavrix-cafe',
                type: 'cafe',
              ),
            ),
          ],
        ),
      );

      await cubit.signInWithClerk();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.shouldOpenDashboard, isTrue);

      await cubit.close();
    },
  );
}

AuthCubit _authCubit(CurrentUser user) {
  final config = const AppConfig(
    apiBaseUrl: 'https://api.example.test',
    customerWebBaseUrl: 'https://menu.example.test',
    devAuthToken: '',
    appEnv: 'development',
    enableDevAuth: false,
    clerkPublishableKey: 'pk_test_example',
  );
  final sessionController = AuthSessionController(
    config: config,
    clerkTokenProvider: ClerkTokenProvider(),
    devTokenProvider: const DevTokenProvider(''),
  );

  return AuthCubit(
    getCurrentUser: GetCurrentUser(_FakeMeRepository(user)),
    authSessionController: sessionController,
  );
}

class _FakeMeRepository implements MeRepository {
  const _FakeMeRepository(this.user);

  final CurrentUser user;

  @override
  Future<Either<Failure, CurrentUser>> getMe() async => Right(user);
}

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

  test('refreshCurrentUser updates onboarding from setup to dashboard', () async {
    final repository = _QueuedMeRepository([
      const CurrentUser(
        id: 'usr_owner',
        email: 'owner@tavrix.local',
        fullName: 'Tavrix Owner',
        role: 'OWNER',
        onboarding: CurrentUserOnboarding(
          hasBusiness: false,
          recommendedNextStep: 'CREATE_BUSINESS',
        ),
      ),
      const CurrentUser(
        id: 'usr_owner',
        email: 'owner@tavrix.local',
        fullName: 'Tavrix Owner',
        role: 'OWNER',
        onboarding: CurrentUserOnboarding(
          hasBusiness: true,
          activeBusinessCount: 1,
          recommendedNextStep: 'OPEN_DASHBOARD',
        ),
      ),
    ]);
    final cubit = _authCubitWithRepository(repository);

    await cubit.signInWithClerk();

    expect(repository.getMeCalls, 1);
    expect(
      cubit.state.user?.onboarding.recommendedNextStep,
      'CREATE_BUSINESS',
    );
    expect(cubit.state.shouldOpenDashboard, isFalse);

    await cubit.refreshCurrentUser();

    expect(repository.getMeCalls, 2);
    expect(
      cubit.state.user?.onboarding.recommendedNextStep,
      'OPEN_DASHBOARD',
    );
    expect(cubit.state.shouldOpenDashboard, isTrue);

    await cubit.close();
  });
}

AuthCubit _authCubit(CurrentUser user) {
  return _authCubitWithRepository(_FakeMeRepository(user));
}

AuthCubit _authCubitWithRepository(MeRepository repository) {
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
    getCurrentUser: GetCurrentUser(repository),
    authSessionController: sessionController,
  );
}

class _FakeMeRepository implements MeRepository {
  const _FakeMeRepository(this.user);

  final CurrentUser user;

  @override
  Future<Either<Failure, CurrentUser>> getMe() async => Right(user);
}

class _QueuedMeRepository implements MeRepository {
  _QueuedMeRepository(this.users);

  final List<CurrentUser> users;
  int getMeCalls = 0;

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    final index = getMeCalls < users.length ? getMeCalls : users.length - 1;
    getMeCalls += 1;
    return Right(users[index]);
  }
}

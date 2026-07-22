import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/app/router/route_names.dart';
import 'package:tavrix_menu_mobile/core/auth/auth_session_controller.dart';
import 'package:tavrix_menu_mobile/core/auth/clerk_token_provider.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/copy/pilot_arabic_copy.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/repositories/me_repository.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/pages/login_screen.dart';

void main() {
  testWidgets(
    'initial auth screen shows separate actions without mixed forms',
    (tester) async {
      final authClient = _FakeOwnerAuthClient();
      final authCubit = _authCubit(_FakeMeRepository(_noBusinessOwner));

      await tester.pumpWidget(
        _ownerAuthWidget(authClient: authClient, authCubit: authCubit),
      );

      expect(
        find.text(PilotArabicCopy.signInExistingWorkspace),
        findsOneWidget,
      );
      expect(
        find.text(PilotArabicCopy.createBusinessWorkspace),
        findsOneWidget,
      );
      expect(find.text(PilotArabicCopy.contactLabel), findsNothing);
      expect(find.text(PilotArabicCopy.verificationCode), findsNothing);
      expect(find.text(PilotArabicCopy.signInHeader), findsNothing);
      expect(find.text(PilotArabicCopy.signUpHeader), findsNothing);

      await authCubit.close();
    },
  );

  testWidgets('sign-in form is separate from create workspace form', (
    tester,
  ) async {
    final authClient = _FakeOwnerAuthClient();
    final authCubit = _authCubit(_FakeMeRepository(_noBusinessOwner));

    await tester.pumpWidget(
      _ownerAuthWidget(authClient: authClient, authCubit: authCubit),
    );

    await tester.tap(find.text(PilotArabicCopy.signInExistingWorkspace));
    await tester.pumpAndSettle();

    expect(find.text(PilotArabicCopy.signInHeader), findsOneWidget);
    expect(find.text(PilotArabicCopy.signUpHeader), findsNothing);
    expect(find.text(PilotArabicCopy.contactLabel), findsOneWidget);
    expect(find.text(PilotArabicCopy.continueLabel), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text(PilotArabicCopy.createBusinessWorkspace));
    await tester.pumpAndSettle();

    expect(find.text(PilotArabicCopy.signUpHeader), findsOneWidget);
    expect(find.text(PilotArabicCopy.signInHeader), findsNothing);
    expect(find.text(PilotArabicCopy.contactLabel), findsOneWidget);
    expect(find.text(PilotArabicCopy.continueLabel), findsOneWidget);

    await authCubit.close();
  });

  testWidgets('unknown sign-in account shows friendly copy only', (
    tester,
  ) async {
    final authClient = _FakeOwnerAuthClient(
      signInStartError: const clerk.ClerkError(
        code: clerk.ClerkErrorCode.serverErrorResponse,
        message: '{arg} (ERROR RECEIVED FROM SERVER)',
        argument: "Couldn't find your account.",
      ),
    );
    final authCubit = _authCubit(_FakeMeRepository(_noBusinessOwner));

    await tester.pumpWidget(
      _ownerAuthWidget(authClient: authClient, authCubit: authCubit),
    );

    await tester.tap(find.text(PilotArabicCopy.signInExistingWorkspace));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'owner@example.test');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text(PilotArabicCopy.accountNotFoundTitle), findsOneWidget);
    expect(find.text(PilotArabicCopy.accountNotFoundBody), findsOneWidget);
    expect(find.textContaining('ERROR_RECEIVED_FROM_SERVER'), findsNothing);
    expect(find.textContaining('ERROR RECEIVED FROM SERVER'), findsNothing);
    expect(find.textContaining("Couldn't find your account"), findsNothing);

    await authCubit.close();
  });

  testWidgets('owner sign-up requests Clerk sign-up before verification', (
    tester,
  ) async {
    final authClient = _FakeOwnerAuthClient();
    final authCubit = _authCubit(_FakeMeRepository(_noBusinessOwner));

    await tester.pumpWidget(
      _ownerAuthWidget(authClient: authClient, authCubit: authCubit),
    );

    await tester.tap(find.text(PilotArabicCopy.createBusinessWorkspace));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'owner@example.test');
    await tester.ensureVisible(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(authClient.ownerSignUpStartCalls, 1);
    expect(authClient.signInStartCalls, 0);
    expect(find.text(PilotArabicCopy.verificationCode), findsOneWidget);
    expect(
      find.textContaining(RegExp('customer signup', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(
        RegExp('staff signup|staff invite', caseSensitive: false),
      ),
      findsNothing,
    );

    await authCubit.close();
  });

  testWidgets('successful owner sign-up calls me and routes to setup', (
    tester,
  ) async {
    final authClient = _FakeOwnerAuthClient(signUpCompletesSession: true);
    final meRepository = _FakeMeRepository(_noBusinessOwner);
    final authCubit = _authCubit(meRepository);

    await tester.pumpWidget(
      _loginWidget(authClient: authClient, authCubit: authCubit),
    );

    await tester.tap(find.text(PilotArabicCopy.createBusinessWorkspace));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'owner@example.test');
    await tester.ensureVisible(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.ensureVisible(find.text(PilotArabicCopy.verifyAndCreate));
    await tester.pumpAndSettle();
    await tester.tap(find.text(PilotArabicCopy.verifyAndCreate));
    await tester.pumpAndSettle();

    expect(authClient.ownerSignUpVerifyCalls, 1);
    expect(meRepository.getMeCalls, 1);
    expect(authCubit.state.shouldOpenDashboard, isFalse);
    expect(find.text('Business Setup route'), findsOneWidget);
    expect(find.text(PilotArabicCopy.passwordlessSetupTitle), findsNothing);
    expect(
      find.textContaining(PilotArabicCopy.passwordRequiredStep),
      findsNothing,
    );

    await authCubit.close();
  });

  testWidgets('passwordless owner sign-up does not require a password step', (
    tester,
  ) async {
    final authClient = _FakeOwnerAuthClient(signUpCompletesSession: true);
    final meRepository = _FakeMeRepository(_noBusinessOwner);
    final authCubit = _authCubit(meRepository);

    await tester.pumpWidget(
      _loginWidget(authClient: authClient, authCubit: authCubit),
    );

    await tester.tap(find.text(PilotArabicCopy.createBusinessWorkspace));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'owner@example.test');
    await tester.ensureVisible(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.ensureVisible(find.text(PilotArabicCopy.verifyAndCreate));
    await tester.pumpAndSettle();
    await tester.tap(find.text(PilotArabicCopy.verifyAndCreate));
    await tester.pumpAndSettle();

    expect(authClient.ownerSignUpVerifyCalls, 1);
    expect(meRepository.getMeCalls, 1);
    expect(find.text('Business Setup route'), findsOneWidget);
    expect(find.textContaining('password'), findsNothing);

    await authCubit.close();
  });

  testWidgets(
    'incomplete signup verification shows actionable sanitized step',
    (tester) async {
      final authClient = _FakeOwnerAuthClient(
        signUpCompletesSession: false,
        signUpRequiredStep: 'تحقق من رقم الهاتف',
      );
      final meRepository = _FakeMeRepository(_noBusinessOwner);
      final authCubit = _authCubit(meRepository);

      await tester.pumpWidget(
        _loginWidget(authClient: authClient, authCubit: authCubit),
      );

      await tester.tap(find.text(PilotArabicCopy.createBusinessWorkspace));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'owner@example.test',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.tap(find.text(PilotArabicCopy.verifyAndCreate));
      await tester.pumpAndSettle();

      expect(
        find.text(PilotArabicCopy.needsMoreVerificationTitle),
        findsOneWidget,
      );
      expect(
        find.text(PilotArabicCopy.needsMoreVerificationBody),
        findsOneWidget,
      );
      expect(find.text('تحقق من رقم الهاتف'), findsNothing);
      expect(meRepository.getMeCalls, 0);
      expect(find.textContaining('missing_requirements'), findsNothing);

      await authCubit.close();
    },
  );

  testWidgets(
    'password-required signup state shows setup copy without raw enum',
    (tester) async {
      final authClient = _FakeOwnerAuthClient(signUpRequiresPassword: true);
      final meRepository = _FakeMeRepository(_noBusinessOwner);
      final authCubit = _authCubit(meRepository);

      await tester.pumpWidget(
        _loginWidget(authClient: authClient, authCubit: authCubit),
      );

      await tester.tap(find.text(PilotArabicCopy.createBusinessWorkspace));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'owner@example.test',
      );
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.tap(find.text(PilotArabicCopy.verifyAndCreate));
      await tester.pumpAndSettle();

      expect(find.text(PilotArabicCopy.passwordlessSetupTitle), findsOneWidget);
      expect(find.text(PilotArabicCopy.passwordlessSetupBody), findsOneWidget);
      expect(
        find.text(PilotArabicCopy.needsMoreVerificationTitle),
        findsNothing,
      );
      expect(find.textContaining('missing_requirements'), findsNothing);
      expect(meRepository.getMeCalls, 0);

      await authCubit.close();
    },
  );
}

Widget _ownerAuthWidget({
  required OwnerAuthClient authClient,
  required AuthCubit authCubit,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: OwnerAuthForm(config: _config, authClient: authClient),
        ),
      ),
    ),
  );
}

Widget _loginWidget({
  required OwnerAuthClient authClient,
  required AuthCubit authCubit,
}) {
  return MaterialApp(
    home: BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: LoginScreen(
        config: _config,
        clerkPanelBuilder: (_, _) =>
            OwnerAuthForm(config: _config, authClient: authClient),
      ),
    ),
    routes: {
      AppRouteNames.businessSetup: (_) =>
          const Scaffold(body: Center(child: Text('Business Setup route'))),
      AppRouteNames.dashboard: (_) =>
          const Scaffold(body: Center(child: Text('Dashboard route'))),
    },
  );
}

AuthCubit _authCubit(MeRepository repository) {
  final sessionController = AuthSessionController(
    config: _config,
    clerkTokenProvider: ClerkTokenProvider(),
    devTokenProvider: const DevTokenProvider(''),
  );

  return AuthCubit(
    getCurrentUser: GetCurrentUser(repository),
    authSessionController: sessionController,
  );
}

const _config = AppConfig(
  apiBaseUrl: 'https://api.example.test',
  customerWebBaseUrl: 'https://menu.example.test',
  devAuthToken: '',
  appEnv: 'development',
  enableDevAuth: false,
  clerkPublishableKey: 'pk_test_example',
);

const _noBusinessOwner = CurrentUser(
  id: 'usr_owner',
  email: 'owner@example.test',
  fullName: 'New Owner',
  role: 'OWNER',
  onboarding: CurrentUserOnboarding(
    hasBusiness: false,
    activeBusinessCount: 0,
    recommendedNextStep: 'CREATE_BUSINESS',
  ),
);

class _FakeMeRepository implements MeRepository {
  _FakeMeRepository(this.user);

  final CurrentUser user;
  int getMeCalls = 0;

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    getMeCalls += 1;
    return Right(user);
  }
}

class _FakeOwnerAuthClient implements OwnerAuthClient {
  _FakeOwnerAuthClient({
    this.signInStartError,
    this.signUpCompletesSession = false,
    this.signUpRequiredStep = 'Complete the required verification step',
    this.signUpRequiresPassword = false,
  });

  final Object? signInStartError;
  final bool signUpCompletesSession;
  final String signUpRequiredStep;
  final bool signUpRequiresPassword;
  bool _isSignedIn = false;
  int signInStartCalls = 0;
  int ownerSignUpStartCalls = 0;
  int ownerSignUpVerifyCalls = 0;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  Future<void> requestSignInCode({
    required clerk.Strategy strategy,
    required String identifier,
  }) async {
    signInStartCalls += 1;
    final error = signInStartError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<OwnerAuthCompletion> verifySignInCode({
    required clerk.Strategy strategy,
    required String code,
  }) async {
    _isSignedIn = true;
    return const OwnerAuthCompletion.complete();
  }

  @override
  Future<void> requestOwnerSignUpCode({
    required clerk.Strategy strategy,
    required String identifier,
  }) async {
    ownerSignUpStartCalls += 1;
  }

  @override
  Future<OwnerAuthCompletion> verifyOwnerSignUpCode({
    required clerk.Strategy strategy,
    required String code,
  }) async {
    ownerSignUpVerifyCalls += 1;
    _isSignedIn = signUpCompletesSession;
    if (signUpRequiresPassword) {
      return const OwnerAuthCompletion.passwordRequired();
    }
    return _isSignedIn
        ? const OwnerAuthCompletion.complete()
        : OwnerAuthCompletion.incomplete(signUpRequiredStep);
  }
}

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
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/pages/login_screen.dart';

void main() {
  testWidgets('QA-ready config shows operator sign-in form', (tester) async {
    final config = _qaReadyConfig();
    final cubit = _authCubit(config);
    await tester.pumpWidget(
      _loginWidget(
        cubit: cubit,
        config: config,
        clerkPanelBuilder: (_, _) =>
            const Text('Sign in to Waflo', key: ValueKey('qaSignInForm')),
      ),
    );

    expect(find.text(PilotArabicCopy.testAccess), findsNothing);
    expect(find.byKey(const ValueKey('qaSignInForm')), findsOneWidget);
    expect(find.text('Debug QA context'), findsNothing);
    expect(
      find.textContaining('Operator sign-in is not available'),
      findsNothing,
    );

    await cubit.close();
  });

  testWidgets('missing config shows debug key names only', (tester) async {
    final config = _missingConfig();
    final cubit = _authCubit(config);
    await tester.pumpWidget(_loginWidget(cubit: cubit, config: config));

    expect(find.text(PilotArabicCopy.appConfigNeedsAttention), findsOneWidget);
    expect(find.textContaining('API_BASE_URL'), findsWidgets);
    expect(find.textContaining('CLERK_PUBLISHABLE_KEY'), findsWidgets);
    expect(find.textContaining('CUSTOMER_WEB_BASE_URL'), findsWidgets);
    expect(find.textContaining('https://api.example.test'), findsNothing);
    expect(find.textContaining('pk_test'), findsNothing);
    expect(
      find.textContaining('Operator sign-in is not available'),
      findsNothing,
    );

    await cubit.close();
  });

  testWidgets('development config shows test access when enabled', (
    tester,
  ) async {
    final config = _developmentConfig();
    final cubit = _authCubit(config);
    await tester.pumpWidget(_loginWidget(cubit: cubit, config: config));

    expect(find.text(PilotArabicCopy.testAccess), findsOneWidget);

    await cubit.close();
  });

  testWidgets('restoring session uses Arabic pilot copy', (tester) async {
    final config = _qaReadyConfig();
    final cubit = _RestoringAuthCubit(config);
    await tester.pumpWidget(_loginWidget(cubit: cubit, config: config));
    await tester.pump();

    expect(find.text(PilotArabicCopy.restoringSession), findsOneWidget);

    await cubit.close();
  });

  testWidgets('Google sign-in stays hidden until native config is verified', (
    tester,
  ) async {
    final config = _googleConfigBlocked();
    final cubit = _authCubit(config);
    await tester.pumpWidget(
      _loginWidget(
        cubit: cubit,
        config: config,
        clerkPanelBuilder: (_, _) =>
            const Text('Sign in to Waflo', key: ValueKey('qaSignInForm')),
      ),
    );

    expect(config.hasGoogleNativeClientConfig, isTrue);
    expect(
      find.textContaining(RegExp('google', caseSensitive: false)),
      findsNothing,
    );

    await cubit.close();
  });
}

Widget _loginWidget({
  required AuthCubit cubit,
  required AppConfig config,
  ClerkSignInPanelBuilder? clerkPanelBuilder,
}) {
  return MaterialApp(
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: LoginScreen(config: config, clerkPanelBuilder: clerkPanelBuilder),
    ),
    routes: {
      AppRouteNames.businessSetup: (_) =>
          const Scaffold(body: Text('Business setup route')),
      AppRouteNames.dashboard: (_) => const Scaffold(body: Text('Dashboard')),
    },
  );
}

AuthCubit _authCubit(
  AppConfig config, {
  ClerkTokenProvider? clerkTokenProvider,
}) {
  final sessionController = AuthSessionController(
    config: config,
    clerkTokenProvider: clerkTokenProvider ?? ClerkTokenProvider(),
    devTokenProvider: DevTokenProvider(config.devAuthToken),
  );

  return AuthCubit(
    getCurrentUser: const GetCurrentUser(_FakeMeRepository()),
    authSessionController: sessionController,
  );
}

class _RestoringAuthCubit extends AuthCubit {
  _RestoringAuthCubit(AppConfig config)
    : super(
        getCurrentUser: const GetCurrentUser(_FakeMeRepository()),
        authSessionController: AuthSessionController(
          config: config,
          clerkTokenProvider: ClerkTokenProvider(),
          devTokenProvider: DevTokenProvider(config.devAuthToken),
        ),
      ) {
    emit(const AuthState(status: AuthStatus.restoring));
  }
}

AppConfig _qaReadyConfig() {
  return const AppConfig(
    apiBaseUrl: 'https://api.example.test',
    customerWebBaseUrl: 'https://menu.example.test',
    devAuthToken: 'dev:user',
    appEnv: 'production',
    enableDevAuth: true,
    clerkPublishableKey: 'pk_test_configured',
  );
}

AppConfig _missingConfig() {
  return const AppConfig(
    apiBaseUrl: '',
    customerWebBaseUrl: '',
    devAuthToken: '',
    appEnv: 'development',
    enableDevAuth: false,
    clerkPublishableKey: '',
  );
}

AppConfig _developmentConfig() {
  return const AppConfig(
    apiBaseUrl: '',
    customerWebBaseUrl: 'https://menu.example.test',
    devAuthToken: 'dev:user',
    appEnv: 'development',
    enableDevAuth: true,
    clerkPublishableKey: '',
  );
}

AppConfig _googleConfigBlocked() {
  return const AppConfig(
    apiBaseUrl: 'https://api.example.test',
    customerWebBaseUrl: 'https://menu.example.test',
    devAuthToken: '',
    appEnv: 'production',
    enableDevAuth: false,
    clerkPublishableKey: 'pk_test_configured',
    googleClientId: 'google-client-placeholder',
    googleServerClientId: 'google-server-placeholder',
  );
}

class _FakeMeRepository implements MeRepository {
  const _FakeMeRepository();

  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    return const Right(
      CurrentUser(
        id: 'usr_owner',
        email: 'owner@tavrix.local',
        fullName: 'Tavrix Owner',
        role: 'OWNER',
      ),
    );
  }
}

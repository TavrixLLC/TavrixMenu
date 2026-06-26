import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    expect(find.text('Continue in dev mode'), findsNothing);
    expect(find.byKey(const ValueKey('qaSignInForm')), findsOneWidget);
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

    expect(find.text('Debug configuration missing'), findsOneWidget);
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

  testWidgets('development config shows dev mode when enabled', (tester) async {
    final config = _developmentConfig();
    final cubit = _authCubit(config);
    await tester.pumpWidget(_loginWidget(cubit: cubit, config: config));

    expect(find.text('Continue in dev mode'), findsOneWidget);

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
  );
}

AuthCubit _authCubit(AppConfig config) {
  final sessionController = AuthSessionController(
    config: config,
    clerkTokenProvider: ClerkTokenProvider(),
    devTokenProvider: DevTokenProvider(config.devAuthToken),
  );

  return AuthCubit(
    getCurrentUser: const GetCurrentUser(_FakeMeRepository()),
    authSessionController: sessionController,
  );
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

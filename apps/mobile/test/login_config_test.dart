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
  testWidgets('production config hides dev mode', (tester) async {
    final cubit = _authCubit(_productionConfig());
    await tester.pumpWidget(
      _loginWidget(cubit: cubit, config: _productionConfig()),
    );

    expect(find.text('Continue in dev mode'), findsNothing);
    expect(
      find.textContaining('Operator sign-in is not available'),
      findsOneWidget,
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

Widget _loginWidget({required AuthCubit cubit, required AppConfig config}) {
  return MaterialApp(
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: LoginScreen(config: config),
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

AppConfig _productionConfig() {
  return const AppConfig(
    apiBaseUrl: 'https://api.example.test',
    customerWebBaseUrl: 'https://menu.example.test',
    devAuthToken: 'dev:user',
    appEnv: 'production',
    enableDevAuth: true,
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

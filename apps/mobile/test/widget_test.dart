import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/app/app.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/entities/current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/repositories/me_repository.dart';
import 'package:tavrix_menu_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/pages/login_screen.dart';

void main() {
  testWidgets('shows business login and opens dashboard in dev mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TavrixMenuApp());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Tavrix Menu'), findsOneWidget);
    expect(find.text('Business user login'), findsOneWidget);
    expect(
      find.textContaining('Customers browse menus through customer-web'),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue in dev mode'));
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Manage Menu'), findsOneWidget);
  });

  testWidgets('hides dev mode button for production config', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) =>
              AuthCubit(getCurrentUser: GetCurrentUser(_FakeMeRepository())),
          child: const LoginScreen(
            config: AppConfig(
              apiBaseUrl: '',
              clerkPublishableKey: '',
              customerWebBaseUrl: 'https://menu.tavrix.com',
              appEnv: 'production',
              enableDevAuth: false,
              enableDevFallback: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continue in dev mode'), findsNothing);
    expect(
      find.text('Developer sign-in is unavailable for this build.'),
      findsOneWidget,
    );
  });

  testWidgets('edits an existing category without framework assertion', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TavrixMenuApp());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue in dev mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage Menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit category').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save category'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Menu management'), findsOneWidget);
  });
}

class _FakeMeRepository implements MeRepository {
  @override
  Future<Either<Failure, CurrentUser>> getMe() async {
    return const Right(
      CurrentUser(
        id: 'user-id',
        email: 'owner@tavrix.local',
        fullName: 'Tavrix Demo Owner',
        role: 'OWNER',
      ),
    );
  }
}

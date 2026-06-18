import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/entities/wallet_scan_result.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/repositories/wallet_scan_repository.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/usecases/scan_wallet_pass.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/bloc/wallet_scan_cubit.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/pages/staff_scanner_screen.dart';

void main() {
  testWidgets('requires a manual token without calling the backend', (
    tester,
  ) async {
    final repository = _FakeWalletScanRepository(
      (_) async => const Right(_scanResult),
    );
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(_screen(cubit));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('walletScanButton')));
    await tester.pump();

    expect(find.text('Enter a wallet QR token.'), findsOneWidget);
    expect(repository.scanCalls, 0);
  });

  testWidgets('shows an invalid token error and keeps the token for correction', (
    tester,
  ) async {
    final repository = _FakeWalletScanRepository(
      (_) async => const Left(
        ValidationFailure('The wallet QR token is invalid or inactive.'),
      ),
    );
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(_screen(cubit));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('walletScanTokenField')),
      'invalid-token',
    );
    await tester.tap(find.byKey(const ValueKey('walletScanButton')));
    await tester.pumpAndSettle();

    expect(
      find.text('The wallet QR token is invalid or inactive.'),
      findsOneWidget,
    );
    expect(_tokenField(tester).controller?.text, 'invalid-token');
  });

  testWidgets('shows loading then renders customer progress and clears token', (
    tester,
  ) async {
    final completer = Completer<Either<Failure, WalletScanResult>>();
    final repository = _FakeWalletScanRepository((_) => completer.future);
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(_screen(cubit));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('walletScanTokenField')),
      'valid-token',
    );
    await tester.tap(find.byKey(const ValueKey('walletScanButton')));
    await tester.pump();

    expect(find.byKey(const ValueKey('walletScanLoading')), findsOneWidget);
    expect(find.text('Scanning...'), findsOneWidget);

    completer.complete(const Right(_scanResult));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('walletScanResult')), findsOneWidget);
    expect(find.text('Demo Customer'), findsOneWidget);
    expect(find.text('+9647700000000'), findsOneWidget);
    expect(find.text('Tavrix Cafe Stamp Card'), findsOneWidget);
    expect(find.text('3 of 10 stamps'), findsOneWidget);
    expect(find.text('Free coffee is not ready yet.'), findsOneWidget);
    expect(_tokenField(tester).controller?.text, isEmpty);
  });
}

WalletScanCubit _cubit(WalletScanRepository repository) {
  return WalletScanCubit(
    getMyBusiness: GetMyBusiness(_FakeBusinessRepository()),
    scanWalletPass: ScanWalletPass(repository),
  );
}

Widget _screen(WalletScanCubit cubit) {
  return BlocProvider<WalletScanCubit>.value(
    value: cubit,
    child: const MaterialApp(home: StaffScannerScreen()),
  );
}

TextField _tokenField(WidgetTester tester) {
  return tester.widget<TextField>(
    find.byKey(const ValueKey('walletScanTokenField')),
  );
}

const _business = Business(
  id: 'bus_123',
  name: 'Tavrix Cafe',
  slug: 'tavrix-cafe',
  publicMenuUrl: 'https://menu.example.test/m/tavrix-cafe',
);

const _scanResult = WalletScanResult(
  membershipId: 'membership_id',
  customerName: 'Demo Customer',
  customerPhone: '+9647700000000',
  programName: 'Tavrix Cafe Stamp Card',
  rewardName: 'Free coffee',
  stamps: 3,
  goal: 10,
  canRedeem: false,
);

class _FakeWalletScanRepository implements WalletScanRepository {
  _FakeWalletScanRepository(this.response);

  final Future<Either<Failure, WalletScanResult>> Function(String token)
      response;
  int scanCalls = 0;

  @override
  Future<Either<Failure, WalletScanResult>> scan({
    required String businessId,
    required String token,
  }) {
    scanCalls += 1;
    expect(businessId, _business.id);
    return response(token);
  }
}

class _FakeBusinessRepository implements BusinessRepository {
  @override
  Future<Either<Failure, Business>> getMyBusiness() async {
    return const Right(_business);
  }

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
    String? logoUrl,
    String? coverUrl,
  }) {
    throw UnimplementedError();
  }
}

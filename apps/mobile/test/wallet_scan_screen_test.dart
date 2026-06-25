import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/core/network/network_info.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/entities/business.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/repositories/business_repository.dart';
import 'package:tavrix_menu_mobile/features/business_setup/domain/usecases/get_my_business.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_action_result.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_card_state.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_membership.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_requests.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/repositories/loyalty_repository.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/usecases/add_loyalty_stamps.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/data/datasources/wallet_scan_remote_data_source.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/data/repositories/wallet_scan_repository_impl.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/entities/wallet_scan_result.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/repositories/wallet_scan_repository.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/domain/usecases/scan_wallet_pass.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/bloc/wallet_scan_cubit.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/pages/staff_scanner_screen.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/presentation/widgets/wallet_qr_camera_scanner.dart';
import 'package:tavrix_menu_mobile/shared/widgets/app_button.dart';

import 'helpers/stub_http_client_adapter.dart';

void main() {
  testWidgets('scanner screen is labeled as a customer wallet business tool', (
    tester,
  ) async {
    final repository = _FakeWalletScanRepository(
      (_) async => const Right(_scanResult),
    );
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(_screen(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Scan customer wallet'), findsWidgets);
    expect(find.text('Customer wallet scan'), findsOneWidget);
    expect(find.textContaining('Staff scanner'), findsNothing);
    expect(find.textContaining('Staff dashboard'), findsNothing);
  });

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
    await _tapWalletScanButton(tester);
    await tester.pump();

    expect(find.text('Enter a wallet QR token.'), findsOneWidget);
    expect(repository.scanCalls, 0);
  });

  testWidgets(
    'HTTP 400 shows invalid token error and keeps token for correction',
    (tester) async {
      final adapter = StubHttpClientAdapter(
        statusCode: 400,
        data: const {
          'statusCode': 400,
          'message': 'The wallet QR token is invalid or inactive.',
        },
      );
      final repository = WalletScanRepositoryImpl(
        remoteDataSource: WalletScanRemoteDataSourceImpl(
          buildTestApiClient(adapter),
        ),
        networkInfo: const NetworkInfoImpl(),
      );
      final cubit = _cubit(repository);
      addTearDown(cubit.close);

      await tester.pumpWidget(_screen(cubit));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('walletScanTokenField')),
        'invalid-token',
      );
      await _tapWalletScanButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('The wallet QR token is invalid or inactive.'),
        findsOneWidget,
      );
      expect(_tokenField(tester).controller?.text, 'invalid-token');
    },
  );

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
    await _tapWalletScanButton(tester);
    await tester.pump();

    expect(find.byKey(const ValueKey('walletScanLoading')), findsOneWidget);
    expect(find.text('Scanning...'), findsOneWidget);

    completer.complete(const Right(_scanResult));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('walletScanResult')), findsOneWidget);
    expect(find.text('Demo Customer'), findsOneWidget);
    expect(find.text('Phone ending 000'), findsOneWidget);
    expect(find.text('+9647700000000'), findsNothing);
    expect(find.text('Tavrix Cafe Stamp Card'), findsOneWidget);
    expect(find.text('3 of 10 stamps'), findsOneWidget);
    expect(find.text('Free coffee is not ready yet.'), findsOneWidget);
    expect(_tokenField(tester).controller?.text, isEmpty);
  });

  testWidgets('camera permission error hides scan overlays', (tester) async {
    var settingsRequested = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 360,
            child: WalletCameraErrorView(
              errorCode: MobileScannerErrorCode.permissionDenied,
              onOpenSettings: () => settingsRequested = true,
              onRetry: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('walletCameraErrorState')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('walletCameraPermissionDenied')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('walletCameraScanFrameOverlay')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('walletCameraSecureScanBadge')),
      findsNothing,
    );
    expect(find.textContaining('camera-test-token'), findsNothing);

    await tester.tap(find.text('Open settings'));
    await tester.pump();
    expect(settingsRequested, isTrue);
    expect(find.text('Try camera again'), findsNothing);
  });

  testWidgets('active camera overlay contains frame and secure badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 360,
            child: WalletCameraActiveOverlay(),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('walletCameraScanFrameOverlay')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('walletCameraSecureScanBadge')),
      findsOneWidget,
    );
  });

  testWidgets(
    'camera result uses existing submit path and ignores duplicate events',
    (tester) async {
      final completer = Completer<Either<Failure, WalletScanResult>>();
      final repository = _FakeWalletScanRepository((_) => completer.future);
      final cubit = _cubit(repository);
      addTearDown(cubit.close);
      ValueChanged<String>? detect;

      await tester.pumpWidget(
        _screen(
          cubit,
          cameraScannerBuilder: (onDetect, onCancel) {
            detect = onDetect;
            return _FakeCameraScanner(onDetect: onDetect, onCancel: onCancel);
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('walletOpenCameraButton')));
      await tester.pump();

      detect?.call('camera-test-token');
      detect?.call('camera-test-token');
      await tester.pump();

      expect(repository.scanCalls, 1);
      expect(repository.receivedTokens, ['camera-test-token']);
      expect(find.byKey(const ValueKey('walletScanLoading')), findsOneWidget);
      expect(find.text('camera-test-token'), findsNothing);

      completer.complete(const Right(_scanResult));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('walletScanResult')), findsOneWidget);
      expect(find.byKey(const ValueKey('walletCameraRetryCard')), findsNothing);
      expect(find.text('camera-test-token'), findsNothing);

      final scanAnotherButton = find.byKey(
        const ValueKey('walletScanAnotherButton'),
      );
      tester.widget<AppButton>(scanAnotherButton).onPressed?.call();
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('fakeWalletCamera')), findsOneWidget);
      expect(find.byKey(const ValueKey('walletScanResult')), findsNothing);
      expect(repository.scanCalls, 1);
    },
  );

  testWidgets(
    'camera failure redacts token and allows retry through existing path',
    (tester) async {
      var attempt = 0;
      final repository = _FakeWalletScanRepository((token) async {
        attempt += 1;
        if (attempt == 1) {
          return Left(ValidationFailure('Invalid wallet code: $token'));
        }
        return const Right(_scanResult);
      });
      final cubit = _cubit(repository);
      addTearDown(cubit.close);
      ValueChanged<String>? detect;

      await tester.pumpWidget(
        _screen(
          cubit,
          cameraScannerBuilder: (onDetect, onCancel) {
            detect = onDetect;
            return _FakeCameraScanner(onDetect: onDetect, onCancel: onCancel);
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('walletOpenCameraButton')));
      await tester.pump();
      detect?.call('camera-sensitive-token');
      await tester.pumpAndSettle();

      expect(repository.scanCalls, 1);
      expect(find.textContaining('camera-sensitive-token'), findsNothing);
      expect(find.text('Invalid wallet code: [redacted]'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('walletCameraRetryCard')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('walletCameraRetryButton')));
      await tester.pumpAndSettle();

      expect(repository.scanCalls, 2);
      expect(repository.receivedTokens, [
        'camera-sensitive-token',
        'camera-sensitive-token',
      ]);
      expect(find.byKey(const ValueKey('walletScanResult')), findsOneWidget);
      expect(find.textContaining('camera-sensitive-token'), findsNothing);
    },
  );

  testWidgets('camera failure allows an intentional rescan', (tester) async {
    final repository = _FakeWalletScanRepository(
      (_) async => const Left(ValidationFailure('Invalid wallet code.')),
    );
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    ValueChanged<String>? detect;

    await tester.pumpWidget(
      _screen(
        cubit,
        cameraScannerBuilder: (onDetect, onCancel) {
          detect = onDetect;
          return _FakeCameraScanner(onDetect: onDetect, onCancel: onCancel);
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('walletOpenCameraButton')));
    await tester.pump();
    detect?.call('camera-retry-token');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('walletCameraRescanButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fakeWalletCamera')), findsOneWidget);
    expect(find.byKey(const ValueKey('walletCameraRetryCard')), findsNothing);
    expect(repository.scanCalls, 1);
  });

  testWidgets('manual retry after camera failure redacts the manual token', (
    tester,
  ) async {
    final repository = _FakeWalletScanRepository(
      (token) async => Left(ValidationFailure('Invalid wallet code: $token')),
    );
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    ValueChanged<String>? detect;

    await tester.pumpWidget(
      _screen(
        cubit,
        cameraScannerBuilder: (onDetect, onCancel) {
          detect = onDetect;
          return _FakeCameraScanner(onDetect: onDetect, onCancel: onCancel);
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('walletOpenCameraButton')));
    await tester.pump();
    detect?.call('camera-sensitive-token');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('walletScanTokenField')),
      'manual-sensitive-token',
    );
    await _tapWalletScanButton(tester);
    await tester.pumpAndSettle();

    expect(repository.receivedTokens, [
      'camera-sensitive-token',
      'manual-sensitive-token',
    ]);
    expect(find.textContaining('camera-sensitive-token'), findsNothing);
    expect(find.text('Invalid wallet code: [redacted]'), findsOneWidget);
    expect(find.byKey(const ValueKey('walletCameraRetryCard')), findsNothing);
  });

  testWidgets('manual fallback remains available beside camera scan', (
    tester,
  ) async {
    final repository = _FakeWalletScanRepository(
      (_) async => const Right(_scanResult),
    );
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _screen(
        cubit,
        cameraScannerBuilder: (onDetect, onCancel) =>
            _FakeCameraScanner(onDetect: onDetect, onCancel: onCancel),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('walletOpenCameraButton')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('walletScanTokenField')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('walletScanTokenField')),
      'manual-fallback-token',
    );
    await _tapWalletScanButton(tester);
    await tester.pumpAndSettle();

    expect(repository.receivedTokens, ['manual-fallback-token']);
    expect(_tokenField(tester).controller?.text, isEmpty);
  });

  // ── Add-stamp tests ──────────────────────────────────────────────────────

  testWidgets(
    'addStamp success updates stamp count and shows confirmation banner',
    (tester) async {
      final scanRepo = _FakeWalletScanRepository(
        (_) async => const Right(_scanResult),
      );
      final stampRepo = _FakeLoyaltyRepository(
        (_) async => Right(
          LoyaltyActionResult(
            membership: const LoyaltyMembership(
              id: 'membership_id',
              stampCount: 4,
            ),
            cardState: const LoyaltyCardState(
              stampCount: 4,
              stampGoal: 10,
              rewardReady: false,
              progressPercent: 40,
              rewardName: 'Free coffee',
              programName: 'Tavrix Cafe Stamp Card',
            ),
          ),
        ),
      );
      final cubit = _cubitWithStamp(scanRepo, stampRepo);
      addTearDown(cubit.close);

      await tester.pumpWidget(_screen(cubit));
      await tester.pumpAndSettle();

      // Scan to get result
      await tester.enterText(
        find.byKey(const ValueKey('walletScanTokenField')),
        'valid-token',
      );
      await _tapWalletScanButton(tester);
      await tester.pumpAndSettle();

      expect(find.text('3 of 10 stamps'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('walletAddStampButton')),
        findsOneWidget,
      );

      // Add stamp — scroll into view first (scrollable screen)
      await tester.ensureVisible(
        find.byKey(const ValueKey('walletAddStampButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('walletAddStampButton')));
      await tester.pumpAndSettle();

      expect(stampRepo.addStampsCalls, 1);
      expect(
        find.byKey(const ValueKey('walletStampSuccessBanner')),
        findsOneWidget,
      );
      expect(find.text('Stamp added successfully.'), findsOneWidget);
      // Progress bar and count should update to 4/10
      expect(find.text('4 of 10 stamps'), findsOneWidget);
      // Button disabled after success
      final btn = tester.widget<AppButton>(
        find.byKey(const ValueKey('walletAddStampButton')),
      );
      expect(btn.onPressed, isNull);
    },
  );

  testWidgets('addStamp prevents duplicate tap', (tester) async {
    final completer = Completer<Either<Failure, LoyaltyActionResult>>();
    final scanRepo = _FakeWalletScanRepository(
      (_) async => const Right(_scanResult),
    );
    final stampRepo = _FakeLoyaltyRepository((_) => completer.future);
    final cubit = _cubitWithStamp(scanRepo, stampRepo);
    addTearDown(cubit.close);

    await tester.pumpWidget(_screen(cubit));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('walletScanTokenField')),
      'valid-token',
    );
    await _tapWalletScanButton(tester);
    await tester.pumpAndSettle();

    // First tap — scroll into view first
    await tester.ensureVisible(
      find.byKey(const ValueKey('walletAddStampButton')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('walletAddStampButton')));
    await tester.pump();

    expect(find.byKey(const ValueKey('walletAddStampLoading')), findsOneWidget);
    expect(find.text('Adding stamp...'), findsOneWidget);

    // Second tap while loading — button is disabled so tap does nothing
    await tester.tap(
      find.byKey(const ValueKey('walletAddStampButton')),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(stampRepo.addStampsCalls, 1);

    completer.complete(
      Right(
        LoyaltyActionResult(
          membership: const LoyaltyMembership(
            id: 'membership_id',
            stampCount: 4,
          ),
          cardState: const LoyaltyCardState(
            stampCount: 4,
            stampGoal: 10,
            rewardReady: false,
            progressPercent: 40,
            rewardName: 'Free coffee',
            programName: 'Tavrix Cafe Stamp Card',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(stampRepo.addStampsCalls, 1);
  });

  testWidgets('addStamp shows error on server failure', (tester) async {
    final scanRepo = _FakeWalletScanRepository(
      (_) async => const Right(_scanResult),
    );
    final stampRepo = _FakeLoyaltyRepository(
      (_) async => const Left(ServerFailure()),
    );
    final cubit = _cubitWithStamp(scanRepo, stampRepo);
    addTearDown(cubit.close);

    await tester.pumpWidget(_screen(cubit));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('walletScanTokenField')),
      'valid-token',
    );
    await _tapWalletScanButton(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('walletAddStampButton')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('walletAddStampButton')));
    await tester.pumpAndSettle();

    expect(
      find.text('The server could not complete this request.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('walletStampSuccessBanner')),
      findsNothing,
    );
    // Button should be re-enabled after error so staff can retry
    final btn = tester.widget<AppButton>(
      find.byKey(const ValueKey('walletAddStampButton')),
    );
    expect(btn.onPressed, isNotNull);
  });

  testWidgets('addStamp shows conflict error on 409 (already rewarded)', (
    tester,
  ) async {
    final scanRepo = _FakeWalletScanRepository(
      (_) async => const Right(_scanResult),
    );
    final stampRepo = _FakeLoyaltyRepository(
      (_) async => const Left(
        ConflictFailure('Membership has already received maximum stamps.'),
      ),
    );
    final cubit = _cubitWithStamp(scanRepo, stampRepo);
    addTearDown(cubit.close);

    await tester.pumpWidget(_screen(cubit));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('walletScanTokenField')),
      'valid-token',
    );
    await _tapWalletScanButton(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('walletAddStampButton')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('walletAddStampButton')));
    await tester.pumpAndSettle();

    expect(
      find.text('Membership has already received maximum stamps.'),
      findsOneWidget,
    );
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

WalletScanCubit _cubit(WalletScanRepository repository) {
  return WalletScanCubit(
    getMyBusiness: GetMyBusiness(_FakeBusinessRepository()),
    scanWalletPass: ScanWalletPass(repository),
    addLoyaltyStamps: AddLoyaltyStamps(
      _FakeLoyaltyRepository((_) async => const Left(ServerFailure())),
    ),
  );
}

WalletScanCubit _cubitWithStamp(
  WalletScanRepository scanRepository,
  LoyaltyRepository loyaltyRepository,
) {
  return WalletScanCubit(
    getMyBusiness: GetMyBusiness(_FakeBusinessRepository()),
    scanWalletPass: ScanWalletPass(scanRepository),
    addLoyaltyStamps: AddLoyaltyStamps(loyaltyRepository),
  );
}

Widget _screen(
  WalletScanCubit cubit, {
  WalletCameraScannerBuilder? cameraScannerBuilder,
}) {
  return BlocProvider<WalletScanCubit>.value(
    value: cubit,
    child: MaterialApp(
      home: StaffScannerScreen(cameraScannerBuilder: cameraScannerBuilder),
    ),
  );
}

TextField _tokenField(WidgetTester tester) {
  return tester.widget<TextField>(
    find.byKey(const ValueKey('walletScanTokenField')),
  );
}

Future<void> _tapWalletScanButton(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('walletScanButton'));
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
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
  final List<String> receivedTokens = [];

  @override
  Future<Either<Failure, WalletScanResult>> scan({
    required String businessId,
    required String token,
  }) {
    scanCalls += 1;
    receivedTokens.add(token);
    expect(businessId, _business.id);
    return response(token);
  }
}

class _FakeLoyaltyRepository implements LoyaltyRepository {
  _FakeLoyaltyRepository(this.addStampsResponse);

  final Future<Either<Failure, LoyaltyActionResult>> Function(
    String membershipId,
  )
  addStampsResponse;
  int addStampsCalls = 0;

  @override
  Future<Either<Failure, LoyaltyActionResult>> addStamps({
    required String businessId,
    required String membershipId,
    required AddStampsRequest request,
  }) {
    addStampsCalls += 1;
    expect(businessId, _business.id);
    expect(membershipId, _scanResult.membershipId);
    return addStampsResponse(membershipId);
  }

  // Unimplemented stubs — not needed for scanner tests
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '${invocation.memberName} not implemented in _FakeLoyaltyRepository',
  );
}

class _FakeCameraScanner extends StatelessWidget {
  const _FakeCameraScanner({required this.onDetect, required this.onCancel});

  final ValueChanged<String> onDetect;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('fakeWalletCamera'),
      children: [
        ElevatedButton(
          key: const ValueKey('fakeWalletCameraDetect'),
          onPressed: () => onDetect('camera-test-token'),
          child: const Text('Detect'),
        ),
        ElevatedButton(
          key: const ValueKey('fakeWalletCameraCancel'),
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
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

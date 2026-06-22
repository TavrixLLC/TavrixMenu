import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/core/network/network_info.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/data/datasources/wallet_scan_remote_data_source.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/data/repositories/wallet_scan_repository_impl.dart';

import 'helpers/stub_http_client_adapter.dart';

void main() {
  test(
    'wallet scan posts the trimmed token and parses safe result data',
    () async {
      final adapter = StubHttpClientAdapter(
        statusCode: 200,
        data: _walletScanResponse,
      );
      final apiClient = buildTestApiClient(adapter);
      final dataSource = WalletScanRemoteDataSourceImpl(apiClient);

      final result = await dataSource.scan(
        businessId: 'bus_123',
        token: '  test-wallet-token  ',
      );

      expect(
        adapter.lastRequest?.path,
        '/businesses/bus_123/loyalty/wallet-scan',
      );
      expect(adapter.lastRequest?.method, 'POST');
      expect(adapter.lastRequest?.data, {'token': 'test-wallet-token'});
      expect(
        adapter.lastRequest?.headers['Authorization'],
        'Bearer test-session-token',
      );
      expect(result.customerName, 'Demo Customer');
      expect(result.customerPhone, '+9647700000000');
      expect(result.programName, 'Tavrix Cafe Stamp Card');
      expect(result.stamps, 3);
      expect(result.goal, 10);
      expect(result.progressPercent, 30);
      expect(result.canRedeem, isFalse);
    },
  );

  test('wallet scan HTTP 400 maps to validation failure', () async {
    final failure = await _scanFailure(400, const {
      'statusCode': 400,
      'message': 'The wallet QR token is invalid or inactive.',
    });

    expect(
      failure,
      const ValidationFailure('The wallet QR token is invalid or inactive.'),
    );
  });

  test('wallet scan HTTP 401 maps to unauthorized failure', () async {
    final failure = await _scanFailure(401, const {
      'statusCode': 401,
      'message': 'Authentication required.',
    });

    expect(failure, isA<UnauthorizedFailure>());
  });

  test('wallet scan HTTP 403 maps to forbidden failure', () async {
    final failure = await _scanFailure(403, const {
      'statusCode': 403,
      'message': 'Business access denied.',
    });

    expect(failure, isA<ForbiddenFailure>());
  });

  test('wallet scan HTTP 500 remains a server failure', () async {
    final failure = await _scanFailure(500, const {
      'statusCode': 500,
      'message': 'Unexpected server error.',
    });

    expect(failure, isA<ServerFailure>());
  });
}

Future<Failure> _scanFailure(
  int statusCode,
  Map<String, dynamic> response,
) async {
  final adapter = StubHttpClientAdapter(statusCode: statusCode, data: response);
  final repository = WalletScanRepositoryImpl(
    remoteDataSource: WalletScanRemoteDataSourceImpl(
      buildTestApiClient(adapter),
    ),
    networkInfo: const NetworkInfoImpl(),
  );
  final result = await repository.scan(
    businessId: 'bus_123',
    token: 'test-wallet-token',
  );

  return result.fold(
    (failure) => failure,
    (_) => throw StateError('Expected wallet scan to fail.'),
  );
}

const _walletScanResponse = <String, dynamic>{
  'membershipId': 'membership_id',
  'customer': {'name': 'Demo Customer', 'phone': '+9647700000000'},
  'program': {
    'name': 'Tavrix Cafe Stamp Card',
    'stampGoal': 10,
    'rewardName': 'Free coffee',
  },
  'progress': {'stamps': 3, 'goal': 10, 'canRedeem': false},
  'walletPass': {'platform': 'GOOGLE_WALLET', 'status': 'ACTIVE'},
};

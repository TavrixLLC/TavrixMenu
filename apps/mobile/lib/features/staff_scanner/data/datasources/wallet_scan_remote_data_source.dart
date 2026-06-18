import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/wallet_scan_result_model.dart';

abstract class WalletScanRemoteDataSource {
  Future<WalletScanResultModel> scan({
    required String businessId,
    required String token,
  });
}

class WalletScanRemoteDataSourceImpl implements WalletScanRemoteDataSource {
  const WalletScanRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  Future<WalletScanResultModel> scan({
    required String businessId,
    required String token,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/loyalty/wallet-scan',
      body: {'token': token.trim()},
    );
    final json = asJsonObject(data, context: 'wallet scan response');
    return WalletScanResultModel.fromJson(json);
  }
}

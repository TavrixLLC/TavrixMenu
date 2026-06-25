import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  bool get canCallBackend;

  Future<DashboardSummaryModel> getDashboardSummary(String businessId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<DashboardSummaryModel> getDashboardSummary(String businessId) async {
    final data = await apiClient.get(
      '/businesses/$businessId/dashboard-summary',
    );
    return _parseSummary(data);
  }

  DashboardSummaryModel _parseSummary(dynamic data) {
    final json = asJsonObject(data, context: 'dashboard summary response');

    try {
      return DashboardSummaryModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid dashboard summary response.');
    }
  }
}

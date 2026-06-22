import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/current_user_model.dart';

abstract class AuthRemoteDataSource {
  bool get canCallBackend;

  Future<CurrentUserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<CurrentUserModel> getMe() async {
    final data = await apiClient.get('/me');
    return _parseCurrentUser(data);
  }

  CurrentUserModel _parseCurrentUser(dynamic data) {
    final json = asJsonObject(data, context: 'current user response');

    try {
      return CurrentUserModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid current user response.');
    }
  }
}

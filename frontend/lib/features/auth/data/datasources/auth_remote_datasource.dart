import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login(LoginRequestModel request);
  Future<UserModel> register(RegisterRequestModel request);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AuthTokenModel> login(LoginRequestModel request) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      return AuthTokenModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(RegisterRequestModel request) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: request.toJson(),
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.get('/auth/me');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }
}
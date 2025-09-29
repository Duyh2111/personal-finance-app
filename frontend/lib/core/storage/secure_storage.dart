import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  const SecureStorage._internal();

  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _loginCredentialsKey = 'login_credentials';

  // Token management
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // User data
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  // Login credentials (for remember me functionality)
  Future<void> saveLoginCredentials(String email, String password) async {
    final credentials = '$email:$password';
    await _storage.write(key: _loginCredentialsKey, value: credentials);
  }

  Future<Map<String, String>?> getLoginCredentials() async {
    final credentials = await _storage.read(key: _loginCredentialsKey);
    if (credentials != null && credentials.contains(':')) {
      final parts = credentials.split(':');
      if (parts.length == 2) {
        return {
          'email': parts[0],
          'password': parts[1],
        };
      }
    }
    return null;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
  }

  Future<void> clearLoginCredentials() async {
    await _storage.delete(key: _loginCredentialsKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
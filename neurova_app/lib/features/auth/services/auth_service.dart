import 'package:dio/dio.dart';

import '../../../shared/services/local_storage_service.dart';

class AuthService {
  AuthService({required Dio dio, required LocalStorageService localStorageService})
    : _dio = dio,
      _localStorageService = localStorageService;

  final Dio _dio;
  final LocalStorageService _localStorageService;

  Future<String> login({required String email, required String password}) async {
    final response = await _dio.post<dynamic>(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );

    final token = _extractToken(response.data);
    await _localStorageService.saveAuthToken(token);
    return token;
  }

  Future<void> logout() {
    return _localStorageService.clearAuthToken();
  }

  Future<String?> restoreToken() {
    return _localStorageService.readAuthToken();
  }

  String _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final token = data['token'] ?? data['accessToken'] ?? data['jwt'];
      if (token is String && token.isNotEmpty) {
        return token;
      }
    }

    throw const FormatException('Token missing in auth response payload.');
  }
}

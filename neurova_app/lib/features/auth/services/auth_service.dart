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
      '/api/auth/login',
      data: <String, dynamic>{'identifier': email, 'password': password},
    );

    final token = _extractToken(response.data);
    await _localStorageService.saveAuthToken(token);
    return token;
  }

  Future<String> register({
    required String name,
    required String lastname,
    required String username,
    required String email,
    required String password,
    String? phonenumber,
    String? bio,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/auth/register',
      data: <String, dynamic>{
        'name': name,
        'lastname': lastname,
        'username': username,
        'email': email,
        'password': password,
        if (phonenumber != null && phonenumber.trim().isNotEmpty)
          'phonenumber': phonenumber.trim(),
        if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
      },
    );

    // Extract and save token
    final token = _extractToken(response.data);
    await _localStorageService.saveAuthToken(token);
    
    if (response.data is Map<String, dynamic>) {
      final message = response.data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return 'Registration successful. Verify your email from Settings.';
  }

  Future<void> logout() {
    return _localStorageService.clearAuthToken();
  }

  Future<String?> restoreToken() {
    return _localStorageService.readAuthToken();
  }

  Future<void> verifyEmail({required String token}) async {
    await _dio.get<dynamic>(
      '/api/auth/verify-email',
      queryParameters: <String, dynamic>{'token': token},
    );
  }

  Future<Map<String, dynamic>> resendVerificationCode() async {
    final response = await _dio.post<dynamic>('/api/auth/resend-verification');

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    return <String, dynamic>{'success': true, 'message': 'Code sent to your email.'};
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

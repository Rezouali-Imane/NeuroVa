import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../shared/services/local_storage_service.dart';

class AuthService {
  AuthService({
    required Dio dio,
    required LocalStorageService localStorageService,
  }) : _dio = dio,
       _localStorageService = localStorageService;

  final Dio _dio;
  final LocalStorageService _localStorageService;

  Future<void> forgotPassword({required String email}) async {
    await _dio.post<dynamic>(
      '/api/auth/forgot-password',
      data: <String, dynamic>{'email': email},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _dio.post<dynamic>(
      '/api/auth/reset-password',
      data: <String, dynamic>{
        'email': email,
        'resetcode': code,
        'newPassword': newPassword,
      },
    );
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
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
    final token = _extractToken(response.data);
    await _localStorageService.saveAuthToken(token);

    if (response.data is Map<String, dynamic>) {
      final message = response.data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return 'Registration successful';
  }

  Future<Map<String, dynamic>> signInWithGoogle({
    required String idToken,
  }) async {
    final response = await _dio.post<dynamic>(
      '/api/auth/google',
      data: <String, dynamic>{'idToken': idToken},
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['accessToken'];
    await _localStorageService.saveAuthToken(token);

    return data;
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

  Future<void> saveToken(String token) async {
    await _localStorageService.saveAuthToken(token);
  }

  Future<Map<String, dynamic>> resendVerificationCode() async {
    final token = await _localStorageService.readAuthToken();
    if (token == null || token.isEmpty) {
      throw const FormatException(
        'Authentication token missing. Please sign in again.',
      );
    }

    final response = await _dio.post<dynamic>(
      '/api/auth/resend-verification',
      options: Options(
        headers: <String, String>{'Authorization': 'Bearer $token'},
      ),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    return <String, dynamic>{
      'success': true,
      'message': 'Verification link sent to your email.',
    };
  }

  String _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final token = data['accessToken'];
      if (token is String && token.isNotEmpty) {
        debugPrint(' AccessToken extracted: ${token.substring(0, 10)}...');
        return token;
      }
    }
    debugPrint(' FAILED to extract token. Data: $data');
    throw const FormatException('AccessToken missing in backend response.');
  }

  Future<Map<String, dynamic>> getMe() async {
    final token = await _localStorageService.readAuthToken();
    final response = await _dio.get<dynamic>(
      '/api/auth/me',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    final body = response.data as Map<String, dynamic>;
    return (body['user'] ?? body['data']) as Map<String, dynamic>;
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../../../core/constants/app_constants.dart';
import '../../../shared/services/local_storage_service.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

final dioProvider = Provider<Dio>((Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const <String, String>{'Content-Type': 'application/json'},
    ),
  );
});

final localStorageServiceProvider = Provider<LocalStorageService>((Ref ref) {
  return LocalStorageService();
});

final authServiceProvider = Provider<AuthService>((Ref ref) {
  return AuthService(
    dio: ref.read(dioProvider),
    localStorageService: ref.read(localStorageServiceProvider),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((Ref ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState.initial());

  final AuthService _authService;

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final token = await _authService.restoreToken();
      final isverified = token != null ? _extractIsVerifiedFromToken(token) : false;
      state = state.copyWith(
        isLoading: false,
        token: token,
        isverified: isverified,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearToken: true,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final token = await _authService.login(email: email, password: password);
      final isverified = _extractIsVerifiedFromToken(token);
      state = state.copyWith(
        isLoading: false,
        token: token,
        isverified: isverified,
        clearError: true,
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearToken: true,
        errorMessage: _readDioError(error),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearToken: true,
        errorMessage: error.toString(),
      );
    }
  }

  Future<String> signUp({
    required String name,
    required String lastname,
    required String username,
    required String email,
    required String password,
    String? phonenumber,
    String? bio,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final message = await _authService.register(
        name: name,
        lastname: lastname,
        username: username,
        email: email,
        password: password,
        phonenumber: phonenumber,
        bio: bio,
      );
      
      // Get the token that was just saved
      final token = await _authService.restoreToken();
      final isverified = token != null ? _extractIsVerifiedFromToken(token) : false;
      
      state = state.copyWith(
        isLoading: false,
        token: token,
        isverified: isverified,
        clearError: true,
      );
      return message;
    } on DioException catch (error) {
      final msg = _readDioError(error);
      state = state.copyWith(
        isLoading: false,
        clearToken: true,
        errorMessage: msg,
      );
      throw Exception(msg);
    } catch (error) {
      final msg = error.toString();
      state = state.copyWith(
        isLoading: false,
        clearToken: true,
        errorMessage: msg,
      );
      throw Exception(msg);
    }
  }

  Future<void> signOut() async {
    await _authService.logout();
    state = const AuthState.initial();
  }

  Future<void> resendVerificationCode() async {
    try {
      await _authService.resendVerificationCode();
    } on DioException catch (error) {
      throw Exception(_readDioError(error));
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<void> verifyEmail({required String token}) async {
    try {
      await _authService.verifyEmail(token: token);
    } on DioException catch (error) {
      throw Exception(_readDioError(error));
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  String _readDioError(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'Cannot reach the server. Make sure backend is running and API base URL is correct.';
    }

    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return error.message ?? 'Authentication request failed.';
  }

  bool _extractIsVerifiedFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = parts[1];
      // Add padding if necessary
      final paddedPayload = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');

      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final json = jsonDecode(decodedString) as Map<String, dynamic>;

      return json['isverified'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }
}
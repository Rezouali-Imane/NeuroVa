import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      state = state.copyWith(isLoading: false, token: token, clearError: true);
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
      state = state.copyWith(isLoading: false, token: token, clearError: true);
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

  Future<void> signOut() async {
    await _authService.logout();
    state = const AuthState.initial();
  }

  String _readDioError(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return error.message ?? 'Authentication request failed.';
  }
}

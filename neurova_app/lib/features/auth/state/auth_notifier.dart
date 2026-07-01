import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/services/local_storage_service.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';
import '../../ai/services/ai_service.dart';
import '../../ai/state/ai_notifier.dart';

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

final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: const String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '721482377248-p28kgvusk83sufe5dn1dvga8esuspm8b.apps.googleusercontent.com',
  ),
  scopes: ['email', 'profile'],
);

final authServiceProvider = Provider<AuthService>((Ref ref) {
  return AuthService(
    dio: ref.read(dioProvider),
    localStorageService: ref.read(localStorageServiceProvider),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  Ref ref,
) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(localStorageServiceProvider),
  );
});

final aiServiceProvider = Provider<AIService>((Ref ref) {
  final dio = ref.watch(dioProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return AIService(dio, localStorage);
});

final aiNotifierProvider =
    StateNotifierProvider.family<AINotifier, AIState, String>((ref, userId) {
      final aiService = ref.watch(aiServiceProvider);
      return AINotifier(aiService, userId);
    });

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._localStorageService)
    : super(const AuthState.initial());

  final AuthService _authService;
  final LocalStorageService _localStorageService;

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final token = await _authService.restoreToken();
      final isverified = token != null
          ? _extractIsVerifiedFromToken(token)
          : false;
      state = state.copyWith(
        isLoading: false,
        token: token,
        isverified: isverified,
        userId: token != null ? _extractUserIdFromToken(token) : null,
        clearError: true,
      );

      if (token != null) {
        await _fetchAndSaveProfile();
      }
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
      final userId = _extractUserIdFromToken(token);

      if (userId != null) {
        await _localStorageService.saveUserId(userId);
      }

      state = state.copyWith(
        isLoading: false,
        token: token,
        isverified: isverified,
        userId: userId,
        clearError: true,
      );
      await _fetchAndSaveProfile();
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

      final token = await _authService.restoreToken();
      final isverified = token != null
          ? _extractIsVerifiedFromToken(token)
          : false;
      final userId = token != null ? _extractUserIdFromToken(token) : null;

      if (token != null) {
        if (userId != null) await _localStorageService.saveUserId(userId);
      }

      state = state.copyWith(
        isLoading: false,
        token: token,
        isverified: isverified,
        userId: userId,
        clearError: true,
      );
      await _fetchAndSaveProfile();
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
    await _localStorageService.clearUserId();
    await _localStorageService.clearUsername();
    await _localStorageService.clearName();
    state = const AuthState.initial();
  }

  Future<void> applyAccessToken(String token) async {
    await _authService.saveToken(token);

    state = state.copyWith(
      token: token,
      isverified: _extractIsVerifiedFromToken(token),
      userId: _extractUserIdFromToken(token),
      clearError: true,
    );
  }

  void markEmailVerified() {
    state = state.copyWith(isverified: true, clearError: true);
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authService.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false, clearError: true);
    } on DioException catch (error) {
      final message = _readDioError(error);
      state = state.copyWith(
        isLoading: false,
        clearToken: true,
        errorMessage: message,
      );
      throw Exception(message);
    } catch (error) {
      final message = error.toString();
      state = state.copyWith(
        isLoading: false,
        clearToken: true,
        errorMessage: message,
      );
      throw Exception(message);
    }
  }

  Future<bool?> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Google sign-in failed: no ID token. Check Client ID and Web configuration.',
        );
        return null;
      }

      final Map<String, dynamic> authData = await _authService.signInWithGoogle(
        idToken: idToken,
      );

      final String token = authData['accessToken'];
      final bool isNew = authData['isNewUser'] ?? false;
      final isverified = _extractIsVerifiedFromToken(token);
      final userId = _extractUserIdFromToken(token);

      if (userId != null) await _localStorageService.saveUserId(userId);

      state = state.copyWith(
        isLoading: false,
        token: token,
        isverified: isverified,
        clearError: true,
      );
      await _fetchAndSaveProfile();
      return isNew;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearToken: true,
        errorMessage: 'Google Error: ${error.toString()}',
      );
      return null;
    }
  }

  Future<void> signInWithGithub() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final githubClientId = const String.fromEnvironment(
      'GITHUB_CLIENT_ID',
      defaultValue: 'Ov23lin97M4AuMTF0vgo',
    );
    final callbackUrl = '${AppConstants.apiBaseUrl}/api/auth/github/callback';
    final url = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': githubClientId,
      'redirect_uri': callbackUrl,
      'scope': 'read:user user:email',
    });

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'authentication via github failed',
        );
        return;
      }

      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> finalizeGithubLogin(String token) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await applyAccessToken(token);
      state = state.copyWith(isLoading: false, clearError: true);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur cant load github profile',
      );
    }
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
      markEmailVerified();
    } on DioException catch (error) {
      throw Exception(_readDioError(error));
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _authService.forgotPassword(email: email);
    } on DioException catch (error) {
      throw Exception(_readDioError(error));
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<void> _fetchAndSaveProfile() async {
    try {
      final user = await _authService.getMe();
      final username = user['username'] as String?;
      final name = user['name'] as String?;
      final userid = user['userid'] as String?;
      if (username != null) await _localStorageService.saveUsername(username);
      if (name != null) await _localStorageService.saveName(name);
      if (userid != null) await _localStorageService.saveUserId(userid);
    } catch (e) {}
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
      final paddedPayload = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );

      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final json = jsonDecode(decodedString) as Map<String, dynamic>;

      return json['isverified'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final paddedPayload = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );

      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final json = jsonDecode(decodedString) as Map<String, dynamic>;

      return json['sub'] as String? ?? json['userid'] as String?;
    } catch (_) {
      return null;
    }
  }
}

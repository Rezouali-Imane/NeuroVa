import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class LocalStorageService {
  LocalStorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<void> saveAuthToken(String token) {
    return _secureStorage.write(key: AppConstants.authTokenKey, value: token);
  }

  Future<String?> readAuthToken() {
    return _secureStorage.read(key: AppConstants.authTokenKey);
  }

  Future<void> clearAuthToken() {
    return _secureStorage.delete(key: AppConstants.authTokenKey);
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingSeenKey, true);
  }

  Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingSeenKey) ?? false;
  }
}

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

  // User ID storage
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<String?> readUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // Username storage
  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<String?> readUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> clearUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  // Active study room persistence
  Future<void> saveActiveRoomId(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeRoomId', roomId);
  }

  Future<String?> readActiveRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('activeRoomId');
  }

  Future<void> clearActiveRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('activeRoomId');
  }

  Future<void> saveAIVoicePersona(String persona) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.aiVoicePersonaKey, persona);
  }

  Future<String?> readAIVoicePersona() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.aiVoicePersonaKey);
  }

  Future<void> saveAIVoiceSpeedPreset(String preset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.aiVoiceSpeedPresetKey, preset);
  }

  Future<String?> readAIVoiceSpeedPreset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.aiVoiceSpeedPresetKey);
  }
}
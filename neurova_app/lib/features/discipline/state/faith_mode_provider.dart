import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/prayer_times_service.dart';

final prayerTimesServiceProvider = Provider((ref) => PrayerTimesService());

final prayerTimesProvider = FutureProvider.family<PrayerTimesResponse?, String>((ref, cityCountry) async {
  final service = ref.watch(prayerTimesServiceProvider);
  
  if (cityCountry.isEmpty) return null;
  
  final parts = cityCountry.split(',');
  if (parts.length < 2) return null;
  
  final city = parts[0].trim();
  final country = parts[1].trim();
  
  return service.fetchPrayerTimes(
    city: city,
    country: country,
    date: DateTime.now(),
  );
});

// Provider to manage faith mode and location settings
final faithModeSettingsProvider = StateNotifierProvider<FaithModeNotifier, FaithModeSettings>((ref) {
  return FaithModeNotifier();
});

class FaithModeSettings {
  final bool enabled;
  final String? city;
  final String? country;
  final List<PrayerTime>? prayerTimes;
  final bool isLoading;
  final String? error;
  
  FaithModeSettings({
    this.enabled = false,
    this.city,
    this.country,
    this.prayerTimes,
    this.isLoading = false,
    this.error,
  });
  
  FaithModeSettings copyWith({
    bool? enabled,
    String? city,
    String? country,
    List<PrayerTime>? prayerTimes,
    bool? isLoading,
    String? error,
  }) {
    return FaithModeSettings(
      enabled: enabled ?? this.enabled,
      city: city ?? this.city,
      country: country ?? this.country,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FaithModeNotifier extends StateNotifier<FaithModeSettings> {
  FaithModeNotifier() : super(FaithModeSettings()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('faith_mode_enabled') ?? false;
      final city = prefs.getString('prayer_city');
      final country = prefs.getString('prayer_country');
      
      state = state.copyWith(
        enabled: enabled,
        city: city,
        country: country,
      );
      
      if (enabled && city != null && country != null) {
        await fetchPrayerTimes(city, country);
      }
    } catch (e) {
      debugPrint('[FaithMode] Error loading settings: $e');
    }
  }
  
  Future<void> toggleFaithMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('faith_mode_enabled', enabled);
      
      state = state.copyWith(enabled: enabled);
      
      if (!enabled) {
        state = state.copyWith(prayerTimes: null);
      }
    } catch (e) {
      debugPrint('[FaithMode] Error toggling faith mode: $e');
      state = state.copyWith(error: 'Failed to save settings');
    }
  }
  
  Future<void> setLocation(String city, String country) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('prayer_city', city);
      await prefs.setString('prayer_country', country);
      
      state = state.copyWith(city: city, country: country);
      
      await fetchPrayerTimes(city, country);
    } catch (e) {
      debugPrint('[FaithMode] Error setting location: $e');
      state = state.copyWith(error: 'Failed to save location');
    }
  }
  
  Future<void> fetchPrayerTimes(String city, String country) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = PrayerTimesService();
      final response = await service.fetchPrayerTimes(
        city: city,
        country: country,
        date: DateTime.now(),
      );
      
      if (response != null) {
        state = state.copyWith(
          prayerTimes: response.times,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: 'Failed to fetch prayer times',
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('[FaithMode] Error fetching prayer times: $e');
      state = state.copyWith(
        error: 'Error: $e',
        isLoading: false,
      );
    }
  }
}

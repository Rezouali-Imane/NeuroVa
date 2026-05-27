import 'package:dio/dio.dart';

class PrayerTime {
  final String name;
  final String time; // HH:mm format
  
  PrayerTime({required this.name, required this.time});
  
  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      name: json['name'] as String,
      time: json['time'] as String,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time,
  };
}

class PrayerTimesResponse {
  final List<PrayerTime> times;
  final String date;
  
  PrayerTimesResponse({required this.times, required this.date});
  
  factory PrayerTimesResponse.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final prayerNames = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Sunset', 'Maghrib', 'Isha'];
    
    final times = prayerNames
        .where((name) => timings.containsKey(name))
        .map((name) {
          final timeStr = (timings[name] as String).split(' ')[0]; // Remove timezone
          return PrayerTime(name: name, time: timeStr);
        })
        .toList();
    
    return PrayerTimesResponse(
      times: times,
      date: json['date']['readable'] as String? ?? '',
    );
  }
}

class PrayerTimesService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  
  PrayerTimesService({Dio? dio}) : _dio = dio ?? Dio();
  
  /// Fetch prayer times for a given city and date
  /// Returns null if fetch fails
  Future<PrayerTimesResponse?> fetchPrayerTimes({
    required String city,
    required String country,
    DateTime? date,
  }) async {
    try {
      final dateStr = date != null 
        ? '${date.day}-${date.month}-${date.year}'
        : '';
      
      final response = await _dio.get(
        '$_baseUrl/timingsByCity',
        queryParameters: {
          'city': city,
          'country': country,
          'method': 2, // ISNA method
          if (dateStr.isNotEmpty) 'date': dateStr,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return PrayerTimesResponse.fromJson(data['data']);
      }
    } catch (e) {
      print('[PrayerTimes] Error fetching prayer times: $e');
    }
    return null;
  }
  
  /// Fetch using coordinates (latitude, longitude)
  Future<PrayerTimesResponse?> fetchPrayerTimesByCoords({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    try {
      final dateStr = date != null 
        ? '${date.day}-${date.month}-${date.year}'
        : '';
      
      final response = await _dio.get(
        '$_baseUrl/timings',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 2,
          'timezonestring': 'auto',
          if (dateStr.isNotEmpty) 'date': dateStr,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return PrayerTimesResponse.fromJson(data['data']);
      }
    } catch (e) {
      print('[PrayerTimes] Error fetching prayer times by coords: $e');
    }
    return null;
  }
}

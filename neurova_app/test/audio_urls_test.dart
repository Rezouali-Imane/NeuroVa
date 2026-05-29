import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

void main() async {
  developer.log('Testing Ambient Audio URLs...\n', name: 'audio_urls_test');
  
  final sounds = {
    'rain': 'https://assets.mixkit.co/active_storage/sfx/2404/2404-preview.mp3',
    'cafe': 'https://assets.mixkit.co/active_storage/sfx/1996/1996-preview.mp3',
    'forest': 'https://assets.mixkit.co/active_storage/sfx/1988/1988-preview.mp3',
    'ocean': 'https://assets.mixkit.co/active_storage/sfx/2017/2017-preview.mp3',
    'white_noise': 'https://assets.mixkit.co/active_storage/sfx/2404/2404-preview.mp3',
    'study': 'https://assets.mixkit.co/active_storage/sfx/2162/2162-preview.mp3',
  };

  int successCount = 0;
  int failureCount = 0;

  for (final entry in sounds.entries) {
    try {
      final response = await http.head(Uri.parse(entry.value))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        developer.log('${entry.key.padRight(15)} - ${response.statusCode} (URL accessible)', name: 'audio_urls_test');
        successCount++;
      } else {
        developer.log('${entry.key.padRight(15)} - ${response.statusCode}', name: 'audio_urls_test');
        failureCount++;
      }
    } catch (e) {
      developer.log('${entry.key.padRight(15)} - Error: $e', name: 'audio_urls_test');
      failureCount++;
    }
  }

  developer.log('\nResults:', name: 'audio_urls_test');
  developer.log('   Working: $successCount/6', name: 'audio_urls_test');
  developer.log('   Failed: $failureCount/6', name: 'audio_urls_test');
  
  if (successCount == 6) {
    developer.log('All audio URLs are accessible and ready to stream!', name: 'audio_urls_test');
  } else {
    developer.log('Some URLs may not be accessible. Check network connection.', name: 'audio_urls_test');
  }
}

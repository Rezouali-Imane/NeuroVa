import 'package:http/http.dart' as http;

void main() async {
  print('🔊 Testing Ambient Audio URLs...\n');
  
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
        print('✅ ${entry.key.padRight(15)} - ${response.statusCode} (URL accessible)');
        successCount++;
      } else {
        print('❌ ${entry.key.padRight(15)} - ${response.statusCode}');
        failureCount++;
      }
    } catch (e) {
      print('❌ ${entry.key.padRight(15)} - Error: $e');
      failureCount++;
    }
  }

  print('\n📊 Results:');
  print('   ✅ Working: $successCount/6');
  print('   ❌ Failed: $failureCount/6');
  
  if (successCount == 6) {
    print('\n🎉 All audio URLs are accessible and ready to stream!');
  } else {
    print('\n⚠️  Some URLs may not be accessible. Check network connection.');
  }
}

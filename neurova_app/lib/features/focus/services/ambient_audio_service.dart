import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmbientSound {
  final String id;
  final String name;
  final String assetPath; // For local assets
  final String? remoteUrl; // For streaming from URLs
  
  AmbientSound({
    required this.id,
    required this.name,
    this.assetPath = '',
    this.remoteUrl,
  });
}

class AmbientAudioService {
  static final AmbientAudioService _instance = AmbientAudioService._internal();
  
  late AudioPlayer _audioPlayer;
  String _currentSound = 'off';
  double _volume = 0.5;
  bool _isPlaying = false;

  final List<AmbientSound> availableSounds = [
    AmbientSound(id: 'off', name: 'Off', assetPath: '', remoteUrl: null),
    // Free streaming ambient sounds from royalty-free sources
    AmbientSound(
      id: 'rain',
      name: 'Rain',
      remoteUrl: 'https://assets.mixkit.co/active_storage/sfx/2404/2404-preview.mp3',
    ),
    AmbientSound(
      id: 'cafe',
      name: 'Café',
      remoteUrl: 'https://assets.mixkit.co/active_storage/sfx/1996/1996-preview.mp3',
    ),
    AmbientSound(
      id: 'forest',
      name: 'Forest',
      remoteUrl: 'https://assets.mixkit.co/active_storage/sfx/1988/1988-preview.mp3',
    ),
    AmbientSound(
      id: 'ocean',
      name: 'Ocean',
      remoteUrl: 'https://assets.mixkit.co/active_storage/sfx/2017/2017-preview.mp3',
    ),
    AmbientSound(
      id: 'white_noise',
      name: 'White Noise',
      remoteUrl: 'https://assets.mixkit.co/active_storage/sfx/2404/2404-preview.mp3',
    ),
    AmbientSound(
      id: 'study',
      name: 'Study Beats',
      remoteUrl: 'https://assets.mixkit.co/active_storage/sfx/2162/2162-preview.mp3',
    ),
  ];

  factory AmbientAudioService() {
    return _instance;
  }

  AmbientAudioService._internal() {
    _audioPlayer = AudioPlayer();
    _init();
  }

  void _init() async {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
    });
    
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSound = prefs.getString('ambient_sound') ?? 'off';
    _volume = prefs.getDouble('ambient_volume') ?? 0.5;
    await _audioPlayer.setVolume(_volume);
  }

  Future<void> playSound(String soundId) async {
    try {
      if (soundId == 'off') {
        await _audioPlayer.stop();
        _currentSound = 'off';
        _isPlaying = false;
      } else {
        final sound = availableSounds.firstWhere((s) => s.id == soundId);
        
        // Use remote URL if available, otherwise use asset
        if (sound.remoteUrl != null && sound.remoteUrl!.isNotEmpty) {
          await _audioPlayer.setUrl(sound.remoteUrl!);
        } else if (sound.assetPath.isNotEmpty) {
          await _audioPlayer.setAsset(sound.assetPath);
        } else {
          throw Exception('No audio source available for $soundId');
        }
        
        await _audioPlayer.setLoopMode(LoopMode.all);
        await _audioPlayer.play();
        
        _currentSound = soundId;
        _isPlaying = true;
      }
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ambient_sound', _currentSound);
    } catch (e) {
      // Silently handle errors to avoid disrupting user experience
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(_volume);
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('ambient_volume', _volume);
    } catch (e) {
      // Silently handle errors
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSound = 'off';
    } catch (e) {
      // Silently handle errors
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      // Silently handle errors
    }
  }

  Future<void> resume() async {
    try {
      if (_currentSound != 'off') {
        await _audioPlayer.play();
        _isPlaying = true;
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  String get currentSound => _currentSound;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmbientSound {
  final String id;
  final String name;
  final String assetPath;
  
  AmbientSound({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}

class AmbientAudioService {
  static final AmbientAudioService _instance = AmbientAudioService._internal();
  
  late AudioPlayer _audioPlayer;
  String _currentSound = 'off';
  double _volume = 0.5;
  bool _isPlaying = false;

  final List<AmbientSound> availableSounds = [
    AmbientSound(id: 'off', name: 'Off', assetPath: ''),
    AmbientSound(id: 'rain', name: 'Rain', assetPath: 'assets/ambient/rain.m4a'),
    AmbientSound(id: 'cafe', name: 'Café', assetPath: 'assets/ambient/cafe.m4a'),
    AmbientSound(id: 'forest', name: 'Forest', assetPath: 'assets/ambient/forest.m4a'),
    AmbientSound(id: 'ocean', name: 'Ocean', assetPath: 'assets/ambient/ocean.m4a'),
    AmbientSound(id: 'white_noise', name: 'White Noise', assetPath: 'assets/ambient/white_noise.m4a'),
    AmbientSound(id: 'study', name: 'Study Beats', assetPath: 'assets/ambient/study_beats.m4a'),
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
        
        await _audioPlayer.setAsset(sound.assetPath);
        await _audioPlayer.setLoopMode(LoopMode.all);
        await _audioPlayer.play();
        
        _currentSound = soundId;
        _isPlaying = true;
      }
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ambient_sound', _currentSound);
    } catch (e) {
      print('[AmbientAudio] Error playing sound: $e');
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
      print('[AmbientAudio] Error setting volume: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSound = 'off';
    } catch (e) {
      print('[AmbientAudio] Error stopping audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      print('[AmbientAudio] Error pausing audio: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (_currentSound != 'off') {
        await _audioPlayer.play();
        _isPlaying = true;
      }
    } catch (e) {
      print('[AmbientAudio] Error resuming audio: $e');
    }
  }

  String get currentSound => _currentSound;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

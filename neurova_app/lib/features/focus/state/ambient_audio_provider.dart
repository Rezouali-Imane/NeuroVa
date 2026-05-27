import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ambient_audio_service.dart';

final ambientAudioServiceProvider = Provider<AmbientAudioService>((ref) {
  return AmbientAudioService();
});

final ambientAudioStateProvider = StateNotifierProvider<
    AmbientAudioNotifier,
    AmbientAudioState>((ref) {
  final service = ref.watch(ambientAudioServiceProvider);
  return AmbientAudioNotifier(service);
});

class AmbientAudioState {
  final String currentSound;
  final double volume;
  final bool isPlaying;
  final List<AmbientSound> availableSounds;

  AmbientAudioState({
    required this.currentSound,
    required this.volume,
    required this.isPlaying,
    required this.availableSounds,
  });

  AmbientAudioState copyWith({
    String? currentSound,
    double? volume,
    bool? isPlaying,
    List<AmbientSound>? availableSounds,
  }) {
    return AmbientAudioState(
      currentSound: currentSound ?? this.currentSound,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
      availableSounds: availableSounds ?? this.availableSounds,
    );
  }
}

class AmbientAudioNotifier extends StateNotifier<AmbientAudioState> {
  final AmbientAudioService _service;

  AmbientAudioNotifier(this._service)
      : super(AmbientAudioState(
          currentSound: 'off',
          volume: 0.5,
          isPlaying: false,
          availableSounds: [],
        )) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(
      availableSounds: _service.availableSounds,
      currentSound: _service.currentSound,
      volume: _service.volume,
      isPlaying: _service.isPlaying,
    );
  }

  Future<void> playSound(String soundId) async {
    await _service.playSound(soundId);
    state = state.copyWith(
      currentSound: soundId,
      isPlaying: soundId != 'off',
    );
  }

  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  Future<void> stop() async {
    await _service.stop();
    state = state.copyWith(currentSound: 'off', isPlaying: false);
  }
}

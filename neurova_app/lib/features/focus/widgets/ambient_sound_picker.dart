import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/ambient_audio_provider.dart';

/// Ambient Sound Picker Widget - Beautiful UI for selecting ambient sounds
class AmbientSoundPicker extends ConsumerWidget {
  const AmbientSoundPicker({super.key});

  IconData _getSoundIcon(String soundId) {
    switch (soundId) {
      case 'rain':
        return Icons.cloud_queue;
      case 'cafe':
        return Icons.local_cafe;
      case 'forest':
        return Icons.park;
      case 'ocean':
        return Icons.waves;
      case 'white_noise':
        return Icons.grain;
      case 'study':
        return Icons.music_note;
      default:
        return Icons.volume_off;
    }
  }

  Color _getSoundColor(String soundId) {
    switch (soundId) {
      case 'rain':
        return const Color(0xFF5DADE2);
      case 'cafe':
        return const Color(0xFF8B6F47);
      case 'forest':
        return const Color(0xFF27AE60);
      case 'ocean':
        return const Color(0xFF3498DB);
      case 'white_noise':
        return const Color(0xFF95A5A6);
      case 'study':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(ambientAudioStateProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3C57D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.volume_up_outlined,
                  color: Color(0xFFF3C57D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ambient Sounds',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      audioState.isPlaying
                          ? 'Now playing: ${audioState.availableSounds.firstWhere((s) => s.id == audioState.currentSound).name}'
                          : 'Off',
                      style: const TextStyle(
                        color: Color(0x99FFFFFF),
                        fontFamily: 'Syne',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sound selection grid
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: audioState.availableSounds.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final sound = audioState.availableSounds[index];
                final isSelected = audioState.currentSound == sound.id;

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(ambientAudioStateProvider.notifier)
                        .playSound(sound.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isSelected
                          ? _getSoundColor(sound.id).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                        color: isSelected
                            ? _getSoundColor(sound.id).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getSoundIcon(sound.id),
                          color: isSelected
                              ? _getSoundColor(sound.id)
                              : Colors.white54,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sound.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontFamily: 'Syne',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Volume control
          if (audioState.isPlaying) ...[
            Text(
              'Volume',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontFamily: 'Syne',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.volume_down,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: audioState.volume,
                      onChanged: (value) {
                        ref
                            .read(ambientAudioStateProvider.notifier)
                            .setVolume(value);
                      },
                      activeColor: const Color(0xFFF3C57D),
                      inactiveColor:
                          Colors.white.withValues(alpha: 0.1),
                      min: 0,
                      max: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.volume_up,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:hooks_riverpod/hooks_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  bool soundsEnabled = true;

  /// Play timer completion sound
  Future<void> playTimerCompleteSound() async {
    if (!soundsEnabled) return;
    // Audio feedback will be handled by haptic feedback for now
  }

  /// Play timer start sound
  Future<void> playTimerStartSound() async {
    if (!soundsEnabled) return;
    // Audio feedback will be handled by haptic feedback for now
  }

  /// Play button click sound
  Future<void> playButtonClickSound() async {
    if (!soundsEnabled) return;
    // Audio feedback will be handled by haptic feedback for now
  }

  /// Dispose resources
  Future<void> dispose() async {
    // No resources to dispose for now
  }
}

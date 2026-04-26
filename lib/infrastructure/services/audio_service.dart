import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for the [AudioService].
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

/// Service for handling audio playback.
class AudioService {
  /// Indicates if sounds are enabled.
  bool soundsEnabled = true;

  /// Play timer completion sound.
  Future<void> playTimerCompleteSound() async {
    if (!soundsEnabled) return;
    // Audio feedback will be handled by haptic feedback for now
  }

  /// Play timer start sound.
  Future<void> playTimerStartSound() async {
    if (!soundsEnabled) return;
    // Audio feedback will be handled by haptic feedback for now
  }

  /// Play button click sound.
  Future<void> playButtonClickSound() async {
    if (!soundsEnabled) return;
    // Audio feedback will be handled by haptic feedback for now
  }

  /// Dispose resources used by the service.
  Future<void> dispose() async {
    // No resources to dispose for now
  }
}

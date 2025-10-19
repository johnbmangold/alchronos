import 'package:injectable/injectable.dart';

@lazySingleton
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

import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool soundsEnabled = true;

  /// Play timer completion sound
  Future<void> playTimerCompleteSound() async {
    if (!soundsEnabled) return;

    try {
      // Use a system sound for timer completion
      await _audioPlayer.play(AssetSource('sounds/timer_complete.mp3'));
    } on Exception {
      // If custom sound fails, use system sound
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    }
  }

  /// Play timer start sound
  Future<void> playTimerStartSound() async {
    if (!soundsEnabled) return;

    try {
      await _audioPlayer.play(AssetSource('sounds/timer_start.mp3'));
    } on Exception {
      // Fallback to system sound
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    }
  }

  /// Play button click sound
  Future<void> playButtonClickSound() async {
    if (!soundsEnabled) return;

    try {
      await _audioPlayer.play(AssetSource('sounds/button_click.mp3'));
    } on Exception {
      // Fallback to system sound
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

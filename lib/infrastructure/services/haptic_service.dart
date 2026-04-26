import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

class HapticService {
  /// Light haptic feedback for button taps
  Future<void> lightImpact() async {
    await Haptics.vibrate(HapticsType.light);
  }

  /// Medium haptic feedback for important actions
  Future<void> mediumImpact() async {
    await Haptics.vibrate(HapticsType.medium);
  }

  /// Heavy haptic feedback for significant events
  Future<void> heavyImpact() async {
    await Haptics.vibrate(HapticsType.heavy);
  }

  /// Selection haptic feedback for UI selections
  Future<void> selectionClick() async {
    await Haptics.vibrate(HapticsType.selection);
  }

  /// Vibrate for timer completion
  Future<void> timerComplete() async {
    await Haptics.vibrate(HapticsType.heavy);
    // Add a slight delay and another impact for emphasis
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await Haptics.vibrate(HapticsType.heavy);
  }

  /// Vibrate for timer pause/resume
  Future<void> timerToggle() async {
    await Haptics.vibrate(HapticsType.medium);
  }

  /// Vibrate for timer start
  Future<void> timerStart() async {
    await Haptics.vibrate(HapticsType.light);
  }

  /// Vibrate for timer stop
  Future<void> timerStop() async {
    await Haptics.vibrate(HapticsType.heavy);
  }
}

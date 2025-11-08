import 'package:alchronos/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioService', () {
    late AudioService audioService;

    setUp(() {
      audioService = AudioService();
    });

    test('soundsEnabled defaults to true', () {
      expect(audioService.soundsEnabled, isTrue);
    });

    test('playTimerCompleteSound does nothing when sounds disabled', () async {
      audioService.soundsEnabled = false;
      await audioService.playTimerCompleteSound();
      // Should complete without error
    });

    test('playTimerCompleteSound completes when sounds enabled', () async {
      audioService.soundsEnabled = true;
      await audioService.playTimerCompleteSound();
      // Should complete without error
    });

    test('playTimerStartSound does nothing when sounds disabled', () async {
      audioService.soundsEnabled = false;
      await audioService.playTimerStartSound();
      // Should complete without error
    });

    test('playTimerStartSound completes when sounds enabled', () async {
      audioService.soundsEnabled = true;
      await audioService.playTimerStartSound();
      // Should complete without error
    });

    test('playButtonClickSound does nothing when sounds disabled', () async {
      audioService.soundsEnabled = false;
      await audioService.playButtonClickSound();
      // Should complete without error
    });

    test('playButtonClickSound completes when sounds enabled', () async {
      audioService.soundsEnabled = true;
      await audioService.playButtonClickSound();
      // Should complete without error
    });

    test('dispose completes without error', () async {
      await audioService.dispose();
      // Should complete without error
    });
  });
}

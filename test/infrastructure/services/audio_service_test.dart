import 'package:alchronos/infrastructure/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AudioService audioService;

  setUp(() {
    audioService = AudioService();
  });

  test('playTimerCompleteSound executes without error', () async {
    expect(() => audioService.playTimerCompleteSound(), returnsNormally);
  });

  test('playTimerStartSound executes without error', () async {
    expect(() => audioService.playTimerStartSound(), returnsNormally);
  });

  test('playButtonClickSound executes without error', () async {
    expect(() => audioService.playButtonClickSound(), returnsNormally);
  });

  test('dispose executes without error', () async {
    expect(() => audioService.dispose(), returnsNormally);
  });

  test('respects soundsEnabled toggle', () async {
    audioService.soundsEnabled = false;
    expect(() => audioService.playButtonClickSound(), returnsNormally);
  });
}

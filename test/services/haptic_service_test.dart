import 'package:alchronos/services/haptic_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticService', () {
    late HapticService hapticService;

    setUp(() {
      hapticService = HapticService();
    });

    test('lightImpact completes without error', () async {
      await hapticService.lightImpact();
      // Should complete without error
    });

    test('mediumImpact completes without error', () async {
      await hapticService.mediumImpact();
      // Should complete without error
    });

    test('heavyImpact completes without error', () async {
      await hapticService.heavyImpact();
      // Should complete without error
    });

    test('selectionClick completes without error', () async {
      await hapticService.selectionClick();
      // Should complete without error
    });

    test('timerComplete completes without error', () async {
      await hapticService.timerComplete();
      // Should complete without error
    });

    test('timerToggle completes without error', () async {
      await hapticService.timerToggle();
      // Should complete without error
    });

    test('timerStart completes without error', () async {
      await hapticService.timerStart();
      // Should complete without error
    });

    test('timerStop completes without error', () async {
      await hapticService.timerStop();
      // Should complete without error
    });
  });
}

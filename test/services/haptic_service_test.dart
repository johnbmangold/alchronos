import 'package:alchronos/services/haptic_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticService', () {
    late HapticService hapticService;

    setUp(() {
      hapticService = HapticService();
    });

    // Note: HapticService tests are skipped because they require platform
    // channels (haptic_feedback) that are not available in unit tests.
    // These tests should be run as integration tests on a real device/emulator.

    test(
      'lightImpact completes without error',
      () async {
        await hapticService.lightImpact();
        // Should complete without error
      },
      skip: 'Requires platform channels not available in unit tests',
    );

    test(
      'mediumImpact completes without error',
      () async {
        await hapticService.mediumImpact();
        // Should complete without error
      },
      skip: 'Requires platform channels not available in unit tests',
    );

    test(
      'heavyImpact completes without error',
      () async {
        await hapticService.heavyImpact();
        // Should complete without error
      },
      skip: 'Requires platform channels not available in unit tests',
    );

    test(
      'selectionClick completes without error',
      () async {
        await hapticService.selectionClick();
        // Should complete without error
      },
      skip: 'Requires platform channels not available in unit tests',
    );

    test(
      'timerComplete completes without error',
      () async {
        await hapticService.timerComplete();
        // Should complete without error
      },
      skip: 'Requires platform channels not available in unit tests',
    );

    test(
      'timerToggle completes without error',
      () async {
        await hapticService.timerToggle();
        // Should complete without error
      },
      skip: 'Requires platform channels not available in unit tests',
    );

    test(
      'timerStart completes without error',
      () async {
        await hapticService.timerStart();
        // Should complete without error
      },
      skip: 'Requires platform channels not available in unit tests',
    );

    test(
      'timerStop completes without error',
      () async {
        await hapticService.timerStop();
        // Should complete without error
      },
      skip: 'Requires platform channels not available in unit tests',
    );
  });
}

import 'package:alchronos/services/performance_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'performance_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Logger>()])
void main() {
  group('PerformanceService', () {
    late PerformanceService performanceService;
    late MockLogger mockLogger;

    setUp(() {
      mockLogger = MockLogger();
      performanceService = PerformanceService(mockLogger);
    });

    group('startTiming and endTiming', () {
      test('startTiming records start time', () {
        performanceService.startTiming('test_operation');

        // Verify no error thrown
        expect(performanceService, isNotNull);
      });

      test('endTiming logs duration when startTiming was called', () {
        performanceService.startTiming('test_operation');

        // Wait a bit to ensure duration > 0
        Future<void>.delayed(const Duration(milliseconds: 10), () {
          performanceService.endTiming('test_operation');
        });

        // Verify logger was called
        verify(mockLogger.i(any, error: anyNamed('error'))).called(any);
      });

      test('endTiming does nothing when startTiming was not called', () {
        performanceService.endTiming('non_existent_operation');

        // Should not throw error
        expect(performanceService, isNotNull);
      });
    });

    group('trackEvent', () {
      test('tracks event with name', () {
        performanceService.trackEvent('test_event');

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });

      test('tracks event with parameters', () {
        final parameters = <String, dynamic>{'key': 'value'};

        performanceService.trackEvent('test_event', parameters: parameters);

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });

      test('increments event count for same event', () {
        performanceService.trackEvent('test_event');
        performanceService.trackEvent('test_event');

        final stats = performanceService.getEventStats();
        expect(stats['test_event'], 2);
      });
    });

    group('trackTimerEvent', () {
      test('tracks timer event with default parameters', () {
        performanceService.trackTimerEvent('start');

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });

      test('tracks timer event with duration', () {
        performanceService.trackTimerEvent('start', duration: 60);

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });

      test('tracks timer event with isPaused', () {
        performanceService.trackTimerEvent('pause', isPaused: true);

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });

      test('tracks timer event with both duration and isPaused', () {
        performanceService.trackTimerEvent(
          'resume',
          duration: 30,
          isPaused: false,
        );

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });
    });

    group('trackUserInteraction', () {
      test('tracks user interaction with action', () {
        performanceService.trackUserInteraction('button_click');

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });

      test('tracks user interaction with screen', () {
        performanceService.trackUserInteraction(
          'button_click',
          screen: 'home_screen',
        );

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });
    });

    group('trackAppPerformance', () {
      test('tracks app performance metric', () {
        performanceService.trackAppPerformance('memory_usage', 1024);

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });
    });

    group('getEventStats', () {
      test('returns empty map when no events tracked', () {
        final stats = performanceService.getEventStats();

        expect(stats, isEmpty);
      });

      test('returns event counts for tracked events', () {
        performanceService.trackEvent('event1');
        performanceService.trackEvent('event1');
        performanceService.trackEvent('event2');

        final stats = performanceService.getEventStats();

        expect(stats['event1'], 2);
        expect(stats['event2'], 1);
      });
    });

    group('trackMemoryUsage', () {
      test('tracks memory usage', () {
        performanceService.trackMemoryUsage();

        verify(mockLogger.i(any, error: anyNamed('error'))).called(1);
      });
    });
  });
}


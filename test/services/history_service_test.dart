import 'package:alchronos/app_database.dart';
import 'package:alchronos/services/history_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'history_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AppDatabase>(), MockSpec<Logger>()])
void main() {
  group('HistoryService', () {
    late HistoryService historyService;
    late MockAppDatabase mockDatabase;
    late MockLogger mockLogger;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockLogger = MockLogger();
      historyService = HistoryService(mockDatabase, mockLogger);
    });

    group('saveCompletedSession', () {
      test('saves session successfully', () async {
        when(mockDatabase.insertTimerSession(any)).thenAnswer((_) async => 1);

        await historyService.saveCompletedSession(
          durationMinutes: 60,
          startTime: DateTime(2024),
          endTime: DateTime(2024, 1, 1, 1),
          wasPaused: false,
        );

        verify(mockDatabase.insertTimerSession(any)).called(1);
      });

      test('saves session with pause count', () async {
        when(mockDatabase.insertTimerSession(any)).thenAnswer((_) async => 1);

        await historyService.saveCompletedSession(
          durationMinutes: 60,
          startTime: DateTime(2024),
          endTime: DateTime(2024, 1, 1, 1),
          wasPaused: true,
          pauseCount: 3,
        );

        verify(mockDatabase.insertTimerSession(any)).called(1);
      });

      test('handles exception gracefully', () async {
        when(mockDatabase.insertTimerSession(any))
            .thenThrow(Exception('Database error'));

        await historyService.saveCompletedSession(
          durationMinutes: 60,
          startTime: DateTime(2024),
          endTime: DateTime(2024, 1, 1, 1),
          wasPaused: false,
        );

        verify(mockLogger.e(any)).called(1);
      });
    });

    group('getHistory', () {
      test('returns list of sessions', () async {
        final expectedSessions = <TimerSessionData>[
          TimerSessionData(
            id: 1,
            durationMinutes: 60,
            startTime: DateTime(2024),
            endTime: DateTime(2024, 1, 1, 1),
            wasPaused: false,
            pauseCount: 0,
            createdAt: DateTime(2024, 1, 1, 1),
          ),
        ];

        when(mockDatabase.getTimerSessions(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
          limit: anyNamed('limit'),
        ),).thenAnswer((_) async => expectedSessions);

        final result = await historyService.getHistory();

        expect(result, expectedSessions);
      });

      test('returns empty list on exception', () async {
        when(mockDatabase.getTimerSessions(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
          limit: anyNamed('limit'),
        ),).thenThrow(Exception('Database error'));

        final result = await historyService.getHistory();

        expect(result, isEmpty);
        verify(mockLogger.e(any)).called(1);
      });
    });

    group('getStatistics', () {
      test('returns empty statistics when no sessions', () async {
        when(mockDatabase.getTimerSessions(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
          limit: anyNamed('limit'),
        ),).thenAnswer((_) async => <TimerSessionData>[]);

        final result = await historyService.getStatistics();

        expect(result.totalSessions, 0);
        expect(result.totalMinutes, 0);
        expect(result.averageMinutes, 0);
      });

      test('calculates statistics correctly', () async {
        final sessions = <TimerSessionData>[
          TimerSessionData(
            id: 1,
            durationMinutes: 60,
            startTime: DateTime(2024),
            endTime: DateTime(2024, 1, 1, 1),
            wasPaused: false,
            pauseCount: 0,
            createdAt: DateTime(2024, 1, 1, 1),
          ),
          TimerSessionData(
            id: 2,
            durationMinutes: 60,
            startTime: DateTime(2024, 1, 2),
            endTime: DateTime(2024, 1, 2, 1),
            wasPaused: false,
            pauseCount: 0,
            createdAt: DateTime(2024, 1, 2, 1),
          ),
          TimerSessionData(
            id: 3,
            durationMinutes: 90,
            startTime: DateTime(2024, 1, 3),
            endTime: DateTime(2024, 1, 3, 1, 30),
            wasPaused: true,
            pauseCount: 2,
            createdAt: DateTime(2024, 1, 3, 1, 30),
          ),
        ];

        when(mockDatabase.getTimerSessions(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
          limit: anyNamed('limit'),
        ),).thenAnswer((_) async => sessions);

        final result = await historyService.getStatistics();

        expect(result.totalSessions, 3);
        expect(result.totalMinutes, 210);
        expect(result.averageMinutes, 70);
        expect(result.totalPauses, 2);
        expect(result.sessionsWithPauses, 1);
        expect(result.mostCommonDuration, 60);
      });

      test('returns empty statistics on exception', () async {
        when(mockDatabase.getTimerSessions(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
          limit: anyNamed('limit'),
        ),).thenThrow(Exception('Database error'));

        final result = await historyService.getStatistics();

        expect(result.totalSessions, 0);
        verify(mockLogger.e(any)).called(1);
      });
    });

    group('clearHistory', () {
      test('clears all history', () async {
        when(mockDatabase.clearAllTimerSessions())
            .thenAnswer((_) async => Future<void>.value());

        await historyService.clearHistory();

        verify(mockDatabase.clearAllTimerSessions()).called(1);
      });

      test('handles exception gracefully', () async {
        when(mockDatabase.clearAllTimerSessions())
            .thenThrow(Exception('Database error'));

        await historyService.clearHistory();

        verify(mockLogger.e(any)).called(1);
      });
    });
  });

  group('TimerStatistics', () {
    test('empty factory creates empty statistics', () {
      final stats = TimerStatistics.empty();

      expect(stats.totalSessions, 0);
      expect(stats.totalMinutes, 0);
      expect(stats.averageMinutes, 0);
      expect(stats.totalPauses, 0);
      expect(stats.sessionsWithPauses, 0);
      expect(stats.mostCommonDuration, 0);
    });

    test('pauseRate returns 0 when no sessions', () {
      final stats = TimerStatistics.empty();

      expect(stats.pauseRate, 0);
    });

    test('pauseRate calculates correctly', () {
      const stats = TimerStatistics(
        totalSessions: 10,
        totalMinutes: 600,
        averageMinutes: 60,
        totalPauses: 5,
        sessionsWithPauses: 3,
        mostCommonDuration: 60,
      );

      expect(stats.pauseRate, 0.3);
    });

    test('formattedTotalTime formats hours and minutes', () {
      const stats = TimerStatistics(
        totalSessions: 1,
        totalMinutes: 125,
        averageMinutes: 125,
        totalPauses: 0,
        sessionsWithPauses: 0,
        mostCommonDuration: 125,
      );

      expect(stats.formattedTotalTime, '2h 5m');
    });

    test('formattedTotalTime formats minutes only', () {
      const stats = TimerStatistics(
        totalSessions: 1,
        totalMinutes: 45,
        averageMinutes: 45,
        totalPauses: 0,
        sessionsWithPauses: 0,
        mostCommonDuration: 45,
      );

      expect(stats.formattedTotalTime, '45m');
    });
  });

  group('DateRange', () {
    test('creates date range with start and end', () {
      final start = DateTime(2024);
      final end = DateTime(2024, 1, 31);
      final range = DateRange(start, end);

      expect(range.start, start);
      expect(range.end, end);
    });
  });
}

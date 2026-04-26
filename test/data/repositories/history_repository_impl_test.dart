import 'package:alchronos/app_database.dart';
import 'package:alchronos/data/repositories/history_repository_impl.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAppDatabase implements AppDatabase {
  List<TimerSessionData> sessions = [];
  bool shouldThrow = false;
  int clearAllCalledCount = 0;

  @override
  Future<int> insertTimerSession(Insertable<TimerSessionData> session) async {
    if (shouldThrow) throw Exception('Database error');

    // Simulate inserting
    final insertable = session as TimerSessionCompanion;
    final newSession = TimerSessionData(
      id: sessions.length + 1,
      durationMinutes: insertable.durationMinutes.value,
      startTime: insertable.startTime.value,
      endTime: insertable.endTime.value,
      wasPaused: insertable.wasPaused.value,
      pauseCount: insertable.pauseCount.value,
      createdAt: insertable.createdAt.value,
    );
    sessions.add(newSession);
    return newSession.id;
  }

  @override
  Future<List<TimerSessionData>> getTimerSessions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    if (shouldThrow) throw Exception('Database error');

    var result = sessions.toList();
    if (startDate != null) {
      result = result.where((s) => !s.createdAt.isBefore(startDate)).toList();
    }
    if (endDate != null) {
      result = result.where((s) => !s.createdAt.isAfter(endDate)).toList();
    }

    // Sort descending by created at to match real db
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null && result.length > limit) {
      result = result.take(limit).toList();
    }
    return result;
  }

  @override
  Future<void> clearAllTimerSessions() async {
    if (shouldThrow) throw Exception('Database error');
    clearAllCalledCount++;
    sessions.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late HistoryRepositoryImpl repository;
  late FakeAppDatabase fakeDatabase;

  setUp(() {
    fakeDatabase = FakeAppDatabase();
    repository = HistoryRepositoryImpl(appDatabase: fakeDatabase);
  });

  group('saveCompletedSession', () {
    test('successfully saves a session', () async {
      final startTime = DateTime.now().subtract(const Duration(minutes: 30));
      final endTime = DateTime.now();

      await repository.saveCompletedSession(
        durationMinutes: 30,
        startTime: startTime,
        endTime: endTime,
        wasPaused: true,
        pauseCount: 2,
      );

      expect(fakeDatabase.sessions.length, 1);
      final saved = fakeDatabase.sessions.first;
      expect(saved.durationMinutes, 30);
      expect(saved.startTime, startTime);
      expect(saved.endTime, endTime);
      expect(saved.wasPaused, isTrue);
      expect(saved.pauseCount, 2);
    });

    test('ignores exceptions when saving', () async {
      fakeDatabase.shouldThrow = true;

      final startTime = DateTime.now().subtract(const Duration(minutes: 30));
      final endTime = DateTime.now();

      // Should not throw
      await repository.saveCompletedSession(
        durationMinutes: 30,
        startTime: startTime,
        endTime: endTime,
        wasPaused: false,
      );
      expect(fakeDatabase.sessions, isEmpty);
    });
  });

  group('getHistory', () {
    test('returns sessions sorted and filtered', () async {
      final now = DateTime.now();
      fakeDatabase.sessions = [
        TimerSessionData(
          id: 1,
          durationMinutes: 10,
          startTime: now,
          endTime: now,
          wasPaused: false,
          pauseCount: 0,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        TimerSessionData(
          id: 2,
          durationMinutes: 20,
          startTime: now,
          endTime: now,
          wasPaused: false,
          pauseCount: 0,
          createdAt: now,
        ),
        TimerSessionData(
          id: 3,
          durationMinutes: 30,
          startTime: now,
          endTime: now,
          wasPaused: false,
          pauseCount: 0,
          createdAt: now.subtract(const Duration(days: 4)),
        ),
      ];

      final result = await repository.getHistory(
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now,
      );

      expect(result.length, 2);
      expect(result.first.id, 2); // newest first
      expect(result[1].id, 1);
    });

    test('returns empty list on exception', () async {
      fakeDatabase.shouldThrow = true;
      final result = await repository.getHistory();
      expect(result, isEmpty);
    });
  });

  group('getStatistics', () {
    test('returns correct statistics for sessions', () async {
      final now = DateTime.now();
      fakeDatabase.sessions = [
        TimerSessionData(
          id: 1,
          durationMinutes: 30,
          startTime: now,
          endTime: now,
          wasPaused: true,
          pauseCount: 1,
          createdAt: now,
        ),
        TimerSessionData(
          id: 2,
          durationMinutes: 30,
          startTime: now,
          endTime: now,
          wasPaused: false,
          pauseCount: 0,
          createdAt: now,
        ),
        TimerSessionData(
          id: 3,
          durationMinutes: 60,
          startTime: now,
          endTime: now,
          wasPaused: true,
          pauseCount: 2,
          createdAt: now,
        ),
      ];

      final stats = await repository.getStatistics();

      expect(stats.totalSessions, 3);
      expect(stats.totalMinutes, 120);
      expect(stats.averageMinutes, 40);
      expect(stats.totalPauses, 3);
      expect(stats.sessionsWithPauses, 2);
      expect(stats.mostCommonDuration, 30);
    });

    test('returns empty statistics when there are no sessions', () async {
      final stats = await repository.getStatistics();
      expect(stats.totalSessions, 0);
      expect(stats.totalMinutes, 0);
    });

    test('returns empty statistics on exception', () async {
      fakeDatabase.shouldThrow = true;
      final stats = await repository.getStatistics();
      expect(stats.totalSessions, 0);
    });
  });

  group('clearHistory', () {
    test('clears all sessions', () async {
      await repository.clearHistory();
      expect(fakeDatabase.clearAllCalledCount, 1);
    });

    test('ignores exception when clearing', () async {
      fakeDatabase.shouldThrow = true;
      await repository.clearHistory(); // should not throw
      expect(fakeDatabase.clearAllCalledCount, 0);
    });
  });
}

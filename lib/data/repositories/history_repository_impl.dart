import 'package:alchronos/app_database.dart';
import 'package:alchronos/data/sources/database_provider.dart';
import 'package:alchronos/domain/repositories/history_repository.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(
    appDatabase: ref.watch(databaseProvider),
  );
});

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required this.appDatabase});

  final AppDatabase appDatabase;

  @override
  Future<void> saveCompletedSession({
    required int durationMinutes,
    required DateTime startTime,
    required DateTime endTime,
    required bool wasPaused,
    int? pauseCount,
  }) async {
    try {
      final session = TimerSessionCompanion(
        durationMinutes: Value(durationMinutes),
        startTime: Value(startTime),
        endTime: Value(endTime),
        wasPaused: Value(wasPaused),
        pauseCount: Value(pauseCount ?? 0),
        createdAt: Value(DateTime.now()),
      );

      await appDatabase.insertTimerSession(session);
    } on Exception {
      // Ignored
    }
  }

  @override
  Future<List<TimerSessionData>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      return await appDatabase.getTimerSessions(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    } on Exception {
      return [];
    }
  }

  @override
  Future<TimerStatistics> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sessions = await getHistory(
        startDate: startDate,
        endDate: endDate,
      );

      if (sessions.isEmpty) {
        return TimerStatistics.empty();
      }

      final totalSessions = sessions.length;
      final totalMinutes = sessions.fold<int>(
        0,
        (sum, session) => sum + session.durationMinutes,
      );
      final averageMinutes = totalMinutes / totalSessions;
      final totalPauses =
          sessions.fold<int>(0, (sum, session) => sum + session.pauseCount);
      final sessionsWithPauses = sessions.where((s) => s.wasPaused).length;

      // Find most common duration
      final durationCounts = <int, int>{};
      for (final session in sessions) {
        durationCounts[session.durationMinutes] =
            (durationCounts[session.durationMinutes] ?? 0) + 1;
      }
      final mostCommonDuration = durationCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      return TimerStatistics(
        totalSessions: totalSessions,
        totalMinutes: totalMinutes,
        averageMinutes: averageMinutes,
        totalPauses: totalPauses,
        sessionsWithPauses: sessionsWithPauses,
        mostCommonDuration: mostCommonDuration,
        dateRange: startDate != null && endDate != null
            ? DateRange(startDate, endDate)
            : null,
      );
    } on Exception {
      return TimerStatistics.empty();
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await appDatabase.clearAllTimerSessions();
    } on Exception catch (_) {
      // Ignored
    }
  }
}

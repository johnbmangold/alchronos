import 'package:alchronos/app_database.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class HistoryService {
  HistoryService(this._appDatabase, this._logger);

  final AppDatabase _appDatabase;
  final Logger _logger;

  /// Save a completed timer session
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

      await _appDatabase.insertTimerSession(session);
    } on Exception catch (e) {
      // Log error but don't throw - history is not critical
      _logger.e('Error saving timer session: $e');
    }
  }

  /// Get timer history for a date range
  Future<List<TimerSessionData>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      return await _appDatabase.getTimerSessions(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    } on Exception catch (e) {
      _logger.e('Error getting timer history: $e');
      return [];
    }
  }

  /// Get statistics for a date range
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
    } on Exception catch (e) {
      _logger.e('Error getting timer statistics: $e');
      return TimerStatistics.empty();
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      await _appDatabase.clearAllTimerSessions();
    } on Exception catch (e) {
      _logger.e('Error clearing timer history: $e');
    }
  }
}

class TimerStatistics {
  const TimerStatistics({
    required this.totalSessions,
    required this.totalMinutes,
    required this.averageMinutes,
    required this.totalPauses,
    required this.sessionsWithPauses,
    required this.mostCommonDuration,
    this.dateRange,
  });

  factory TimerStatistics.empty() {
    return const TimerStatistics(
      totalSessions: 0,
      totalMinutes: 0,
      averageMinutes: 0,
      totalPauses: 0,
      sessionsWithPauses: 0,
      mostCommonDuration: 0,
    );
  }

  final int totalSessions;
  final int totalMinutes;
  final double averageMinutes;
  final int totalPauses;
  final int sessionsWithPauses;
  final int mostCommonDuration;
  final DateRange? dateRange;

  double get pauseRate =>
      totalSessions > 0 ? sessionsWithPauses / totalSessions : 0;
  String get formattedTotalTime {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class DateRange {
  const DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;
}

import 'package:alchronos/app_database.dart';

/// Repository interface for managing historical timer sessions.
abstract class HistoryRepository {
  /// Saves a completed timer session to history.
  Future<void> saveCompletedSession({
    required int durationMinutes,
    required DateTime startTime,
    required DateTime endTime,
    required bool wasPaused,
    int? pauseCount,
  });

  /// Retrieves a list of historical timer sessions, optionally filtered
  /// by date.
  Future<List<TimerSessionData>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Retrieves aggregate statistics for timer sessions.
  Future<TimerStatistics> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Clears all historical timer sessions.
  Future<void> clearHistory();
}

/// Contains aggregate statistics about timer sessions.
class TimerStatistics {
  /// Creates a new [TimerStatistics] instance.
  const TimerStatistics({
    required this.totalSessions,
    required this.totalMinutes,
    required this.averageMinutes,
    required this.totalPauses,
    required this.sessionsWithPauses,
    required this.mostCommonDuration,
    this.dateRange,
  });

  /// Creates an empty [TimerStatistics] instance with zeroed values.
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

  /// The total number of completed sessions.
  final int totalSessions;

  /// The total duration of all sessions in minutes.
  final int totalMinutes;

  /// The average duration of a session in minutes.
  final double averageMinutes;

  /// The total number of times sessions were paused.
  final int totalPauses;

  /// The number of sessions that had at least one pause.
  final int sessionsWithPauses;

  /// The most frequent session duration in minutes.
  final int mostCommonDuration;

  /// The date range covered by these statistics.
  final DateRange? dateRange;

  /// The ratio of sessions with pauses to total sessions.
  double get pauseRate =>
      totalSessions > 0 ? sessionsWithPauses / totalSessions : 0;

  /// A formatted string representing the total time across all sessions.
  String get formattedTotalTime {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Represents a range between two dates.
class DateRange {
  /// Creates a new [DateRange] instance.
  const DateRange(this.start, this.end);

  /// The start date.
  final DateTime start;

  /// The end date.
  final DateTime end;
}

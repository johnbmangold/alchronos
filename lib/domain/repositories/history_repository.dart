import 'package:alchronos/app_database.dart';

abstract class HistoryRepository {
  Future<void> saveCompletedSession({
    required int durationMinutes,
    required DateTime startTime,
    required DateTime endTime,
    required bool wasPaused,
    int? pauseCount,
  });

  Future<List<TimerSessionData>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  Future<TimerStatistics> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> clearHistory();
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

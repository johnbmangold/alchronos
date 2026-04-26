import 'package:alchronos/app_database.dart';

/// Repository interface for managing partial or ongoing timer runs.
abstract class PartialRunRepository {
  /// Retrieves a partial run that is active after the given [time].
  Future<PartialRunData?> getPartialRunAfterTime(DateTime time);

  /// Clears existing runs and stores a new partial run ending at [endTime].
  Future<int> clearRunsAndPutPartialRun(
    DateTime endTime,
    int secondsRemaining,
  );

  /// Counts the total number of stored partial runs.
  Future<int> count();

  /// Clears all stored partial runs.
  Future<int> clearAllPartialRuns();
}

import 'package:alchronos/app_database.dart';

abstract class PartialRunRepository {
  Future<PartialRunData?> getPartialRunAfterTime(DateTime time);
  Future<int> clearRunsAndPutPartialRun(
    DateTime endTime,
    int secondsRemaining,
  );
  Future<int> count();
  Future<int> clearAllPartialRuns();
}

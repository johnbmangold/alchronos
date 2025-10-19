import 'package:alchronos/app_database.dart';
import 'package:alchronos/services/partial_run_service.dart';
import 'package:injectable/injectable.dart';

@injectable
class PartialRunRepository {
  PartialRunRepository({required PartialRunService partialRunService})
      : _partialRunService = partialRunService;

  final PartialRunService _partialRunService;

  Future<PartialRunData?> getPartialRunAfterTime(DateTime time) {
    return _partialRunService.getPartialRunAfterTime(time);
  }

  Future<int> clearRunsAndPutPartialRun(
    DateTime endTime,
    int secondsRemaining,
  ) async {
    await _partialRunService.deleteAllPartialRuns();
    return _putPartialRun(endTime, secondsRemaining);
  }

  Future<int> _putPartialRun(DateTime endTime, int secondsRemaining) {
    return _partialRunService.putPartialRun(endTime, secondsRemaining);
  }

  Future<int> count() {
    return _partialRunService.count();
  }

  Future<int> clearAllPartialRuns() {
    return _partialRunService.deleteAllPartialRuns();
  }
}

import 'package:alchronos/home/models/partial_run.dart';
import 'package:alchronos/services/partial_run_service.dart';

class PartialRunRepository {
  PartialRunRepository({required PartialRunService partialRunService})
      : _partialRunService = partialRunService;

  final PartialRunService _partialRunService;

  Future<PartialRun?> getPartialRunAfterTime(DateTime time) {
    return _partialRunService.getPartialRunAfterTime(time);
  }

  Future<int> clearRunsAndPutPartialRun(PartialRun partialRun) async {
    await _partialRunService.deleteAllPartialRuns();
    return _putPartialRun(partialRun);
  }

  Future<int> _putPartialRun(PartialRun partialRun) {
    return _partialRunService.putPartialRun(partialRun);
  }

  Future<int> count() {
    return _partialRunService.count();
  }
}

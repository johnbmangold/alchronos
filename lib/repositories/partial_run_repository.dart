import 'package:alchronos/home/models/partial_run.dart';
import 'package:alchronos/services/partial_run_service.dart';

class PartialRunRepository {
  PartialRunRepository({required this.partialRunService});

  final PartialRunService partialRunService;

  Future<PartialRun?> getPartialRunAfterTime(DateTime time) {
    return partialRunService.getPartialRunAfterTime(time);
  }

  Future<int> clearRunsAndPutPartialRun(PartialRun partialRun) async {
    await partialRunService.deleteAllPartialRuns();
    return _putPartialRun(partialRun);
  }

  Future<int> _putPartialRun(PartialRun partialRun) {
    return partialRunService.putPartialRun(partialRun);
  }
}

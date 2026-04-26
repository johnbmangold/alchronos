import 'package:alchronos/app_database.dart';
import 'package:alchronos/data/sources/database_provider.dart';
import 'package:alchronos/domain/repositories/partial_run_repository.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final partialRunRepositoryProvider = Provider<PartialRunRepository>((ref) {
  return PartialRunRepositoryImpl(
    appDatabase: ref.watch(databaseProvider),
  );
});

class PartialRunRepositoryImpl implements PartialRunRepository {
  PartialRunRepositoryImpl({required this.appDatabase});

  final AppDatabase appDatabase;

  @override
  Future<PartialRunData?> getPartialRunAfterTime(DateTime time) async {
    return appDatabase.getPartialRunAfterTime(time: time);
  }

  @override
  Future<int> clearRunsAndPutPartialRun(
    DateTime endTime,
    int secondsRemaining,
  ) async {
    await clearAllPartialRuns();
    return _putPartialRun(endTime, secondsRemaining);
  }

  Future<int> _putPartialRun(DateTime endTime, int secondsRemaining) async {
    final entity = PartialRunCompanion(
      endTime: Value(endTime),
      secondsRemaining: Value(secondsRemaining),
    );
    return appDatabase.insertPartialRun(entity);
  }

  @override
  Future<int> count() async {
    return appDatabase.countPartialRuns();
  }

  @override
  Future<int> clearAllPartialRuns() async {
    return appDatabase.clearAllPartialRuns();
  }
}

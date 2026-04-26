import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class PartialRun extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get secondsRemaining => integer()();
  DateTimeColumn get endTime => dateTime()();
}

class TimerSession extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get durationMinutes => integer()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  BoolColumn get wasPaused => boolean().withDefault(const Constant(false))();
  IntColumn get pauseCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [PartialRun, TimerSession])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app_database');
  }

  // Partial Run methods
  Future<PartialRunData?> getPartialRunAfterTime({
    required DateTime time,
  }) async {
    final query = select(partialRun)
      ..where((t) => t.endTime.isBiggerThanValue(time))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<int> insertPartialRun(Insertable<PartialRunData> run) async {
    return into(partialRun).insert(run);
  }

  Future<int> countPartialRuns() async {
    final countExp = partialRun.id.count();
    final query = selectOnly(partialRun)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<int> clearAllPartialRuns() async {
    return delete(partialRun).go();
  }

  // Timer Session methods
  Future<int> insertTimerSession(Insertable<TimerSessionData> session) async {
    return into(timerSession).insert(session);
  }

  Future<List<TimerSessionData>> getTimerSessions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final query = select(timerSession);

    if (startDate != null) {
      query.where((t) => t.createdAt.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query.where((t) => t.createdAt.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.get();
  }

  Future<void> clearAllTimerSessions() async {
    await delete(timerSession).go();
  }
}

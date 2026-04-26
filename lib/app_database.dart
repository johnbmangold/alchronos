import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The table definition for storing partial timer runs.
class PartialRun extends Table {
  /// The unique identifier for the partial run.
  IntColumn get id => integer().autoIncrement()();

  /// The amount of seconds remaining when the run was recorded.
  IntColumn get secondsRemaining => integer()();

  /// The expected end time of the timer.
  DateTimeColumn get endTime => dateTime()();
}

/// The table definition for storing completed or recorded timer sessions.
class TimerSession extends Table {
  /// The unique identifier for the timer session.
  IntColumn get id => integer().autoIncrement()();

  /// The total duration of the timer in minutes.
  IntColumn get durationMinutes => integer()();

  /// The time when the timer started.
  DateTimeColumn get startTime => dateTime()();

  /// The time when the timer ended.
  DateTimeColumn get endTime => dateTime()();

  /// Indicates whether the timer was paused during its run.
  BoolColumn get wasPaused => boolean().withDefault(const Constant(false))();

  /// The number of times the timer was paused.
  IntColumn get pauseCount => integer().withDefault(const Constant(0))();

  /// The timestamp when this record was created.
  DateTimeColumn get createdAt => dateTime()();
}

/// The main Drift database class for the Alchronos application.
@DriftDatabase(tables: [PartialRun, TimerSession])
class AppDatabase extends _$AppDatabase {
  /// Creates the [AppDatabase] instance by opening a local connection.
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app_database');
  }

  /// Retrieves a partial run that is scheduled to end after the given [time].
  Future<PartialRunData?> getPartialRunAfterTime({
    required DateTime time,
  }) async {
    final query = select(partialRun)
      ..where((t) => t.endTime.isBiggerThanValue(time))
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Inserts a new [run] into the partial run table.
  Future<int> insertPartialRun(Insertable<PartialRunData> run) async {
    return into(partialRun).insert(run);
  }

  /// Returns the total count of stored partial runs.
  Future<int> countPartialRuns() async {
    final countExp = partialRun.id.count();
    final query = selectOnly(partialRun)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Deletes all entries in the partial run table.
  Future<int> clearAllPartialRuns() async {
    return delete(partialRun).go();
  }

  /// Inserts a new completed [session] into the timer session table.
  Future<int> insertTimerSession(Insertable<TimerSessionData> session) async {
    return into(timerSession).insert(session);
  }

  /// Retrieves timer sessions, optionally filtered by [startDate] and
  /// [endDate], and limited to [limit] results, ordered by creation
  /// date descending.
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

  /// Deletes all entries in the timer session table.
  Future<void> clearAllTimerSessions() async {
    await delete(timerSession).go();
  }
}

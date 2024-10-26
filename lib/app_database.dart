import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

part 'app_database.g.dart';

class PartialRun extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get secondsRemaining => integer()();
  DateTimeColumn get endTime => dateTime()();
}

@lazySingleton
@DriftDatabase(tables: [PartialRun])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app_database');
  }
}

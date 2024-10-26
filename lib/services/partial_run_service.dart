import 'dart:async';

import 'package:alchronos/app_database.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

@injectable
class PartialRunService {
  PartialRunService(this._db);

  final AppDatabase _db;

  Future<PartialRunData?> getPartialRunAfterTime(DateTime time) async {
    return _db.managers.partialRun
        .filter((f) => f.endTime.isAfter(time))
        .getSingleOrNull();
  }

  Future<PartialRunData?> getPartialRunBeforeTime(DateTime time) async {
    return _db.managers.partialRun
        .filter((f) => f.endTime.isBefore(time))
        .getSingleOrNull();
  }

  Future<int> putPartialRun(DateTime endTime, int secondsRemaining) async {
    return _db.managers.partialRun.create(
      (f) => f(
        endTime: endTime,
        secondsRemaining: secondsRemaining,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> deletePartialRun(int id) async {
    return _db.managers.partialRun.filter((f) => f.id(id)).delete();
  }

  Future<int> deleteAllPartialRuns() async {
    return _db.managers.partialRun.delete();
  }

  Future<int> count() async {
    return _db.managers.partialRun.count();
  }
}

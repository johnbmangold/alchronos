import 'dart:async';

import 'package:alchronos/home/home.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

@injectable
class PartialRunService {
  PartialRunService() {
    unawaited(db = _openDb());
  }

  late final Future<Isar> db;
  final String dbName = 'PartialRunSchema';

  Future<Isar> _openDb() async {
    if (Isar.instanceNames.contains(dbName)) {
      return Future.value(Isar.getInstance(dbName));
    }

    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [PartialRunSchema],
      directory: dir.path,
      name: dbName,
    );
  }

  Future<PartialRun?> getPartialRunAfterTime(DateTime time) async {
    final isar = await db;
    return isar.partialRuns.filter().endTimeGreaterThan(time).findFirst();
  }

  Future<PartialRun?> getPartialRunBeforeTime(DateTime time) async {
    final isar = await db;
    return isar.partialRuns.filter().endTimeLessThan(time).findFirst();
  }

  Future<int> putPartialRun(PartialRun partialRun) async {
    final isar = await db;
    return isar.writeTxn(() => isar.partialRuns.put(partialRun));
  }

  Future<bool> deletePartialRun(int id) async {
    final isar = await db;
    return isar.writeTxn(() => isar.partialRuns.delete(id));
  }

  Future<void> deleteAllPartialRuns() async {
    final isar = await db;
    return isar.writeTxn(() => isar.partialRuns.clear());
  }

  Future<int> count() async {
    final isar = await db;
    return isar.partialRuns.count();
  }
}

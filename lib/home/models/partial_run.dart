import 'package:isar/isar.dart';

part 'partial_run.g.dart';

@collection
class PartialRun {
  Id id = Isar.autoIncrement;
  int? secondsRemaining;
  DateTime? endTime;
}

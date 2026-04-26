import 'package:alchronos/app_database.dart';
import 'package:alchronos/data/repositories/partial_run_repository_impl.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

class FakeAppDatabase implements AppDatabase {
  List<PartialRunData> runs = [];
  int clearAllCalledCount = 0;
  bool shouldThrow = false;

  @override
  Future<PartialRunData?> getPartialRunAfterTime({
    required DateTime time,
  }) async {
    if (shouldThrow) throw Exception('Database error');

    for (final run in runs) {
      if (run.endTime.isAfter(time)) {
        return run; // Limit 1 in real DB
      }
    }
    return null;
  }

  @override
  Future<int> insertPartialRun(Insertable<PartialRunData> run) async {
    if (shouldThrow) throw Exception('Database error');

    final companion = run as PartialRunCompanion;
    final newRun = PartialRunData(
      id: runs.length + 1,
      secondsRemaining: companion.secondsRemaining.value,
      endTime: companion.endTime.value,
    );
    runs.add(newRun);
    return newRun.id;
  }

  @override
  Future<int> countPartialRuns() async {
    if (shouldThrow) throw Exception('Database error');
    return runs.length;
  }

  @override
  Future<int> clearAllPartialRuns() async {
    if (shouldThrow) throw Exception('Database error');
    clearAllCalledCount++;
    runs.clear();
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late PartialRunRepositoryImpl repository;
  late FakeAppDatabase fakeDatabase;

  setUp(() {
    fakeDatabase = FakeAppDatabase();
    repository = PartialRunRepositoryImpl(appDatabase: fakeDatabase);
  });

  group('getPartialRunAfterTime', () {
    test('returns null if no run exists after time', () async {
      fakeDatabase.runs = [
        PartialRunData(
          id: 1,
          secondsRemaining: 60,
          endTime: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];

      final result = await repository.getPartialRunAfterTime(DateTime.now());
      expect(result, isNull);
    });

    test('returns the run if it exists after time', () async {
      final endTime = DateTime.now().add(const Duration(minutes: 5));
      final run = PartialRunData(id: 1, secondsRemaining: 60, endTime: endTime);
      fakeDatabase.runs = [run];

      final result = await repository.getPartialRunAfterTime(DateTime.now());
      expect(result, isNotNull);
      expect(result?.id, 1);
    });
  });

  group('clearRunsAndPutPartialRun', () {
    test('clears existing runs and inserts the new one', () async {
      fakeDatabase.runs = [
        PartialRunData(id: 1, secondsRemaining: 60, endTime: DateTime.now()),
      ];

      final newEndTime = DateTime.now().add(const Duration(minutes: 10));
      await repository.clearRunsAndPutPartialRun(newEndTime, 600);

      expect(fakeDatabase.clearAllCalledCount, 1);
      expect(fakeDatabase.runs.length, 1);
      expect(fakeDatabase.runs.first.secondsRemaining, 600);
      expect(fakeDatabase.runs.first.endTime, newEndTime);
    });
  });

  group('count', () {
    test('returns the correct number of partial runs', () async {
      fakeDatabase.runs = [
        PartialRunData(id: 1, secondsRemaining: 60, endTime: DateTime.now()),
        PartialRunData(id: 2, secondsRemaining: 60, endTime: DateTime.now()),
      ];

      final count = await repository.count();
      expect(count, 2);
    });
  });

  group('clearAllPartialRuns', () {
    test('clears all partial runs', () async {
      fakeDatabase.runs = [
        PartialRunData(id: 1, secondsRemaining: 60, endTime: DateTime.now()),
      ];

      await repository.clearAllPartialRuns();
      expect(fakeDatabase.clearAllCalledCount, 1);
      expect(fakeDatabase.runs, isEmpty);
    });
  });
}

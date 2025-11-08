import 'package:alchronos/app_database.dart';
import 'package:alchronos/services/partial_run_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'partial_run_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AppDatabase>()])
void main() {
  group('PartialRunService', () {
    late PartialRunService partialRunService;
    late MockAppDatabase mockDatabase;
    late MockPartialRunTableManager mockPartialRunManager;
    late MockPartialRunFilter mockFilter;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockPartialRunManager = MockPartialRunTableManager();
      mockFilter = MockPartialRunFilter();

      when(mockDatabase.managers).thenReturn(
        MockAppDatabaseManagers(
          partialRun: mockPartialRunManager,
        ),
      );

      partialRunService = PartialRunService(mockDatabase);
    });

    group('getPartialRunAfterTime', () {
      test('returns PartialRunData when found', () async {
        final testTime = DateTime(2024, 1, 1);
        final expectedData = PartialRunData(
          id: 1,
          endTime: DateTime(2024, 1, 2),
          secondsRemaining: 60,
        );

        when(mockPartialRunManager.filter(any))
            .thenReturn(mockFilter);
        when(mockFilter.getSingleOrNull())
            .thenAnswer((_) async => expectedData);

        final result =
            await partialRunService.getPartialRunAfterTime(testTime);

        expect(result, expectedData);
      });

      test('returns null when not found', () async {
        final testTime = DateTime(2024, 1, 1);

        when(mockPartialRunManager.filter(any))
            .thenReturn(mockFilter);
        when(mockFilter.getSingleOrNull()).thenAnswer((_) async => null);

        final result =
            await partialRunService.getPartialRunAfterTime(testTime);

        expect(result, isNull);
      });
    });

    group('getPartialRunBeforeTime', () {
      test('returns PartialRunData when found', () async {
        final testTime = DateTime(2024, 1, 2);
        final expectedData = PartialRunData(
          id: 1,
          endTime: DateTime(2024, 1, 1),
          secondsRemaining: 60,
        );

        when(mockPartialRunManager.filter(any))
            .thenReturn(mockFilter);
        when(mockFilter.getSingleOrNull())
            .thenAnswer((_) async => expectedData);

        final result =
            await partialRunService.getPartialRunBeforeTime(testTime);

        expect(result, expectedData);
      });

      test('returns null when not found', () async {
        final testTime = DateTime(2024, 1, 1);

        when(mockPartialRunManager.filter(any))
            .thenReturn(mockFilter);
        when(mockFilter.getSingleOrNull()).thenAnswer((_) async => null);

        final result =
            await partialRunService.getPartialRunBeforeTime(testTime);

        expect(result, isNull);
      });
    });

    group('putPartialRun', () {
      test('creates and returns id', () async {
        final endTime = DateTime(2024, 1, 1);
        const secondsRemaining = 60;
        const expectedId = 1;

        when(
          mockPartialRunManager.create(
            any,
            mode: anyNamed('mode'),
          ),
        ).thenAnswer((_) async => expectedId);

        final result = await partialRunService.putPartialRun(
          endTime,
          secondsRemaining,
        );

        expect(result, expectedId);
        verify(
          mockPartialRunManager.create(
            any,
            mode: InsertMode.insertOrReplace,
          ),
        ).called(1);
      });
    });

    group('deletePartialRun', () {
      test('deletes partial run by id', () async {
        const id = 1;
        const expectedDeleted = 1;

        when(mockPartialRunManager.filter(any))
            .thenReturn(mockFilter);
        when(mockFilter.delete()).thenAnswer((_) async => expectedDeleted);

        final result = await partialRunService.deletePartialRun(id);

        expect(result, expectedDeleted);
      });
    });

    group('deleteAllPartialRuns', () {
      test('deletes all partial runs', () async {
        const expectedDeleted = 5;

        when(mockPartialRunManager.delete())
            .thenAnswer((_) async => expectedDeleted);

        final result = await partialRunService.deleteAllPartialRuns();

        expect(result, expectedDeleted);
        verify(mockPartialRunManager.delete()).called(1);
      });
    });

    group('count', () {
      test('returns count of partial runs', () async {
        const expectedCount = 3;

        when(mockPartialRunManager.count())
            .thenAnswer((_) async => expectedCount);

        final result = await partialRunService.count();

        expect(result, expectedCount);
        verify(mockPartialRunManager.count()).called(1);
      });
    });
  });
}

// Mock classes for AppDatabase structure
class MockAppDatabaseManagers {
  MockAppDatabaseManagers({required this.partialRun});

  final MockPartialRunTableManager partialRun;
}

class MockPartialRunTableManager extends Mock {
  MockPartialRunFilter filter(dynamic Function(dynamic) f) => super.noSuchMethod(
        Invocation.method(#filter, [f]),
        returnValue: MockPartialRunFilter(),
      );

  Future<int> create(
    dynamic Function(dynamic) f, {
    required InsertMode mode,
  }) =>
      super.noSuchMethod(
        Invocation.method(#create, [f], {#mode: mode}),
        returnValue: Future<int>.value(0),
      );

  Future<int> delete() => super.noSuchMethod(
        Invocation.method(#delete, []),
        returnValue: Future<int>.value(0),
      );

  Future<int> count() => super.noSuchMethod(
        Invocation.method(#count, []),
        returnValue: Future<int>.value(0),
      );
}

class MockPartialRunFilter extends Mock {
  Future<PartialRunData?> getSingleOrNull() => super.noSuchMethod(
        Invocation.method(#getSingleOrNull, []),
        returnValue: Future<PartialRunData?>.value(null),
      );

  Future<int> delete() => super.noSuchMethod(
        Invocation.method(#delete, []),
        returnValue: Future<int>.value(0),
      );

  MockPartialRunFilter id(int id) => super.noSuchMethod(
        Invocation.method(#id, [id]),
        returnValue: MockPartialRunFilter(),
      );
}


import 'package:alchronos/app_database.dart';
import 'package:alchronos/repositories/repositories.dart';
import 'package:alchronos/services/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'partial_run_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PartialRunService>()])
void main() async {
  late MockPartialRunService mockPartialRunService;
  late PartialRunRepository partialRunRepository;
  final afterDate = DateTime(2070);

  setUp(() {
    mockPartialRunService = MockPartialRunService();
    partialRunRepository =
        PartialRunRepository(partialRunService: mockPartialRunService);
  });

  PartialRunData getPartialRunAfter() {
    final partialRun =
        PartialRunData(id: -1, endTime: afterDate, secondsRemaining: 22);
    return partialRun;
  }

  test(
    'getPartialRunAfterTime returns PartialRun when time is before',
    () async {
      final partialRun = getPartialRunAfter();
      when(mockPartialRunService.getPartialRunAfterTime(any))
          .thenAnswer((realInvocation) => Future.value(partialRun));
      final pRun =
          await partialRunRepository.getPartialRunAfterTime(DateTime.now());
      expect(pRun, isNotNull);
    },
  );

  test(
    'getPartialRunAfterTime returns null when time is after',
    () async {
      final pRun =
          await partialRunRepository.getPartialRunAfterTime(DateTime.now());
      expect(pRun, isNull);
    },
  );

  test(
    'clearRunsAndPutPartialRun clears and stores only one',
    () async {
      when(mockPartialRunService.count())
          .thenAnswer((realInvocation) async => 123);
      when(mockPartialRunService.putPartialRun(any, any))
          .thenAnswer((realInvocation) async => 321);
      expect(await partialRunRepository.count(), 123);
      final id = await partialRunRepository.clearRunsAndPutPartialRun(
        DateTime.now(),
        33,
      );
      expect(id, 321);
    },
  );

  test(
    'count returns count',
    () async {
      when(mockPartialRunService.count())
          .thenAnswer((realInvocation) async => 123);
      expect(await partialRunRepository.count(), 123);
    },
  );
}

import 'package:alchronos/app_database.dart';
import 'package:alchronos/core/errors/app_exceptions.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:alchronos/home/views/home_start_view.dart';
import 'package:alchronos/repositories/repositories.dart';
import 'package:alchronos/services/audio_service.dart';
import 'package:alchronos/services/haptic_service.dart';
import 'package:alchronos/services/history_service.dart';
import 'package:alchronos/services/performance_service.dart';
import 'package:alchronos/services/settings_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_cubit_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PartialRunRepository>(),
  MockSpec<FlutterLocalNotificationsPlugin>(),
  MockSpec<StorageRepository>(),
  MockSpec<HapticService>(),
  MockSpec<AudioService>(),
  MockSpec<SettingsService>(),
  MockSpec<PerformanceService>(),
  MockSpec<HistoryService>(),
  MockSpec<Logger>(),
])
void main() {
  group('HomeCubit', () {
    late HomeCubit homeCubit;
    late MockPartialRunRepository mockPartialRunRepository;
    late MockFlutterLocalNotificationsPlugin
        mockFlutterLocalNotificationsPlugin;
    late MockStorageRepository mockStorageRepository;
    late MockHapticService mockHapticService;
    late MockAudioService mockAudioService;
    late MockSettingsService mockSettingsService;
    late MockPerformanceService mockPerformanceService;
    late MockHistoryService mockHistoryService;
    late MockLogger mockLogger;

    setUp(() {
      mockPartialRunRepository = MockPartialRunRepository();
      mockFlutterLocalNotificationsPlugin =
          MockFlutterLocalNotificationsPlugin();
      mockStorageRepository = MockStorageRepository();
      mockHapticService = MockHapticService();
      mockAudioService = MockAudioService();
      mockSettingsService = MockSettingsService();
      mockPerformanceService = MockPerformanceService();
      mockHistoryService = MockHistoryService();
      mockLogger = MockLogger();

      homeCubit = HomeCubit(
        logger: mockLogger,
        partialRunRepository: mockPartialRunRepository,
        flutterLocalNotificationsPlugin: mockFlutterLocalNotificationsPlugin,
        storageRepository: mockStorageRepository,
        hapticService: mockHapticService,
        audioService: mockAudioService,
        settingsService: mockSettingsService,
        performanceService: mockPerformanceService,
        historyService: mockHistoryService,
      );
    });

    tearDown(() {
      homeCubit.close();
    });

    group('init', () {
      test('emits HomeStart when no partial run exists', () async {
        when(mockStorageRepository.readTimerDurationPreference())
            .thenAnswer((_) async => TimerDuration.standard);
        when(mockPartialRunRepository.getPartialRunAfterTime(any))
            .thenAnswer((_) async => null);
        when(mockPerformanceService.startTiming(any)).thenReturn(null);
        when(mockPerformanceService.trackTimerEvent(any, duration: any))
            .thenReturn(null);
        when(mockPerformanceService.endTiming(any)).thenReturn(null);

        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.init();

        expect(states.last, isA<HomeStart>());
        verify(mockPerformanceService.startTiming('init')).called(1);
        verify(mockPerformanceService.endTiming('init')).called(1);
        verify(mockPerformanceService.trackTimerEvent('start_fresh'))
            .called(1);
      });

      test('emits HomeRunning when partial run exists', () async {
        final partialRun = PartialRunData(
          id: 1,
          endTime: DateTime.now().add(const Duration(minutes: 60)),
          secondsRemaining: 3600,
        );

        when(mockStorageRepository.readTimerDurationPreference())
            .thenAnswer((_) async => TimerDuration.standard);
        when(mockPartialRunRepository.getPartialRunAfterTime(any))
            .thenAnswer((_) async => partialRun);
        when(mockPerformanceService.startTiming(any)).thenReturn(null);
        when(mockPerformanceService.trackTimerEvent(any, duration: any))
            .thenReturn(null);
        when(mockPerformanceService.endTiming(any)).thenReturn(null);

        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.init();

        expect(states.last, isA<HomeRunning>());
        verify(mockPerformanceService.trackTimerEvent(
          'resume_existing',
          duration: 60,
        )).called(1);
      });

      test('emits HomeError when exception occurs', () async {
        when(mockStorageRepository.readTimerDurationPreference())
            .thenThrow(const StorageException('Storage error'));
        when(mockPerformanceService.startTiming(any)).thenReturn(null);
        when(mockPerformanceService.endTiming(any)).thenReturn(null);

        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.init();

        expect(states.last, isA<HomeError>());
      });
    });

    group('reset', () {
      test('emits HomeStart and clears partial runs', () async {
        when(mockPartialRunRepository.clearAllPartialRuns())
            .thenAnswer((_) async => 1);
        when(mockHapticService.timerStop())
            .thenAnswer((_) async => {});
        when(mockAudioService.playButtonClickSound())
            .thenAnswer((_) async => {});
        when(mockPerformanceService.trackTimerEvent(any))
            .thenReturn(null);

        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.reset();

        expect(states.last, isA<HomeStart>());
        verify(mockPartialRunRepository.clearAllPartialRuns()).called(1);
        verify(mockHapticService.timerStop()).called(1);
        verify(mockAudioService.playButtonClickSound()).called(1);
        verify(mockPerformanceService.trackTimerEvent('stop')).called(1);
      });

      test('saves completed session when timer was running', () async {
        final partialRun = PartialRunData(
          id: 1,
          endTime: DateTime.now().add(const Duration(minutes: 60)),
          secondsRemaining: 3600,
        );

        when(mockPartialRunRepository.clearAllPartialRuns())
            .thenAnswer((_) async => 1);
        when(mockHapticService.timerStop())
            .thenAnswer((_) async => {});
        when(mockAudioService.playButtonClickSound())
            .thenAnswer((_) async => {});
        when(mockPerformanceService.trackTimerEvent(any))
            .thenReturn(null);
        when(mockHistoryService.saveCompletedSession(
          durationMinutes: anyNamed('durationMinutes'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
          wasPaused: anyNamed('wasPaused'),
          pauseCount: anyNamed('pauseCount'),
        )).thenAnswer((_) async => {});

        // Set initial state to HomeRunning
        homeCubit.emit(
          HomeRunning(
            partialRunData: partialRun,
            totalDurationInSeconds: 3600,
          ),
        );

        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.reset();

        expect(states.last, isA<HomeStart>());
        verify(mockHistoryService.saveCompletedSession(
          durationMinutes: anyNamed('durationMinutes'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
          wasPaused: anyNamed('wasPaused'),
          pauseCount: anyNamed('pauseCount'),
        )).called(1);
      });
    });

    group('pauseTimer', () {
      test('pauses timer when running and not paused', () async {
        final partialRun = PartialRunData(
          id: 1,
          endTime: DateTime.now().add(const Duration(minutes: 60)),
          secondsRemaining: 3600,
        );

        when(mockPerformanceService.trackTimerEvent(
          any,
          duration: any,
        )).thenReturn(null);
        when(mockHapticService.timerToggle())
            .thenAnswer((_) async => {});

        homeCubit.emit(
          HomeRunning(
            partialRunData: partialRun,
            totalDurationInSeconds: 3600,
            isPaused: false,
          ),
        );

        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.pauseTimer();

        expect(states.last, isA<HomeRunning>());
        expect((states.last as HomeRunning).isPaused, isTrue);
        verify(mockHapticService.timerToggle()).called(1);
        verify(mockPerformanceService.trackTimerEvent(
          'pause',
          duration: 60,
        )).called(1);
      });

      test('does nothing when timer is already paused', () async {
        final partialRun = PartialRunData(
          id: 1,
          endTime: DateTime.now().add(const Duration(minutes: 60)),
          secondsRemaining: 3600,
        );

        homeCubit.emit(
          HomeRunning(
            partialRunData: partialRun,
            totalDurationInSeconds: 3600,
            isPaused: true,
          ),
        );

        final initialState = homeCubit.state;
        await homeCubit.pauseTimer();

        expect(homeCubit.state, initialState);
      });
    });

    group('resumeTimer', () {
      test('resumes timer when paused', () async {
        final partialRun = PartialRunData(
          id: 1,
          endTime: DateTime.now().add(const Duration(minutes: 60)),
          secondsRemaining: 3600,
        );

        when(mockPerformanceService.trackTimerEvent(
          any,
          duration: any,
        )).thenReturn(null);
        when(mockHapticService.timerToggle())
            .thenAnswer((_) async => {});

        homeCubit.emit(
          HomeRunning(
            partialRunData: partialRun,
            totalDurationInSeconds: 3600,
            isPaused: true,
          ),
        );

        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.resumeTimer();

        expect(states.last, isA<HomeRunning>());
        expect((states.last as HomeRunning).isPaused, isFalse);
        verify(mockHapticService.timerToggle()).called(1);
        verify(mockPerformanceService.trackTimerEvent(
          'resume',
          duration: 60,
        )).called(1);
      });

      test('does nothing when timer is not paused', () async {
        final partialRun = PartialRunData(
          id: 1,
          endTime: DateTime.now().add(const Duration(minutes: 60)),
          secondsRemaining: 3600,
        );

        homeCubit.emit(
          HomeRunning(
            partialRunData: partialRun,
            totalDurationInSeconds: 3600,
            isPaused: false,
          ),
        );

        final initialState = homeCubit.state;
        await homeCubit.resumeTimer();

        expect(homeCubit.state, initialState);
      });
    });

    group('getPartialRun', () {
      test('returns partial run from repository', () async {
        final testTime = DateTime.now();
        final expectedPartialRun = PartialRunData(
          id: 1,
          endTime: testTime.add(const Duration(minutes: 60)),
          secondsRemaining: 3600,
        );

        when(mockPartialRunRepository.getPartialRunAfterTime(testTime))
            .thenAnswer((_) async => expectedPartialRun);

        final result = await homeCubit.getPartialRun(testTime);

        expect(result, expectedPartialRun);
        verify(mockPartialRunRepository.getPartialRunAfterTime(testTime))
            .called(1);
      });
    });

    group('getPreferredDuration', () {
      test('returns duration from storage repository', () async {
        when(mockStorageRepository.readTimerDurationPreference())
            .thenAnswer((_) async => TimerDuration.longer);

        final result = await homeCubit.getPreferredDuration();

        expect(result, TimerDuration.longer);
        verify(mockStorageRepository.readTimerDurationPreference()).called(1);
      });
    });

    group('writeCustomDuration', () {
      test('writes custom duration when valid', () async {
        when(mockStorageRepository.writeCustomDuration(any))
            .thenAnswer((_) async => {});

        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.writeCustomDuration(90);

        // Should not emit error state
        expect(states.whereType<HomeError>(), isEmpty);
      });

      test('emits HomeError when duration is invalid', () async {
        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.writeCustomDuration(0);

        expect(states.last, isA<HomeError>());
      });

      test('emits HomeError when duration exceeds max', () async {
        final states = <HomeState>[];
        homeCubit.stream.listen((state) => states.add(state));

        await homeCubit.writeCustomDuration(1441);

        expect(states.last, isA<HomeError>());
      });
    });

    group('durationStream', () {
      test('emits duration values', () async {
        final values = <int>[];
        final subscription = homeCubit.durationStream.listen((value) {
          values.add(value);
        });

        // Manually trigger stream emission through init
        when(mockStorageRepository.readTimerDurationPreference())
            .thenAnswer((_) async => TimerDuration.standard);
        when(mockPartialRunRepository.getPartialRunAfterTime(any))
            .thenAnswer((_) async => null);
        when(mockPerformanceService.startTiming(any)).thenReturn(null);
        when(mockPerformanceService.trackTimerEvent(any, duration: any))
            .thenReturn(null);
        when(mockPerformanceService.endTiming(any)).thenReturn(null);

        await homeCubit.init();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(values, isNotEmpty);
        await subscription.cancel();
      });
    });
  });
}

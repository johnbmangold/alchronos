import 'package:alchronos/app_database.dart';
import 'package:alchronos/domain/repositories/history_repository.dart';
import 'package:alchronos/domain/repositories/partial_run_repository.dart';
import 'package:alchronos/domain/repositories/settings_repository.dart';
import 'package:alchronos/domain/use_cases/timer_use_cases.dart';
import 'package:alchronos/infrastructure/services/audio_service.dart';
import 'package:alchronos/infrastructure/services/background_task_service.dart';
import 'package:alchronos/infrastructure/services/haptic_service.dart';
import 'package:alchronos/infrastructure/services/notification_service.dart';
import 'package:alchronos/infrastructure/services/performance_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSettingsRepository implements SettingsRepository {
  bool reminderEnabled = false;
  int reminderMinutes = 0;

  @override
  Future<bool> isReminderEnabled() async => reminderEnabled;

  @override
  Future<int> getReminderMinutes() async => reminderMinutes;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePartialRunRepository implements PartialRunRepository {
  int clearRunsCalledCount = 0;
  int clearAllPartialRunsCalledCount = 0;

  @override
  Future<int> clearRunsAndPutPartialRun(
    DateTime endTime,
    int durationInSeconds,
  ) async {
    clearRunsCalledCount++;
    return 1;
  }

  @override
  Future<int> clearAllPartialRuns() async {
    clearAllPartialRunsCalledCount++;
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHistoryRepository implements HistoryRepository {
  int saveCompletedSessionCalledCount = 0;

  @override
  Future<void> saveCompletedSession({
    required int durationMinutes,
    required DateTime startTime,
    required DateTime endTime,
    required bool wasPaused,
    int? pauseCount,
  }) async {
    saveCompletedSessionCalledCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNotificationService implements NotificationService {
  int scheduleReminderNotificationCalledCount = 0;

  @override
  Future<void> scheduleReminderNotification(
    int reminderMinutes,
    int totalMinutes,
    String drinkTimerComplete,
    String notificationMessage,
  ) async {
    scheduleReminderNotificationCalledCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBackgroundTaskService implements BackgroundTaskService {
  int scheduleTimerTaskCalledCount = 0;
  int cancelTimerTaskCalledCount = 0;

  @override
  Future<void> scheduleTimerTask(
    int durationMinutes,
    String drinkTimerComplete,
    String notificationMessage,
  ) async {
    scheduleTimerTaskCalledCount++;
  }

  @override
  Future<void> cancelTimerTask() async {
    cancelTimerTaskCalledCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHapticService implements HapticService {
  int timerStartCalledCount = 0;
  int timerStopCalledCount = 0;
  int timerToggleCalledCount = 0;

  @override
  Future<void> timerStart() async {
    timerStartCalledCount++;
  }

  @override
  Future<void> timerStop() async {
    timerStopCalledCount++;
  }

  @override
  Future<void> timerToggle() async {
    timerToggleCalledCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAudioService implements AudioService {
  int playTimerStartSoundCalledCount = 0;
  int playButtonClickSoundCalledCount = 0;

  @override
  Future<void> playTimerStartSound() async {
    playTimerStartSoundCalledCount++;
  }

  @override
  Future<void> playButtonClickSound() async {
    playButtonClickSoundCalledCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePerformanceService implements PerformanceService {
  int trackTimerEventCalledCount = 0;

  @override
  void trackTimerEvent(String eventType, {int? duration, bool? isPaused}) {
    trackTimerEventCalledCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeSettingsRepository fakeSettingsRepository;
  late FakePartialRunRepository fakePartialRunRepository;
  late FakeHistoryRepository fakeHistoryRepository;
  late FakeNotificationService fakeNotificationService;
  late FakeBackgroundTaskService fakeBackgroundTaskService;
  late FakeHapticService fakeHapticService;
  late FakeAudioService fakeAudioService;
  late FakePerformanceService fakePerformanceService;

  setUp(() {
    fakeSettingsRepository = FakeSettingsRepository();
    fakePartialRunRepository = FakePartialRunRepository();
    fakeHistoryRepository = FakeHistoryRepository();
    fakeNotificationService = FakeNotificationService();
    fakeBackgroundTaskService = FakeBackgroundTaskService();
    fakeHapticService = FakeHapticService();
    fakeAudioService = FakeAudioService();
    fakePerformanceService = FakePerformanceService();
  });

  group('StartTimerUseCase', () {
    late StartTimerUseCase useCase;

    setUp(() {
      useCase = StartTimerUseCase(
        settingsRepository: fakeSettingsRepository,
        partialRunRepository: fakePartialRunRepository,
        notificationService: fakeNotificationService,
        backgroundTaskService: fakeBackgroundTaskService,
        hapticService: fakeHapticService,
        audioService: fakeAudioService,
        performanceService: fakePerformanceService,
      );
    });

    test('should throw Exception when duration is invalid', () async {
      // Act & Assert
      expect(
        () => useCase.execute(0, 'Done', 'Message'),
        throwsException,
      );
      expect(
        () => useCase.execute(1441, 'Done', 'Message'),
        throwsException,
      );
    });

    test('should schedule background task and save partial run', () async {
      // Arrange
      const minutes = 30;
      const completeMessage = 'Done';
      const notificationMessage = 'Message';
      const expectedSeconds = minutes * 60;

      // Act
      final result = await useCase.execute(
        minutes,
        completeMessage,
        notificationMessage,
      );

      // Assert
      expect(fakeBackgroundTaskService.scheduleTimerTaskCalledCount, 1);
      expect(
        fakeNotificationService.scheduleReminderNotificationCalledCount,
        0,
      );
      expect(fakePartialRunRepository.clearRunsCalledCount, 1);
      expect(fakeHapticService.timerStartCalledCount, 1);
      expect(fakeAudioService.playTimerStartSoundCalledCount, 1);
      expect(fakePerformanceService.trackTimerEventCalledCount, 1);

      expect(result.secondsRemaining, expectedSeconds);
      expect(result.id, -1);
    });

    test('should schedule reminder notification when enabled and valid',
        () async {
      // Arrange
      fakeSettingsRepository
        ..reminderEnabled = true
        ..reminderMinutes = 10;

      const minutes = 30;

      // Act
      await useCase.execute(minutes, 'Done', 'Message');

      // Assert
      expect(
        fakeNotificationService.scheduleReminderNotificationCalledCount,
        1,
      );
    });
  });

  group('PauseTimerUseCase', () {
    late PauseTimerUseCase useCase;

    setUp(() {
      useCase = PauseTimerUseCase(
        performanceService: fakePerformanceService,
        hapticService: fakeHapticService,
      );
    });

    test('should track pause event and trigger haptics', () async {
      // Act
      await useCase.execute(120);

      // Assert
      expect(fakePerformanceService.trackTimerEventCalledCount, 1);
      expect(fakeHapticService.timerToggleCalledCount, 1);
    });
  });

  group('ResumeTimerUseCase', () {
    late ResumeTimerUseCase useCase;

    setUp(() {
      useCase = ResumeTimerUseCase(
        performanceService: fakePerformanceService,
        hapticService: fakeHapticService,
      );
    });

    test('should track resume event and trigger haptics', () async {
      // Act
      await useCase.execute(180);

      // Assert
      expect(fakePerformanceService.trackTimerEventCalledCount, 1);
      expect(fakeHapticService.timerToggleCalledCount, 1);
    });
  });

  group('StopTimerUseCase', () {
    late StopTimerUseCase useCase;

    setUp(() {
      useCase = StopTimerUseCase(
        partialRunRepository: fakePartialRunRepository,
        historyRepository: fakeHistoryRepository,
        hapticService: fakeHapticService,
        audioService: fakeAudioService,
        performanceService: fakePerformanceService,
        backgroundTaskService: fakeBackgroundTaskService,
      );
    });

    test('should stop timer and clean up without saving if currentRun is null',
        () async {
      // Act
      await useCase.execute(
        currentRun: null,
        totalDurationInSeconds: 60,
        isPaused: false,
      );

      // Assert
      expect(fakeHistoryRepository.saveCompletedSessionCalledCount, 0);
      expect(fakePartialRunRepository.clearAllPartialRunsCalledCount, 1);
      expect(fakeBackgroundTaskService.cancelTimerTaskCalledCount, 1);
      expect(fakeHapticService.timerStopCalledCount, 1);
      expect(fakeAudioService.playButtonClickSoundCalledCount, 1);
      expect(fakePerformanceService.trackTimerEventCalledCount, 1);
    });

    test('should stop timer, clean up, and save history if currentRun exists',
        () async {
      // Arrange
      final endTime = DateTime.now().add(const Duration(minutes: 30));
      final currentRun =
          PartialRunData(id: 1, secondsRemaining: 1800, endTime: endTime);

      // Act
      await useCase.execute(
        currentRun: currentRun,
        totalDurationInSeconds: 1800,
        isPaused: true,
      );

      // Assert
      expect(fakeHistoryRepository.saveCompletedSessionCalledCount, 1);
      expect(fakePartialRunRepository.clearAllPartialRunsCalledCount, 1);
    });
  });
}

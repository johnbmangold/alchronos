import 'package:alchronos/app_database.dart';
import 'package:alchronos/data/repositories/history_repository_impl.dart';
import 'package:alchronos/data/repositories/partial_run_repository_impl.dart';
import 'package:alchronos/data/repositories/settings_repository_impl.dart';
import 'package:alchronos/domain/repositories/history_repository.dart';
import 'package:alchronos/domain/repositories/partial_run_repository.dart';
import 'package:alchronos/domain/repositories/settings_repository.dart';
import 'package:alchronos/infrastructure/services/audio_service.dart';
import 'package:alchronos/infrastructure/services/background_task_service.dart';
import 'package:alchronos/infrastructure/services/haptic_service.dart';
import 'package:alchronos/infrastructure/services/notification_service.dart';
import 'package:alchronos/infrastructure/services/performance_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final startTimerUseCaseProvider = Provider<StartTimerUseCase>((ref) {
  return StartTimerUseCase(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    partialRunRepository: ref.watch(partialRunRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
    backgroundTaskService: ref.watch(backgroundTaskServiceProvider),
    hapticService: ref.watch(hapticServiceProvider),
    audioService: ref.watch(audioServiceProvider),
    performanceService: ref.watch(performanceServiceProvider),
  );
});

class StartTimerUseCase {
  StartTimerUseCase({
    required this.settingsRepository,
    required this.partialRunRepository,
    required this.notificationService,
    required this.backgroundTaskService,
    required this.hapticService,
    required this.audioService,
    required this.performanceService,
  });

  final SettingsRepository settingsRepository;
  final PartialRunRepository partialRunRepository;
  final NotificationService notificationService;
  final BackgroundTaskService backgroundTaskService;
  final HapticService hapticService;
  final AudioService audioService;
  final PerformanceService performanceService;

  Future<PartialRunData> execute(
    int minutes,
    String drinkTimerComplete,
    String notificationMessage,
  ) async {
    if (minutes <= 0 || minutes > 1440) {
      throw Exception('Invalid timer duration');
    }

    // set workmanager task
    await backgroundTaskService.scheduleTimerTask(
      minutes,
      drinkTimerComplete,
      notificationMessage,
    );

    // Schedule reminder notification if enabled
    final isReminderEnabled = await settingsRepository.isReminderEnabled();
    final reminderMinutes = await settingsRepository.getReminderMinutes();

    if (isReminderEnabled && reminderMinutes > 0 && reminderMinutes < minutes) {
      await notificationService.scheduleReminderNotification(
        reminderMinutes,
        minutes,
        drinkTimerComplete,
        notificationMessage,
      );
    }

    final durationInSeconds = minutes * 60;
    final now = DateTime.now();
    final endTime = now.add(Duration(seconds: durationInSeconds));

    await partialRunRepository.clearRunsAndPutPartialRun(
      endTime,
      durationInSeconds,
    );

    final partialRunData = PartialRunData(
      id: -1,
      secondsRemaining: durationInSeconds,
      endTime: endTime,
    );

    await hapticService.timerStart();
    await audioService.playTimerStartSound();
    performanceService.trackTimerEvent('start', duration: minutes);

    return partialRunData;
  }
}

final pauseTimerUseCaseProvider = Provider<PauseTimerUseCase>((ref) {
  return PauseTimerUseCase(
    performanceService: ref.watch(performanceServiceProvider),
    hapticService: ref.watch(hapticServiceProvider),
  );
});

class PauseTimerUseCase {
  PauseTimerUseCase({
    required this.performanceService,
    required this.hapticService,
  });

  final PerformanceService performanceService;
  final HapticService hapticService;

  Future<void> execute(int totalDurationInSeconds) async {
    performanceService.trackTimerEvent(
      'pause',
      duration: totalDurationInSeconds ~/ 60,
    );
    await hapticService.timerToggle();
  }
}

final resumeTimerUseCaseProvider = Provider<ResumeTimerUseCase>((ref) {
  return ResumeTimerUseCase(
    performanceService: ref.watch(performanceServiceProvider),
    hapticService: ref.watch(hapticServiceProvider),
  );
});

class ResumeTimerUseCase {
  ResumeTimerUseCase({
    required this.performanceService,
    required this.hapticService,
  });

  final PerformanceService performanceService;
  final HapticService hapticService;

  Future<void> execute(int totalDurationInSeconds) async {
    performanceService.trackTimerEvent(
      'resume',
      duration: totalDurationInSeconds ~/ 60,
    );
    await hapticService.timerToggle();
  }
}

final stopTimerUseCaseProvider = Provider<StopTimerUseCase>((ref) {
  return StopTimerUseCase(
    partialRunRepository: ref.watch(partialRunRepositoryProvider),
    historyRepository: ref.watch(historyRepositoryProvider),
    hapticService: ref.watch(hapticServiceProvider),
    audioService: ref.watch(audioServiceProvider),
    performanceService: ref.watch(performanceServiceProvider),
    backgroundTaskService: ref.watch(backgroundTaskServiceProvider),
  );
});

class StopTimerUseCase {
  StopTimerUseCase({
    required this.partialRunRepository,
    required this.historyRepository,
    required this.hapticService,
    required this.audioService,
    required this.performanceService,
    required this.backgroundTaskService,
  });

  final PartialRunRepository partialRunRepository;
  final HistoryRepository historyRepository;
  final HapticService hapticService;
  final AudioService audioService;
  final PerformanceService performanceService;
  final BackgroundTaskService backgroundTaskService;

  Future<void> execute({
    required PartialRunData? currentRun,
    required int totalDurationInSeconds,
    required bool isPaused,
  }) async {
    if (currentRun != null) {
      final durationMinutes = totalDurationInSeconds ~/ 60;
      final startTime =
          currentRun.endTime.subtract(Duration(minutes: durationMinutes));
      final endTime = DateTime.now();

      await historyRepository.saveCompletedSession(
        durationMinutes: durationMinutes,
        startTime: startTime,
        endTime: endTime,
        wasPaused: isPaused,
        pauseCount: isPaused ? 1 : 0,
      );
    }

    await partialRunRepository.clearAllPartialRuns();
    await backgroundTaskService.cancelTimerTask();
    await hapticService.timerStop();
    await audioService.playButtonClickSound();
    performanceService.trackTimerEvent('stop');
  }
}

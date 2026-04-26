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

/// Provider for [StartTimerUseCase].
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

/// Use case that handles starting the timer.
class StartTimerUseCase {
  /// Creates a [StartTimerUseCase].
  StartTimerUseCase({
    required this.settingsRepository,
    required this.partialRunRepository,
    required this.notificationService,
    required this.backgroundTaskService,
    required this.hapticService,
    required this.audioService,
    required this.performanceService,
  });

  /// The settings repository to check reminder preferences.
  final SettingsRepository settingsRepository;

  /// The repository for storing the ongoing partial run.
  final PartialRunRepository partialRunRepository;

  /// The service for scheduling local notifications.
  final NotificationService notificationService;

  /// The service for scheduling the background timer task.
  final BackgroundTaskService backgroundTaskService;

  /// The service for haptic feedback.
  final HapticService hapticService;

  /// The service for audio feedback.
  final AudioService audioService;

  /// The service for tracking performance and analytics.
  final PerformanceService performanceService;

  /// Executes the start timer logic for the given [minutes], with completion
  /// text [drinkTimerComplete] and [notificationMessage].
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

/// Provider for [PauseTimerUseCase].
final pauseTimerUseCaseProvider = Provider<PauseTimerUseCase>((ref) {
  return PauseTimerUseCase(
    performanceService: ref.watch(performanceServiceProvider),
    hapticService: ref.watch(hapticServiceProvider),
  );
});

/// Use case that handles pausing the timer.
class PauseTimerUseCase {
  /// Creates a [PauseTimerUseCase].
  PauseTimerUseCase({
    required this.performanceService,
    required this.hapticService,
  });

  /// The service for tracking performance and analytics.
  final PerformanceService performanceService;

  /// The service for haptic feedback.
  final HapticService hapticService;

  /// Executes the pause timer logic for the current timer with
  /// [totalDurationInSeconds].
  Future<void> execute(int totalDurationInSeconds) async {
    performanceService.trackTimerEvent(
      'pause',
      duration: totalDurationInSeconds ~/ 60,
    );
    await hapticService.timerToggle();
  }
}

/// Provider for [ResumeTimerUseCase].
final resumeTimerUseCaseProvider = Provider<ResumeTimerUseCase>((ref) {
  return ResumeTimerUseCase(
    performanceService: ref.watch(performanceServiceProvider),
    hapticService: ref.watch(hapticServiceProvider),
  );
});

/// Use case that handles resuming the timer.
class ResumeTimerUseCase {
  /// Creates a [ResumeTimerUseCase].
  ResumeTimerUseCase({
    required this.performanceService,
    required this.hapticService,
  });

  /// The service for tracking performance and analytics.
  final PerformanceService performanceService;

  /// The service for haptic feedback.
  final HapticService hapticService;

  /// Executes the resume timer logic for the current timer with
  /// [totalDurationInSeconds].
  Future<void> execute(int totalDurationInSeconds) async {
    performanceService.trackTimerEvent(
      'resume',
      duration: totalDurationInSeconds ~/ 60,
    );
    await hapticService.timerToggle();
  }
}

/// Provider for [StopTimerUseCase].
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

/// Use case that handles stopping the timer and saving the session history.
class StopTimerUseCase {
  /// Creates a [StopTimerUseCase].
  StopTimerUseCase({
    required this.partialRunRepository,
    required this.historyRepository,
    required this.hapticService,
    required this.audioService,
    required this.performanceService,
    required this.backgroundTaskService,
  });

  /// The repository to clear the current partial run.
  final PartialRunRepository partialRunRepository;

  /// The repository to save the completed session to history.
  final HistoryRepository historyRepository;

  /// The service for haptic feedback.
  final HapticService hapticService;

  /// The service for audio feedback.
  final AudioService audioService;

  /// The service for tracking performance and analytics.
  final PerformanceService performanceService;

  /// The service to cancel any pending background tasks.
  final BackgroundTaskService backgroundTaskService;

  /// Executes the stop timer logic. Takes the [currentRun], the
  /// [totalDurationInSeconds], and whether the timer [isPaused].
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

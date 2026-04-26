import 'dart:async';

import 'package:alchronos/app_database.dart';
import 'package:alchronos/core/errors/app_exceptions.dart';
import 'package:alchronos/core/errors/error_handler.dart';
import 'package:alchronos/data/repositories/partial_run_repository_impl.dart';
import 'package:alchronos/data/repositories/settings_repository_impl.dart';
import 'package:alchronos/domain/use_cases/timer_use_cases.dart';
import 'package:alchronos/home/views/views.dart';
import 'package:alchronos/infrastructure/services/performance_service.dart';
import 'package:alchronos/presentation/home/home_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider for observing the current timer duration stream.
final durationStreamProvider = StreamProvider<int>((ref) {
  final controller = StreamController<int>();

  ref
    ..onDispose(controller.close)
    ..listen(homeNotifierProvider, (previous, next) async {
      // Just to fetch when duration changes
    });

  return controller.stream;
});

/// Notifier Provider responsible for state management on the Home screen.
final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

/// The `Notifier` managing the business logic for the Home screen.
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeInitial();
  }

  /// Initializes the state by reading settings and partial runs.
  Future<void> init() async {
    final performanceService = ref.read(performanceServiceProvider)
      ..startTiming('init');
    try {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final timerDuration = await settingsRepo.readTimerDurationPreference();
      final minutes = timerDuration.isCustom
          ? await settingsRepo.readCustomDuration()
          : timerDuration.minutes;

      final partialRunRepo = ref.read(partialRunRepositoryProvider);
      final partialRun =
          await partialRunRepo.getPartialRunAfterTime(DateTime.now());

      if (partialRun == null) {
        performanceService.trackTimerEvent('start_fresh');
        state = HomeStart();
        return;
      }

      performanceService.trackTimerEvent('resume_existing', duration: minutes);
      state = HomeRunning(
        partialRunData: partialRun,
        totalDurationInSeconds: minutes * 60,
      );
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeNotifier.init',
      );
      state = HomeError(ErrorHandler.getUserFriendlyMessage(error));
    } finally {
      performanceService.endTiming('init');
    }
  }

  /// Resets the active timer and stops it immediately.
  Future<void> reset() async {
    try {
      final currentState = state;
      PartialRunData? currentRun;
      var totalDuration = 0;
      var isPaused = false;

      if (currentState is HomeRunning) {
        currentRun = currentState.partialRunData;
        totalDuration = currentState.totalDurationInSeconds;
        isPaused = currentState.isPaused;
      }

      final stopTimerUseCase = ref.read(stopTimerUseCaseProvider);
      await stopTimerUseCase.execute(
        currentRun: currentRun,
        totalDurationInSeconds: totalDuration,
        isPaused: isPaused,
      );

      state = HomeStart();
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeNotifier.reset',
      );
      state = HomeError(ErrorHandler.getUserFriendlyMessage(error));
    }
  }

  /// Pauses the currently running timer.
  Future<void> pauseTimer() async {
    final currentState = state;
    if (currentState is HomeRunning && !currentState.isPaused) {
      final pauseTimerUseCase = ref.read(pauseTimerUseCaseProvider);
      await pauseTimerUseCase.execute(currentState.totalDurationInSeconds);
      state = currentState.copyWith(
        isPaused: true,
        pausedAt: DateTime.now(),
      );
    }
  }

  /// Resumes the currently paused timer.
  Future<void> resumeTimer() async {
    final currentState = state;
    if (currentState is HomeRunning && currentState.isPaused) {
      final resumeTimerUseCase = ref.read(resumeTimerUseCaseProvider);
      await resumeTimerUseCase.execute(currentState.totalDurationInSeconds);
      state = currentState.copyWith(
        isPaused: false,
      );
    }
  }

  /// Starts the timer using current preferences and updates the UI state.
  Future<void> start(
    String drinkTimerComplete,
    String notificationMessage, {
    bool enableReminder = false,
    int reminderMinutes = 5,
  }) async {
    try {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final timerDuration = await settingsRepo.readTimerDurationPreference();
      final minutes = timerDuration.isCustom
          ? await settingsRepo.readCustomDuration()
          : timerDuration.minutes;

      final startTimerUseCase = ref.read(startTimerUseCaseProvider);
      final partialRun = await startTimerUseCase.execute(
        minutes,
        drinkTimerComplete,
        notificationMessage,
      );

      state = HomeRunning(
        partialRunData: partialRun,
        totalDurationInSeconds: minutes * 60,
      );
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeNotifier.start',
      );
      state = HomeError(ErrorHandler.getUserFriendlyMessage(error));
    }
  }

  /// Writes a new preferred timer duration into settings.
  Future<void> writePreferredDuration(TimerDuration timerDuration) async {
    try {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      await settingsRepo.writeTimerDurationPreference(timerDuration);

      // Update duration state provider here
      unawaited(ref.read(currentTimerDurationProvider.notifier).refresh());
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeNotifier.writePreferredDuration',
      );
      state = HomeError(ErrorHandler.getUserFriendlyMessage(error));
    }
  }

  /// Writes a user-defined custom timer duration (in minutes) into settings.
  Future<void> writeCustomDuration(int minutes) async {
    try {
      if (minutes <= 0 || minutes > 1440) {
        throw const ValidationException('Invalid custom duration');
      }
      final settingsRepo = ref.read(settingsRepositoryProvider);
      await settingsRepo.writeCustomDuration(minutes);

      // Update duration state provider here
      unawaited(ref.read(currentTimerDurationProvider.notifier).refresh());
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeNotifier.writeCustomDuration',
      );
      state = HomeError(ErrorHandler.getUserFriendlyMessage(error));
    }
  }
}

/// Provider to get the latest configured timer duration.
final currentTimerDurationProvider =
    AsyncNotifierProvider<CurrentTimerDurationNotifier, int>(() {
  return CurrentTimerDurationNotifier();
});

/// Async notifier for fetching and refreshing the current timer duration.
class CurrentTimerDurationNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() async {
    return _fetchDuration();
  }

  Future<int> _fetchDuration() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final timerDuration = await settingsRepo.readTimerDurationPreference();
    if (timerDuration.isCustom) {
      return settingsRepo.readCustomDuration();
    }
    return timerDuration.minutes;
  }

  /// Refreshes the currently cached duration setting.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchDuration);
  }
}

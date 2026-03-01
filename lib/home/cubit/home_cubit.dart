import 'dart:async';

import 'package:alchronos/app_database.dart';
import 'package:alchronos/core/errors/app_exceptions.dart';
import 'package:alchronos/core/errors/error_handler.dart';
import 'package:alchronos/home/views/views.dart';
import 'package:alchronos/main.dart';
import 'package:alchronos/repositories/repositories.dart';
import 'package:alchronos/services/audio_service.dart';
import 'package:alchronos/services/haptic_service.dart';
import 'package:alchronos/services/history_service.dart';
import 'package:alchronos/services/performance_service.dart';
import 'package:alchronos/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

part 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.logger,
    required this.partialRunRepository,
    required this.flutterLocalNotificationsPlugin,
    required this.storageRepository,
    required this.hapticService,
    required this.audioService,
    required this.settingsService,
    required this.performanceService,
    required this.historyService,
  }) : super(HomeInitial());

  final Logger logger;
  final PartialRunRepository partialRunRepository;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final StorageRepository storageRepository;
  final HapticService hapticService;
  final AudioService audioService;
  final SettingsService settingsService;
  final PerformanceService performanceService;
  final HistoryService historyService;
  final workmanagerUniqueName = 'com.idlewild.alchronos.drink.timer.start';
  final workmanagerTaskName = 'com.idlewild.alchronos.drink.timer.start';
  final StreamController<int> _durationStreamController =
      StreamController<int>.broadcast();
  Stream<int> get durationStream => _durationStreamController.stream;

  Future<void> init() async {
    performanceService.startTiming('init');
    try {
      final timerDuration = await getPreferredDuration();
      final minutes = timerDuration.isCustom
          ? await storageRepository.readCustomDuration()
          : timerDuration.minutes;
      _durationStreamController.add(minutes);

      final partialRun = await getPartialRun(DateTime.now());
      if (partialRun == null) {
        performanceService.trackTimerEvent('start_fresh');
        emit(HomeStart());
        return;
      }

      performanceService.trackTimerEvent('resume_existing', duration: minutes);
      emit(
        HomeRunning(
          partialRunData: partialRun,
          totalDurationInSeconds: minutes * 60,
        ),
      );
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeCubit.init',
      );
      emit(HomeError(ErrorHandler.getUserFriendlyMessage(error)));
    } finally {
      performanceService.endTiming('init');
    }
  }

  Future<void> reset() async {
    try {
      // Save completed session to history if timer was running
      final currentState = state;
      if (currentState is HomeRunning) {
        await _saveCompletedSession(currentState);
      }

      // Clear any existing partial runs from the database
      await partialRunRepository.clearAllPartialRuns();
      await hapticService.timerStop();
      await audioService.playButtonClickSound();

      // Track timer stop event
      performanceService.trackTimerEvent('stop');

      emit(HomeStart());
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeCubit.reset',
      );
      emit(HomeError(ErrorHandler.getUserFriendlyMessage(error)));
    }
  }

  Future<void> pauseTimer() async {
    final currentState = state;
    if (currentState is HomeRunning && !currentState.isPaused) {
      performanceService.trackTimerEvent(
        'pause',
        duration: currentState.totalDurationInSeconds ~/ 60,
      );
      await hapticService.timerToggle();
      emit(
        currentState.copyWith(
          isPaused: true,
          pausedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> resumeTimer() async {
    final currentState = state;
    if (currentState is HomeRunning && currentState.isPaused) {
      performanceService.trackTimerEvent(
        'resume',
        duration: currentState.totalDurationInSeconds ~/ 60,
      );
      await hapticService.timerToggle();
      emit(
        currentState.copyWith(
          isPaused: false,
        ),
      );
    }
  }

  Future<void> start(
    String drinkTimerComplete,
    String notificationMessage, {
    bool enableReminder = false,
    int reminderMinutes = 5,
  }) async {
    try {
      // get preferred duration
      final timerDuration = await getPreferredDuration();
      final minutes = timerDuration.isCustom
          ? await storageRepository.readCustomDuration()
          : timerDuration.minutes;

      // Validate duration
      if (minutes <= 0 || minutes > 1440) {
        // Max 24 hours
        throw const ValidationException('Invalid timer duration');
      }

      // set workmanager task
      await Workmanager().registerOneOffTask(
        workmanagerUniqueName,
        workmanagerTaskName,
        initialDelay: Duration(minutes: minutes),
        inputData: {
          workmanagerTitleKey: drinkTimerComplete,
          workmanagerMessageKey: notificationMessage,
        },
      );

      // Schedule reminder notification if enabled
      final isReminderEnabled = await settingsService.isReminderEnabled();
      final reminderMinutes = await settingsService.getReminderMinutes();

      if (isReminderEnabled &&
          reminderMinutes > 0 &&
          reminderMinutes < minutes) {
        await _scheduleReminderNotification(
          reminderMinutes,
          minutes,
          drinkTimerComplete,
          notificationMessage,
        );
      }

      final partialRun = await _createPartialRun(DateTime.now(), minutes);

      // Add haptic and audio feedback for timer start
      await hapticService.timerStart();
      await audioService.playTimerStartSound();

      // Track timer start event
      performanceService.trackTimerEvent('start', duration: minutes);

      // emit running state
      emit(
        HomeRunning(
          partialRunData: partialRun,
          totalDurationInSeconds: minutes * 60,
        ),
      );
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeCubit.start',
      );
      emit(HomeError(ErrorHandler.getUserFriendlyMessage(error)));
    }
  }

  Future<PartialRunData?> getPartialRun(DateTime currentTime) async {
    return partialRunRepository.getPartialRunAfterTime(currentTime);
  }

  Future<int> _setPartialRun(DateTime endTime, int secondsRemaining) async {
    return partialRunRepository.clearRunsAndPutPartialRun(
      endTime,
      secondsRemaining,
    );
  }

  Future<PartialRunData> _createPartialRun(DateTime now, int minutes) async {
    final durationInSeconds = minutes * 60;
    final partialRunData = PartialRunData(
      id: -1,
      secondsRemaining: durationInSeconds,
      endTime: now.add(Duration(seconds: durationInSeconds)),
    );
    await _setPartialRun(
      partialRunData.endTime,
      partialRunData.secondsRemaining,
    );
    return partialRunData;
  }

  Future<TimerDuration> getPreferredDuration() async {
    return storageRepository.readTimerDurationPreference();
  }

  Future<void> writedPreferredDuration(TimerDuration timerDuration) async {
    try {
      await storageRepository.writeTimerDurationPreference(timerDuration);
      final minutes = timerDuration.isCustom
          ? await storageRepository.readCustomDuration()
          : timerDuration.minutes;
      _durationStreamController.add(minutes);
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeCubit.writedPreferredDuration',
      );
      emit(HomeError(ErrorHandler.getUserFriendlyMessage(error)));
    }
  }

  Future<void> writeCustomDuration(int minutes) async {
    try {
      if (minutes <= 0 || minutes > 1440) {
        throw const ValidationException('Invalid custom duration');
      }
      await storageRepository.writeCustomDuration(minutes);
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeCubit.writeCustomDuration',
      );
      emit(HomeError(ErrorHandler.getUserFriendlyMessage(error)));
    }
  }

  Future<void> _saveCompletedSession(HomeRunning state) async {
    try {
      final durationMinutes = state.totalDurationInSeconds ~/ 60;
      final startTime = state.partialRunData.endTime
          .subtract(Duration(minutes: durationMinutes));
      final endTime = DateTime.now();

      await historyService.saveCompletedSession(
        durationMinutes: durationMinutes,
        startTime: startTime,
        endTime: endTime,
        wasPaused: state.isPaused,
        pauseCount: state.isPaused ? 1 : 0, // Simplified pause count
      );
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeCubit._saveCompletedSession',
      );
    }
  }

  Future<void> _scheduleReminderNotification(
    int reminderMinutes,
    int totalMinutes,
    String title,
    String message,
  ) async {
    try {
      final reminderDelay = Duration(minutes: totalMinutes - reminderMinutes);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 1, // Unique ID for reminder
        title: 'Timer Reminder',
        body: 'Your timer will complete in $reminderMinutes minutes',
        scheduledDate: tz.TZDateTime.now(tz.local).add(reminderDelay),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'timer_reminder',
            'Timer Reminders',
            channelDescription: 'Notifications for timer reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on Exception catch (error) {
      await ErrorHandler.handleError(
        error,
        StackTrace.current,
        context: 'HomeCubit._scheduleReminderNotification',
      );
    }
  }

  @override
  Future<void> close() async {
    await _durationStreamController.close();
    return super.close();
  }
}

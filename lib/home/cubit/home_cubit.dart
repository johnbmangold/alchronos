import 'dart:async';

import 'package:alchronos/app_database.dart';
import 'package:alchronos/core/errors/app_exceptions.dart';
import 'package:alchronos/core/errors/error_handler.dart';
import 'package:alchronos/home/views/views.dart';
import 'package:alchronos/main.dart';
import 'package:alchronos/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

part 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.logger,
    required this.partialRunRepository,
    required this.flutterLocalNotificationsPlugin,
    required this.storageRepository,
  }) : super(HomeInitial());

  final Logger logger;
  final PartialRunRepository partialRunRepository;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final StorageRepository storageRepository;
  final workmanagerUniqueName = 'com.idlewild.alchronos.drink.timer.start';
  final workmanagerTaskName = 'com.idlewild.alchronos.drink.timer.start';
  final StreamController<int> _durationStreamController =
      StreamController<int>.broadcast();
  Stream<int> get durationStream => _durationStreamController.stream;

  Future<void> init() async {
    try {
      final timerDuration = await getPreferredDuration();
      final minutes = timerDuration.isCustom
          ? await storageRepository.readCustomDuration()
          : timerDuration.minutes;
      _durationStreamController.add(minutes);

      final partialRun = await getPartialRun(DateTime.now());
      if (partialRun == null) {
        emit(HomeStart());
        return;
      }

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
    }
  }

  Future<void> reset() async {
    try {
      // Clear any existing partial runs from the database
      await partialRunRepository.clearAllPartialRuns();
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

  void pauseTimer() {
    final currentState = state;
    if (currentState is HomeRunning && !currentState.isPaused) {
      emit(
        currentState.copyWith(
          isPaused: true,
          pausedAt: DateTime.now(),
        ),
      );
    }
  }

  void resumeTimer() {
    final currentState = state;
    if (currentState is HomeRunning && currentState.isPaused) {
      emit(
        currentState.copyWith(
          isPaused: false,
        ),
      );
    }
  }

  Future<void> start(
    String drinkTimerComplete,
    String notificationMessage,
  ) async {
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

      final partialRun = await _createPartialRun(DateTime.now(), minutes);

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

  @override
  Future<void> close() async {
    await _durationStreamController.close();
    return super.close();
  }
}

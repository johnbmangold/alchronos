import 'dart:async';

import 'package:alchronos/app_database.dart';
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
  final StreamController<int> _durationStreamController = StreamController();
  Stream<int> get durationStream => _durationStreamController.stream;

  Future<void> init() async {
    final timerDuration = await getPreferredDuration();
    _durationStreamController.add(timerDuration.minutes);

    final partialRun = await getPartialRun(DateTime.now());
    if (partialRun == null) {
      emit(HomeStart());
      return;
    }

    emit(
      HomeRunning(
        partialRunData: partialRun,
        totalDurationInSeconds: timerDuration.minutesToSeconds,
      ),
    );
  }

  void reset() {
    emit(HomeStart());
  }

  Future<void> start(
    String drinkTimerComplete,
    String notificationMessage,
  ) async {
    // get preferred duration
    final timerDuration = await getPreferredDuration();

    // set workmanager task
    await Workmanager().registerOneOffTask(
      workmanagerUniqueName,
      workmanagerTaskName,
      initialDelay: Duration(minutes: timerDuration.minutes),
      inputData: {
        workmanagerTitleKey: drinkTimerComplete,
        workmanagerMessageKey: notificationMessage,
      },
    );

    final partialRun = await _createOneHourPartialRun(DateTime.now());

    // emit running state
    emit(
      HomeRunning(
        partialRunData: partialRun,
        totalDurationInSeconds: timerDuration.minutesToSeconds,
      ),
    );
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

  Future<PartialRunData> _createOneHourPartialRun(DateTime now) async {
    final timerDuration = await getPreferredDuration();
    final durationInSeconds = timerDuration.minutesToSeconds;
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
    await storageRepository.writeTimerDurationPreference(timerDuration);
    _durationStreamController.add(timerDuration.minutes);
  }
}

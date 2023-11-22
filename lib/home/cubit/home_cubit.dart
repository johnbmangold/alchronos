import 'package:alchronos/home/models/models.dart';
import 'package:alchronos/local_notifications.dart';
import 'package:alchronos/main.dart';
import 'package:alchronos/repositories/repositories.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.logger,
    required this.partialRunRepository,
  }) : super(HomeInitial());

  final Logger logger;
  final PartialRunRepository partialRunRepository;

  Future<void> init() async {
    final partialRun = await getPartialRun(DateTime.now());
    if (partialRun == null) {
      emit(HomeStart());
      return;
    }

    emit(HomeRunning(partialRun: partialRun));
  }

  Future<void> reinit() async {
    emit(HomeInitial());
    await init();
  }

  Future<void> start() async {
    // set up background fetch
    await _initPlatformState();

    // start background fetch
    await BackgroundFetch.start().then((int status) {
      logger.i('[BackgroundFetch] start success: $status');
    }).catchError((Object e) {
      logger.e('[BackgroundFetch] start FAILURE: $e');
    });

    final partialRun = await _createOneHourPartialRun(DateTime.now());

    // emit running state
    emit(HomeRunning(partialRun: partialRun));
  }

  Future<PartialRun?> getPartialRun(DateTime currentTime) async {
    return partialRunRepository.getPartialRunAfterTime(currentTime);
  }

  Future<int> _setPartialRun(PartialRun partialRun) async {
    return partialRunRepository.clearRunsAndPutPartialRun(partialRun);
  }

  Future<void> showNotificationAndStop() async {
    await BackgroundFetch.stop();
    await showNotification();
    emit(HomeStart());
  }

  Future<void> showNotification() async {
    await getIt.get<FlutterLocalNotificationsPlugin>().show(
          getIt.get<LocalNotifications>().getNotificationId(),
          'Drink Timer Complete',
          'You can order another drink when you\'re feeling up to it.',
          getIt.get<LocalNotifications>().getNotificationDetailsTimesUp(),
          payload: 1.toString(),
        );
  }

  Future<void> _initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: oneHourInMinutes,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      (String taskId) async {
        // <-- Event handler
        // This is the fetch-event callback.
        logger.i('[BackgroundFetch] Event received $taskId');

        // show notification that timer is done
        await showNotification();

        await BackgroundFetch.stop(taskId);

        // IMPORTANT:  You must signal completion of your task or the OS can punish your app
        // for taking too long in the background.
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        // <-- Task timeout handler.
        // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
        logger.i('[BackgroundFetch] TASK TIMEOUT taskId: $taskId');
        await BackgroundFetch.stop(taskId);
        BackgroundFetch.finish(taskId);
      },
    );

    logger.i('[BackgroundFetch] configure success: $status');
  }

  Future<PartialRun> _createOneHourPartialRun(DateTime now) async {
    final newPartialRun = PartialRun();
    newPartialRun.secondsRemaining = oneHourInSeconds;
    newPartialRun.endTime = now.add(const Duration(seconds: oneHourInSeconds));
    await _setPartialRun(newPartialRun);
    return newPartialRun;
  }
}

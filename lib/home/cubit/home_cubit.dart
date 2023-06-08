import 'package:alchronos/main.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> start() async {
    await initPlatformState();
    BackgroundFetch.start().then((int status) {
      logger.i('[BackgroundFetch] start success: $status');
    }).catchError((e) {
      logger.e('[BackgroundFetch] start FAILURE: $e');
    });
    emit(HomeRunning());
  }

  void stop() {
    emit(HomeInitial());
  }

  Future<void> initPlatformState() async {
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

        BackgroundFetch.stop(taskId);

        // IMPORTANT:  You must signal completion of your task or the OS can punish your app
        // for taking too long in the background.
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        // <-- Task timeout handler.
        // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
        logger.i('[BackgroundFetch] TASK TIMEOUT taskId: $taskId');
        BackgroundFetch.stop(taskId);
        BackgroundFetch.finish(taskId);
      },
    );
    logger.i('[BackgroundFetch] configure success: $status');
  }
}

import 'package:alchronos/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:workmanager/workmanager.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void start() {
    Workmanager().registerOneOffTask(
      taskIdentifier,
      taskName,
      initialDelay: const Duration(seconds: oneHourInSeconds),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    logger.i('registerOneOffTask: $taskName');
    emit(HomeRunning());
  }

  void stop() {
    emit(HomeInitial());
  }
}

import 'package:alchronos/home/models/models.dart';
import 'package:alchronos/main.dart';
import 'package:alchronos/repositories/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:workmanager/workmanager.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.logger,
    required this.partialRunRepository,
    required this.flutterLocalNotificationsPlugin,
    required this.l10n,
  }) : super(HomeInitial());

  final Logger logger;
  final PartialRunRepository partialRunRepository;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final AppLocalizations l10n;

  Future<void> init() async {
    final partialRun = await getPartialRun(DateTime.now());
    if (partialRun == null) {
      emit(HomeStart());
      return;
    }

    emit(HomeRunning(partialRun: partialRun));
  }

  void reset() {
    emit(HomeStart());
  }

  Future<void> start() async {
    // set workmanager task
    await Workmanager().registerOneOffTask(
      'drinkTimerStart',
      'drink_timer_start',
      initialDelay: const Duration(minutes: oneHourInMinutes),
    );

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

  Future<PartialRun> _createOneHourPartialRun(DateTime now) async {
    final newPartialRun = PartialRun();
    newPartialRun.secondsRemaining = oneHourInSeconds;
    newPartialRun.endTime = now.add(Duration(seconds: oneHourInSeconds));
    await _setPartialRun(newPartialRun);
    return newPartialRun;
  }
}

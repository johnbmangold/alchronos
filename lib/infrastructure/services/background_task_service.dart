import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workmanager/workmanager.dart';

/// Provider for the [BackgroundTaskService].
final backgroundTaskServiceProvider = Provider<BackgroundTaskService>((ref) {
  return BackgroundTaskService();
});

/// Service responsible for scheduling background tasks using Workmanager.
class BackgroundTaskService {
  /// Unique name for the Workmanager task.
  final workmanagerUniqueName = 'com.idlewild.alchronos.drink.timer.start';

  /// Task name for the Workmanager task.
  final workmanagerTaskName = 'com.idlewild.alchronos.drink.timer.start';

  /// Schedules a timer task to run in the background after [minutes].
  Future<void> scheduleTimerTask(
    int minutes,
    String title,
    String message,
  ) async {
    await Workmanager().registerOneOffTask(
      workmanagerUniqueName,
      workmanagerTaskName,
      initialDelay: Duration(minutes: minutes),
      inputData: {
        'title': title,
        'message': message,
      },
    );
  }

  /// Cancels the scheduled timer background task.
  Future<void> cancelTimerTask() async {
    await Workmanager().cancelByUniqueName(workmanagerUniqueName);
  }
}

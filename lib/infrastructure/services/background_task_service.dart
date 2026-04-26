import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workmanager/workmanager.dart';

final backgroundTaskServiceProvider = Provider<BackgroundTaskService>((ref) {
  return BackgroundTaskService();
});

class BackgroundTaskService {
  final workmanagerUniqueName = 'com.idlewild.alchronos.drink.timer.start';
  final workmanagerTaskName = 'com.idlewild.alchronos.drink.timer.start';

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

  Future<void> cancelTimerTask() async {
    await Workmanager().cancelByUniqueName(workmanagerUniqueName);
  }
}

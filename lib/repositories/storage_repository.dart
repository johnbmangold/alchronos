import 'package:alchronos/home/views/views.dart';
import 'package:alchronos/services/services.dart';
import 'package:injectable/injectable.dart';

@injectable
class StorageRepository {
  const StorageRepository({required this.storageService});

  final StorageService storageService;
  String get timerDurationKey => 'timer_duration_key';
  String get customDurationKey => 'custom_duration_key';

  Future<void> writeTimerDurationPreference(TimerDuration timerDuration) async {
    await storageService.writeValue(timerDurationKey, timerDuration.name);
  }

  Future<TimerDuration> readTimerDurationPreference() async {
    final name = await storageService.readValue(timerDurationKey);
    if (name == null || name.isEmpty) {
      await storageService.writeValue(
        timerDurationKey,
        TimerDuration.standard.name,
      );
      return TimerDuration.standard;
    }

    return TimerDuration.fromString(name);
  }

  Future<void> writeCustomDuration(int minutes) async {
    await storageService.writeValue(customDurationKey, minutes.toString());
  }

  Future<int> readCustomDuration() async {
    final value = await storageService.readValue(customDurationKey);
    return int.tryParse(value ?? '60') ?? 60;
  }
}

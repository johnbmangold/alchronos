import 'package:alchronos/home/views/views.dart';

abstract class SettingsRepository {
  Future<void> writeTimerDurationPreference(TimerDuration timerDuration);
  Future<TimerDuration> readTimerDurationPreference();

  Future<void> writeCustomDuration(int minutes);
  Future<int> readCustomDuration();

  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, {required bool value});

  Future<int?> readInt(String key);
  Future<void> writeInt(String key, {required int value});

  // Derived properties from SettingsService
  Future<bool> isReminderEnabled();
  Future<void> setReminderEnabled({required bool enabled});
  Future<int> getReminderMinutes();
  Future<void> setReminderMinutes(int minutes);
}

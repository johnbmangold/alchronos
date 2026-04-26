import 'package:alchronos/home/views/views.dart';

/// Repository interface for managing user settings and preferences.
abstract class SettingsRepository {
  /// Writes the user's preferred timer duration.
  Future<void> writeTimerDurationPreference(TimerDuration timerDuration);

  /// Reads the user's preferred timer duration.
  Future<TimerDuration> readTimerDurationPreference();

  /// Writes a custom timer duration in minutes.
  Future<void> writeCustomDuration(int minutes);

  /// Reads the custom timer duration in minutes.
  Future<int> readCustomDuration();

  /// Reads a boolean value from settings by [key].
  Future<bool?> readBool(String key);

  /// Writes a boolean [value] to settings by [key].
  Future<void> writeBool(String key, {required bool value});

  /// Reads an integer value from settings by [key].
  Future<int?> readInt(String key);

  /// Writes an integer [value] to settings by [key].
  Future<void> writeInt(String key, {required int value});

  /// Checks if reminder notifications are enabled.
  Future<bool> isReminderEnabled();

  /// Sets whether reminder notifications are [enabled].
  Future<void> setReminderEnabled({required bool enabled});

  /// Gets the number of minutes before the timer ends to show a reminder.
  Future<int> getReminderMinutes();

  /// Sets the number of [minutes] before the timer ends to show a reminder.
  Future<void> setReminderMinutes(int minutes);
}

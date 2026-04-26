import 'package:alchronos/data/sources/secure_storage_data_source.dart';
import 'package:alchronos/domain/repositories/settings_repository.dart';
import 'package:alchronos/home/views/views.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    dataSource: ref.watch(secureStorageDataSourceProvider),
  );
});

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({required this.dataSource});

  final SecureStorageDataSource dataSource;

  String get timerDurationKey => 'timer_duration_key';
  String get customDurationKey => 'custom_duration_key';
  String get _reminderEnabledKey => 'reminder_enabled_key';
  String get _reminderMinutesKey => 'reminder_minutes_key';

  @override
  Future<void> writeTimerDurationPreference(TimerDuration timerDuration) async {
    await dataSource.writeValue(timerDurationKey, timerDuration.name);
  }

  @override
  Future<TimerDuration> readTimerDurationPreference() async {
    final name = await dataSource.readValue(timerDurationKey);
    if (name == null || name.isEmpty) {
      await dataSource.writeValue(
        timerDurationKey,
        TimerDuration.standard.name,
      );
      return TimerDuration.standard;
    }
    return TimerDuration.fromString(name);
  }

  @override
  Future<void> writeCustomDuration(int minutes) async {
    await dataSource.writeValue(customDurationKey, minutes.toString());
  }

  @override
  Future<int> readCustomDuration() async {
    final value = await dataSource.readValue(customDurationKey);
    return int.tryParse(value ?? '60') ?? 60;
  }

  @override
  Future<bool?> readBool(String key) async {
    final value = await dataSource.readValue(key);
    if (value == null) return null;
    return value == 'true';
  }

  @override
  Future<void> writeBool(String key, {required bool value}) async {
    await dataSource.writeValue(key, value.toString());
  }

  @override
  Future<int?> readInt(String key) async {
    final value = await dataSource.readValue(key);
    return int.tryParse(value ?? '');
  }

  @override
  Future<void> writeInt(String key, {required int value}) async {
    await dataSource.writeValue(key, value.toString());
  }

  @override
  Future<bool> isReminderEnabled() async {
    return await readBool(_reminderEnabledKey) ?? true; // Default true
  }

  @override
  Future<void> setReminderEnabled({required bool enabled}) async {
    await writeBool(_reminderEnabledKey, value: enabled);
  }

  @override
  Future<int> getReminderMinutes() async {
    return await readInt(_reminderMinutesKey) ?? 5; // Default 5 mins
  }

  @override
  Future<void> setReminderMinutes(int minutes) async {
    await writeInt(_reminderMinutesKey, value: minutes);
  }
}

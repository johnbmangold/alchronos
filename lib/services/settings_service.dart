import 'package:alchronos/repositories/storage_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SettingsService {
  SettingsService(this._storageRepository);

  final StorageRepository _storageRepository;

  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _reminderMinutesKey = 'reminder_minutes';

  /// Check if reminder notifications are enabled
  Future<bool> isReminderEnabled() async {
    try {
      return await _storageRepository.readBool(_reminderEnabledKey) ?? false;
    } on Exception {
      return false;
    }
  }

  /// Enable or disable reminder notifications
  Future<void> setReminderEnabled({required bool enabled}) async {
    await _storageRepository.writeBool(_reminderEnabledKey, value: enabled);
  }

  /// Get reminder minutes before timer ends
  Future<int> getReminderMinutes() async {
    try {
      return await _storageRepository.readInt(_reminderMinutesKey) ?? 5;
    } on Exception {
      return 5;
    }
  }

  /// Set reminder minutes before timer ends
  Future<void> setReminderMinutes({required int minutes}) async {
    if (minutes > 0 && minutes <= 60) {
      await _storageRepository.writeInt(_reminderMinutesKey, value: minutes);
    }
  }
}

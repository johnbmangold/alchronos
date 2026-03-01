// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:alchronos/app_database.dart' as _i388;
import 'package:alchronos/configurator.dart' as _i188;
import 'package:alchronos/home/cubit/home_cubit.dart' as _i925;
import 'package:alchronos/local_notifications.dart' as _i871;
import 'package:alchronos/repositories/partial_run_repository.dart' as _i524;
import 'package:alchronos/repositories/repositories.dart' as _i312;
import 'package:alchronos/repositories/storage_repository.dart' as _i111;
import 'package:alchronos/services/audio_service.dart' as _i472;
import 'package:alchronos/services/haptic_service.dart' as _i533;
import 'package:alchronos/services/history_service.dart' as _i365;
import 'package:alchronos/services/partial_run_service.dart' as _i590;
import 'package:alchronos/services/performance_service.dart' as _i1052;
import 'package:alchronos/services/services.dart' as _i638;
import 'package:alchronos/services/settings_service.dart' as _i402;
import 'package:alchronos/services/storage_service.dart' as _i79;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    gh.factory<_i974.Logger>(() => appModule.logger);
    gh.factory<_i163.FlutterLocalNotificationsPlugin>(
        () => appModule.flutterLocalNotificationsPlugin);
    gh.factory<_i558.FlutterSecureStorage>(
        () => appModule.flutterSecureStorage);
    gh.lazySingleton<_i388.AppDatabase>(() => _i388.AppDatabase());
    gh.lazySingleton<_i472.AudioService>(() => _i472.AudioService());
    gh.lazySingleton<_i533.HapticService>(() => _i533.HapticService());
    gh.lazySingleton<_i871.LocalNotifications>(() => _i871.LocalNotifications(
        flutterLocalNotificationsPlugin:
            gh<_i163.FlutterLocalNotificationsPlugin>()));
    gh.factory<_i79.StorageService>(() => _i79.StorageService(
        flutterSecureStorage: gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i1052.PerformanceService>(
        () => _i1052.PerformanceService(gh<_i974.Logger>()));
    gh.lazySingleton<_i365.HistoryService>(() => _i365.HistoryService(
          gh<_i388.AppDatabase>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i590.PartialRunService>(
        () => _i590.PartialRunService(gh<_i388.AppDatabase>()));
    gh.factory<_i111.StorageRepository>(() =>
        _i111.StorageRepository(storageService: gh<_i638.StorageService>()));
    gh.factory<_i524.PartialRunRepository>(() => _i524.PartialRunRepository(
        partialRunService: gh<_i590.PartialRunService>()));
    gh.lazySingleton<_i402.SettingsService>(
        () => _i402.SettingsService(gh<_i111.StorageRepository>()));
    gh.factory<_i925.HomeCubit>(() => _i925.HomeCubit(
          logger: gh<_i974.Logger>(),
          partialRunRepository: gh<_i312.PartialRunRepository>(),
          flutterLocalNotificationsPlugin:
              gh<_i163.FlutterLocalNotificationsPlugin>(),
          storageRepository: gh<_i312.StorageRepository>(),
          hapticService: gh<_i533.HapticService>(),
          audioService: gh<_i472.AudioService>(),
          settingsService: gh<_i402.SettingsService>(),
          performanceService: gh<_i1052.PerformanceService>(),
          historyService: gh<_i365.HistoryService>(),
        ));
    return this;
  }
}

class _$AppModule extends _i188.AppModule {}

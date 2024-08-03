// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:alchronos/configurator.dart' as _i12;
import 'package:alchronos/local_notifications.dart' as _i5;
import 'package:alchronos/repositories/partial_run_repository.dart' as _i9;
import 'package:alchronos/repositories/storage_repository.dart' as _i10;
import 'package:alchronos/services/partial_run_service.dart' as _i7;
import 'package:alchronos/services/services.dart' as _i11;
import 'package:alchronos/services/storage_service.dart' as _i8;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i3;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i4;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i6;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    gh.factory<_i3.FlutterLocalNotificationsPlugin>(
        () => appModule.flutterLocalNotificationsPlugin);
    gh.factory<_i4.FlutterSecureStorage>(() => appModule.flutterSecureStorage);
    gh.lazySingleton<_i5.LocalNotifications>(() => _i5.LocalNotifications(
        flutterLocalNotificationsPlugin:
            gh<_i3.FlutterLocalNotificationsPlugin>()));
    gh.factory<_i6.Logger>(() => appModule.logger);
    gh.factory<_i7.PartialRunService>(() => _i7.PartialRunService());
    gh.factory<_i8.StorageService>(() => _i8.StorageService(
        flutterSecureStorage: gh<_i4.FlutterSecureStorage>()));
    gh.factory<_i9.PartialRunRepository>(() => _i9.PartialRunRepository(
        partialRunService: gh<_i7.PartialRunService>()));
    gh.factory<_i10.StorageRepository>(() =>
        _i10.StorageRepository(storageService: gh<_i11.StorageService>()));
    return this;
  }
}

class _$AppModule extends _i12.AppModule {}

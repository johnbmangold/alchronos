import 'dart:async';

import 'package:alchronos/firebase_options.dart';
import 'package:alchronos/local_notifications.dart';
import 'package:alchronos/received_notification.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alchronos/home/views/home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const taskIdentifier = 'drinkTimerIdentifier';
const taskName = 'drinkTimerName';
const oneHourInMinutes = 60;
const oneHourInSeconds = 3600;

final getIt = GetIt.instance;

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initFirebase();

  registerDependencies();

  await getIt.get<LocalNotifications>().initialize();

  runApp(const AlchronosApp());

  await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  FlutterNativeSplash.remove();
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };
}

void registerDependencies() {
  // Logger
  getIt.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(),
    ),
  );

  // FlutterLocalNotificationPlugin
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );

  // LocalNotifications
  getIt.registerLazySingleton(
    () => LocalNotifications(
      flutterLocalNotificationsPlugin:
          getIt.get<FlutterLocalNotificationsPlugin>(),
    ),
  );
}

class AlchronosApp extends StatelessWidget {
  const AlchronosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final alchronosPink = Colors.pink.shade100;
    CustomColors lightCustomColors = CustomColors(
      brand: alchronosPink,
      drinkStartColor: Colors.amber.shade300,
      drinkEndColor: Colors.amberAccent.shade700,
    );
    CustomColors darkCustomColors = CustomColors(
      brand: alchronosPink,
      drinkStartColor: Colors.amber.shade300,
      drinkEndColor: Colors.amberAccent.shade700,
    );

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          lightCustomColors = lightCustomColors.harmonized(lightColorScheme);
          darkColorScheme = darkDynamic.harmonized();
          darkCustomColors = darkCustomColors.harmonized(darkColorScheme);
        } else {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: alchronosPink,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: alchronosPink,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'Alchronos',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            extensions: [lightCustomColors],
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            extensions: [darkCustomColors],
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        );
      },
    );
  }
}

Future<void> showNotificationInBackground() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final localNotifications = LocalNotifications(
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  );
  await flutterLocalNotificationsPlugin.show(
    localNotifications.getNotificationId(),
    'Drink Timer Complete',
    'You can order another drink when you\'re feeling up to it.',
    localNotifications.getNotificationDetailsTimesUp(),
    payload: 1.toString(),
  );
}

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
Future<void> backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    getIt.get<Logger>().i('[BackgroundFetch] Headless task timed-out: $taskId');
    await BackgroundFetch.stop(taskId);
    BackgroundFetch.finish(taskId);
    return;
  }

  getIt.get<Logger>().i('[BackgroundFetch] Headless event received: $taskId');
  await showNotificationInBackground();
  await BackgroundFetch.stop(taskId);
  BackgroundFetch.finish(taskId);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  getIt
      .get<Logger>()
      .i('notification(${notificationResponse.id}) action tapped: '
          '${notificationResponse.actionId} with'
          ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    getIt.get<Logger>().i(
          'notification action tapped with input: ${notificationResponse.input}',
        );
  }
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.brand,
    required this.drinkStartColor,
    required this.drinkEndColor,
  });

  final Color? brand;
  final Color? drinkStartColor;
  final Color? drinkEndColor;

  @override
  CustomColors copyWith({
    Color? brand,
    Color? drinkStartColor,
    Color? drinkEndColor,
  }) {
    return CustomColors(
      brand: brand ?? this.brand,
      drinkStartColor: drinkStartColor ?? this.drinkStartColor,
      drinkEndColor: drinkEndColor ?? this.drinkEndColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      brand: Color.lerp(brand, other.brand, t),
      drinkStartColor: Color.lerp(drinkStartColor, other.drinkStartColor, t),
      drinkEndColor: Color.lerp(drinkEndColor, other.drinkEndColor, t),
    );
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(
      brand: brand!.harmonizeWith(dynamic.primary),
      drinkStartColor: drinkStartColor!.harmonizeWith(dynamic.primary),
      drinkEndColor: drinkEndColor!.harmonizeWith(dynamic.primary),
    );
  }
}

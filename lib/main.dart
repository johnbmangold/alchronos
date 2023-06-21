import 'dart:async';

import 'package:alchronos/about/views/about_screen.dart';
import 'package:alchronos/firebase_options.dart';
import 'package:alchronos/local_notifications.dart';
import 'package:alchronos/received_notification.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alchronos/home/views/home_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

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

  registerDependencies();

  await getIt.get<LocalNotifications>().initialize();

  runApp(MyApp(logger: getIt.get<Logger>()));

  FlutterNativeSplash.remove();
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
    () => FlutterLocalNotificationsPlugin(),
  );

  // LocalNotifications
  getIt.registerLazySingleton(
    () => LocalNotifications(
      flutterLocalNotificationsPlugin:
          getIt.get<FlutterLocalNotificationsPlugin>(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => HomeScreen(logger: getIt.get<Logger>()),
    ),
    GoRoute(
      name: 'about',
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.logger});

  final Logger logger;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Alchronos',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink.shade100,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink.shade100,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}

Future<void> showNotification() async {
  await getIt.get<FlutterLocalNotificationsPlugin>().show(
        getIt.get<LocalNotifications>().getNotificationId(),
        'Drink Timer Complete',
        'You can order another drink when you\'re feeling up to it.',
        getIt.get<LocalNotifications>().getNotificationDetailsTimesUp(),
        payload: 1.toString(),
      );
}

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
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
  await showNotification();
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

import 'dart:async';

import 'package:alchronos/configurator.dart';
import 'package:alchronos/firebase_options.dart';
import 'package:alchronos/home/views/home_screen.dart';
import 'package:alchronos/l10n/app_localizations.dart';
import 'package:alchronos/local_notifications.dart';
import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

const workmanagerTitleKey = 'title';
const workmanagerMessageKey = 'message';
const fallbackTitle = 'Drink Timer Complete';
const fallbackMessage =
    "You can order another drink when you're feeling up to it.";

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initFirebase();
  configureDependencies();

  await getIt.get<LocalNotifications>().initialize(headless: false);

  await Workmanager().initialize(callbackDispatcher);

  runApp(const AlchronosApp());
}

// Mandatory if the App is obfuscated or using Flutter 3.1+
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await showNotificationInBackground(
      inputData?[workmanagerTitleKey].toString() ?? fallbackTitle,
      inputData?[workmanagerMessageKey].toString() ?? fallbackMessage,
    );
    return Future.value(true);
  });
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(FirebaseCrashlytics.instance.recordError(error, stack));
    return true;
  };
}

class AlchronosApp extends StatelessWidget {
  const AlchronosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final alchronosPink = Colors.pink.shade100;
    var lightCustomColors = CustomColors(
      brand: alchronosPink,
      drinkStartColor: Colors.amber.shade300,
      drinkEndColor: Colors.amberAccent.shade700,
    );
    var darkCustomColors = CustomColors(
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
          lightColorScheme = ColorScheme.fromSeed(seedColor: alchronosPink);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: alchronosPink,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'Alchronos',
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

Future<void> showNotificationInBackground(String title, String message) async {
  final logger = Logger(printer: PrettyPrinter())
    ..i('[BackgroundFetch] Headless event received');
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final localNotifications = LocalNotifications(
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  );
  logger.i('[BackgroundFetch] Initializing notifications');
  await localNotifications.initialize(headless: true);
  logger.i('[BackgroundFetch] Showing notification');
  await flutterLocalNotificationsPlugin.show(
    localNotifications.getNotificationId(),
    title,
    message,
    localNotifications.getNotificationDetailsTimesUp(),
    payload: 1.toString(),
  );
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  final logger = Logger(printer: PrettyPrinter())
    ..i(
      'notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}',
    );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    logger.i(
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

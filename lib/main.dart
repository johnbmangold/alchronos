import 'dart:async';

import 'package:alchronos/firebase_options.dart';
import 'package:alchronos/home/views/home_screen.dart';
import 'package:alchronos/infrastructure/services/notification_service.dart';
import 'package:alchronos/l10n/app_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

/// Key used to pass the notification title through Workmanager.
const workmanagerTitleKey = 'title';

/// Key used to pass the notification message through Workmanager.
const workmanagerMessageKey = 'message';

/// The fallback title used when no title is provided for the notification.
const fallbackTitle = 'Drink Timer Complete';

/// The fallback message used when no message is provided for the notification.
const fallbackMessage =
    "You can order another drink when you're feeling up to it.";

/// The main entry point for the Flutter application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initFirebase();

  // Initialize background tasks
  await Workmanager().initialize(callbackDispatcher);

  runApp(
    const ProviderScope(
      child: AlchronosApp(),
    ),
  );
}

/// The callback dispatcher used by Workmanager to handle background tasks.
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

/// Initializes Firebase services and Crashlytics error reporting.
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

/// The root widget of the Alchronos application.
class AlchronosApp extends ConsumerStatefulWidget {
  /// Creates an [AlchronosApp] widget.
  const AlchronosApp({super.key});

  @override
  ConsumerState<AlchronosApp> createState() => _AlchronosAppState();
}

class _AlchronosAppState extends ConsumerState<AlchronosApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notifications
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize(headless: false);
    });
  }

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
      drinkStartColor: Colors.amber.shade400,
      drinkEndColor: Colors.amberAccent.shade400,
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
            brightness: Brightness.dark,
            scaffoldBackgroundColor: darkColorScheme.surface,
            cardColor: darkColorScheme.surfaceContainerHighest,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: darkColorScheme.onSurface),
              bodyMedium: TextStyle(color: darkColorScheme.onSurface),
              bodySmall: TextStyle(color: darkColorScheme.onSurfaceVariant),
              titleLarge: TextStyle(color: darkColorScheme.onSurface),
              titleMedium: TextStyle(color: darkColorScheme.onSurface),
              titleSmall: TextStyle(color: darkColorScheme.onSurface),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkColorScheme.primary,
                foregroundColor: darkColorScheme.onPrimary,
                elevation: 2,
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: darkColorScheme.primary,
                foregroundColor: darkColorScheme.onPrimary,
                elevation: 2,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: darkColorScheme.primary,
                side: BorderSide(color: darkColorScheme.primary),
              ),
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        );
      },
    );
  }
}

/// Triggers a local notification when the app is in the background.
Future<void> showNotificationInBackground(String title, String message) async {
  final logger = Logger(printer: PrettyPrinter())
    ..i('[BackgroundFetch] Headless event received');
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final notificationService = NotificationService(
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
  );
  logger.i('[BackgroundFetch] Initializing notifications');
  await notificationService.initialize(headless: true);
  logger.i('[BackgroundFetch] Showing notification');
  await flutterLocalNotificationsPlugin.show(
    id: notificationService.getNotificationId(),
    title: title,
    body: message,
    notificationDetails: notificationService.getNotificationDetailsTimesUp(),
    payload: 1.toString(),
  );
}

/// Callback triggered when a notification is tapped while the app
/// is in the background.
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

/// Defines custom theme colors extending the standard ThemeData.
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  /// Creates [CustomColors] with the specified brand and drink colors.
  const CustomColors({
    required this.brand,
    required this.drinkStartColor,
    required this.drinkEndColor,
  });

  /// The primary brand color.
  final Color? brand;

  /// The starting gradient color for the drink animation.
  final Color? drinkStartColor;

  /// The ending gradient color for the drink animation.
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

  /// Harmonizes the custom colors with the given dynamic [ColorScheme].
  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(
      brand: brand!.harmonizeWith(dynamic.primary),
      drinkStartColor: drinkStartColor!.harmonizeWith(dynamic.primary),
      drinkEndColor: drinkEndColor!.harmonizeWith(dynamic.primary),
    );
  }
}

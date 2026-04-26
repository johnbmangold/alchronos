import 'dart:io';
import 'dart:math';

import 'package:alchronos/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
  );
});

class NotificationService {
  const NotificationService({required this.flutterLocalNotificationsPlugin});

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> initialize({required bool headless}) async {
    tz.initializeTimeZones();

    /// A notification action which triggers a App navigation event
    const navigationActionId = 'id_3';

    // details of app launch
    await _checkAppLaunch();

    // Android notification settings
    final initializationSettingsAndroid = _getAndroidSettings();

    // Darwin notification categories (channels)
    final darwinNotificationCategories =
        _getDarwinCategories(navigationActionId);

    // Darwin notification settings
    final initializationSettingsDarwin =
        _getDarwinSettings(darwinNotificationCategories);

    // Linux Notification Settings
    final initializationSettingsLinux = _getLinuxSettings();

    // Notification settings
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    // initialize notifications
    await _initializeFlutterLocalNotificationsPlugin(
      initializationSettings,
      navigationActionId,
    );

    if (!headless) await _requestAndroidNotificationPermission();
  }

  NotificationDetails getNotificationDetailsTimesUp() {
    return NotificationDetails(
      android: _getAndroidNotificationDetailsTimesUp(),
    );
  }

  int getNotificationId() {
    final cryptoRandom = Random.secure();
    return cryptoRandom.nextInt(1000000);
  }

  Future<void> scheduleReminderNotification(
    int reminderMinutes,
    int totalMinutes,
    String title,
    String message,
  ) async {
    final reminderDelay = Duration(minutes: totalMinutes - reminderMinutes);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1, // Unique ID for reminder
      title: 'Timer Reminder',
      body: 'Your timer will complete in $reminderMinutes minutes',
      scheduledDate: tz.TZDateTime.now(tz.local).add(reminderDelay),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_reminder',
          'Timer Reminders',
          channelDescription: 'Notifications for timer reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _initializeFlutterLocalNotificationsPlugin(
    InitializationSettings initializationSettings,
    String navigationActionId,
  ) async {
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
          // user selected a notification
          // Handle notification selection
          case NotificationResponseType.selectedNotificationAction:
            // user selected notification action i.e. 'Mark as Read'
            if (notificationResponse.actionId == navigationActionId) {
              // Handle notification action
            }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _checkAppLaunch() async {
    final notificationAppLaunchDetails = !kIsWeb && Platform.isLinux
        ? null
        : await flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();

    // determine if action is needed from selected notification
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      // handle notification selection
      //notificationAppLaunchDetails!.notificationResponse?.payload;
    }
  }

  Future<void> _requestAndroidNotificationPermission() async {
    if (!Platform.isAndroid) return;

    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  AndroidInitializationSettings _getAndroidSettings() {
    return const AndroidInitializationSettings('app_icon');
  }

  List<DarwinNotificationCategory> _getDarwinCategories(
    String navigationActionId,
  ) {
    /// Defines a iOS/MacOS notification category for text input actions.
    const darwinNotificationCategoryText = 'textCategory';

    /// Defines a iOS/MacOS notification category for plain actions.
    const darwinNotificationCategoryPlain = 'plainCategory';

    return <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
    ];
  }

  DarwinInitializationSettings _getDarwinSettings(
    List<DarwinNotificationCategory> darwinNotificationCategories,
  ) {
    return DarwinInitializationSettings(
      notificationCategories: darwinNotificationCategories,
    );
  }

  LinuxInitializationSettings _getLinuxSettings() {
    return LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icon/app_icon.png'),
    );
  }

  AndroidNotificationDetails _getAndroidNotificationDetailsTimesUp() {
    return const AndroidNotificationDetails(
      'times_up',
      'Drink Timer Completion',
      channelDescription: 'Notification sent when drink timer has completed',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Drink timer has completed.',
    );
  }
}

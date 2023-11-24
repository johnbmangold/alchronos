import 'dart:io';
import 'dart:math';

import 'package:alchronos/main.dart';
import 'package:alchronos/received_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  const LocalNotifications({required this.flutterLocalNotificationsPlugin});

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> initialize(bool headless) async {
    /// A notification action which triggers a App navigation event
    const String navigationActionId = 'id_3';

    // details of app launch
    await _checkAppLaunch();

    // Android notification settings
    final AndroidInitializationSettings initializationSettingsAndroid =
        _getAndroidSettings();

    // Darwin notification categories (channels)
    final List<DarwinNotificationCategory> darwinNotificationCategories =
        _getDarwinCategories(navigationActionId);

    // Darwin notification settings
    final DarwinInitializationSettings initializationSettingsDarwin =
        _getDarwinSettings(darwinNotificationCategories);

    // Linux Notification Settings
    final LinuxInitializationSettings initializationSettingsLinux =
        _getLinuxSettings();

    // Notification settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
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

  Future<void> _initializeFlutterLocalNotificationsPlugin(
    InitializationSettings initializationSettings,
    String navigationActionId,
  ) async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            // user selected a notification
            selectNotificationStream.add(notificationResponse.payload);
          case NotificationResponseType.selectedNotificationAction:
            // user selected notification action i.e. 'Mark as Read'
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _checkAppLaunch() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
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

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  AndroidInitializationSettings _getAndroidSettings() {
    return const AndroidInitializationSettings('app_icon');
  }

  List<DarwinNotificationCategory> _getDarwinCategories(
    String navigationActionId,
  ) {
    /// Defines a iOS/MacOS notification category for text input actions.
    const String darwinNotificationCategoryText = 'textCategory';

    /// Defines a iOS/MacOS notification category for plain actions.
    const String darwinNotificationCategoryPlain = 'plainCategory';

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
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
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

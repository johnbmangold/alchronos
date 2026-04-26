import 'package:alchronos/infrastructure/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class FakeFlutterLocalNotificationsPlugin
    implements FlutterLocalNotificationsPlugin {
  int initializeCalledCount = 0;
  int zonedScheduleCalledCount = 0;
  InitializationSettings? lastInitializationSettings;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #initialize) {
      initializeCalledCount++;
      if (invocation.positionalArguments.isNotEmpty) {
        lastInitializationSettings =
            invocation.positionalArguments.first as InitializationSettings?;
      } else if (invocation.namedArguments.containsKey(#settings)) {
        lastInitializationSettings =
            invocation.namedArguments[#settings] as InitializationSettings?;
      }
      return Future<bool?>.value(true);
    }
    if (invocation.memberName == #zonedSchedule) {
      zonedScheduleCalledCount++;
      return Future<void>.value();
    }
    if (invocation.memberName == #getNotificationAppLaunchDetails) {
      return Future<NotificationAppLaunchDetails?>.value();
    }
    if (invocation.memberName == #resolvePlatformSpecificImplementation) {
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late NotificationService service;
  late FakeFlutterLocalNotificationsPlugin fakePlugin;

  setUpAll(tz.initializeTimeZones);

  setUp(() {
    fakePlugin = FakeFlutterLocalNotificationsPlugin();
    service = NotificationService(flutterLocalNotificationsPlugin: fakePlugin);
  });

  group('initialize', () {
    test('initializes flutterLocalNotificationsPlugin with correct settings',
        () async {
      await service.initialize(headless: true);

      expect(fakePlugin.initializeCalledCount, 1);

      final settings = fakePlugin.lastInitializationSettings;
      expect(settings, isNotNull);
      expect(settings?.android, isNotNull);
      expect(settings?.iOS, isNotNull);
      expect(settings?.macOS, isNotNull);
      expect(settings?.linux, isNotNull);
    });
  });

  group('getNotificationId', () {
    test('returns a number', () {
      final id = service.getNotificationId();
      expect(id, isA<int>());
    });
  });

  group('getNotificationDetailsTimesUp', () {
    test('returns AndroidNotificationDetails for times up', () {
      final details = service.getNotificationDetailsTimesUp();
      expect(details.android?.channelId, 'times_up');
      expect(details.android?.importance, Importance.max);
      expect(details.android?.priority, Priority.max);
    });
  });

  group('scheduleReminderNotification', () {
    test('schedules notification with correct time delta', () async {
      await service.scheduleReminderNotification(5, 30, 'Title', 'Message');

      expect(fakePlugin.zonedScheduleCalledCount, 1);
    });
  });
}

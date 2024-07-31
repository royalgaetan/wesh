import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationChannel {
  final String channelId;
  final String channelName;
  final String channelDescription;
  final Importance channelImportance;
  final Priority channelPriority;
  final AudioAttributesUsage audioAttributesUsage;

  NotificationChannel({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.channelPriority,
    required this.channelImportance,
    required this.audioAttributesUsage,
  });
}

class NotificationApi {
  static final notification = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  // Init Notification Api [Without Listen to OnNotificationTap]
  static Future initWithoutListenToOnNotificationTap({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    // const ios = IOSInitializationSettings();
    const settings = InitializationSettings(android: android);

    await notification.initialize(settings, onDidReceiveNotificationResponse: (payload) async {
      log('Has triggered : initWithoutListenToOnNotificationTap');
    });

    if (initScheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }

  // Init Notification Api
  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    // const ios = IOSInitializationSettings();
    const settings = InitializationSettings(android: android);

    // When app is closed
    final details = await notification.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      log('Has triggered Notification when CLOSED');
      onNotification.add(details.notificationResponse!.payload);
    }

    await notification.initialize(settings, onDidReceiveNotificationResponse: (notificationfResponse) async {
      log('Has triggered Notification');
      onNotification.add(notificationfResponse.payload);
    });

    if (initScheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }

  // Notification Details
  static Future notificationDetails(
      {required NotificationChannel channel, required largeIconPath, int? badgeNumber}) async {
    // final styleInformation = BigPictureStyleInformation(const FilePathAndroidBitmap(''), largeIcon: largeIconPath);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.channelId,
        channel.channelName,
        channelDescription: channel.channelDescription,
        importance: channel.channelImportance,
        priority: channel.channelPriority,
        channelShowBadge: true,
        audioAttributesUsage: channel.audioAttributesUsage,
        number: badgeNumber,
        // styleInformation: styleInformation,
        styleInformation: const BigTextStyleInformation(''),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
      ),
      // iOS: const IOSNotificationDetails(),
    );
  }

  // Show Simple Notification
  static Future showSimpleNotification({
    required NotificationChannel channel,
    required String largeIconPath,
    required int id,
    required String title,
    required String body,
    required String payload,
    int? badgeNumber,
  }) async {
    log('#Notification ID: $id');
    notification.show(
      id,
      title,
      body,
      await notificationDetails(channel: channel, largeIconPath: largeIconPath, badgeNumber: badgeNumber),
      payload: payload,
    );
  }

  // Show Scheduled Notification
  static Future showScheduledNotification({
    required NotificationChannel channel,
    required String largeIconPath,
    required int id,
    required String title,
    required String body,
    required String payload,
    required tz.TZDateTime tzDateTime,
    DateTimeComponents? dateTimeComponents,
  }) async {
    log('#Notification [Scheduled] ID: $id | $tzDateTime | $body');
    try {
      notification.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        await notificationDetails(channel: channel, largeIconPath: largeIconPath),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: dateTimeComponents,
      );
    } catch (e) {
      //
      log('Err: $e');
    }
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationChannel {
  final String channelId;
  final String channelName;
  final String channelDescription;
  final Importance channelImportance;
  final Priority channelPriority;

  NotificationChannel({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.channelPriority,
    required this.channelImportance,
  });
}

class NotificationApi {
  static final notification = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  // Init Notification Api
  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = IOSInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await notification.initialize(settings, onSelectNotification: (payload) async {
      onNotification.add(payload);
    });
  }

  // Notification Details
  static Future notificationDetails({required NotificationChannel channel, required largeIconPath}) async {
    // final styleInformation = BigPictureStyleInformation(const FilePathAndroidBitmap(''), largeIcon: largeIconPath);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.channelId,
        channel.channelName,
        channelDescription: channel.channelDescription,
        importance: channel.channelImportance,
        priority: channel.channelPriority,
        // styleInformation: styleInformation,
        largeIcon: FilePathAndroidBitmap(largeIconPath),
      ),
      iOS: const IOSNotificationDetails(),
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
  }) async {
    notification.show(
      id,
      title,
      body,
      await notificationDetails(channel: channel, largeIconPath: largeIconPath),
      payload: payload,
    );
  }

  // Show Scheduled Notification
}

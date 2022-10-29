final String notificationsTable = 'notifications';

// FIELDS
class NotificationFields {
  static final List<String> values = [
    'notificationId',
    'uid',
    'contentId',
    'type',
    'createdAt',
  ];

  static final String notificationId = 'notificationId';
  static final String uid = 'uid';
  static final String contentId = 'contentId';
  static final String type = 'type';
  static final String createdAt = 'createdAt';
}

class Notification {
  final String notificationId;
  final String uid;
  final String contentId;
  final String type;
  final DateTime createdAt;

  // Constructor
  Notification({
    required this.notificationId,
    required this.uid,
    required this.contentId,
    required this.type,
    required this.createdAt,
  });

  // toJson
  Map<String, Object?> toJson() => {
        NotificationFields.notificationId: notificationId,
        NotificationFields.uid: uid,
        NotificationFields.contentId: contentId,
        NotificationFields.type: type,
        NotificationFields.createdAt: createdAt.toIso8601String(),
      };

  // fromJson
  static Notification fromJson(Map<String, dynamic> json) => Notification(
        notificationId: (json[NotificationFields.notificationId]) ?? '',
        uid: json[NotificationFields.uid] ?? '',
        contentId: json[NotificationFields.contentId] ?? '',
        type: json[NotificationFields.type] ?? '',
        //
        createdAt: json[NotificationFields.createdAt] != null
            ? DateTime.parse(json[NotificationFields.createdAt])
            : DateTime.now(),
      );
}

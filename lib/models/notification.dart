import 'package:cloud_firestore/cloud_firestore.dart';

// FIELDS

class NotificationFields {
  static final List<String> values = [
    'notificationId',
    'uid',
    'contentId',
    'type',
    'createdAt',
  ];

  static const String notificationId = 'notificationId';
  static const String uid = 'uid';
  static const String contentId = 'contentId';
  static const String type = 'type';
  static const String createdAt = 'createdAt';
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
  Map<String, dynamic> toJson() => {
        NotificationFields.notificationId: notificationId,
        NotificationFields.uid: uid,
        NotificationFields.contentId: contentId,
        NotificationFields.type: type,
        NotificationFields.createdAt: createdAt,
      };

  // fromJson
  static Notification fromJson(Map<String, dynamic> json) => Notification(
        notificationId: (json[NotificationFields.notificationId]) ?? '',
        uid: json[NotificationFields.uid] ?? '',
        contentId: json[NotificationFields.contentId] ?? '',
        type: json[NotificationFields.type] ?? '',
        //
        createdAt: json['createdAt'] != null && json['createdAt'] != ''
            ? (json['createdAt'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
      );
}

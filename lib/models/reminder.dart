// FIELDS
import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderFields {
  static final List<String> values = [
    'title',
    'reminderId',
    'uid',
    'reminderDelay',
    'eventId',
    'createdAt',
    'modifiedAt',
    'remindAt',
    'remindFrom',
    'recurrence',
    'status',
  ];

  static const String title = 'title';
  static const String reminderId = 'reminderId';
  static const String uid = 'uid';
  static const String reminderDelay = 'reminderDelay';
  static const String eventId = 'eventId';
  static const String createdAt = 'createdAt';
  static const String modifiedAt = 'modifiedAt';
  static const String remindAt = 'remindAt';
  static const String remindFrom = 'remindFrom';
  static const String recurrence = 'recurrence';
  static const String status = 'status';
}

class Reminder {
  final String title;
  final String reminderId;
  final String uid;
  final String reminderDelay;
  final String eventId;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime remindAt;
  final DateTime remindFrom;
  final String recurrence;
  final String status;

  // Constructor
  Reminder({
    required this.title,
    required this.reminderId,
    required this.uid,
    required this.reminderDelay,
    required this.status,
    required this.eventId,
    required this.recurrence,
    required this.createdAt,
    required this.remindAt,
    required this.modifiedAt,
    required this.remindFrom,
  });

  // Copy

  // toJson
  Map<String, Object?> toJson() => {
        ReminderFields.title: title,
        ReminderFields.reminderId: reminderId,
        ReminderFields.uid: uid,
        ReminderFields.reminderDelay: reminderDelay,
        ReminderFields.eventId: eventId,
        ReminderFields.createdAt: createdAt,
        ReminderFields.modifiedAt: modifiedAt,
        ReminderFields.remindAt: remindAt,
        ReminderFields.remindFrom: remindFrom,
        ReminderFields.recurrence: recurrence,
        ReminderFields.status: status,
      };

  // fromJson
  static Reminder fromJson(Map<String, dynamic> json) => Reminder(
      title: json[ReminderFields.title] ?? '',
      uid: json[ReminderFields.uid] ?? '',
      reminderId: json[ReminderFields.reminderId] ?? '',
      reminderDelay: json[ReminderFields.reminderDelay] ?? '',
      eventId: json[ReminderFields.eventId] ?? '',
      recurrence: json[ReminderFields.recurrence] ?? '',
      status: json[ReminderFields.status] ?? '',
      //
      //
      createdAt: json['createdAt'] != null && json['createdAt'] != ''
          ? (json['createdAt'] as Timestamp).toDate().toLocal()
          : DateTime.now(),

      //
      modifiedAt: json['modifiedAt'] != null && json['modifiedAt'] != ''
          ? (json['modifiedAt'] as Timestamp).toDate().toLocal()
          : DateTime.now(),
      //
      remindFrom: json['remindFrom'] != null && json['remindFrom'] != ''
          ? (json['remindFrom'] as Timestamp).toDate().toLocal()
          : DateTime.now(),
      //
      remindAt: json['remindAt'] != null && json['remindAt'] != ''
          ? (json['remindAt'] as Timestamp).toDate().toLocal()
          : DateTime.now()
      //
      );
}

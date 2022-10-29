final String remindersTable = 'reminders';

// FIELDS
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

  static final String title = 'title';
  static final String reminderId = 'reminderId';
  static final String uid = 'uid';
  static final String reminderDelay = 'reminderDelay';
  static final String eventId = 'eventId';
  static final String createdAt = 'createdAt';
  static final String modifiedAt = 'modifiedAt';
  static final String remindAt = 'remindAt';
  static final String remindFrom = 'remindFrom';
  static final String recurrence = 'recurrence';
  static final String status = 'status';
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
        ReminderFields.createdAt: createdAt.toIso8601String(),
        ReminderFields.modifiedAt: modifiedAt.toIso8601String(),
        ReminderFields.remindAt: remindAt.toIso8601String(),
        ReminderFields.remindFrom: remindFrom.toIso8601String(),
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
        createdAt: json[ReminderFields.createdAt] != null
            ? DateTime.parse(json[ReminderFields.createdAt])
            : DateTime.now(),
        //
        modifiedAt: json[ReminderFields.modifiedAt] != null
            ? DateTime.parse(json[ReminderFields.modifiedAt])
            : DateTime.now(),
        //
        remindFrom: json[ReminderFields.remindFrom] != null
            ? DateTime.parse(json[ReminderFields.remindFrom])
            : DateTime.now(),
        //
        remindAt: json[ReminderFields.remindAt] != null
            ? DateTime.parse(json[ReminderFields.remindAt])
            : DateTime.now(),
        //
      );
}

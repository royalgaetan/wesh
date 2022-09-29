final String remindersTable = 'reminders';

// FIELDS
class ReminderFields {
  static final List<String> values = [
    '_id',
    'reminderId',
    'eventId',
    'remindAt',
    'status',
  ];

  static final String id = '_id';
  static final String reminderId = 'reminderId';
  static final String eventId = 'eventId';
  static final String remindAt = 'remindAt';
  static final String status = 'status';
}

class Reminder {
  final int? id;
  final String reminderId;
  final String eventId;
  final DateTime remindAt;
  final String status;

  // Constructor
  Reminder({
    this.id,
    required this.reminderId,
    required this.status,
    required this.eventId,
    required this.remindAt,
  });

  // Copy
  Reminder copy({
    int? id,
    String? reminderId,
    String? eventId,
    DateTime? remindAt,
    String? status,
  }) =>
      Reminder(
        id: id ?? this.id,
        reminderId: reminderId ?? this.reminderId,
        eventId: eventId ?? this.eventId,
        remindAt: remindAt ?? this.remindAt,
        status: status ?? this.status,
      );

  // toJson
  Map<String, Object?> toJson() => {
        ReminderFields.id: id,
        ReminderFields.reminderId: reminderId,
        ReminderFields.eventId: eventId,
        ReminderFields.remindAt: remindAt.toIso8601String(),
        ReminderFields.status: status,
      };

  // fromJson
  static Reminder fromJson(Map<String, Object?> json) => Reminder(
        id: json[ReminderFields.id] as int,
        reminderId: json[ReminderFields.reminderId] as String,
        eventId: json[ReminderFields.eventId] as String,
        remindAt: DateTime.parse(json[ReminderFields.remindAt] as String),
        status: json[ReminderFields.status] as String,
      );
}

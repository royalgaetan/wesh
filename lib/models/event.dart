final String eventTable = 'events';

// FIELS
class EventFields {
  static final List<String> values = [
    'eventId',
    'uid',
    'title',
    'caption',
    'trailing',
    'type',
    'color',
    'location',
    'link',
    'createdAt',
    'modifiedAt',
    'startDateTime',
    'endDateTime',
    'status',
  ];

  static final String eventId = 'eventId';
  static final String uid = 'uid';
  static final String title = 'title';
  static final String caption = 'caption';
  static final String trailing = 'trailing';
  static final String type = 'type';
  static final String color = 'color';
  static final String location = 'location';
  static final String link = 'link';
  static final String createdAt = 'createdAt';
  static final String modifiedAt = 'modifiedAt';
  static final String startDateTime = 'startDateTime';
  static final String endDateTime = 'endDateTime';
  static final String status = 'status';
}

class Event {
  final String eventId;
  final String uid;
  final String title;
  final String caption;
  final String trailing;
  final String type;
  final int color;
  final String location;
  final String link;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String status;

  // Constructor
  Event(
      {required this.eventId,
      required this.uid,
      required this.trailing,
      required this.type,
      required this.title,
      required this.color,
      required this.link,
      required this.caption,
      required this.location,
      required this.createdAt,
      required this.modifiedAt,
      required this.startDateTime,
      required this.endDateTime,
      required this.status});

  // Copy
  Event copy({
    String? eventId,
    String? uid,
    String? title,
    String? caption,
    String? type,
    String? trailing,
    int? color,
    String? location,
    String? link,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? status,
  }) =>
      Event(
        eventId: eventId ?? this.eventId,
        uid: uid ?? this.uid,
        title: title ?? this.title,
        caption: caption ?? this.caption,
        type: type ?? this.type,
        trailing: trailing ?? this.trailing,
        color: color ?? this.color,
        location: location ?? this.location,
        link: link ?? this.link,
        createdAt: createdAt ?? this.createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        startDateTime: startDateTime ?? this.startDateTime,
        endDateTime: endDateTime ?? this.endDateTime,
        status: status ?? this.status,
      );

  // toJson
  Map<String, Object?> toJson() => {
        EventFields.eventId: eventId,
        EventFields.uid: uid,
        EventFields.title: title,
        EventFields.caption: caption,
        EventFields.type: type,
        EventFields.trailing: trailing,
        EventFields.color: color,
        EventFields.location: location,
        EventFields.link: link,
        EventFields.createdAt: createdAt.toIso8601String(),
        EventFields.modifiedAt: modifiedAt.toIso8601String(),
        EventFields.startDateTime: startDateTime.toIso8601String(),
        EventFields.endDateTime: endDateTime.toIso8601String(),
        EventFields.status: status,
      };

  // fromJson
  static Event fromJson(Map<String, dynamic> json) => Event(
        eventId: (json[EventFields.eventId]) ?? '',
        uid: json[EventFields.uid] ?? '',
        type: json[EventFields.type] ?? '',
        trailing: json[EventFields.trailing] ?? '',
        title: json[EventFields.title] ?? '',
        color: json[EventFields.color] ?? 0,
        link: json[EventFields.link] ?? '',
        caption: json[EventFields.caption] ?? '',
        location: json[EventFields.location] ?? '',
        //
        createdAt: json[EventFields.createdAt] != null
            ? DateTime.parse(json[EventFields.createdAt])
            : DateTime.now(),
        //
        modifiedAt: json[EventFields.modifiedAt] != null
            ? DateTime.parse(json[EventFields.modifiedAt])
            : DateTime.now(),
        //
        startDateTime: json[EventFields.startDateTime] != null
            ? DateTime.parse(json[EventFields.startDateTime])
            : DateTime.now(),
        //
        endDateTime: json[EventFields.endDateTime] != null
            ? DateTime.parse(json[EventFields.endDateTime])
            : DateTime.now(),
        //
        status: json[EventFields.status] ?? '',
      );
}

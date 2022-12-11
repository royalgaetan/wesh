// FIELS
class EventFields {
  static const String eventId = 'eventId';
  static const String uid = 'uid';
  static const String title = 'title';
  static const String caption = 'caption';
  static const String trailing = 'trailing';
  static const String type = 'type';
  static const String color = 'color';
  static const String location = 'location';
  static const String link = 'link';
  static const String createdAt = 'createdAt';
  static const String modifiedAt = 'modifiedAt';
  static const String eventDurationType = 'eventDurationType';
  static const String eventDurations = 'eventDurations';
  static const String status = 'status';
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
  final String eventDurationType;
  final List<dynamic> eventDurations;
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
      required this.eventDurationType,
      required this.eventDurations,
      required this.status});

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
        EventFields.eventDurations: eventDurations,
        EventFields.eventDurationType: eventDurationType,
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
        createdAt: json[EventFields.createdAt] != null ? DateTime.parse(json[EventFields.createdAt]) : DateTime.now(),
        //
        modifiedAt:
            json[EventFields.modifiedAt] != null ? DateTime.parse(json[EventFields.modifiedAt]) : DateTime.now(),
        //
        status: json[EventFields.status] ?? '',
        eventDurationType: json[EventFields.eventDurationType] ?? '',
        eventDurations: json[EventFields.eventDurations] ?? [],
      );
}

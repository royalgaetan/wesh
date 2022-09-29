import 'package:wesh/models/messagestatus.dart';
import 'package:wesh/models/messagetype.dart';

final String messagesTable = 'messages';

// FIELDS
class MessageFields {
  static final List<String> values = [
    '_id',
    'messageId',
    'eventId',
    'senderId',
    'receiverId',
    'createdAt',
    'status',
    'type',
    'data',
    'caption',
  ];

  static final String id = '_id';
  static final String messageId = 'messageId';
  static final String eventId = 'eventId';
  static final String senderId = 'senderId';
  static final String receiverId = 'receiverId';
  static final String createdAt = 'createdAt';
  static final String status = 'status';
  static final String type = 'type';
  static final String data = 'data';
  static final String caption = 'caption';
}

class Message {
  final int? id;
  final String messageId;
  final String? eventId;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String status;
  final String type;
  final String data;
  final String caption;

// Constructor
  Message(
      {this.id,
      required this.messageId,
      required this.senderId,
      required this.receiverId,
      required this.createdAt,
      required this.status,
      required this.type,
      required this.data,
      required this.caption,
      this.eventId});

  // Copy
  Message copy({
    int? id,
    String? messageId,
    String? eventId,
    String? senderId,
    String? receiverId,
    DateTime? createdAt,
    String? status,
    String? type,
    String? data,
    String? caption,
  }) =>
      Message(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        eventId: eventId ?? this.eventId,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
        type: type ?? this.type,
        data: data ?? this.data,
        caption: caption ?? this.caption,
      );

  // toJson
  Map<String, Object?> toJson() => {
        MessageFields.id: id,
        MessageFields.messageId: messageId,
        MessageFields.eventId: eventId,
        MessageFields.senderId: senderId,
        MessageFields.receiverId: receiverId,
        MessageFields.createdAt: createdAt.toIso8601String(),
        MessageFields.status: status,
        MessageFields.type: type,
        MessageFields.data: data,
        MessageFields.caption: caption,
      };

  // fromJson
  static Message fromJson(Map<String, Object?> json) => Message(
        id: json[MessageFields.id] as int,
        messageId: json[MessageFields.messageId] as String,
        eventId: json[MessageFields.eventId] as String,
        senderId: json[MessageFields.senderId] as String,
        receiverId: json[MessageFields.receiverId] as String,
        createdAt: DateTime.parse(json[MessageFields.createdAt] as String),
        status: json[MessageFields.status] as String,
        type: json[MessageFields.type] as String,
        data: json[MessageFields.data] as String,
        caption: json[MessageFields.caption] as String,
      );
}

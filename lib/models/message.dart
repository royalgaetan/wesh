import 'package:cloud_firestore/cloud_firestore.dart';

// FIELDS
class MessageFields {
  static final List<String> values = [
    'messageId',
    'discussionId',
    'eventId',
    'storyId',
    'senderId',
    'receiverId',
    'createdAt',
    'status',
    'deleteFor',
    'read',
    'seen',
    'type',
    'data',
    'thumbnail',
    'filename',
    'caption',
    'paymentId',
    'messageToReplyId',
    'messageToReplyType',
    'messageToReplyData',
    'messageToReplyFilename',
    'messageToReplyThumbnail',
    'messageToReplyCaption',
    'messageToReplySenderId',
  ];

  static const String messageId = 'messageId';
  static const String discussionId = 'discussionId';
  static const String eventId = 'eventId';
  static const String storyId = 'storyId';
  static const String senderId = 'senderId';
  static const String receiverId = 'receiverId';
  static const String createdAt = 'createdAt';
  static const String status = 'status';
  static const String deleteFor = 'deleteFor';
  static const String read = 'read';
  static const String seen = 'seen';
  static const String type = 'type';
  static const String data = 'data';
  static const String thumbnail = 'thumbnail';
  static const String filename = 'filename';
  static const String caption = 'caption';
  static const String paymentId = 'paymentId';
  static const String messageToReplyId = 'messageToReplyId';
  static const String messageToReplyType = 'messageToReplyType';
  static const String messageToReplyData = 'messageToReplyData';
  static const String messageToReplyFilename = 'messageToReplyFilename';
  static const String messageToReplyThumbnail = 'messageToReplyThumbnail';
  static const String messageToReplyCaption = 'messageToReplyCaption';
  static const String messageToReplySenderId = 'messageToReplySenderId';
}

class Message {
  final String messageId;
  final String discussionId;
  final String eventId;
  final String storyId;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final int status;
  final String type;
  final List deleteFor;
  final List read;
  final List seen;
  final String data;
  final String thumbnail;
  final String filename;
  final String caption;
  final String paymentId;
  final String messageToReplyId;
  final String messageToReplyType;
  final String messageToReplyData;
  final String messageToReplyFilename;
  final String messageToReplyThumbnail;
  final String messageToReplyCaption;
  final String messageToReplySenderId;

// Constructor
  Message({
    required this.messageId,
    required this.discussionId,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.status,
    required this.type,
    required this.data,
    required this.deleteFor,
    required this.read,
    required this.seen,
    required this.caption,
    required this.eventId,
    required this.thumbnail,
    required this.filename,
    required this.storyId,
    required this.paymentId,
    required this.messageToReplyId,
    required this.messageToReplyType,
    required this.messageToReplyData,
    required this.messageToReplyFilename,
    required this.messageToReplyThumbnail,
    required this.messageToReplyCaption,
    required this.messageToReplySenderId,
  });

  // toJson
  Map<String, Object> toJson() => {
        MessageFields.messageId: messageId,
        MessageFields.discussionId: discussionId,
        MessageFields.eventId: eventId,
        MessageFields.storyId: storyId,
        MessageFields.senderId: senderId,
        MessageFields.receiverId: receiverId,
        MessageFields.createdAt: createdAt,
        MessageFields.type: type,
        MessageFields.data: data,
        MessageFields.caption: caption,
        MessageFields.thumbnail: thumbnail,
        MessageFields.filename: filename,
        MessageFields.status: status,
        MessageFields.deleteFor: deleteFor,
        MessageFields.read: read,
        MessageFields.seen: seen,
        MessageFields.paymentId: paymentId,
        MessageFields.messageToReplyId: messageToReplyId,
        MessageFields.messageToReplyType: messageToReplyType,
        MessageFields.messageToReplyData: messageToReplyData,
        MessageFields.messageToReplyFilename: messageToReplyFilename,
        MessageFields.messageToReplyThumbnail: messageToReplyThumbnail,
        MessageFields.messageToReplyCaption: messageToReplyCaption,
        MessageFields.messageToReplySenderId: messageToReplySenderId,
      };

  // fromJson
  static Message fromJson(Map<String, dynamic> json) => Message(
        messageId: json['messageId'] ?? '',
        discussionId: json['discussionId'] ?? '',
        eventId: json['eventId'] ?? '',
        storyId: json['storyId'] ?? '',
        senderId: json['senderId'] ?? '',
        receiverId: json['receiverId'] ?? '',
        status: json['status'] ?? 0,
        type: json['type'] ?? '',
        data: json['data'] ?? '',
        caption: json['caption'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
        filename: json['filename'] ?? '',
        deleteFor: json['deleteFor'] ?? [],
        read: json['read'] ?? [],
        seen: json['seen'] ?? [],
        //

        createdAt: json['createdAt'] != null && json['createdAt'] != ''
            ? (json['createdAt'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
        //
        paymentId: json['paymentId'] ?? '',
        //
        messageToReplyId: json['messageToReplyId'] ?? '',
        messageToReplyType: json['messageToReplyType'] ?? '',
        messageToReplyData: json['messageToReplyData'] ?? '',
        messageToReplyFilename: json['messageToReplyFilename'] ?? '',
        messageToReplyThumbnail: json['messageToReplyThumbnail'] ?? '',
        messageToReplyCaption: json['messageToReplyCaption'] ?? '',
        messageToReplySenderId: json['messageToReplySenderId'] ?? '',
      );
}

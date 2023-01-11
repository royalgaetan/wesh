import 'package:cloud_firestore/cloud_firestore.dart';

class FeedBack {
  final String feedbackId;
  final String uid;
  final String name;
  final String content;
  final String reactionTitle;
  final String reactionEmoji;
  final DateTime createdAt;
  // Constructor
  FeedBack({
    required this.feedbackId,
    required this.uid,
    required this.name,
    required this.reactionTitle,
    required this.reactionEmoji,
    required this.content,
    required this.createdAt,
  });

  // ToJson

  Map<String, dynamic> toJson() => {
        'feedbackId': feedbackId,
        'uid': uid,
        'name': name,
        'reactionTitle': reactionTitle,
        'reactionEmoji': reactionEmoji,
        'content': content,
        'createdAt': createdAt,
      };

  // From Json
  static FeedBack fromJson(Map<String, dynamic> json) => FeedBack(
        feedbackId: json['feedbackId'] ?? '',
        uid: json['uid'] ?? '',
        name: json['name'] ?? '',
        content: json['content'] ?? '',
        reactionTitle: json['reactionTitle'] ?? '',
        reactionEmoji: json['reactionEmoji'] ?? '',
        //
        createdAt: json['createdAt'] != null && json['createdAt'] != ''
            ? (json['createdAt'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
        //
      );
}

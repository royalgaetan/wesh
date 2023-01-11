import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String questionId;
  final String uid;
  final String name;
  final String content;
  final DateTime createdAt;
  // Constructor
  Question({
    required this.questionId,
    required this.uid,
    required this.name,
    required this.content,
    required this.createdAt,
  });

  // ToJson

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'uid': uid,
        'name': name,
        'content': content,
        'createdAt': createdAt,
      };

  // From Json
  static Question fromJson(Map<String, dynamic> json) => Question(
        questionId: json['questionId'] ?? '',
        uid: json['uid'] ?? '',
        name: json['name'] ?? '',
        content: json['content'] ?? '',
        //
        createdAt: json['createdAt'] != null && json['createdAt'] != ''
            ? (json['createdAt'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
        //
      );
}

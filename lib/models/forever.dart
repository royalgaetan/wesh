import 'package:cloud_firestore/cloud_firestore.dart';

// FIELDS

class ForeverFields {
  static final List<String> values = [
    'foreverId',
    'title',
    'uid',
    'createdAt',
    'modifiedAt',
    'stories',
  ];

  static const String title = 'title';
  static const String foreverId = 'foreverId';
  static const String uid = 'uid';
  static const String createdAt = 'createdAt';
  static const String modifiedAt = 'modifiedAt';
  static const String stories = 'stories';
}

class Forever {
  final String title;
  final String foreverId;
  final String uid;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<dynamic> stories;

  // Constructor
  Forever({
    required this.title,
    required this.foreverId,
    required this.uid,
    required this.createdAt,
    required this.modifiedAt,
    required this.stories,
  });

  // toJson
  Map<String, dynamic> toJson() => {
        ForeverFields.title: title,
        ForeverFields.foreverId: foreverId,
        ForeverFields.uid: uid,
        ForeverFields.createdAt: createdAt,
        ForeverFields.modifiedAt: modifiedAt,
        ForeverFields.stories: stories,
      };

  // fromJson
  static Forever fromJson(Map<String, dynamic> json) => Forever(
        title: json[ForeverFields.title] ?? '',
        foreverId: json[ForeverFields.foreverId] ?? '',
        uid: json[ForeverFields.uid] ?? '',
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
        //
        stories: json[ForeverFields.stories] ?? [],
      );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as usermodel;

class Celebration {
  final String title;
  final String description;
  final String type;
  final String id;
  final usermodel.User userPoster;
  final DateTime dateTime;
  // Constructor
  Celebration({
    required this.title,
    required this.description,
    required this.type,
    required this.id,
    required this.userPoster,
    required this.dateTime,
  });

  // Copy

  // toJson
  Map<String, Object?> toJson() => {
        'title': title,
        'id': id,
        'description': description,
        'type': type,
        'userPoster': userPoster,
        'dateTime': title,
      };

  // fromJson
  static Celebration fromJson(Map<String, dynamic> json) => Celebration(
        title: json['title'] ?? '',
        id: json['id'] ?? '',
        description: json['description'] ?? '',
        type: json['type'] ?? '',
        userPoster: json['userPoster'] ?? '',

        //
        dateTime: json['dateTime'] != null && json['dateTime'] != ''
            ? (json['dateTime'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
        //
      );
}

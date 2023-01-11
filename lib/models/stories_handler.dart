import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wesh/models/story.dart';

class StoriesHandler {
  final String origin;
  final String posterId;
  final String avatarPath;
  final String title;
  final DateTime lastStoryDateTime;
  final List<Story> stories;
  // Constructor
  StoriesHandler({
    required this.origin,
    required this.posterId,
    required this.avatarPath,
    required this.title,
    required this.lastStoryDateTime,
    required this.stories,
  });

  // ToJson

  Map<String, dynamic> toJson() => {
        'origin': origin,
        'posterId': posterId,
        'avatarPath': avatarPath,
        'title': title,
        'lastStoryDateTime': lastStoryDateTime,
        'stories': stories,
      };

  // From Json
  static StoriesHandler fromJson(Map<String, dynamic> json) => StoriesHandler(
        origin: json['origin'] ?? '',
        posterId: json['posterId'] ?? '',
        avatarPath: json['avatarPath'] ?? '',
        title: json['title'] ?? '',
        stories: json['stories'] ?? [],
        //
        lastStoryDateTime: json['lastStoryDateTime'] != null && json['lastStoryDateTime'] != ''
            ? (json['lastStoryDateTime'] as Timestamp).toDate().toLocal()
            : DateTime.now(),
        //
      );
}

import 'package:cloud_firestore/cloud_firestore.dart';

// FIELDS
class StoryFields {
  static final List<String> values = [
    'storyId',
    'content',
    'uid',
    'eventId',
    'bgColor',
    'fontType',
    'storyType',
    'caption',
    'videoThumbnail',
    'createdAt',
    'endAt',
    'viewers',
  ];

  static const String storyId = 'storyId';
  static const String content = 'content';
  static const String uid = 'uid';
  static const String bgColor = 'bgColor';
  static const String fontType = 'fontType';
  static const String storyType = 'storyType';
  static const String caption = 'caption';
  static const String videoThumbnail = 'videoThumbnail';
  static const String eventId = 'eventId';
  static const String createdAt = 'createdAt';
  static const String endAt = 'endAt';
  static const String viewers = 'viewers';
}

class Story {
  final String storyId;
  final String content;
  final String uid;
  final int bgColor;
  final int fontType;
  final String storyType;
  final String caption;
  final String videoThumbnail;
  final String eventId;
  final DateTime createdAt;
  final DateTime endAt;
  final List<dynamic> viewers;

  // Constructor
  Story({
    required this.storyId,
    required this.content,
    required this.uid,
    required this.bgColor,
    required this.fontType,
    required this.storyType,
    required this.caption,
    required this.videoThumbnail,
    required this.eventId,
    required this.createdAt,
    required this.endAt,
    required this.viewers,
  });

  // toJson
  Map<String, dynamic> toJson() => {
        StoryFields.storyId: storyId,
        StoryFields.content: content,
        StoryFields.uid: uid,
        StoryFields.bgColor: bgColor,
        StoryFields.fontType: fontType,
        StoryFields.storyType: storyType,
        StoryFields.caption: caption,
        StoryFields.videoThumbnail: videoThumbnail,
        StoryFields.eventId: eventId,
        StoryFields.createdAt: createdAt,
        StoryFields.endAt: endAt,
        StoryFields.viewers: viewers,
      };

  // fromJson
  static Story fromJson(Map<String, dynamic> json) => Story(
        storyId: json[StoryFields.storyId] ?? '',
        content: json[StoryFields.content] ?? '',
        uid: json[StoryFields.uid] ?? '',
        bgColor: json[StoryFields.bgColor] ?? 0,
        fontType: json[StoryFields.fontType] ?? 0,
        storyType: json[StoryFields.storyType] ?? '',
        caption: json[StoryFields.caption] ?? '',
        videoThumbnail: json[StoryFields.videoThumbnail] ?? '',
        eventId: json[StoryFields.eventId] ?? '',
        //
        createdAt: json['createdAt'] != null && json['createdAt'] != ''
            ? (json['createdAt'] as Timestamp).toDate().toLocal()
            : DateTime(0),
        //
        endAt: json['endAt'] != null && json['endAt'] != ''
            ? (json['endAt'] as Timestamp).toDate().toLocal()
            : DateTime(0),

        //
        viewers: json[StoryFields.viewers] ?? [],
      );
}

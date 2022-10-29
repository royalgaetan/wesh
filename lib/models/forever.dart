final String foreverTable = 'forevers';

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
  Map<String, Object?> toJson() => {
        ForeverFields.title: title,
        ForeverFields.foreverId: foreverId,
        ForeverFields.uid: uid,
        ForeverFields.createdAt: createdAt.toIso8601String(),
        ForeverFields.modifiedAt: modifiedAt.toIso8601String(),
        ForeverFields.stories: stories,
      };

  // fromJson
  static Forever fromJson(Map<String, dynamic> json) => Forever(
        title: json[ForeverFields.title] ?? '',
        foreverId: json[ForeverFields.foreverId] ?? '',
        uid: json[ForeverFields.uid] ?? '',
        //
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime(0),
        //
        modifiedAt: json['modifiedAt'] != null
            ? DateTime.parse(json['modifiedAt'])
            : DateTime(0),
        //
        stories: json[ForeverFields.stories] ?? [],
      );
}

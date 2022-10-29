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

  Map<String, Object?> toJson() => {
        'questionId': questionId,
        'uid': uid,
        'name': name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  // From Json
  static Question fromJson(Map<String, dynamic> json) => Question(
        questionId: json['questionId'] ?? '',
        uid: json['uid'] ?? '',
        name: json['name'] ?? '',
        content: json['content'] ?? '',
        //
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        //
      );
}

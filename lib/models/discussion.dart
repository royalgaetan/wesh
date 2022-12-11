import 'package:cloud_firestore/cloud_firestore.dart';

class Discussion {
  final List participants;
  final String discussionId;
  final String discussionType;
  final List<dynamic> isTypingList;
  final List<dynamic> isRecordingVoiceNoteList;
  final List messages;

  Discussion({
    required this.participants,
    required this.discussionId,
    required this.discussionType,
    required this.isTypingList,
    required this.isRecordingVoiceNoteList,
    required this.messages,
  });

  // ToJson
  Map<String, Object> toJson() => {
        'participants': participants,
        'discussionId': discussionId,
        'discussionType': discussionType,
        'isTypingList': isTypingList,
        'isRecordingVoiceNoteList': isRecordingVoiceNoteList,
        'messages': messages,
      };

  // From Json
  static Discussion fromJson(Map<String, dynamic> json) => Discussion(
        participants: json['participants'] ?? [],
        discussionId: json['discussionId'] ?? '',
        discussionType: json['discussionType'] ?? '',
        messages: json['messages'] ?? [],
        isTypingList: json['isTypingList'] ?? [],
        isRecordingVoiceNoteList: json['isRecordingVoiceNoteList'] ?? [],
      );
}

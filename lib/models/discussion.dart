import 'package:wesh/models/messagetype.dart';

class Discussion {
  final String profilPicture;
  final String username;
  final String lastMessage;
  final MessageType lastMessageType;
  final bool isTyping;
  final DateTime lastMessageDate;
  final int nbMessagesUnread;

  Discussion(
      {required this.profilPicture,
      required this.username,
      required this.lastMessage,
      required this.isTyping,
      required this.lastMessageType,
      required this.lastMessageDate,
      required this.nbMessagesUnread});
}

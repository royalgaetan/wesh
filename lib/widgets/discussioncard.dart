import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wesh/models/discussion.dart';
import 'package:wesh/models/messagetype.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/utils/constants.dart';

class DiscussionCard extends StatelessWidget {
  final Discussion discussion;

  const DiscussionCard({
    required this.discussion,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InboxPage(uid: '4')),
        );
      },
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(children: [
          // Trailing Avatar
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(discussion.profilPicture),
          ),

          // Username + Last Message
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${discussion.username}',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 6,
                ),

                // Last Message Row
                !discussion.isTyping
                    ? Row(
                        children: [
                          getMsgTypeIcon(discussion.lastMessageType),
                          Expanded(
                            child: Text(
                              '${discussion.lastMessage}',
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.7)),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'Ecrit...',
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                  color: kSecondColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
              ],
            ),
          ),

          // Unread Messages Number + Last Message Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${DateFormat('HH:mm').format(discussion.lastMessageDate)}',
                style:
                    TextStyle(color: kSecondColor, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 6,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: kSecondColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${discussion.nbMessagesUnread}',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

// Get Message Type Icon
Widget getMsgTypeIcon(MessageType lastMessageType) {
  // if MessageType.text
  // if (lastMessageType == MessageType.text) {
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 5),
  //     child: CircleAvatar(
  //       radius: 11,
  //       backgroundColor: Colors.lightBlue.shade200,
  //       child: Icon(FontAwesomeIcons.comment, color: Colors.white, size: 13),
  //     ),
  //   );
  // }

  // if MessageType.image
  if (lastMessageType == MessageType.image) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(FontAwesomeIcons.image, color: Colors.grey, size: 18),
    );
  }

  // if MessageType.video
  else if (lastMessageType == MessageType.video) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(FontAwesomeIcons.play, color: Colors.red, size: 18),
    );
  }

  // if MessageType.music
  else if (lastMessageType == MessageType.music) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(FontAwesomeIcons.itunesNote,
          color: Colors.purple.shade300, size: 18),
    );
  }

  // if MessageType.voicenote
  else if (lastMessageType == MessageType.voicenote) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(FontAwesomeIcons.microphone, color: Colors.black87, size: 18),
    );
  }

  // if MessageType.gift
  else if (lastMessageType == MessageType.gift) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: CircleAvatar(
        radius: 11,
        backgroundColor: Colors.orangeAccent,
        child: Icon(FontAwesomeIcons.gift, color: Colors.white, size: 13),
      ),
    );
  }

  // if MessageType.payment
  else if (lastMessageType == MessageType.payment) {
    return Icon(FontAwesomeIcons.dollarSign,
        color: Colors.green.shade300, size: 18);
  }

  // Default
  return Container();
}

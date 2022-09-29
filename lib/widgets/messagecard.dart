import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wesh/models/message.dart';
import 'package:wesh/models/messagestatus.dart';
import 'package:wesh/pages/in.pages/fileviewer.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/audiowidget.dart';

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // refreshMessage();
  }

  // Future refreshMessage() async {
  //   var message = await SqlDatabase.instance.readMessage(widget.messageId);
  //   setState(() {
  //     messagea = message;
  //   });
  //   print("MEEEUU: ${messagea!.caption}");
  //   return messagea;
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Text('Humm: ${messagea?.caption}');
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: isMyId(widget.message.senderId)
                ? const EdgeInsets.only(
                    left: 80,
                    right: 5,
                    top: 3,
                    bottom: 4,
                  )
                : const EdgeInsets.only(
                    left: 5,
                    right: 80,
                    top: 3,
                    bottom: 4,
                  ),
            padding: const EdgeInsets.all(10),
            width: 200,
            decoration: BoxDecoration(
              color: isMyId(widget.message.senderId)
                  ? kSecondColor.withOpacity(0.1)
                  : Color(0xFFF0F0F0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: isMyId(widget.message.senderId)
                    ? Radius.circular(20)
                    : Radius.circular(0),
                bottomRight: isMyId(widget.message.senderId)
                    ? Radius.circular(0)
                    : Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If Msg is an Image, Video, Music, Voicenote, Gift, Payment
                getMessageData(
                    context, widget.message.type, widget.message.data),
                Text(
                  widget.message.caption,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),

                // Message Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Date
                    Text(
                      '${DateFormat('hh:mm').format(widget.message.createdAt)}',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 3,
                    ),

                    // Status: doubleticks, seen, sent, pending
                    isMyId(widget.message.senderId)
                        ? getMessageStatusIcon(widget.message.status)
                        : Container()
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// If Msg is an Image, Video, Music, Voicenote, Gift, Payment
Widget getMessageData(BuildContext context, String messageType, dynamic data) {
  // MessageType == Image
  if (messageType == 'image') {
    return GestureDetector(
      onTap: () {
        // Display Picture
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FileViewer(fileType: 'image', data: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 10),
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: FileImage(File(data)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // MessageType == Music
  if (messageType == 'music') {
    var pathLength = File(data).path.length;
    var finalMusicPath = File(data).path.substring(7, pathLength - 1);
    return Column(
      children: [AudioWidget(data: finalMusicPath)],
    );
  }

  // MessageType == Video
  if (messageType == 'video') {
    return FutureBuilder(
        future: getVideoThumbnail(data),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () {
                // Play Video
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FileViewer(fileType: 'video', data: data),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video Thumbnail

                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 10),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(snapshot.data as Uint8List)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Play Button
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black87.withOpacity(0.5),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            );
          }

          return Text('Thumbnail is : ${snapshot.data}');
        });
  }

  return Container();
}

// My Id verifier
bool isMyId(String id) {
  if (id == myId) {
    return true;
  }
  return false;
}

// Get Message Status
Widget getMessageStatusIcon(String status) {
  if (status == MessageStatus.sent) {
    return Icon(
      Icons.check,
      color: Colors.black54,
      size: 16,
    );
  } else if (status == MessageStatus.seen) {
    return Icon(
      Icons.done,
      color: Colors.black54,
      size: 18,
    );
  } else if (status == MessageStatus.doubleticks) {
    return Icon(
      Icons.done_all_rounded,
      color: kSecondColor,
      size: 18,
    );
  }

  return Icon(
    Icons.access_time_rounded,
    color: Colors.black54,
    size: 18,
  );
}

// AUDIO WIDGET
// -----------
// -----------
// -----------

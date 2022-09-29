import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uuid/uuid.dart';
import 'package:wesh/models/message.dart';
import 'package:wesh/pages/in.pages/fileviewer.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/modal.dart';

class PreviewMessageFile extends StatefulWidget {
  final String filetype;
  final XFile? file;
  final String uid;
  String? eventIdAttached;

  PreviewMessageFile(
      {Key? key,
      required this.filetype,
      this.file,
      required this.uid,
      this.eventIdAttached})
      : super(key: key);

  @override
  State<PreviewMessageFile> createState() => _PreviewMessageFileState();
}

class _PreviewMessageFileState extends State<PreviewMessageFile> {
  final TextEditingController captionMessageController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          splashRadius: 25,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // IMAGE
          widget.filetype == 'image'
              ? PhotoView(
                  imageProvider: FileImage(File(widget.file!.path)),
                )
              : Container(
                  child: const Text('Erreur de chargement...'),
                ),

          // VIDEO
          widget.filetype == 'video'
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 300,
                        child: Center(
                            child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 34,
                              )),
                        )),
                      ),
                    ],
                  ),
                )
              : Container(),

          // ADD CAPTION & SEND BUTTO
          Padding(
            padding: EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
                top: widget.eventIdAttached != null ? 0 : 10),
            child: Row(
              children: [
                // Entry Message Fields
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color(0xFFF0F0F0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          splashRadius: 22,
                          splashColor: kSecondColor,
                          onPressed: () {
                            // Show Emoji Keyboard Here !
                          },
                          icon: Icon(
                            FontAwesomeIcons.faceGrin,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: captionMessageController,
                            cursorColor: Colors.black,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18),
                            maxLines: 5,
                            minLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Ajoutez une description...',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 18),
                            ),
                          ),
                        ),
                        IconButton(
                          splashRadius: 22,
                          splashColor: kSecondColor,
                          onPressed: () async {
                            // Show Event Selector
                            String? selectedEvent = await showModalBottomSheet(
                              isDismissible: true,
                              enableDrag: true,
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: ((context) => Modal(
                                    minChildSize: .4,
                                    child: EventSelector(
                                      uid: widget.uid,
                                    ),
                                  )),
                            );

                            // Check the Event Selected
                            if (selectedEvent != null) {
                              setState(() {
                                widget.eventIdAttached = selectedEvent;
                              });
                              print('selected event is: $selectedEvent');
                            } else if (selectedEvent == null) {
                              setState(() {
                                widget.eventIdAttached = selectedEvent;
                              });
                              print('selected event is: $selectedEvent');
                            }
                          },
                          icon: Icon(
                            FontAwesomeIcons.splotch,
                            color: widget.eventIdAttached != null
                                ? kSecondColor
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // [ACTION BUTTON] Send Message Button or Mic Button
                const SizedBox(
                  width: 20,
                ),

                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    // Send Message Here !

                    // Move to App Directory
                    try {
                      if (widget.file != null) {
                        final Directory directory =
                            await getApplicationDocumentsDirectory();
                        var filename = '${Uuid().v4()}';

                        var path = '';

                        // Check File type
                        if (widget.filetype == 'image') {
                          filename = 'msgImage_${Uuid().v4()}';
                          path = '${directory.path}/$filename.jpg';
                        } else if (widget.filetype == 'video') {
                          filename = 'msgVideo_${Uuid().v4()}';
                          path = '${directory.path}/$filename.mp4';
                        }

                        var res = widget.file!.saveTo(path).whenComplete(() =>
                            print('Message File was saved correctly at $path'));

                        // Save msg to Sql DB
                        final newMessage = Message(
                          messageId: 'message_${const Uuid().v4()}',
                          eventId: widget.eventIdAttached ?? '',
                          senderId: '3',
                          receiverId: '4',
                          createdAt: DateTime.now(),
                          status: 'pending',
                          type: widget.filetype,
                          data: path,
                          caption: captionMessageController.text,
                        );

                        // await SqlDatabase.instance
                        //     .createMessage(newMessage)
                        //     .then((value) {
                        //   setState(() {
                        //     captionMessageController.text = '';
                        //   });

                        //   Navigator.pop(context);
                        // });
                      } else if (widget.file == null) {
                        Navigator.pop(context);
                        throw Exception('Erreur : $e');
                      }
                    } catch (e) {
                      throw Exception('Erreur : $e');
                    }

                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    backgroundColor: kSecondColor,
                    radius: 28,
                    child: Transform.translate(
                      offset: Offset(1, -1),
                      child: Transform.rotate(
                        angle: -pi / 4,
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

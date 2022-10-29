import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wesh/models/message.dart';
import 'package:wesh/pages/addpage.dart';
import 'package:wesh/pages/in.pages/addon.dart';
import 'package:wesh/pages/in.pages/create_or_update_event.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/messagecard.dart';

import 'package:chewie/chewie.dart';
import 'package:wesh/widgets/messagefilepicker.dart';

import '../../models/event.dart';
import '../../models/story.dart';
import '../../utils/functions.dart';
import '../../widgets/modal.dart';

class InboxPage extends StatefulWidget {
  final String uid;
  late Event? eventAttached;
  late Story? storyAttached;

  InboxPage({required this.uid, this.eventAttached, this.storyAttached});

  @override
  State<InboxPage> createState() => _InboxState();
}

class _InboxState extends State<InboxPage> {
  final TextEditingController textMessageController = TextEditingController();
  late bool isAddOtherMsgMethod = true;
  List<Message> _messages = [];
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();

    textMessageController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    refreshMessages();
  }

  Future refreshMessages() async {
    _messages = [];
    setState(() => isLoading = true);
    // _messages = await SqlDatabase.instance.readAllMessages('4');
    Future.delayed(const Duration(milliseconds: 200))
        .then((value) => setState(() => isLoading = false));
    debugPrint('Messages ARE: ${_messages.length}');
    return _messages;
  }

  detachEventorStory() {
    setState(() {
      widget.eventAttached = null;
      widget.storyAttached = null;
    });
  }

  showEventSelector(context) async {
    dynamic selectedEvent = await showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: ((context) => Modal(
            minChildSize: .4,
            child: const EventSelector(),
          )),
    );

    // Check the Event Selected
    if (selectedEvent != null && selectedEvent != 'remove') {
      setState(() {
        widget.eventAttached = selectedEvent;
        widget.storyAttached = null;
      });
      debugPrint('selected event is: $selectedEvent');
    } else if (selectedEvent == 'remove') {
      setState(() {
        widget.eventAttached = null;
      });
      debugPrint('selected event is: $selectedEvent');
    } else if (selectedEvent == null) {
      debugPrint('selected event is: $selectedEvent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          splashRadius: 25,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/avatar 13.jpg'),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Username',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            splashRadius: 25,
            onPressed: () {
              // Chat Actions Here !
            },
            icon: const Icon(
              FontAwesomeIcons.ellipsisVertical,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Addon(),
                    ));
              },
              child: const Text("Watch Video"),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: Expanded(
                      child: CupertinoActivityIndicator(
                        radius: 12,
                      ),
                    ),
                  )
                :
                // Chat body
                ListView.builder(
                    // reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        // Text('Index ${_messages[index].caption}')
                        MessageCard(message: _messages[index]),
                  ),
          ),
          // Chat Bottom Actions
          SafeArea(
            child: BottomAppBar(
              elevation:
                  widget.eventAttached == null && widget.storyAttached == null
                      ? 0
                      : 20,
              child: Column(
                children: [
                  // INPUTS + SEND BUTTON
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        top: widget.eventAttached == null &&
                                widget.storyAttached == null
                            ? 3
                            : 10),
                    child: Row(
                      children: [
                        // Entry Message Fields
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  widget.eventAttached == null &&
                                          widget.storyAttached == null
                                      ? 50
                                      : 20),
                              color: kGreyColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    // Display Event or Story Attached
                                    widget.eventAttached != null &&
                                            widget.storyAttached == null
                                        ? InkWell(
                                            onTap: () {
                                              // Show Event Selector
                                              showEventSelector(context);
                                            },
                                            child: getEventGridPreview(
                                                widget.eventAttached!),
                                          )
                                        : Container(),

                                    widget.eventAttached == null &&
                                            widget.storyAttached != null
                                        ? SizedBox(
                                            height: 70,
                                            child: Column(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      AspectRatio(
                                                        aspectRatio: 4 / 4,
                                                        child: getStoryGridPreviewByType(
                                                            widget
                                                                .storyAttached!),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      const Text(
                                                        'Story',
                                                        style: TextStyle(
                                                            fontSize: 19,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Divider
                                                const SizedBox(height: 4),

                                                const SizedBox(
                                                  width: double.infinity,
                                                  child: Divider(
                                                    height: 1,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),

                                    // Button Detach event or story linked
                                    Visibility(
                                      visible: widget.eventAttached != null ||
                                          widget.storyAttached != null,
                                      child: IconButton(
                                        splashRadius: 22,
                                        onPressed: () {
                                          //
                                          detachEventorStory();
                                        },
                                        icon: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.grey.shade600,
                                          child: const Icon(Icons.close,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // MAIN FIELD: type your msg here + action buttons
                                Row(
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
                                        controller: textMessageController,
                                        onChanged: (value) {},
                                        cursorColor: Colors.black,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                        maxLines: 5,
                                        minLines: 1,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Ecrivez ici...',
                                          hintStyle: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ),

                                    // SEND OTHER MESSAGES TYPE
                                    Visibility(
                                      visible:
                                          textMessageController.text.isEmpty,
                                      child: IconButton(
                                        splashRadius: 22,
                                        splashColor: kSecondColor,
                                        onPressed: () async {
                                          // Show All Messages Format Picker Here !
                                          var fileselected =
                                              await showModalBottomSheet(
                                            isDismissible: true,
                                            enableDrag: true,
                                            isScrollControlled: true,
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: ((context) => Modal(
                                                  initialChildSize: .4,
                                                  maxChildSize: .4,
                                                  minChildSize: .4,
                                                  child:
                                                      const MessageFilePicker(
                                                          uid: '4',
                                                          eventAttached: null),
                                                )),
                                          );

                                          refreshMessages();

                                          debugPrint(
                                              'File picked is: ${fileselected!.path}');
                                        },
                                        icon: Icon(
                                          FontAwesomeIcons.paperclip,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    // const SizedBox(
                                    //   width: 0,
                                    // ),
                                    IconButton(
                                      splashRadius: 22,
                                      splashColor: kSecondColor,
                                      onPressed: () async {
                                        // Show Event Selector
                                        showEventSelector(context);
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.splotch,
                                        color: widget.eventAttached != null
                                            ? kSecondColor
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // [ACTION BUTTON] Send Message Button or Mic Button
                        const SizedBox(
                          width: 13,
                        ),

                        textMessageController.text.isNotEmpty
                            ? InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () async {
                                  // Send Message Here !
                                  final newMessage = Message(
                                    messageId: 'message_${const Uuid().v4()}',
                                    eventId: widget.eventAttached != null
                                        ? widget.eventAttached!.eventId
                                        : '',
                                    storyId: widget.storyAttached != null
                                        ? widget.storyAttached!.storyId
                                        : '',
                                    senderId: '3',
                                    receiverId: '4',
                                    createdAt: DateTime.now(),
                                    status: 'pending',
                                    type: 'text',
                                    data: '',
                                    caption: textMessageController.text,
                                  );

                                  // await SqlDatabase.instance
                                  //     .createMessage(newMessage);
                                  setState(() {
                                    textMessageController.text = '';
                                  });
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
                            : InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  // Send Voicenote !
                                },
                                child: CircleAvatar(
                                  backgroundColor: kSecondColor,
                                  radius: 28,
                                  child: Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

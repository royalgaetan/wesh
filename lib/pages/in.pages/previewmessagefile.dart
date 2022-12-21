import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/audiowidget.dart';
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/modal.dart';
import '../../models/event.dart';
import '../../models/message.dart';
import '../../models/story.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/videowidget.dart';

class PreviewMessageFile extends StatefulWidget {
  final String filetype;
  final File file;
  final String userReceiverId;
  final String? discussionId;
  late Message? messageToReply;
  late Event? eventAttached;
  late Story? storyAttached;

  PreviewMessageFile(
      {Key? key,
      required this.filetype,
      required this.file,
      required this.userReceiverId,
      this.eventAttached,
      this.storyAttached,
      this.discussionId,
      this.messageToReply})
      : super(key: key);

  @override
  State<PreviewMessageFile> createState() => _PreviewMessageFileState();
}

class _PreviewMessageFileState extends State<PreviewMessageFile> {
  final TextEditingController captionMessageController = TextEditingController();
  FocusNode messageCaptionFocus = FocusNode();
  String messageTextValue = '';
  bool showEmojiKeyboard = false;
  //

  StreamController<String> togglePlayPauseVideo = StreamController.broadcast();

  detachEventOrStoryOrMessage() {
    if (!mounted) return;
    setState(() {
      widget.eventAttached = null;
      widget.storyAttached = null;
      widget.messageToReply = null;
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
            minHeightSize: MediaQuery.of(context).size.height / 1.4,
            maxHeightSize: MediaQuery.of(context).size.height,
            child: const EventSelector(),
          )),
    );

    if (selectedEvent != null && selectedEvent != 'remove') {
      if (!mounted) return;
      setState(() {
        widget.eventAttached = selectedEvent;
        widget.storyAttached = null;
        widget.messageToReply = null;
      });
      debugPrint('selected event is: $selectedEvent');
    } else if (selectedEvent == 'remove') {
      if (!mounted) return;
      setState(() {
        widget.eventAttached = null;
      });
      debugPrint('selected event is: $selectedEvent');
    } else if (selectedEvent == null) {
      debugPrint('selected event is: $selectedEvent');
    }
  }

  sendMessageFile() async {
    showFullPageLoader(context: context);

    // init values
    bool? result = false;
    String userReceiverId = widget.userReceiverId;
    String discussionId = widget.discussionId ?? '';
    String eventId = widget.eventAttached != null ? widget.eventAttached!.eventId : '';
    String storyId = widget.storyAttached != null ? widget.storyAttached!.storyId : '';

    // Process with Image
    if (widget.filetype == 'image') {
      result = await sendMessage(
        context: context,
        userReceiverId: userReceiverId,
        messageType: 'image',
        discussionId: discussionId,
        eventId: eventId,
        storyId: storyId,
        messageTextValue: '',
        messageCaptionText: captionMessageController.text,
        voiceNotePath: '',
        imagePath: widget.file.path,
        videoPath: '',
        musicPath: '',
        isPaymentMessage: false,
        amount: 0,
        receiverPhoneNumber: '',
        paymentMethod: '',
        transactionId: '',
        messageToReplyId: widget.messageToReply != null ? widget.messageToReply?.messageId ?? '' : '',
        messageToReplySenderId: widget.messageToReply != null ? widget.messageToReply?.senderId ?? '' : '',
        messageToReplyType: widget.messageToReply != null ? widget.messageToReply?.type ?? '' : '',
        messageToReplyCaption: widget.messageToReply != null ? widget.messageToReply?.caption ?? '' : '',
        messageToReplyFilename: widget.messageToReply != null ? widget.messageToReply?.filename ?? '' : '',
        messageToReplyData: widget.messageToReply != null ? widget.messageToReply?.data ?? '' : '',
        messageToReplyThumbnail: widget.messageToReply != null ? widget.messageToReply?.thumbnail ?? '' : '',
      );
    }

    // Process with Video
    if (widget.filetype == 'video') {
      result = await sendMessage(
        context: context,
        userReceiverId: userReceiverId,
        messageType: 'video',
        discussionId: discussionId,
        eventId: eventId,
        storyId: storyId,
        messageTextValue: '',
        messageCaptionText: captionMessageController.text,
        voiceNotePath: '',
        imagePath: '',
        videoPath: widget.file.path,
        musicPath: '',
        isPaymentMessage: false,
        amount: 0,
        paymentMethod: '',
        transactionId: '',
        receiverPhoneNumber: '',
        messageToReplyId: widget.messageToReply != null ? widget.messageToReply?.messageId ?? '' : '',
        messageToReplySenderId: widget.messageToReply != null ? widget.messageToReply?.senderId ?? '' : '',
        messageToReplyType: widget.messageToReply != null ? widget.messageToReply?.type ?? '' : '',
        messageToReplyCaption: widget.messageToReply != null ? widget.messageToReply?.caption ?? '' : '',
        messageToReplyFilename: widget.messageToReply != null ? widget.messageToReply?.filename ?? '' : '',
        messageToReplyData: widget.messageToReply != null ? widget.messageToReply?.data ?? '' : '',
        messageToReplyThumbnail: widget.messageToReply != null ? widget.messageToReply?.thumbnail ?? '' : '',
      );
    }

    // Process with Music
    if (widget.filetype == 'music') {
      result = await sendMessage(
        context: context,
        userReceiverId: userReceiverId,
        messageType: 'music',
        discussionId: discussionId,
        eventId: eventId,
        storyId: storyId,
        messageTextValue: '',
        messageCaptionText: captionMessageController.text,
        voiceNotePath: '',
        imagePath: '',
        videoPath: '',
        isPaymentMessage: false,
        amount: 0,
        receiverPhoneNumber: '',
        paymentMethod: '',
        transactionId: '',
        musicPath: widget.file.path,
        messageToReplyId: widget.messageToReply != null ? widget.messageToReply?.messageId ?? '' : '',
        messageToReplySenderId: widget.messageToReply != null ? widget.messageToReply?.senderId ?? '' : '',
        messageToReplyType: widget.messageToReply != null ? widget.messageToReply?.type ?? '' : '',
        messageToReplyCaption: widget.messageToReply != null ? widget.messageToReply?.caption ?? '' : '',
        messageToReplyFilename: widget.messageToReply != null ? widget.messageToReply?.filename ?? '' : '',
        messageToReplyData: widget.messageToReply != null ? widget.messageToReply?.data ?? '' : '',
        messageToReplyThumbnail: widget.messageToReply != null ? widget.messageToReply?.thumbnail ?? '' : '',
      );
    }

    // Process with Gift

    // Process with Payment

    // POP THE SCREEN
    // POP THE MODAL TOO
    // ignore: use_build_context_synchronously
    Navigator.pop(
      context,
    );

    if (result == true || result == false) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context, 'send_process_finished');
      // ignore: use_build_context_synchronously
      Navigator.pop(context, 'send_process_finished');
    }
  }

  bool onWillPopHandler(context) {
    if (showEmojiKeyboard == true) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return false;
    } // ignore: use_build_context_synchronously
    Navigator.pop(context);
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onWillPopHandler(context);
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: widget.filetype == 'music' ? const Color(0xFF10131C) : Colors.black, // Status bar
          systemNavigationBarColor: widget.filetype == 'music' ? const Color(0xFF10131C) : Colors.black, // Status bar
        ),
        child: Scaffold(
          backgroundColor: widget.filetype == 'music' ? const Color(0xFF10131C) : Colors.black,
          appBar: MorphingAppBar(
            heroTag: 'previewMessageFilePageAppBar',
            elevation: 0,
            backgroundColor: widget.filetype == 'music' ? const Color(0xFF10131C) : Colors.transparent,
            leading: IconButton(
              splashRadius: 0.06.sw,
              onPressed: () async {
                bool result = onWillPopHandler(context);
                if (result) {
                  // POP THE SCREEN

                } else {
                  //
                }
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
                      imageProvider: FileImage(File(widget.file.path)),
                    )
                  : const Text('Erreur de chargement...'),

              // VIDEO
              widget.filetype == 'video'
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VideoPlayerWidget(
                            data: widget.file.path,
                            togglePlayPause: togglePlayPauseVideo,
                          )
                        ],
                      ),
                    )
                  : Container(),

              // MUSIC
              widget.filetype == 'music'
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Music Artwork
                            const CircleAvatar(
                              radius: 100,
                              backgroundColor: kGreyColor,
                              backgroundImage: AssetImage(music),
                            ),

                            //
                            const SizedBox(height: 20),
                            // Audio Slider
                            AudioWidget(data: widget.file.path, btnTheme: 'white'),
                          ],
                        ),
                      ),
                    )
                  : Container(),

              // ADD CAPTION & SEND BUTTON
              // Chat Bottom Actions
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    BottomAppBar(
                      color: Colors.transparent,
                      elevation:
                          widget.messageToReply == null && widget.eventAttached == null && widget.storyAttached == null
                              ? 0
                              : 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // INPUTS + SEND BUTTON
                          Padding(
                            padding: EdgeInsets.only(
                                left: 0.02.sw,
                                right: 0.02.sw,
                                bottom: 0.02.sw,
                                top: widget.messageToReply == null &&
                                        widget.eventAttached == null &&
                                        widget.storyAttached == null
                                    ? 0.01.sw
                                    : 0.02.sw),
                            child: Row(
                              children: [
                                // Entry Message Fields
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(widget.messageToReply == null &&
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
                                            // Display Message to reply
                                            widget.messageToReply != null &&
                                                    widget.eventAttached == null &&
                                                    widget.storyAttached == null
                                                ? Wrap(
                                                    children: [
                                                      getMessageToReplyGridPreview(
                                                        messageToReplyId: widget.messageToReply?.messageId ?? '',
                                                        messageToReplySenderId: widget.messageToReply?.senderId ?? '',
                                                        messageToReplyType: widget.messageToReply?.type ?? '',
                                                        messageToReplyCaption: widget.messageToReply?.caption ?? '',
                                                        messageToReplyFilename: widget.messageToReply?.filename ?? '',
                                                        messageToReplyData: widget.messageToReply?.data ?? '',
                                                        messageToReplyThumbnail: widget.messageToReply?.thumbnail ?? '',
                                                      ),
                                                    ],
                                                  )
                                                : Container(),

                                            // Display Event Attached
                                            widget.eventAttached != null &&
                                                    widget.storyAttached == null &&
                                                    widget.messageToReply == null
                                                ? InkWell(
                                                    onTap: () {
                                                      // Show Event Selector
                                                      showEventSelector(context);
                                                    },
                                                    child: getEventGridPreview(
                                                        eventId: widget.eventAttached?.eventId ?? ''),
                                                  )
                                                : Container(),

                                            // Display Story Attached
                                            widget.storyAttached != null &&
                                                    widget.eventAttached == null &&
                                                    widget.messageToReply == null
                                                ? getStoryGridPreview(storyId: widget.storyAttached?.storyId ?? '')
                                                : Container(),

                                            // Button Detach event or story linked
                                            Visibility(
                                              visible: widget.messageToReply != null ||
                                                  widget.eventAttached != null ||
                                                  widget.storyAttached != null,
                                              child: IconButton(
                                                splashRadius: 22,
                                                onPressed: () {
                                                  //
                                                  detachEventOrStoryOrMessage();
                                                },
                                                icon: CircleAvatar(
                                                  radius: 0.04.sw,
                                                  backgroundColor: Colors.grey.shade600.withOpacity(0.7),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 0.06.sw,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // MAIN FIELD: type your msg here + action buttons
                                        Row(
                                          children: [
                                            IconButton(
                                              splashRadius: 0.06.sw,
                                              splashColor: kSecondColor,
                                              onPressed: () {
                                                // Show Emoji Keyboard Here !
                                                setState(() {
                                                  showEmojiKeyboard = !showEmojiKeyboard;
                                                });
                                                if (showEmojiKeyboard) {
                                                  messageCaptionFocus.unfocus();
                                                } else {
                                                  messageCaptionFocus.requestFocus();
                                                }
                                              },
                                              icon: Icon(
                                                FontAwesomeIcons.faceGrin,
                                                size: 0.06.sw,
                                                color: showEmojiKeyboard ? kSecondColor : Colors.grey.shade600,
                                              ),
                                            ),

                                            // Show normal bottom bar
                                            Expanded(
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    messageTextValue = value;
                                                  });
                                                },
                                                onTap: () {
                                                  // Dismiss emoji keyboard
                                                  setState(() {
                                                    showEmojiKeyboard = false;
                                                  });
                                                },
                                                focusNode: messageCaptionFocus,
                                                controller: captionMessageController,
                                                cursorColor: Colors.black38,
                                                style: TextStyle(color: Colors.black87, fontSize: 15.sp),
                                                maxLines: 5,
                                                minLines: 1,
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.all(0.009.sw),
                                                  hintText: 'Ecrivez ici...',
                                                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp),
                                                ),
                                              ),
                                            ),

                                            IconButton(
                                              splashRadius: 0.06.sw,
                                              splashColor: kSecondColor,
                                              onPressed: () async {
                                                // Show Event Selector
                                                showEventSelector(context);
                                              },
                                              icon: Icon(
                                                FontAwesomeIcons.splotch,
                                                size: 0.06.sw,
                                                color:
                                                    widget.eventAttached != null ? kSecondColor : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // [ACTION BUTTON] Send Message Button or Mic Button
                                InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () async {
                                    // VIBRATE
                                    triggerVibration();

                                    // Stop playing video

                                    togglePlayPauseVideo.sink.add('pause');

                                    // Send Message File Here !
                                    sendMessageFile();

                                    captionMessageController.clear();

                                    setState(() {
                                      messageTextValue = '';
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 13),
                                    child: CircleAvatar(
                                      backgroundColor: kSecondColor,
                                      radius: 0.077.sw,
                                      child: Transform.translate(
                                        offset: const Offset(1, -1),
                                        child: Transform.rotate(
                                          angle: -pi / 4,
                                          child: Icon(
                                            Icons.send_rounded,
                                            size: 0.06.sw,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Show Emoji Keyboard
                    emojiPickerOffstage(showEmojiKeyboard: showEmojiKeyboard, textController: captionMessageController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

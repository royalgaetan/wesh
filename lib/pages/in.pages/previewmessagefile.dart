// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/audio_wave_widget.dart';
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/modal.dart';
import '../../models/event.dart';
import '../../models/message.dart';
import '../../models/story.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/videowidget.dart';

// ignore: must_be_immutable
class PreviewMessageFile extends StatefulWidget {
  final String filetype;
  final File file;
  final String userReceiverId;
  final String? discussionId;
  late Message? messageToReply;
  late Event? eventAttached;
  late Story? storyAttached;

  PreviewMessageFile(
      {super.key,
      required this.filetype,
      required this.file,
      required this.userReceiverId,
      this.eventAttached,
      this.storyAttached,
      this.discussionId,
      this.messageToReply});

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

  @override
  void initState() {
    super.initState();
    setSuitableStatusBarColor(Colors.black87);
  }

  @override
  void dispose() {
    super.dispose();
    setSuitableStatusBarColor(Colors.white);
  }

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
      if (!mounted) return;
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
    if (!mounted) return;
    Navigator.pop(
      context,
    );

    if (result == true || result == false) {
      if (!mounted) return;
      Navigator.pop(context, 'send_process_finished');
      if (!mounted) return;
      Navigator.pop(context, 'send_process_finished');
    }
  }

  onWillPopHandler(context) {
    if (showEmojiKeyboard == true) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return false;
    }

    Navigator.pop(context);
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        onWillPopHandler(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          elevation: 0,
          backgroundColor: Colors.transparent,
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
        extendBodyBehindAppBar: false,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // MEDIA CONTENT
            Container(
              height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 20,
              alignment: Alignment.center,
              child: () {
                // IMAGE
                if (widget.filetype == 'image') {
                  return PhotoView(
                    imageProvider: FileImage(File(widget.file.path)),
                  );
                }

                // VIDEO
                else if (widget.filetype == 'video') {
                  return VideoPlayerWidget(
                    data: widget.file.path,
                    togglePlayPause: togglePlayPauseVideo,
                  );
                }

                // MUSIC / SONG
                else if (widget.filetype == 'music') {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Music Artwork
                          const CircleAvatar(
                            radius: 80,
                            backgroundColor: kGreyColor,
                            backgroundImage: AssetImage(music),
                          ),

                          //
                          const SizedBox(height: 30),
                          // Audio Slider
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            child: AudioWaveWidget(
                              path: widget.file.path,
                              noOfSamples: ((0.7 * 1.sw) / 6).toInt(),
                            ),
                          ),

                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'Nothing to display!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }(),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ADD CAPTION & SEND BUTTON
                Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    margin: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: 5,
                        top: widget.messageToReply == null &&
                                widget.eventAttached == null &&
                                widget.storyAttached == null
                            ? 4
                            : 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kGreyColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: widget.messageToReply == null &&
                                          widget.eventAttached == null &&
                                          widget.storyAttached == null
                                      ? EdgeInsets.zero
                                      : const EdgeInsets.fromLTRB(15, 7, 10, 7),
                                  child: Stack(
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
                                              child: getEventGridPreview(eventId: widget.eventAttached?.eventId ?? ''),
                                            )
                                          : Container(),

                                      // Display Story Attached
                                      widget.storyAttached != null &&
                                              widget.eventAttached == null &&
                                              widget.messageToReply == null
                                          ? getStoryGridPreview(storyId: widget.storyAttached?.storyId ?? '')
                                          : Container(),

                                      // Button: Detach event or story or message linked
                                      Visibility(
                                        visible: widget.messageToReply != null ||
                                            widget.eventAttached != null ||
                                            widget.storyAttached != null,
                                        child: GestureDetector(
                                          onTap: () {
                                            detachEventOrStoryOrMessage();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 3, top: 3),
                                            child: CircleAvatar(
                                              radius: 13,
                                              backgroundColor: Colors.grey.shade600.withOpacity(0.8),
                                              child: const Icon(Icons.close, color: Colors.white, size: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                widget.storyAttached == null &&
                                        widget.eventAttached == null &&
                                        widget.messageToReply == null
                                    ? Container()
                                    : const Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: BuildDivider(padding: 0),
                                      ),

                                // MAIN FIELD: type your msg here + action buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Emoji Button
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
                                        cursorColor: kSecondColor,
                                        style: TextStyle(color: Colors.black87, fontSize: 15.sp),
                                        maxLines: 5,
                                        minLines: 1,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Add a caption...',
                                          contentPadding: const EdgeInsets.all(1),
                                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15.sp),
                                        ),
                                      ),
                                    ),

                                    // Attach event Button
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
                                        color: widget.eventAttached != null ? kSecondColor : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // [ACTION BUTTON] Send Message Button
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () async {
                            // VIBRATE
                            triggerVibration();

                            // Stop playing video
                            togglePlayPauseVideo.sink.add('pause');

                            // Send Message File Here !
                            sendMessageFile();

                            // Flush data
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
                              child: Icon(
                                Icons.send_rounded,
                                size: 0.06.sw,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Show Emoji Keyboard
                EmojiPickerOffstage(showEmojiKeyboard: showEmojiKeyboard, textController: captionMessageController),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

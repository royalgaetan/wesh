// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wesh/models/message.dart';
import 'package:wesh/pages/in.pages/forward_to.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/counter.dart';
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/messagecard.dart';
import 'package:wesh/widgets/messagefilepicker.dart';
import '../../models/discussion.dart';
import '../../models/event.dart';
import '../../models/story.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/modal.dart';
import '../profile.dart';
import '../settings.pages/bug_report_page.dart';

class InboxPage extends StatefulWidget {
  Discussion? discussion;
  final String userReceiverId;
  late Event? eventAttached;
  late Story? storyAttached;

  InboxPage({
    super.key,
    this.discussion,
    this.eventAttached,
    required this.userReceiverId,
    this.storyAttached,
  });

  @override
  State<InboxPage> createState() => _InboxState();
}

class _InboxState extends State<InboxPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  //
  bool isConnected = false;
  StreamSubscription? internetSubscription;
  //
  bool showEmojiKeyboard = false;
  //
  List<Message> listMsg = [];
  Message? messageToReply;

  FocusNode messageTextFocus = FocusNode();
  TextEditingController messageTextController = TextEditingController();
  String messageTextValue = '';
  late bool isAddOtherMsgMethod = true;
  bool isLoading = false;

  //
  bool isRecordingVoiceNote = false;
  late final RecorderController recorderController;
  final voiceNoteRecordingCounter = Counter();
  Duration voiceNoteRecordingDurationElapsed = const Duration(seconds: 0);
  String voiceNotePath = '';
  double voiceNoteRecordButtonLeftPosition = 0.0;

  //
  final ItemScrollController _scrollController = ItemScrollController();

  ValueNotifier<bool> showScrollDownButton = ValueNotifier<bool>(false);
  final messagesList = BehaviorSubject<int>();
  List<int> messagesListLength = [];
  bool isLastMessageVisible = true;

  //
  bool deleteAlsoAssociatedMessageFiles = false;
  bool isSelectionMode = false;
  Map<String, Message> messagesSelectedList = {};

  void addOrRemoveMessageFromAllMessagesSelected(Map<String, Message> message) {
    // VIBRATE
    triggerVibration(duration: 50);

    if (messagesSelectedList.keys.contains(message.keys.first)) {
      if (!mounted) return;
      setState(() {
        messagesSelectedList.remove(message.keys.first);
        //
        if (messagesSelectedList.isEmpty) {
          isSelectionMode = false;
        }
      });
    } else {
      if (!mounted) return;
      setState(() {
        messagesSelectedList.addAll(message);
      });
    }
    debugPrint('Selection mode : $isSelectionMode');
    debugPrint('Messages selected list: $messagesSelectedList');
  }

  Future refreshDiscussion() async {
    if (widget.discussion == null) {
      setState(() {
        isLoading = true;
      });
      // Get Discussion of [anotherUserId] and [Me]
      List<Discussion> listOfExistingDiscussions = await FirestoreMethods.getListOfExistingDiscussions(
          userSenderId: FirebaseAuth.instance.currentUser!.uid, userReceiverId: widget.userReceiverId);

      dev.log('listOfExistingDiscussions: ${listOfExistingDiscussions.map((d) => d.discussionId)}');
      if (listOfExistingDiscussions.isNotEmpty) {
        setState(() {
          widget.discussion = listOfExistingDiscussions.first;
        });
        dev.log('widget.discussion: ${widget.discussion!.participants}');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //
    setCurrentActivePageFromIndex(index: 5, userId: widget.userReceiverId);
    refreshDiscussion();

    // Init Voice Recorder
    recorderController = RecorderController();

    resetStatusAndNavigationBar();
  }

  resetStatusAndNavigationBar() {
    // Reset Status and Navigation bar Colors: if not as default
    setSuitableStatusBarColor(Colors.white);
    setSuitableNavigationBarColor(Colors.white);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Show back Status Bar: if not as default
    toggleStatusBar(true);
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose Recording Counter
    voiceNoteRecordingCounter.dispose();
    // Dispose Recorder()
    recorderController.dispose();

    //
    internetSubscription?.cancel();
  }

  //
  scrollTo(List<Message> list, String messageId) {
    List<String> listOfMsgIds = list.map((message) => message.messageId).toList();
    int messageIndex = listOfMsgIds.indexOf(messageId);

    _scrollController.scrollTo(index: messageIndex, duration: const Duration(milliseconds: 300));
  }

  bool hasMessagesSelectedListAmessageWithFiles(Map<String, Message> list) {
    for (Message message in list.values) {
      if (message.type != 'text') {
        return true;
      }
    }
    return false;
  }

  bool hasMessagesSelectedListOnlyMessageWithFiles(Map<String, Message> list) {
    List<bool> result = [];
    for (Message message in list.values) {
      if (message.type != 'text') {
        result.add(true);
      } else {
        result.add(false);
      }
    }
    return result.contains(false) ? false : true;
  }

  disableSelectionMode() {
    if (!mounted) return;
    setState(() {
      isSelectionMode = false;
      messagesSelectedList = {};
    });
  }

  // Delete Messages
  deleteMessages(Map<String, Message> listOfMessages) async {
    // Show Delete Decision Modal
    List deleteDecision = await showModalDecision(
      context: context,
      header: 'Delete',
      content:
          'Are you sure you want to permanently delete ${listOfMessages.length > 1 ? 'these ${listOfMessages.length} messages' : 'this message'}?',
      firstButton: 'Cancel',
      secondButton: 'Delete',
      checkBoxValue: deleteAlsoAssociatedMessageFiles,
      checkBoxCaption: hasMessagesSelectedListAmessageWithFiles(listOfMessages)
          ? 'Check this box to also delete ${listOfMessages.length > 1 ? 'the files associated with these messages' : 'the file associated with this message'}'
          : null,
    );
    if (deleteDecision[0] == true) {
      // Delete message.s...

      // ignore: use_build_context_synchronously
      await FirestoreMethods.deleteMessages(context, listOfMessages, deleteDecision[1]);
      disableSelectionMode();
    }
  }

  // Reply message
  replyMessage(Message msg) async {
    //
    disableSelectionMode();
    //
    // Return if file doesn't exist
    if (msg.type != 'text' && msg.type != 'payment') {
      List directories = await getDirectories();
      File file = File('${directories[0]}/$appName/${getSpecificDirByType(msg.type)}/${msg.filename}');
      if (!file.existsSync()) return;
    }

    // Return if messafe has Status 0
    if (msg.status == 0) return;

    // Return if widget is unmounted
    if (!mounted) return;

    setState(() {
      messageToReply = msg;
      //
      widget.eventAttached = null;
      widget.storyAttached = null;
    });
  }

  // Forward message
  forwardMessage(Map<String, Message> list) async {
    List directories = await getDirectories();

    List<bool> filesValidity = [];
    List<Message> validMessages = [];

    for (Message message in list.values) {
      // IF MESSAGE HAS FILE
      if (message.type != 'text') {
        File messageFile = File('${directories[0]}/$appName/${getSpecificDirByType(message.type)}/${message.filename}');
        // Check files existence
        if (messageFile.existsSync()) {
          validMessages.add(message);
          filesValidity.add(true);
        } else {
          filesValidity.add(false);
        }
      }
      // IF MESSAGE IS TEXT
      else if (message.type == 'text') {
        validMessages.add(message);
        filesValidity.add(true);
      }
    }
    if (filesValidity.contains(false)) {
      if (!mounted) return;
      showSnackbar(context,
          filesValidity.length == 1 ? 'This message cannot be shared!' : 'Some messages cannot be shared!', null);
    }

    // // Send Message
    if (validMessages.isNotEmpty) {
      if (!mounted) return;
      await Navigator.push(
        context,
        SwipeablePageRoute(
          builder: (context) {
            return ForwardToPage(
                previousPageName: 'inbox', typeToForward: 'messages', messagesToForward: validMessages);
          },
        ),
      );
      disableSelectionMode();
    }

    disableSelectionMode();
  }

  // Copy message : only Text message
  copyMessage(Message message) async {
    await Clipboard.setData(ClipboardData(text: message.data));
    // ignore: use_build_context_synchronously
    showSnackbar(context, 'Your message has been successfully copied!', kSuccessColor);

    disableSelectionMode();
  }

  // Share message : excepted Text message
  shareMessage(Map<String, Message> list) async {
    List directories = await getDirectories();

    List<bool> filesValidity = [];
    List<String> validFilesPath = [];

    for (var message in list.values) {
      File messageFile = File('${directories[0]}/$appName/${getSpecificDirByType(message.type)}/${message.filename}');
      // Check files existence
      if (messageFile.existsSync()) {
        validFilesPath.add(messageFile.path);
        filesValidity.add(true);
      } else {
        filesValidity.add(false);
      }
    }
    if (filesValidity.contains(false)) {
      // ignore: use_build_context_synchronously
      showSnackbar(
          // ignore: use_build_context_synchronously
          context,
          filesValidity.length == 1 ? 'This message cannot be shared!' : 'Some messages cannot be shared!',
          null);
    }
    disableSelectionMode();
    // Share Plugin
    if (validFilesPath.isNotEmpty) {
      try {
        await Share.shareXFiles(validFilesPath.map((p) => XFile(p)).toList());
      } catch (e) {
        // Handle error
        debugPrint('Erreur : $e');
        if (!mounted) return;
        showSnackbar(context, 'An error occured!', null);
      }
    }
  }

  detachEventOrStoryOrMessage() {
    if (!mounted) return;
    setState(() {
      widget.eventAttached = null;
      widget.storyAttached = null;
      messageToReply = null;
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

    // Check the Event Selected
    if (selectedEvent != null && selectedEvent != 'remove') {
      if (!mounted) return;
      setState(() {
        widget.eventAttached = selectedEvent;
        widget.storyAttached = null;
        messageToReply = null;
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

  Future<void> onWillPopHandler(context) async {
    if (showEmojiKeyboard == true) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return;
    }
    if (isSelectionMode == true) {
      disableSelectionMode();
      return;
    }
    Navigator.pop(context);
  }

  startVoiceNoteRecording() async {
    debugPrint('=> Start Voicenote Recording');

    // VIBRATE
    triggerVibration();

    // Check if Microphone Permission is granted
    if (await Permission.microphone.isGranted) {
      // Show Voicenote bottom bar
      setState(() {
        isRecordingVoiceNote = true;
      });

      // Start Recording
      await recorderController.record();

      // Start from ZERO: the Recording Counter
      voiceNoteRecordingCounter.reset();
      voiceNoteRecordingCounter.start(const Duration(seconds: 1));

      // Update Recording Elapsed Duration
      voiceNoteRecordingCounter.durationStream.listen((elapsedDuration) {
        if (mounted) {
          setState(() {
            voiceNoteRecordingDurationElapsed = elapsedDuration;
          });
        }
      });

      // Add [Me] to IsRecordingVoiceNoteList
      // FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
      //   discussionId: widget.discussion?.discussionId ?? '',
      //   type: 'isRecordingVoiceNote',
      //   action: 'add',
      // );
    }
    // Else Request Permission, if not granted!
    else if (await Permission.microphone.isPermanentlyDenied) {
      if (await Permission.microphone.isPermanentlyDenied) {
        // Show Modal Decision
        List deleteDecision = await showModalDecision(
          // ignore: use_build_context_synchronously
          context: context,
          header: 'Microphone Permission Required',
          content:
              'We need access to your microphone to continue. Please grant microphone permission in the app settings',
          firstButton: 'Cancel',
          secondButton: 'Open Settings',
        );

        if (deleteDecision[0] == true) {
          // Redirect to App Settings Page
          openAppSettings();
        }
      }
    } else {
      await Permission.microphone.request();
    }
  }

  sendVoiceNoteMessage() async {
    debugPrint('=> Send Voicenote');

    // Get last message : NB: last is 1st
    if (listMsg.isNotEmpty) {
      Message lastMessage = listMsg.first;
      scrollTo(listMsg, lastMessage.messageId);
    }
    // Reset isRecordingVoiceNote to false
    if (mounted) {
      setState(() {
        isRecordingVoiceNote = false;
      });
    }

    // Stop Recorder()
    final path = await recorderController.stop();
    // Reset Recording Duration Counter
    voiceNoteRecordingCounter.reset();

    // Get Voicenote audio path and detach any story/event/messageToReply attached
    if (path != null) {
      debugPrint('Voicenote path: $path');
      if (mounted) {
        setState(() {
          voiceNotePath = path;
        });
      }
      detachEventOrStoryOrMessage();

      await sendMessage(
        // ignore: use_build_context_synchronously
        context: context,
        userReceiverId: widget.userReceiverId,
        messageType: 'voicenote',
        discussionId: widget.discussion?.discussionId ?? '',
        eventId: widget.eventAttached != null ? widget.eventAttached!.eventId : '',
        storyId: widget.storyAttached != null ? widget.storyAttached!.storyId : '',
        messageTextValue: '',
        messageCaptionText: '',
        voiceNotePath: voiceNotePath,
        imagePath: '',
        videoPath: '',
        isPaymentMessage: false,
        amount: 0,
        paymentMethod: '',
        transactionId: '',
        receiverPhoneNumber: '',
        musicPath: '',
        messageToReplyId: messageToReply != null ? messageToReply?.messageId ?? '' : '',
        messageToReplySenderId: messageToReply != null ? messageToReply?.senderId ?? '' : '',
        messageToReplyType: messageToReply != null ? messageToReply?.type ?? '' : '',
        messageToReplyCaption: messageToReply != null ? messageToReply?.caption ?? '' : '',
        messageToReplyFilename: messageToReply != null ? messageToReply?.filename ?? '' : '',
        messageToReplyData: messageToReply != null ? messageToReply?.data ?? '' : '',
        messageToReplyThumbnail: messageToReply != null ? messageToReply?.thumbnail ?? '' : '',
      );

      // Remove [Me] from IsRecordingVoiceNoteList
      // FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
      //   discussionId: widget.discussion?.discussionId ?? '',
      //   type: 'isRecordingVoiceNote',
      //   action: 'remove',
      // );

      // Refresh the Whole Discussion
      await refreshDiscussion();
    }
  }

  cancelVoiceNoteRecoding() {
    debugPrint('=> Cancel Voicenote');

    // Delete recording and reset Recorder()
    recorderController.refresh();
    recorderController.stop();
    recorderController.reset();

    // Reset Recording Duration Counter
    voiceNoteRecordingCounter.reset();

    // Reset isRecordingVoiceNote to false && Record Button Position to initial
    if (mounted) {
      setState(() {
        voiceNoteRecordButtonLeftPosition = 0.0;
        isRecordingVoiceNote = false;
        voiceNotePath = '';
      });
    }

    // // Remove [Me] from IsRecordingVoiceNoteList
    // FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
    //   discussionId: widget.discussion?.discussionId ?? '',
    //   type: 'isRecordingVoiceNote',
    //   action: 'remove',
    // );
  }

  sendNormalMessage() async {
    // VIBRATE
    await triggerVibration();

    // Get last message : NB: last is 1st
    // Then Scroll to it
    if (listMsg.isNotEmpty) {
      Message lastMessage = listMsg.first;
      scrollTo(listMsg, lastMessage.messageId);
    }

    // Send Text Message !
    sendMessage(
      // ignore: use_build_context_synchronously
      context: context,
      userReceiverId: widget.userReceiverId,
      messageType: 'text',
      discussionId: widget.discussion?.discussionId ?? '',
      eventId: widget.eventAttached != null ? widget.eventAttached!.eventId : '',
      storyId: widget.storyAttached != null ? widget.storyAttached!.storyId : '',
      messageTextValue: messageTextValue,
      messageCaptionText: '',
      voiceNotePath: '',
      imagePath: '',
      videoPath: '',
      musicPath: '',
      isPaymentMessage: false,
      amount: 0,
      receiverPhoneNumber: '',
      paymentMethod: '',
      transactionId: '',
      messageToReplyId: messageToReply != null ? messageToReply?.messageId ?? '' : '',
      messageToReplySenderId: messageToReply != null ? messageToReply?.senderId ?? '' : '',
      messageToReplyType: messageToReply != null ? messageToReply?.type ?? '' : '',
      messageToReplyCaption: messageToReply != null ? messageToReply?.caption ?? '' : '',
      messageToReplyFilename: messageToReply != null ? messageToReply?.filename ?? '' : '',
      messageToReplyData: messageToReply != null ? messageToReply?.data ?? '' : '',
      messageToReplyThumbnail: messageToReply != null ? messageToReply?.thumbnail ?? '' : '',
    );

    // Flush Textfield Controller && Detach Any attached Event / Story / MessageToReply
    messageTextController.clear();
    detachEventOrStoryOrMessage();
    if (!mounted) return;
    setState(() {
      messageTextValue = '';
    });
    await refreshDiscussion();
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        onWillPopHandler(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 0.08.sh),
            child: Stack(
              children: [
                // NORMAL APP BAR
                MorphingAppBar(
                  toolbarHeight: 46,
                  scrolledUnderElevation: 0.0,
                  heroTag: 'inboxPageAppBar',
                  elevation: 0,
                  backgroundColor: Colors.white,
                  titleSpacing: 0,
                  leadingWidth: 90,
                  leading: Row(
                    children: [
                      IconButton(
                        splashRadius: 0.06.sw,
                        onPressed: () async {
                          await onWillPopHandler(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Redirect to Profile Page
                          Navigator.push(
                              context,
                              SwipeablePageRoute(
                                builder: (context) => ProfilePage(uid: widget.userReceiverId, showBackButton: true),
                              ));
                        },
                        child: BuildUserProfilePicture(radius: 15, userId: widget.userReceiverId),
                      )
                    ],
                  ),
                  title: GestureDetector(
                    onTap: () {
                      // Redirect to Profile Page
                      Navigator.push(
                          context,
                          SwipeablePageRoute(
                            builder: (context) => ProfilePage(uid: widget.userReceiverId, showBackButton: true),
                          ));
                    },
                    child: Wrap(
                      children: [
                        // Username + Date OR IsTyping OR IsRecordingVoiceNote
                        StreamBuilder(
                          stream: FirestoreMethods.getDiscussionById(widget.discussion?.discussionId ?? ''),
                          builder: (context, snapshot) {
                            // Handle error
                            if (snapshot.hasError) {
                              return Container();
                            }
                            // Handle Data
                            if (snapshot.hasData) {
                              Discussion streamDiscussion = snapshot.data as Discussion;

                              List otherParticipants = streamDiscussion.participants
                                  .where((userId) =>
                                      userId != FirebaseAuth.instance.currentUser!.uid &&
                                      !(userId as String).contains('_'))
                                  .toList();
                              debugPrint('otherParticipants: $otherParticipants');

                              // // IF [ANOTHER USER IS] TYPING : only display if Internet Connection is active
                              if (isConnected && streamDiscussion.isTypingList.contains(otherParticipants.first)) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'typing...',
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          color: kSecondColor),
                                    ),
                                  ],
                                );
                              }

                              // // IF [ANOTHER USER IS] RECORDING VOICE NOTE : only display if Internet Connection is active
                              if (isConnected &&
                                  streamDiscussion.isRecordingVoiceNoteList.contains(otherParticipants.first)) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Lottie.asset(
                                      height: 20,
                                      waves,
                                      // width: double.infinity,
                                    ),
                                  ],
                                );
                              }

                              return BuildUserNameToDisplay(userId: widget.userReceiverId);
                            }

                            // Loader
                            return BuildUserNameToDisplay(userId: widget.userReceiverId);
                          },
                        )
                      ],
                    ),
                  ),
                  actions: [
                    PopupMenuButton(
                      icon: const Icon(
                        FontAwesomeIcons.ellipsisVertical,
                        color: Colors.black,
                      ),
                      enableFeedback: true,
                      elevation: 2,
                      splashRadius: 0.06.sw,
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            // Redirect to Profile Page
                            Navigator.push(
                                context,
                                SwipeablePageRoute(
                                  builder: (context) => ProfilePage(uid: widget.userReceiverId, showBackButton: true),
                                ));
                            break;
                          case 1:
                            // Delete all messages in chat
                            Map<String, Message> allMessagesList = {};

                            // Get all discussion messages
                            for (Message message in listMsg) {
                              allMessagesList.addAll({message.messageId: message});
                            }
                            deleteMessages(allMessagesList);
                            break;
                          case 2:

                            // Redirect Bug Report Page
                            Navigator.push(context, SwipeablePageRoute(builder: (context) => const BugReportPage()));
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 10),
                              Text('Profile', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.black87),
                              const SizedBox(width: 10),
                              Text('Clear', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              const Icon(Icons.bug_report_outlined, color: Colors.black87),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('Report', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // SELECTION MODE APP BAR
                Visibility(
                  visible: isSelectionMode && messagesSelectedList.isNotEmpty ? true : false,
                  child: MorphingAppBar(
                    toolbarHeight: 46,
                    scrolledUnderElevation: 0.0,
                    heroTag: 'inboxSelectionModeAppBar',
                    elevation: 0,
                    backgroundColor: Colors.white,
                    titleSpacing: 0,
                    leading: IconButton(
                      splashRadius: 0.06.sw,
                      onPressed: () async {
                        disableSelectionMode();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                    ),
                    title: Wrap(
                      children: [
                        Text(
                          '${messagesSelectedList.length.toString()} selected',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    // Selection Mode Actions
                    actions: [
                      // Reply to message
                      Visibility(
                        visible: messagesSelectedList.length == 1 && messagesSelectedList.values.first.status != 0
                            ? true
                            : false,
                        child: Tooltip(
                          message: 'Reply',
                          child: IconButton(
                            splashRadius: 0.06.sw,
                            onPressed: () async {
                              replyMessage(messagesSelectedList.values.first);
                            },
                            icon: const Icon(
                              Icons.reply,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),

                      // Delete Message(s)
                      Tooltip(
                        message: 'Delete',
                        child: IconButton(
                          splashRadius: 0.06.sw,
                          onPressed: () async {
                            deleteMessages(messagesSelectedList);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // Copy message
                      Visibility(
                        visible: messagesSelectedList.length == 1 && messagesSelectedList.values.first.type == 'text',
                        child: Tooltip(
                          message: 'Copy',
                          child: IconButton(
                            splashRadius: 0.06.sw,
                            onPressed: () async {
                              copyMessage(messagesSelectedList.values.first);
                            },
                            icon: const Icon(
                              Icons.content_copy_rounded,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),

                      // Share message(s)
                      Visibility(
                        visible: messagesSelectedList.isNotEmpty &&
                            hasMessagesSelectedListOnlyMessageWithFiles(messagesSelectedList),
                        child: Tooltip(
                          message: 'Share',
                          child: IconButton(
                            splashRadius: 0.06.sw,
                            onPressed: () async {
                              shareMessage(messagesSelectedList);
                            },
                            icon: const Icon(
                              Icons.share,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),

                      // Forward message(s)
                      Visibility(
                        visible: messagesSelectedList.isNotEmpty ? true : false,
                        child: Tooltip(
                          message: 'Forward',
                          child: IconButton(
                            splashRadius: 0.06.sw,
                            onPressed: () async {
                              forwardMessage(messagesSelectedList);
                            },
                            icon: Transform.scale(
                              scaleX: -1,
                              child: const Icon(
                                Icons.reply,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
        body: Column(
          children: [
            // Display all Messages
            Expanded(
              child: isLoading
                  ? Center(
                      child: CupertinoActivityIndicator(
                        radius: 12.sp,
                      ),
                    )
                  :
                  //   Chat body
                  StreamBuilder(
                      stream: FirestoreMethods.getMessagesByDiscussionId(widget.discussion?.discussionId ?? ''),
                      builder: (context, snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          // Handle error
                          debugPrint('error: ${snapshot.error}');
                          return SizedBox(width: 0.5.sw, child: const BuildErrorWidget(onWhiteBackground: true));
                        }

                        if (snapshot.hasData && snapshot.data != null) {
                          listMsg = snapshot.data as List<Message>;

                          // Remove [Invalid Message] && [DeleteForMe Message]
                          if (listMsg.isNotEmpty) {
                            listMsg = listMsg.where((currentMessage) {
                              // [Invalid Message]
                              if (currentMessage.senderId != FirebaseAuth.instance.currentUser!.uid &&
                                  currentMessage.status == 0) {
                                return false;
                              }

                              // Retrieve [DeleteForMe Message]
                              if (currentMessage.deleteFor.contains(FirebaseAuth.instance.currentUser!.uid)) {
                                return false;
                              }

                              return true;
                            }).toList();

                            messagesListLength.add(listMsg.length);
                          }

                          // Show Scroll to the end btn : if necessary
                          if (listMsg.isNotEmpty &&
                              listMsg.any((m) => m.senderId != FirebaseAuth.instance.currentUser!.uid) &&
                              isLastMessageVisible == false &&
                              messagesListLength.length > 2 &&
                              messagesListLength.last > messagesListLength[messagesListLength.length - 2]) {
                            showScrollDownButton.value = true;
                          }

                          listMsg.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                          // No discussion found
                          if (listMsg.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(30),
                              height: 300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start the conversation!',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // listMsg = listMsg.where((el) => el.type == 'voicenote' || el.type == 'music').toList();

                          // Discussion found
                          return Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // All messages
                              NotificationListener<ScrollEndNotification>(
                                onNotification: (scrollEnd) {
                                  final metrics = scrollEnd.metrics;
                                  if (metrics.atEdge) {
                                    bool isBottom = metrics.pixels == 0;
                                    if (isBottom) {
                                      debugPrint('At the bottom');
                                      showScrollDownButton.value = false;
                                    }
                                  }
                                  return true;
                                },
                                child: ScrollablePositionedList.builder(
                                  itemCount: listMsg.length,
                                  itemScrollController: _scrollController,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    Message message = listMsg[index];
                                    bool hasTheSameDateWithNextMessage = false;
                                    num nextMessageIndex = index + 1;

                                    // Get next message index
                                    if (nextMessageIndex >= listMsg.length - 1) {
                                      nextMessageIndex = index;
                                    } else {
                                      nextMessageIndex = index + 1;
                                    }
                                    Message nextMessage = listMsg[nextMessageIndex as int];

                                    if (DateUtils.dateOnly(message.createdAt)
                                        .isAtSameMomentAs(DateUtils.dateOnly(nextMessage.createdAt))) {
                                      hasTheSameDateWithNextMessage = true;
                                    }

                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onLongPress: (() {
                                        if (isSelectionMode == false) {
                                          if (!mounted) return;
                                          setState(() {
                                            isSelectionMode = true;
                                          });
                                          // Add or remove message
                                          addOrRemoveMessageFromAllMessagesSelected({message.messageId: message});
                                        }
                                      }),
                                      onTap: () {
                                        if (isSelectionMode == true) {
                                          addOrRemoveMessageFromAllMessagesSelected({message.messageId: message});
                                        }
                                      },
                                      child: VisibilityDetector(
                                        key: Key(message.messageId),
                                        onVisibilityChanged: (VisibilityInfo info) {
                                          if (listMsg.isNotEmpty &&
                                              info.visibleFraction == 0 &&
                                              listMsg.first.messageId == message.messageId) {
                                            if (mounted) {
                                              setState(() {
                                                isLastMessageVisible = false;
                                              });
                                            }
                                          } else if (listMsg.isNotEmpty &&
                                              info.visibleFraction == 1.0 &&
                                              listMsg.first.messageId == message.messageId) {
                                            if (mounted) {
                                              setState(() {
                                                isLastMessageVisible = true;
                                              });
                                            }
                                          }
                                          debugPrint("Last message is visible : $isLastMessageVisible");
                                        },
                                        child: MessageCard(
                                          onScrollTo: () {
                                            scrollTo(listMsg, message.messageToReplyId);
                                          },
                                          onSwipe: () async {
                                            // VIBRATE
                                            triggerVibration();
                                            // Right Swipe Detected
                                            replyMessage(message);
                                          },
                                          currentMessageIndex: index,
                                          listMsgLength: listMsg.length,
                                          nextMessage: nextMessage,
                                          hasTheSameDateWithNextMessage: hasTheSameDateWithNextMessage,
                                          message: message,
                                          isMessageSelected:
                                              messagesSelectedList.keys.contains(message.messageId) ? true : false,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Scroll downBtn : when viewport doesn't contains the last message
                              Visibility(
                                visible:
                                    showScrollDownButton.value == false && isLastMessageVisible == false ? true : false,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20, bottom: 10),
                                      child: GestureDetector(
                                        onTap: () {
                                          showScrollDownButton.value = false;
                                          // Get last message : NB: last is 1st
                                          Message lastMessage = listMsg.first;
                                          scrollTo(listMsg, lastMessage.messageId);
                                        },
                                        child: Material(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          elevation: 3,
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.black54,
                                            radius: 18,
                                            child: Icon(
                                              Icons.arrow_downward_outlined,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              // Scroll downBtn : on Message added
                              ValueListenableBuilder(
                                valueListenable: showScrollDownButton,
                                builder: (context, value, child) {
                                  return showScrollDownButton.value == true
                                      ? Container(
                                          height: 30,
                                          margin: const EdgeInsets.only(bottom: 10),
                                          child: Material(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            elevation: 5,
                                            child: CupertinoButton(
                                              color: Colors.black54,
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              borderRadius: BorderRadius.circular(15),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'New message',
                                                    style: TextStyle(
                                                        fontSize: 11.sp,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  const Icon(Icons.arrow_downward_outlined,
                                                      color: Colors.white, size: 15),
                                                ],
                                              ),
                                              onPressed: () async {
                                                //
                                                showScrollDownButton.value = false;

                                                // Get last message : NB: last is 1st
                                                Message lastMessage = listMsg.first;
                                                scrollTo(listMsg, lastMessage.messageId);
                                              },
                                            ),
                                          ),
                                        )
                                      : Container();
                                },
                              )
                            ],
                          );
                        }
                        return const SizedBox(
                          height: 100,
                          child: CupertinoActivityIndicator(),
                        );
                      },
                    ),
            ),

            // Chat Bottom Actions
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Material(
                  elevation:
                      messageToReply == null && widget.eventAttached == null && widget.storyAttached == null ? 0 : 20,
                  child: Container(
                    margin: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: 5,
                        top: messageToReply == null && widget.eventAttached == null && widget.storyAttached == null
                            ? 4
                            : 7),
                    child: Row(
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
                                  padding: messageToReply == null &&
                                          widget.eventAttached == null &&
                                          widget.storyAttached == null
                                      ? EdgeInsets.zero
                                      : const EdgeInsets.fromLTRB(10, 7, 10, 7),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      // Display Message to reply
                                      messageToReply != null &&
                                              widget.eventAttached == null &&
                                              widget.storyAttached == null
                                          ? Padding(
                                              padding: const EdgeInsets.only(left: 5, top: 3),
                                              child: Wrap(
                                                children: [
                                                  getMessageToReplyGridPreview(
                                                    messageToReplyId: messageToReply?.messageId ?? '',
                                                    messageToReplySenderId: messageToReply?.senderId ?? '',
                                                    messageToReplyType: messageToReply?.type ?? '',
                                                    messageToReplyCaption: messageToReply?.caption ?? '',
                                                    messageToReplyFilename: messageToReply?.filename ?? '',
                                                    messageToReplyData: messageToReply?.data ?? '',
                                                    messageToReplyThumbnail: messageToReply?.thumbnail ?? '',
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),

                                      // Display Event Attached
                                      widget.eventAttached != null &&
                                              widget.storyAttached == null &&
                                              messageToReply == null
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
                                              messageToReply == null
                                          ? getStoryGridPreview(storyId: widget.storyAttached?.storyId ?? '')
                                          : Container(),

                                      // Button: Detach event or story or message linked
                                      Visibility(
                                        visible: messageToReply != null ||
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
                                // Divider
                                widget.storyAttached == null && widget.eventAttached == null && messageToReply == null
                                    ? Container()
                                    : const Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: BuildDivider(padding: 0),
                                      ),

                                // MAIN FIELD: type your msg here + action buttons
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 100),
                                  crossFadeState:
                                      !isRecordingVoiceNote ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                  // Show normal bottom bar: textfield
                                  firstChild: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Emoji button
                                      IconButton(
                                        splashRadius: 0.06.sw,
                                        splashColor: kSecondColor,
                                        onPressed: () {
                                          // Show Emoji Keyboard Here !
                                          if (!mounted) return;
                                          setState(() {
                                            showEmojiKeyboard = !showEmojiKeyboard;
                                          });
                                          if (showEmojiKeyboard) {
                                            messageTextFocus.unfocus();
                                          } else {
                                            messageTextFocus.requestFocus();
                                          }
                                        },
                                        icon: Icon(
                                          FontAwesomeIcons.faceGrin,
                                          size: 0.06.sw,
                                          color: showEmojiKeyboard ? kSecondColor : Colors.grey.shade600,
                                        ),
                                      ),

                                      // Message Textfield
                                      Expanded(
                                        child: TextField(
                                          onChanged: (value) {
                                            if (!mounted) return;
                                            setState(() {
                                              messageTextValue = value.trimLeft().trimRight().trim();
                                            });
                                            // debugPrint('Is typing');
                                            // // Add [Me] in IsTypingList
                                            // FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
                                            //   discussionId: widget.discussion?.discussionId ?? '',
                                            //   type: 'isTyping',
                                            //   action: 'add',
                                            // );
                                            // Debouncer(milliseconds: 2000).run(() {
                                            //   debugPrint('Stop typing');
                                            //   // Remove [Me] in IsTypingList
                                            //   FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
                                            //     discussionId: widget.discussion?.discussionId ?? '',
                                            //     type: 'isTyping',
                                            //     action: 'remove',
                                            //   );
                                            // });
                                          },
                                          onTap: () {
                                            if (mounted) {
                                              // Dismiss emoji keyboard
                                              setState(() {
                                                showEmojiKeyboard = false;
                                              });
                                            }
                                          },
                                          focusNode: messageTextFocus,
                                          controller: messageTextController,
                                          cursorColor: kSecondColor,
                                          style: TextStyle(color: Colors.black87, fontSize: 15.sp),
                                          maxLines: 5,
                                          minLines: 1,
                                          keyboardType: TextInputType.multiline,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Type here...',
                                            contentPadding: const EdgeInsets.all(1),
                                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15.sp),
                                          ),
                                        ),
                                      ),

                                      // Send file/media
                                      messageTextValue == ''
                                          ? IconButton(
                                              splashColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onPressed: () async {
                                                // Show All Messages Format Picker Here !
                                                dynamic fileselected = await showModalBottomSheet(
                                                  isDismissible: true,
                                                  enableDrag: true,
                                                  isScrollControlled: true,
                                                  context: context,
                                                  backgroundColor: Colors.transparent,
                                                  builder: ((context) => Modal(
                                                        maxHeightSize: 270,
                                                        minHeightSize: 270,
                                                        child: MessageFilePicker(
                                                          discussionId: widget.discussion?.discussionId ?? '',
                                                          userReceiverId: widget.userReceiverId,
                                                          messageToReply: messageToReply,
                                                          eventAttached: widget.eventAttached,
                                                          storyAttached: widget.storyAttached,
                                                        ),
                                                      )),
                                                );

                                                if (fileselected != null) {
                                                  debugPrint('File picked is: $fileselected');
                                                  detachEventOrStoryOrMessage();
                                                } else if (fileselected == null) {
                                                  // ignore: use_build_context_synchronously
                                                  // Navigator.pop(context);
                                                }
                                              },
                                              icon: Icon(
                                                FontAwesomeIcons.paperclip,
                                                size: 0.06.sw,
                                                color: Colors.grey.shade600,
                                              ),
                                            )
                                          : Container(),

                                      // Attach event button
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
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
                                  // Show Voicenote bottom bar
                                  secondChild: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        height: 0.12.sw,
                                        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                        child: Text(
                                          getDurationFormat(voiceNoteRecordingDurationElapsed),
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: kSecondColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      // CircleAvatar(
                                      //   radius: 25,
                                      //   backgroundColor: Colors.transparent,
                                      //   child: IconButton(
                                      //     splashColor: Colors.transparent,
                                      //     onPressed: () {
                                      //       cancelVoiceNoteRecoding();
                                      //     },
                                      //     icon: Icon(
                                      //       Icons.delete,
                                      //       color: Colors.grey.shade600,
                                      //     ),
                                      //   ),
                                      // ),

                                      // Voicenote Wave Displayer
                                      Expanded(
                                        child: AudioWaveforms(
                                          size: const Size(double.infinity, 20),
                                          recorderController: recorderController,
                                          waveStyle: const WaveStyle(
                                            showHourInDuration: true,
                                            waveThickness: 2,
                                            spacing: 6,
                                            durationLinesHeight: 0,
                                            durationLinesColor: kSecondColor,
                                            showDurationLabel: true,
                                            showBottom: true,
                                            showTop: true,
                                            extendWaveform: true,
                                            showMiddleLine: false,
                                          ),
                                        ),
                                      ),

                                      // Voicenote Recording Indication: "< Cancel"
                                      GestureDetector(
                                        onTap: () {
                                          cancelVoiceNoteRecoding();
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 0.12.sw,
                                          margin: const EdgeInsets.fromLTRB(5, 5, 20, 5),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.keyboard_arrow_left_rounded,
                                                color: Colors.grey.shade600,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Cancel',
                                                maxLines: 1,
                                                overflow: TextOverflow.fade,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
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

                        // Fake Container to represent the space taken by [ACTION BUTTONS] Send Message Button or Mic Button
                        const SizedBox(width: 55),
                      ],
                    ),
                  ),
                ),

                // [ACTION BUTTONS] Send Message Button or Mic Button
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (messageTextValue == '') {
                            // MIC BUTTON: record a voicenote
                            return GestureDetector(
                              onLongPressDown: (_) {
                                startVoiceNoteRecording();
                              },
                              onLongPressEnd: (_) {
                                sendVoiceNoteMessage();
                              },
                              onVerticalDragUpdate: (details) {
                                if (details.delta.dx > 10 || details.delta.dy > 10) {
                                  // On vertical drag: cancel recording
                                  cancelVoiceNoteRecoding();
                                }
                              },
                              onHorizontalDragUpdate: (details) {
                                // Update the position of the Record Button during the left drag only
                                setState(() {
                                  voiceNoteRecordButtonLeftPosition += (details.delta.dx * 25) / 100;
                                });
                              },
                              onHorizontalDragEnd: (details) {
                                cancelVoiceNoteRecoding();
                              },
                              child: Tooltip(
                                triggerMode: TooltipTriggerMode.tap,
                                message: 'Hold to record, release to send',
                                child: Transform.translate(
                                  offset: Offset(voiceNoteRecordButtonLeftPosition, 0),
                                  child: Transform.scale(
                                    scale: isRecordingVoiceNote ? 1.7 : 1,
                                    child: CircleAvatar(
                                      backgroundColor: kSecondColor,
                                      radius: 0.077.sw,
                                      child: Icon(
                                        Icons.mic,
                                        size: 0.06.sw,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // SEND MESSAGE BUTTON
                            return InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                sendNormalMessage();
                              },
                              child: CircleAvatar(
                                backgroundColor: kSecondColor,
                                radius: 0.077.sw,
                                child: Icon(
                                  Icons.send_rounded,
                                  size: 0.06.sw,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Show Emoji Keyboard
            EmojiPickerOffstage(
              showEmojiKeyboard: showEmojiKeyboard,
              textController: messageTextController,
              onBackspacePressed: () {
                if (!mounted) return;
                setState(() {
                  if (messageTextValue.isNotEmpty) {
                    messageTextValue = messageTextValue.substring(0, messageTextValue.length - 1);
                  }
                });
              },
              onEmojiSelected: (category, emoji) {
                if (!mounted) return;
                setState(() {
                  messageTextValue = '$messageTextValue${emoji.emoji}';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

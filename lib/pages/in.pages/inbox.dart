import 'dart:async';
import 'dart:io';
import 'dart:math';
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
import 'package:wesh/widgets/eventselector.dart';
import 'package:wesh/widgets/messagecard.dart';
import 'package:wesh/widgets/messagefilepicker.dart';
import '../../models/discussion.dart';
import '../../models/event.dart';
import '../../models/story.dart';
import '../../services/sharedpreferences.service.dart';
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
    Key? key,
    this.discussion,
    this.eventAttached,
    required this.userReceiverId,
    this.storyAttached,
  }) : super(key: key);

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
  List<Message>? listMsg = [];
  Message? messageToReply;

  FocusNode messageTextFocus = FocusNode();
  TextEditingController messageTextController = TextEditingController();
  String messageTextValue = '';
  late bool isAddOtherMsgMethod = true;
  bool isLoading = false;

  //

  late final RecorderController recorderController;
  String voiceNotePath = '';
  double voiceNoteButtonScale = 1;
  bool showVoicenoteBottomBar = false;

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
    }
  }

  @override
  void initState() {
    super.initState();
    //
    refreshDiscussion();
    //
    recorderController = RecorderController();
    //
    FirestoreMethods.updateMessagesToStatus3(widget.discussion?.messages.map((m) => m as String).toList() ?? []);
  }

  @override
  void dispose() {
    super.dispose();
    recorderController.dispose();
    //
    internetSubscription != null ? internetSubscription!.cancel() : null;

    // Remove Current Active Page
    UserSimplePreferences.setCurrentActivePageHandler('');
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
      header: 'Supprimer',
      content:
          'Voulez-vous supprimer définitivement ${listOfMessages.length > 1 ? 'ces ${listOfMessages.length} messages' : 'ce message'}',
      firstButton: 'Annuler',
      secondButton: 'Supprimer',
      checkBoxValue: deleteAlsoAssociatedMessageFiles,
      checkBoxCaption: hasMessagesSelectedListAmessageWithFiles(listOfMessages)
          ? 'Cocher la case pour supprimer également ${listOfMessages.length > 1 ? 'les fichiers associés à ces messages' : 'le fichier associé à ce message'}'
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
      // ignore: use_build_context_synchronously
      showSnackbar(
          context,
          filesValidity.length == 1
              ? 'Ce message ne peut pas être envoyé !'
              : 'Certains messages ne peuvent pas être envoyé !',
          null);
    }

    // // Send Message
    if (validMessages.isNotEmpty) {
      // ignore: use_build_context_synchronously
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
    showSnackbar(context, 'Votre message a bien été copié !', kSuccessColor);
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
          context,
          filesValidity.length == 1
              ? 'Ce message ne peut pas être partagé !'
              : 'Certains messages ne peuvent pas être partagé !',
          null);
    }
    disableSelectionMode();
    // Share Plugin
    if (validFilesPath.isNotEmpty) {
      await Share.shareFiles(validFilesPath).onError((error, stackTrace) {
        // Handle error
        debugPrint('Erreur : $error');
        showSnackbar(context, 'Une erreur s\'est produite', null);
      });
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

  Future<bool> onWillPopHandler(context) async {
    if (showEmojiKeyboard == true) {
      setState(() {
        showEmojiKeyboard = false;
      });

      return false;
    }
    if (isSelectionMode == true) {
      disableSelectionMode();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    // Set Current Active Page
    UserSimplePreferences.setCurrentActivePageHandler(context.widget.toStringShort());

    return WillPopScope(
      onWillPop: () async {
        return await onWillPopHandler(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 0.08.sh),
            child: Stack(
              children: [
                // NORMAL APP BAR
                MorphingAppBar(
                  heroTag: 'inboxPageAppBar',
                  elevation: 0,
                  backgroundColor: Colors.white,
                  titleSpacing: 0,
                  leadingWidth: 100,
                  leading: Row(
                    children: [
                      IconButton(
                        splashRadius: 0.06.sw,
                        onPressed: () async {
                          bool result = await onWillPopHandler(context);
                          if (result) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          } else {
                            //
                          }
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
                        child: buildUserProfilePicture(radius: 15, userId: widget.userReceiverId),
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
                                      'écrit...',
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

                              return buildUserNameToDisplay(userId: widget.userReceiverId);
                            }

                            // Loader
                            return buildUserNameToDisplay(userId: widget.userReceiverId);
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
                            for (Message message in listMsg ?? []) {
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
                              Text('Profil', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.black87),
                              const SizedBox(width: 10),
                              Text('Vider la discussion', style: TextStyle(fontSize: 14.sp)),
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
                              Text('Reporter', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // SELECTION MODE APP BAR
                Visibility(
                  visible: isSelectionMode && messagesSelectedList.length > 0 ? true : false,
                  child: MorphingAppBar(
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
                          '${messagesSelectedList.length.toString()} selectionné${messagesSelectedList.length > 1 ? 's' : ''}',
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
                      // Reply Message
                      Visibility(
                        visible: messagesSelectedList.length == 1 && messagesSelectedList.values.first.status != 0
                            ? true
                            : false,
                        child: Tooltip(
                          message: 'Répondre',
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

                      // Delete Messages
                      Tooltip(
                        message: 'Supprimer',
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

                      Visibility(
                        visible: messagesSelectedList.length == 1 && messagesSelectedList.values.first.type == 'text',
                        child: Tooltip(
                          message: 'Copier',
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

                      Visibility(
                        visible: messagesSelectedList.isNotEmpty &&
                            hasMessagesSelectedListOnlyMessageWithFiles(messagesSelectedList),
                        child: Tooltip(
                          message: 'Partager',
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

                      // Forward message
                      Visibility(
                        visible: messagesSelectedList.isNotEmpty ? true : false,
                        child: Tooltip(
                          message: 'Envoyer',
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
            // Display all Messags
            Expanded(
              child: isLoading
                  ? Center(
                      child: Expanded(
                        child: CupertinoActivityIndicator(
                          radius: 12.sp,
                        ),
                      ),
                    )
                  :
                  // Chat body
                  StreamBuilder(
                      stream: FirestoreMethods.getMessagesByDiscussionId(widget.discussion?.discussionId ?? ''),
                      builder: (context, snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          // Handle error
                          debugPrint('error: ${snapshot.error}');
                          return SizedBox(width: 0.5.sw, child: const buildErrorWidget(onWhiteBackground: true));
                        }

                        if (snapshot.hasData) {
                          listMsg = snapshot.data as List<Message>?;

                          // Remove [Invalid Message] && [DeleteForMe Message]
                          listMsg = listMsg!.where((currentMessage) {
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

                          messagesListLength.add(listMsg!.length);

                          // Show Scroll to the end btn : if necessary
                          if (isLastMessageVisible == false &&
                              messagesListLength.length > 2 &&
                              messagesListLength.last > messagesListLength[messagesListLength.length - 2]) {
                            showScrollDownButton.value = true;
                          }

                          listMsg!.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                          // No discussion found
                          if (listMsg!.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(30),
                              height: 300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Commencez la discussion !',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

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
                                  itemCount: listMsg!.length,
                                  itemScrollController: _scrollController,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    Message message = listMsg![index];
                                    bool hasTheSameDateWithNextMessage = false;
                                    num nextMessageIndex = index + 1;

                                    // Get next message index
                                    if (nextMessageIndex >= listMsg!.length - 1) {
                                      nextMessageIndex = index;
                                    } else {
                                      nextMessageIndex = index + 1;
                                    }
                                    Message nextMessage = listMsg![nextMessageIndex as int];

                                    if (DateUtils.dateOnly(message.createdAt)
                                        .isAtSameMomentAs(DateUtils.dateOnly(nextMessage.createdAt))) {
                                      hasTheSameDateWithNextMessage = true;
                                    }

                                    return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
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
                                          if (listMsg != null &&
                                              listMsg!.isNotEmpty &&
                                              info.visibleFraction == 0 &&
                                              listMsg!.first.messageId == message.messageId) {
                                            if (!mounted) return;
                                            setState(() {
                                              isLastMessageVisible = false;
                                            });
                                          } else if (listMsg != null &&
                                              listMsg!.isNotEmpty &&
                                              info.visibleFraction == 1.0 &&
                                              listMsg!.first.messageId == message.messageId) {
                                            if (!mounted) return;
                                            setState(() {
                                              isLastMessageVisible = true;
                                            });
                                          }
                                          debugPrint("Last message is visible : $isLastMessageVisible");
                                        },
                                        child: MessageCard(
                                          onScrollTo: () {
                                            scrollTo(listMsg!, message.messageToReplyId);
                                          },
                                          onSwipe: () async {
                                            // VIBRATE
                                            triggerVibration();
                                            // Right Swipe Detected
                                            replyMessage(message);
                                          },
                                          currentMessageIndex: index,
                                          listMsgLength: listMsg!.length,
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 30,
                                      margin: const EdgeInsets.only(bottom: 10, left: 10),
                                      child: Material(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        elevation: 5,
                                        child: CupertinoButton(
                                          color: kSecondColor.withOpacity(0.8),
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          borderRadius: BorderRadius.circular(20),
                                          child: Icon(
                                            Icons.keyboard_double_arrow_down_rounded,
                                            color: Colors.white,
                                            size: 0.04.sw,
                                          ),
                                          onPressed: () async {
                                            //
                                            showScrollDownButton.value = false;

                                            // Get last message : NB: last is 1st
                                            Message lastMessage = listMsg!.first;
                                            scrollTo(listMsg!, lastMessage.messageId);
                                          },
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
                                              color: kSecondColor,
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              borderRadius: BorderRadius.circular(20),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Nouveau message',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_double_arrow_down_rounded,
                                                    color: Colors.white,
                                                    size: 0.04.sw,
                                                  ),
                                                ],
                                              ),
                                              onPressed: () async {
                                                //
                                                showScrollDownButton.value = false;

                                                // Get last message : NB: last is 1st
                                                Message lastMessage = listMsg!.first;
                                                scrollTo(listMsg!, lastMessage.messageId);
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
            SafeArea(
              child: BottomAppBar(
                elevation:
                    messageToReply == null && widget.eventAttached == null && widget.storyAttached == null ? 0 : 20,
                child: Column(
                  children: [
                    // INPUTS + SEND BUTTON
                    Padding(
                      padding: EdgeInsets.only(
                          left: 0.02.sw,
                          right: 0.02.sw,
                          bottom: 0.02.sw,
                          top: messageToReply == null && widget.eventAttached == null && widget.storyAttached == null
                              ? 0.01.sw
                              : 0.02.sw),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Entry Message Fields
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(messageToReply == null &&
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
                                      messageToReply != null &&
                                              widget.eventAttached == null &&
                                              widget.storyAttached == null
                                          ? Wrap(
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

                                      // Button Detach event or story or message linked
                                      Visibility(
                                        visible: messageToReply != null ||
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
                                  AnimatedCrossFade(
                                    duration: const Duration(milliseconds: 100),
                                    crossFadeState: showVoicenoteBottomBar == false
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                    firstChild:
                                        // Normal bottom bar
                                        Row(
                                      children: [
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

                                        // Show normal bottom bar
                                        Expanded(
                                          child: TextField(
                                            onChanged: (value) {
                                              if (!mounted) return;
                                              setState(() {
                                                messageTextValue = value.trimLeft().trimRight().trim();
                                              });
                                              debugPrint('Is typing');
                                              // Add [Me] in IsTypingList
                                              FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
                                                discussionId: widget.discussion?.discussionId ?? '',
                                                type: 'isTyping',
                                                action: 'add',
                                              );
                                              Debouncer(milliseconds: 2000).run(() {
                                                debugPrint('Stop typing');
                                                // Remove [Me] in IsTypingList
                                                FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
                                                  discussionId: widget.discussion?.discussionId ?? '',
                                                  type: 'isTyping',
                                                  action: 'remove',
                                                );
                                              });
                                            },
                                            onTap: () {
                                              if (!mounted) return;
                                              // Dismiss emoji keyboard
                                              setState(() {
                                                showEmojiKeyboard = false;
                                              });
                                            },
                                            focusNode: messageTextFocus,
                                            controller: messageTextController,
                                            cursorColor: Colors.black38,
                                            style: TextStyle(color: Colors.black87, fontSize: 15.sp),
                                            maxLines: 5,
                                            minLines: 1,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Ecrivez ici...',
                                              contentPadding: EdgeInsets.all(0.009.sw),
                                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp),
                                            ),
                                          ),
                                        ),

                                        // SEND OTHER MESSAGES TYPE
                                        Visibility(
                                          visible: messageTextValue == '' ? true : false,
                                          child: IconButton(
                                            splashRadius: 0.06.sw,
                                            splashColor: kSecondColor,
                                            onPressed: () async {
                                              // Show All Messages Format Picker Here !
                                              dynamic fileselected = await showModalBottomSheet(
                                                isDismissible: true,
                                                enableDrag: true,
                                                isScrollControlled: true,
                                                context: context,
                                                backgroundColor: Colors.transparent,
                                                builder: ((context) => Modal(
                                                      maxHeightSize: 300,
                                                      minHeightSize: 300,
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
                                            color: widget.eventAttached != null ? kSecondColor : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    secondChild:
                                        // Voicenote bottom bar
                                        Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.transparent,
                                            child: IconButton(
                                              splashColor: Colors.transparent,
                                              onPressed: () async {
                                                // Delete recording here !
                                                recorderController.refresh();
                                                recorderController.stop();
                                                recorderController.reset();
                                                if (!mounted) return;
                                                setState(() {
                                                  showVoicenoteBottomBar = false;
                                                  voiceNotePath = '';
                                                });
                                                // Remove [Me] from IsRecordingVoiceNoteList
                                                FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
                                                  discussionId: widget.discussion?.discussionId ?? '',
                                                  type: 'isRecordingVoiceNote',
                                                  action: 'remove',
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Voicenote displayer
                                        Expanded(
                                          child: AudioWaveforms(
                                            size: const Size(double.infinity, 20),
                                            recorderController: recorderController,
                                            waveStyle: const WaveStyle(
                                                durationLinesColor: kSecondColor,
                                                showDurationLabel: true,
                                                showBottom: true,
                                                showTop: true,
                                                extendWaveform: false,
                                                showMiddleLine: false,
                                                durationStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                          ),
                                        ),

                                        const SizedBox(
                                          width: 10,
                                        ),

                                        // BUTTON: SEND VOICENOTE RECORDING OR REQUEST MIC PERMISSION
                                        FutureBuilder<bool>(
                                          future: Permission.microphone.isGranted,
                                          builder: (context, snapshot) {
                                            // Handle Error
                                            if (snapshot.hasError) {
                                              return Container();
                                            }

                                            if (snapshot.hasData) {
                                              // MIC PERMISSION GRANTED : true
                                              if (snapshot.data == true) {
                                                return CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: kSecondColor,
                                                  child: IconButton(
                                                    splashRadius: 22,
                                                    splashColor: kSecondColor,
                                                    onPressed: () async {
                                                      // Handle Scroll

                                                      // VIBRATE
                                                      await triggerVibration();

                                                      // Get last message : NB: last is 1st
                                                      if (listMsg != null && listMsg!.isNotEmpty) {
                                                        Message lastMessage = listMsg!.first;
                                                        scrollTo(listMsg!, lastMessage.messageId);
                                                      }

                                                      // Send Voicenote Message
                                                      //
                                                      if (await Permission.microphone.request().isGranted) {
                                                        //
                                                        if (!mounted) return;
                                                        setState(() {
                                                          showVoicenoteBottomBar = false;
                                                        });
                                                        // Remove [Me] from IsRecordingVoiceNoteList
                                                        FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
                                                          discussionId: widget.discussion?.discussionId ?? '',
                                                          type: 'isRecordingVoiceNote',
                                                          action: 'remove',
                                                        );
                                                        //
                                                        final path = await recorderController.stop();
                                                        //
                                                        if (path != null) {
                                                          debugPrint('Voicenote path: $path');
                                                          if (!mounted) return;
                                                          setState(() {
                                                            voiceNotePath = path;
                                                          });
                                                          detachEventOrStoryOrMessage();
                                                          //
                                                          await sendMessage(
                                                            context: context,
                                                            userReceiverId: widget.userReceiverId,
                                                            messageType: 'voicenote',
                                                            discussionId: widget.discussion?.discussionId ?? '',
                                                            eventId: widget.eventAttached != null
                                                                ? widget.eventAttached!.eventId
                                                                : '',
                                                            storyId: widget.storyAttached != null
                                                                ? widget.storyAttached!.storyId
                                                                : '',
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
                                                            messageToReplyId: messageToReply != null
                                                                ? messageToReply?.messageId ?? ''
                                                                : '',
                                                            messageToReplySenderId: messageToReply != null
                                                                ? messageToReply?.senderId ?? ''
                                                                : '',
                                                            messageToReplyType: messageToReply != null
                                                                ? messageToReply?.type ?? ''
                                                                : '',
                                                            messageToReplyCaption: messageToReply != null
                                                                ? messageToReply?.caption ?? ''
                                                                : '',
                                                            messageToReplyFilename: messageToReply != null
                                                                ? messageToReply?.filename ?? ''
                                                                : '',
                                                            messageToReplyData: messageToReply != null
                                                                ? messageToReply?.data ?? ''
                                                                : '',
                                                            messageToReplyThumbnail: messageToReply != null
                                                                ? messageToReply?.thumbnail ?? ''
                                                                : '',
                                                          );

                                                          //
                                                          await refreshDiscussion();
                                                        } else {
                                                          // ignore: use_build_context_synchronously
                                                          showSnackbar(context, 'Une erreur s\'est produite', null);
                                                        }
                                                      }
                                                    },
                                                    icon: Transform.translate(
                                                      offset: const Offset(1, -1),
                                                      child: Transform.rotate(
                                                        angle: -pi / 4,
                                                        child: const Icon(
                                                          Icons.send_rounded,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              // MIC PERMISSION DENIED : false
                                              else {
                                                return CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: kSecondColor,
                                                  child: IconButton(
                                                    splashRadius: 22,
                                                    splashColor: kSecondColor,
                                                    onPressed: () async {
                                                      // Ask for MIC PERMISSION
                                                      //
                                                      if (await Permission.microphone.request().isGranted) {
                                                        recorderController.refresh();
                                                        recorderController.stop();
                                                        recorderController.reset();
                                                        if (!mounted) return;
                                                        setState(() {
                                                          showVoicenoteBottomBar = false;
                                                          voiceNotePath = '';
                                                        });
                                                        // Add [Me] to IsRecordingVoiceNoteList
                                                        FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
                                                          discussionId: widget.discussion?.discussionId ?? '',
                                                          type: 'isRecordingVoiceNote',
                                                          action: 'add',
                                                        );
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.settings_backup_restore_outlined,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }

                                            //  Loading...
                                            return const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: CircularProgressIndicator(
                                                color: kSecondColor,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // [ACTION BUTTON] Send Message Button or Mic Button
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 100),
                            crossFadeState:
                                messageTextValue == '' ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                            firstChild: Visibility(
                              visible: showVoicenoteBottomBar == true ? false : true,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 7),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    // VIBRATE
                                    triggerVibration();

                                    // Show Voicenote bottom bar
                                    if (!mounted) return;
                                    setState(() {
                                      voiceNoteButtonScale = 0.8;
                                    });
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      if (!mounted) return;
                                      setState(() {
                                        voiceNoteButtonScale = 1;
                                        showVoicenoteBottomBar = true;
                                      });

                                      recorderController.record();
                                      // Add [Me] to IsRecordingVoiceNoteList
                                      FirestoreMethods.updateIsTypingOrIsRecordingVoiceNoteList(
                                        discussionId: widget.discussion?.discussionId ?? '',
                                        type: 'isRecordingVoiceNote',
                                        action: 'add',
                                      );
                                    });
                                  },
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 50),
                                    scale: voiceNoteButtonScale,
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
                            ),
                            secondChild: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () async {
                                // Handle Scroll

                                // VIBRATE
                                await triggerVibration();

                                // Get last message : NB: last is 1st
                                if (listMsg != null && listMsg!.isNotEmpty) {
                                  Message lastMessage = listMsg!.first;
                                  scrollTo(listMsg!, lastMessage.messageId);
                                }

                                // Send Text Message !
                                await sendMessage(
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
                                  messageToReplyThumbnail:
                                      messageToReply != null ? messageToReply?.thumbnail ?? '' : '',
                                );

                                messageTextController.clear();
                                if (!mounted) return;
                                setState(() {
                                  messageTextValue = '';
                                });
                                //
                                detachEventOrStoryOrMessage();
                                await refreshDiscussion();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 7),
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Show Emoji Keyboard
            emojiPickerOffstage(
              showEmojiKeyboard: showEmojiKeyboard,
              textController: messageTextController,
              onBackspacePressed: () {
                if (!mounted) return;
                setState(() {
                  if (messageTextValue != null && messageTextValue.isNotEmpty) {
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

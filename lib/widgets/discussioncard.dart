import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/discussion.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/buildWidgets.dart';

import '../models/message.dart';

class DiscussionCard extends StatefulWidget {
  final Discussion discussion;

  const DiscussionCard({
    super.key,
    required this.discussion,
  });

  @override
  State<DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<DiscussionCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  //
  bool isConnected = false;
  StreamSubscription? internetSubscription;

  @override
  void initState() {
    //
    super.initState();
    //
    internetSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasConnection = status == InternetConnectionStatus.connected;
      setState(() {
        isConnected = hasConnection;
      });
      debugPrint('isConnected: $isConnected');
    });
    //
    updateMessagesAsReadForThisDiscussion();
  }

  updateMessagesAsReadForThisDiscussion() async {
    // Set All Discussion'Messages as Read
    List<Message>? discussionMessages =
        await FirestoreMethods.getMessagesByDiscussionId(widget.discussion.discussionId).first;
    log('Mark all as read: ${widget.discussion.discussionId}');
    FirestoreMethods.updateMessagesAsRead(discussionMessages ?? []);
  }

  @override
  void dispose() {
    //
    super.dispose();
    //
    internetSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          SwipeablePageRoute(
              canOnlySwipeFromEdge: true,
              builder: (_) => InboxPage(
                    userReceiverId: widget.discussion.participants
                        .where((userId) =>
                            userId != FirebaseAuth.instance.currentUser!.uid && !(userId as String).contains('_'))
                        .toList()
                        .first,
                    discussion: widget.discussion,
                  )),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          // Trailing Avatar
          BuildUserProfilePicture(
              radius: 0.065.sw,
              userId: widget.discussion.participants
                  .where(
                      (userId) => userId != FirebaseAuth.instance.currentUser!.uid && !(userId as String).contains('_'))
                  .toList()
                  .first),

          // Username + Last Message
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              children: [
                // Username + Unread Messages Number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BuildUserNameToDisplay(
                      userId: widget.discussion.participants
                          .where((userId) =>
                              userId != FirebaseAuth.instance.currentUser!.uid && !(userId as String).contains('_'))
                          .toList()
                          .first,
                      hasShimmerLoader: true,
                    ),
                    BuildNumberOfUnreadMessages(discussion: widget.discussion),
                  ],
                ),
                const SizedBox(height: 3),

                // Last Message + Date OR IsTyping OR IsRecordingVoiceNote
                StreamBuilder(
                  stream: FirestoreMethods.getDiscussionById(widget.discussion.discussionId),
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
                              userId != FirebaseAuth.instance.currentUser!.uid && !(userId as String).contains('_'))
                          .toList();
                      debugPrint('otherParticipants: $otherParticipants');

                      // IF [ANOTHER USER IS] TYPING : only display if Internet Connection is active
                      if (isConnected && streamDiscussion.isTypingList.contains(otherParticipants.first)) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'is typing...',
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: kSecondColor),
                            ),
                          ],
                        );
                      }

                      // // IF [ANOTHER USER IS] RECORDING VOICE NOTE : only display if Internet Connection is active
                      if (isConnected && streamDiscussion.isRecordingVoiceNoteList.contains(otherParticipants.first)) {
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

                      return BuildLastMessageInDiscussionCard(discussion: widget.discussion);
                    }

                    // Loader
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade300,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade300,
                            ),
                            margin: const EdgeInsets.only(bottom: 2),
                            width: 70,
                            height: 10,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

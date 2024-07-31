import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/searchpage.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/functions.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import '../widgets/buildWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wesh/widgets/discussioncard.dart';
import '../models/discussion.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  RefreshController refreshController = RefreshController(initialRefresh: false);
  List<Discussion> allDiscussionsResult = [];
  bool isLoading = false;

  onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 200));
    FirestoreMethods.getCurrentUserDiscussions().listen((data) {
      if (mounted) {
        setState(() {
          allDiscussionsResult = data;
          isLoading = false;
        });
      }
      refreshController.refreshCompleted();
    }).onError((err) {
      refreshController.refreshFailed();
      debugPrint('An error occured while refreshing chats: $err');
    });
  }

  @override
  void initState() {
    //
    super.initState();
    //

    setState(() {
      isLoading = true;
    });
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  MorphingSliverAppBar(
                    scrolledUnderElevation: 0.0,
                    heroTag: 'discussionPageAppBar',
                    backgroundColor: Colors.white,
                    elevation: 0,
                    expandedHeight: 70.sp,
                    // pinned: true,
                    floating: true,
                    snap: true,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 15, bottom: 10),
                      title: Text(
                        'Chats',
                        style: TextStyle(color: Colors.black, fontSize: 17.sp),
                      ),
                    ),
                  )
                ],
            body: isLoading
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(50),
                      height: 100,
                      child: const CupertinoActivityIndicator(),
                    ),
                  )
                : () {
                    // DATA FOUND
                    if (allDiscussionsResult.isNotEmpty) {
                      return StreamBuilder<List<Map<String, Object>>>(
                          stream: FirestoreMethods.getMessagesFromListOfDiscussion(allDiscussionsResult),
                          builder: (context, snapshot) {
                            // Create Map<String, Object>
                            List<Map<String, Object>> listOfDiscussionAndMessages = snapshot.data ?? [];
                            List<Map<String, Object>> listOfDiscussionsWithLastMessageDateTime = [];

                            for (Discussion discussion in allDiscussionsResult) {
                              List<Message> discussionMessages = listOfDiscussionAndMessages
                                  .where((map) => map['discussionId'] == discussion.discussionId)
                                  .map((map) => (map['message'] as Message))
                                  .toList();

                              Message? lastMessage = getLastMessageOfDiscussion(discussionMessages);
                              if (lastMessage != null) {
                                listOfDiscussionsWithLastMessageDateTime
                                    .add({'lastMessageDateTime': lastMessage.createdAt, 'discussion': discussion});
                              }
                            }

                            return SmartRefresher(
                              enablePullDown: true,
                              enablePullUp: false,
                              header: const ClassicHeader(
                                refreshingIcon: CupertinoActivityIndicator(
                                  color: Colors.black,
                                  animating: true,
                                ),
                                releaseText: '',
                                idleText: '',
                                failedText: 'An error occured. Try again!',
                                refreshingText: '',
                                completeText: '',
                              ),
                              controller: refreshController,
                              onRefresh: onRefresh,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    GroupedListView<Map<String, Object>, DateTime>(
                                      useStickyGroupSeparators: true, // optional
                                      floatingHeader: true, // optional
                                      order: GroupedListOrder.DESC, // optional
                                      shrinkWrap: true,

                                      physics: const NeverScrollableScrollPhysics(),
                                      elements: listOfDiscussionsWithLastMessageDateTime,
                                      groupBy: (discussionMap) =>
                                          DateUtils.dateOnly(discussionMap['lastMessageDateTime'] as DateTime),
                                      itemComparator: (discussionMap1, discussionMap2) =>
                                          (discussionMap1['lastMessageDateTime'] as DateTime)
                                              .compareTo(discussionMap2['lastMessageDateTime'] as DateTime),
                                      groupSeparatorBuilder: (DateTime groupByValue) {
                                        return BuildGroupSeparatorWidget(groupByValue: groupByValue, simpleMode: true);
                                      },
                                      itemBuilder: (context, Map<String, Object> discussionMap) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child:
                                              DiscussionCard(discussion: (discussionMap['discussion'] as Discussion)),
                                        );
                                      },
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 40),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                    // NO DATA FOUND
                    else {
                      return Container(
                        padding: const EdgeInsets.all(50),
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              empty,
                              height: 100,
                              width: double.infinity,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'No chat found!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Redirect to Search Page => So User can search for someone to chat with
                                Navigator.push(
                                  context,
                                  SwipeablePageRoute(
                                    builder: (_) => const SearchPage(
                                      initialPageIndex: 1,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Text(
                                  'Find someone to chat with',
                                  style: TextStyle(fontSize: 14, color: kSecondColor),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  }()));
  }
}

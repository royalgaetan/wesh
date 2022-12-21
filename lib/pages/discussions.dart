import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/functions.dart';
import '../models/message.dart';
import '../services/sharedpreferences.service.dart';
import '../utils/constants.dart';
import '../widgets/buildWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wesh/widgets/discussioncard.dart';
import '../models/discussion.dart';
import '../providers/user.provider.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  void dispose() {
    //
    super.dispose();

    // Remove Current Active Page
    UserSimplePreferences.setCurrentActivePageHandler('');
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    // Set Current Active Page
    UserSimplePreferences.setCurrentActivePageHandler(context.widget.toStringShort());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Discussion>>(
          stream: Provider.of<UserProvider>(context).getCurrentUserDiscussions(),
          builder: (context, snapshot) {
            // Handle Errors
            if (snapshot.hasError) {
              debugPrint('error: ${snapshot.error}');
              return const Center(
                child: buildErrorWidget(onWhiteBackground: true),
              );
            }

            // Handle Data and perform search
            if (snapshot.hasData) {
              List<Discussion> result = snapshot.data!;

              return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        MorphingSliverAppBar(
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
                              'Messages',
                              style: TextStyle(color: Colors.black, fontSize: 17.sp),
                            ),
                          ),
                        )
                      ],
                  body: () {
                    // DATA FOUND
                    if (result.isNotEmpty) {
                      return StreamBuilder<List<Map<String, Object>>>(
                          stream: FirestoreMethods.getMessagesFromListOfDiscussion(result),
                          builder: (context, snapshot) {
                            // Create Map<String, Object>
                            List<Map<String, Object>> listOfDiscussionAndMessages = snapshot.data ?? [];
                            List<Map<String, Object>> listOfDiscussionsWithLastMessageDateTime = [];

                            for (Discussion discussion in result) {
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

                            return SingleChildScrollView(
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
                                      return buildGroupSeparatorWidget(groupByValue: groupByValue, simpleMode: true);
                                    },
                                    itemBuilder: (context, Map<String, Object> discussionMap) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: DiscussionCard(discussion: (discussionMap['discussion'] as Discussion)),
                                      );
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 40),
                                  )
                                ],
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
                              height: 150,
                              width: double.infinity,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Aucune discussion trouvée !',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }());
            }

            // Display Loading while waiting
            return Center(
              child: Container(
                padding: const EdgeInsets.all(50),
                height: 100,
                child: const CupertinoActivityIndicator(),
              ),
            );
          }),
    );
  }
}

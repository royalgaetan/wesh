// ignore: file_names
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/widgets/story_all_viewers_modal.dart';
import '../../models/stories_handler.dart';
import '../../models/story.dart';
import '../../services/firestore.methods.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/modal.dart';
import '../../widgets/story_add_to_forever_modal.dart';
import '../../widgets/story_more_options_modal.dart';

class StoriesViewer extends StatefulWidget {
  final int indexInStoriesHandlerList;
  final List<StoriesHandler> storiesHandlerList;
  const StoriesViewer({Key? key, required this.indexInStoriesHandlerList, required this.storiesHandlerList})
      : super(key: key);

  @override
  State<StoriesViewer> createState() => _StoriesViewerState();
}

class _StoriesViewerState extends State<StoriesViewer> {
  final storyController = StoryController();
  late PageController controller;

  //
  List pageViewItem = [];

  @override
  void initState() {
    super.initState();
    //
    setSuitableStatusBarColor(Colors.black87);

    //
    controller = PageController(initialPage: widget.indexInStoriesHandlerList);

    // build All Stories Pages
    pageViewItem = widget.storiesHandlerList
        .map((storiesHandler) {
          if (storiesHandler.stories.isNotEmpty) {
            return StoriesPage(
              storiesHandler: storiesHandler,
              storyController: storyController,
              pageController: controller,
            );
          }
        })
        .toList()
        .where((element) => element != null)
        .toList();
  }

  @override
  void dispose() {
    //
    super.dispose();
    //
    setSuitableStatusBarColor(Colors.white);
    //
    controller.dispose();
    storyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () {
        //
        setSuitableStatusBarColor(Colors.white);
        //
        Navigator.of(context).pop();
        storyController.pause();
        storyController.dispose();
      },
      // Note that scrollable widget inside DismissiblePage might limit the functionality
      // If scroll direction matches DismissiblePage direction
      direction: DismissiblePageDismissDirection.down,
      backgroundColor: Colors.transparent,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black.withOpacity(0),
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: PageView.builder(
              itemCount: pageViewItem.length,
              scrollDirection: Axis.horizontal,
              controller: controller,
              itemBuilder: (context, position) {
                return pageViewItem[position];
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Display Story MAIN_VIEW
class StoriesPage extends StatefulWidget {
  const StoriesPage({
    Key? key,
    required this.storiesHandler,
    required this.storyController,
    required this.pageController,
  }) : super(key: key);

  final StoriesHandler storiesHandler;
  final StoryController storyController;
  final PageController pageController;

  @override
  State<StoriesPage> createState() => _StoriesPage();
}

class _StoriesPage extends State<StoriesPage> with WidgetsBindingObserver {
  ValueNotifier<int> currentStoryDisplayed = ValueNotifier<int>(0);
  List<StoryItem> storiesItemList = [];
  bool isStoryHeaderAndFooterVisible = true;
  List<Story> storiesListSeenByCurrentUser = [];
  Story? lastStoryUnseen;
  int? skipUntilIndex;
  //

  ScreenshotController storySreenshotController = ScreenshotController();

  @override
  void dispose() {
    //
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    widget.storyController.pause();
  }

  @override
  void initState() {
    //
    super.initState();

    // Listen to storyController : Go to previous story if necessary
    widget.storyController.playbackNotifier.stream.listen(
      (event) {
        if (event.name == 'previous' && currentStoryDisplayed.value == 0) {
          widget.pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
        }
      },
    );

    storiesItemList = widget.storiesHandler.stories
        .map((story) => getStoryItemByType(story, widget.storyController))
        .toList()
        .reversed
        .toList();

    // Get the First Story seen by currentUser
    List<Story> storiesListSeenByCurrentUser = widget.storiesHandler.stories
        .where((story) => story.viewers.contains(FirebaseAuth.instance.currentUser!.uid))
        .toList()
        .reversed
        .toList();

    // Jump to the first story unseen
    if (storiesListSeenByCurrentUser.isNotEmpty) {
      lastStoryUnseen = storiesListSeenByCurrentUser.last;
      log('lastStoryUnseen: ${lastStoryUnseen?.content}');
      //
      for (int i = 0; i < storiesListSeenByCurrentUser.length; i++) {
        //

        if (storiesListSeenByCurrentUser[i] != lastStoryUnseen) {
          setState(() {
            widget.storyController.next();
            skipUntilIndex = i;
          });
          log('Skip story : ${storiesListSeenByCurrentUser[i].content}');
          log('skipUntilIndex : $i');
        }
      }
    }

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.storyController.play();
        debugPrint("app in resumed");
        break;
      case AppLifecycleState.inactive:
        widget.storyController.pause();
        debugPrint("app in inactive");
        break;
      case AppLifecycleState.paused:
        widget.storyController.pause();
        debugPrint("app in paused");
        break;
      case AppLifecycleState.detached:
        widget.storyController.dispose();
        debugPrint("app in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: storySreenshotController,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          // Story view
          GestureDetector(
            onTapDown: (details) {
              setState(() {
                isStoryHeaderAndFooterVisible = false;
              });
            },
            onTapCancel: () {
              setState(() {
                isStoryHeaderAndFooterVisible = true;
              });
            },
            child: StoryView(
              // onVerticalSwipeComplete: (direction) {
              //   if (direction == Direction.up) {
              //     widget.storyController.pause();
              //     widget.storyController.dispose();

              //   }
              // },
              onStoryShow: (storyItem) {
                //
                currentStoryDisplayed.value = storiesItemList.indexOf(storyItem);

                // UPDATE : Add currentUserId to Story Viewers
                FirestoreMethods.updateStoryViewersList(context, FirebaseAuth.instance.currentUser!.uid,
                    widget.storiesHandler.stories[currentStoryDisplayed.value].storyId);

                // Conditions to Skip story
                if (skipUntilIndex != null && currentStoryDisplayed.value <= skipUntilIndex!) {
                  widget.storyController.next();
                  log('Skip story : ${currentStoryDisplayed.value}');
                } else {
                  skipUntilIndex = null;
                }
              },

              storyItems: storiesItemList,
              controller: widget.storyController,
              repeat: false,
              onComplete: () {
                // Jump to next Forever
                widget.pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
              },
              // To disable vertical swipe gestures, ignore this parameter.
              // Preferrably for inline story view.
            ),
          ),

          // Other story options : Header, Add to Forevers, Answer to story, Take a Screenchot, etc.
          ValueListenableBuilder(
            valueListenable: currentStoryDisplayed,
            builder: (context, value, child) {
              StoriesHandler newStoryHandler = StoriesHandler(
                avatarPath: widget.storiesHandler.avatarPath,
                lastStoryDateTime: widget.storiesHandler.lastStoryDateTime,
                origin: widget.storiesHandler.origin,
                posterId: widget.storiesHandler.posterId,
                title: widget.storiesHandler.title,
                stories: widget.storiesHandler.stories.toList().reversed.toList(),
              );

              return buildStoryViewerHeaderAndFooter(
                isWidgetVisible: isStoryHeaderAndFooterVisible,
                storiesHandler: newStoryHandler,
                currentStoryDisplayed: currentStoryDisplayed,
                storyController: widget.storyController,
                storySreenshotController: storySreenshotController,
              );
            },
          )
        ],
      ),
    );
  }
}

// BUILD STORY VIEWER HEADER AND FOOTER
class buildStoryViewerHeaderAndFooter extends StatelessWidget {
  final bool isWidgetVisible;
  final StoriesHandler storiesHandler;
  final ValueNotifier<int> currentStoryDisplayed;

  final StoryController storyController;
  final ScreenshotController storySreenshotController;

  const buildStoryViewerHeaderAndFooter({
    super.key,
    required this.storiesHandler,
    required this.currentStoryDisplayed,
    required this.storySreenshotController,
    required this.storyController,
    required this.isWidgetVisible,
  });

  gotToProfilePage({required BuildContext context, required String uid}) async {
    storyController.pause();
    await Navigator.push(
        context,
        SwipeablePageRoute(
          builder: (context) => ProfilePage(uid: uid, showBackButton: true),
        ));

    storyController.play();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: isWidgetVisible ? 1 : 0,
      child: Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17),
              child: Row(
                children: [
                  //
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Hero avatar
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: GestureDetector(
                              onTap: () {
                                if (storiesHandler.origin == 'userStories') {
                                  gotToProfilePage(context: context, uid: storiesHandler.posterId);
                                }
                              },
                              child: storiesHandler.origin == 'foreverStories'
                                  ? buildForeverCover(foreverId: storiesHandler.posterId)
                                  : buildCachedNetworkImage(
                                      url: storiesHandler.avatarPath,
                                      radius: 0.05.sw,
                                      backgroundColor: kGreyColor,
                                      paddingOfProgressIndicator: 10,
                                    )),
                        ),

                        const SizedBox(
                          width: 10,
                        ),
                        // StoryPoster name  && Story info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // 1st ROW : StoryPoster name  + Story time
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      storiesHandler.posterId == FirebaseAuth.instance.currentUser!.uid
                                          ? 'Moi'
                                          : storiesHandler.title,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    getTimeAgoShortForm(storiesHandler.stories[currentStoryDisplayed.value].createdAt),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(.6),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              // 2nd ROW : Event Attached
                              buildAttachedEventRow(
                                storyController: storyController,
                                eventId: storiesHandler.stories[currentStoryDisplayed.value].eventId,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        // More options
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: IconButton(
                            splashRadius: 0.06.sw,
                            onPressed: () async {
                              storyController.pause();

                              //  show more story options
                              bool? result = await showModalBottomSheet(
                                enableDrag: true,
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: ((context) => Scaffold(
                                      backgroundColor: Colors.transparent,
                                      body: Modal(
                                        minHeightSize: 200,
                                        maxHeightSize: 200,
                                        child: StoryMoreOptionsModal(
                                          story: storiesHandler.stories[currentStoryDisplayed.value],
                                          storySreenshotController: storySreenshotController,
                                          isSuppressionBtnAllowed:
                                              storiesHandler.origin == 'foreverStories' ? false : true,
                                        ),
                                      ),
                                    )),
                              );

                              if (result == null) {
                                storyController.play();
                              }
                            },
                            icon: const Icon(Icons.more_vert_outlined, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // FOOTER
            Column(
              children: [
                // CAPTION
                Visibility(
                  visible: storiesHandler.stories[currentStoryDisplayed.value].caption.isNotEmpty ? true : false,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.5),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              storiesHandler.stories[currentStoryDisplayed.value].caption,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 13.sp),
                            )),
                      ],
                    ),
                  ),
                ),

                //ACTIONS BUTTONS

                storiesHandler.origin == 'singleStory' || storiesHandler.origin == 'foreverStories'
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // LEFT BUTTONS

                            // ChipButton: Show stories viewers modal
                            Visibility(
                              visible: storiesHandler.posterId == FirebaseAuth.instance.currentUser?.uid,
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
                                child: ActionChip(
                                    padding: const EdgeInsets.all(4),
                                    onPressed: () async {
                                      storyController.pause();
                                      // Show Modal : Story Viewers
                                      bool? result = await showModalBottomSheet(
                                        enableDrag: true,
                                        isScrollControlled: true,
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: ((context) => Scaffold(
                                              backgroundColor: Colors.transparent,
                                              body: Modal(
                                                minHeightSize: MediaQuery.of(context).size.height / 2,
                                                maxHeightSize: MediaQuery.of(context).size.height,
                                                child: StoryAllViewerModal(
                                                    story: storiesHandler.stories[currentStoryDisplayed.value]),
                                              ),
                                            )),
                                      );

                                      if (result == null) {
                                        storyController.play();
                                      }
                                    },
                                    label: FittedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          '${storiesHandler.stories[currentStoryDisplayed.value].viewers.length} ${getSatTheEnd(storiesHandler.stories[currentStoryDisplayed.value].viewers.length, 'vue')}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13.sp),
                                        ),
                                      ),
                                    ),
                                    backgroundColor: Colors.white),
                              ),
                            ),

                            //
                            const Spacer(),
                            // RIGHT BUTTONS
                            // Add to Forevers
                            Visibility(
                              visible: storiesHandler.posterId == FirebaseAuth.instance.currentUser!.uid,
                              child: Container(
                                alignment: Alignment.center,
                                constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
                                child: IconButton(
                                  splashRadius: 0.06.sw,
                                  onPressed: () async {
                                    storyController.pause();

                                    // Show add to Forever Modal
                                    await showModalBottomSheet(
                                      enableDrag: true,
                                      isScrollControlled: true,
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: ((context) => Scaffold(
                                            backgroundColor: Colors.transparent,
                                            body: Modal(
                                              minHeightSize: MediaQuery.of(context).size.height / 1.5,
                                              maxHeightSize: MediaQuery.of(context).size.height,
                                              child: AddtoForeverModal(
                                                story: storiesHandler.stories[currentStoryDisplayed.value],
                                              ),
                                            ),
                                          )),
                                    );

                                    storyController.play();
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.circleNotch,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ),

                            // Answer to the story
                            Visibility(
                              visible: storiesHandler.posterId != FirebaseAuth.instance.currentUser!.uid,
                              child: InkWell(
                                onTap: () async {
                                  storyController.pause();

                                  // Redirect to InboxPage +StoryAttached

                                  await Navigator.push(
                                      context,
                                      SwipeablePageRoute(
                                        builder: (context) => InboxPage(
                                            userReceiverId: storiesHandler.posterId,
                                            storyAttached: storiesHandler.stories[currentStoryDisplayed.value]),
                                      ));

                                  //
                                  storyController.play();
                                },
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 40, maxHeight: 40),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      // Label
                                      Text(
                                        'Répondre',
                                        style: TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
                                      ),

                                      // Spacer
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      // Icon
                                      Icon(
                                        Icons.arrow_forward_ios_sharp,
                                        color: Colors.white,
                                        size: 12.sp,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                            //
                          ],
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

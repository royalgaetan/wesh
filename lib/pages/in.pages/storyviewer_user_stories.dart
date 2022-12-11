import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/providers/user.provider.dart';
import 'package:wesh/widgets/story_all_viewers_modal.dart';
import '../../models/story.dart';
import '../../models/user.dart' as UserModel;
import '../../services/firestore.methods.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/modal.dart';
import '../../widgets/story_add_to_forever_modal.dart';
import '../../widgets/story_more_options_modal.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StoryPage extends StatefulWidget {
  final UserModel.User user;
  StoryPage({Key? key, required this.user}) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final storyController = StoryController();
  PageController controller = PageController();
  static dynamic currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    currentPageValue = 0.0;
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });

    // Get Current User StoryItem
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    storyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List pageViewItem = [
      // Page 1
      StoryPageView(user: widget.user, storyController: storyController),

      // Page 2
      //
      //
      // TODO
    ];

    return DismissiblePage(
      onDismissed: () {
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
          child: PageView.builder(
            itemCount: pageViewItem.length,
            scrollDirection: Axis.horizontal,
            controller: controller,
            itemBuilder: (context, position) {
              return Transform(
                transform: Matrix4.identity()..rotateX(currentPageValue - position),
                child: pageViewItem[position],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Display Story MAIN_VIEW
class StoryPageView extends StatefulWidget {
  const StoryPageView({
    Key? key,
    required this.user,
    required this.storyController,
  }) : super(key: key);

  final UserModel.User user;
  final StoryController storyController;

  @override
  State<StoryPageView> createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> with WidgetsBindingObserver {
  ValueNotifier<int> currentStoryDisplayed = ValueNotifier<int>(0);
  late ValueNotifier<bool> isAllowedToJump;
  ValueNotifier<List<StoryItem?>> storiesItemList = ValueNotifier<List<StoryItem?>>([]);

  ScreenshotController storySreenshotController = ScreenshotController();
  ValueNotifier<bool> isStoryHeaderAndFooterVisible = ValueNotifier<bool>(true);

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Permission to jump to the next story
    isAllowedToJump = ValueNotifier<bool>(true);
    debugPrint('init stories page...');

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
    return StreamBuilder(
      stream: Provider.of<UserProvider>(context).getUserStories(widget.user.id),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<Story> allStories = [];

          // Display All Stories
          for (Story storySelected in (snapshot.data as List<Story>)) {
            // Check Story validity : isStoryExpired
            if (storySelected.endAt.isAfter(DateTime.now())) {
              StoryItem storyWidgetToAdd = getStoryItemByType(storySelected, widget.storyController);

              allStories.add(storySelected);
            }
          }

          // Sort Stories
          allStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          storiesItemList.value = allStories.map((story) => getStoryItemByType(story, widget.storyController)).toList();

          // Display All StoryItems

          // Get the First Story seen by currentUser
          List<Story> storiesListSeenByCurrentUser =
              allStories.where((story) => story.viewers.contains(FirebaseAuth.instance.currentUser!.uid)).toList();

          //
          storiesListSeenByCurrentUser.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          debugPrint('allStories: ${allStories.map((e) => e.storyId)}');
          debugPrint('storiesListSeenByCurrentUser: ${storiesListSeenByCurrentUser.map((e) => e.storyId)}');

          //
          return Screenshot(
            controller: storySreenshotController,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                // Story view
                GestureDetector(
                  onTapDown: (details) {
                    isStoryHeaderAndFooterVisible.value = false;
                    debugPrint('Story viewer state: onTapDown');
                  },
                  onTapCancel: () {
                    isStoryHeaderAndFooterVisible.value = true;
                    debugPrint('Story viewer state: onTapCancel');
                  },
                  child: ValueListenableBuilder(
                      valueListenable: storiesItemList,
                      builder: (context, value, child) {
                        return StoryView(
                          // onVerticalSwipeComplete: (direction) {
                          //   if (direction == Direction.up) {
                          //     widget.storyController.pause();
                          //     widget.storyController.dispose();

                          //   }
                          // },
                          onStoryShow: (StoryItem) {
                            //
                            currentStoryDisplayed.value = storiesItemList.value.indexOf(StoryItem);
                            // UPDATE : Add currentUserId to Story Viewers
                            FirestoreMethods().updateStoryViewersList(context, FirebaseAuth.instance.currentUser!.uid,
                                allStories[currentStoryDisplayed.value].storyId);

                            debugPrint('INITIAL VALUE of Skip story : ${isAllowedToJump.value}');
                            // Jump to Next /if the currentUser has already seen this story
                            List storiesListSeenByCurrentUserWithOnlyStoriesId =
                                storiesListSeenByCurrentUser.map((e) => e.storyId).toList();
                            String storyIdToCheck = allStories[currentStoryDisplayed.value].storyId;

                            // Conditions to Skip story
                            if (isAllowedToJump.value &&
                                //
                                storiesListSeenByCurrentUserWithOnlyStoriesId.indexOf(storyIdToCheck) <
                                    storiesListSeenByCurrentUserWithOnlyStoriesId.length - 1 &&
                                //
                                storiesListSeenByCurrentUser.contains(allStories[currentStoryDisplayed.value])) {
                              widget.storyController.next();
                              debugPrint('Skip story : ${isAllowedToJump.value}');
                            }

                            // Else :
                            else {
                              isAllowedToJump.value = false;
                              debugPrint('Don\'t skip story : ${isAllowedToJump.value}');
                            }
                          },

                          storyItems: storiesItemList.value,
                          controller: widget.storyController,
                          repeat: false,
                          onComplete: () {},
                          // To disable vertical swipe gestures, ignore this parameter.
                          // Preferrably for inline story view.
                        );
                      }),
                ),

                // Other story options : Header, Add to Forevers, Answer to story, Take a Screenchot, etc.
                ValueListenableBuilder(
                  valueListenable: isStoryHeaderAndFooterVisible,
                  builder: (BuildContext context, value, Widget? child) {
                    return AnimatedSwitcher(
                      switchInCurve: Curves.ease,
                      switchOutCurve: Curves.ease,
                      duration: const Duration(milliseconds: 300),
                      child: isStoryHeaderAndFooterVisible.value
                          ? buildStoryViewerHeaderAndFooter(
                              allStories: allStories,
                              currentStoryDisplayed: currentStoryDisplayed,
                              user: widget.user,
                              uid: widget.user.id,
                              type: 'userStories',
                              isAllowedToJump: isAllowedToJump,
                              storiesItemList: storiesItemList,
                              storyController: widget.storyController,
                              storySreenshotController: storySreenshotController,
                            )
                          : Container(),
                    );
                  },
                )
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          // Handle error
          debugPrint('error: ${snapshot.error}');
          return const Center(
            child: Text('Une erreur s\'est produite', style: TextStyle(color: Colors.white)),
          );
        }

        // Display CircularProgressIndicator
        return const Center(
          child: CupertinoActivityIndicator(color: Colors.white60, radius: 15),
        );
      },
    );
  }
}

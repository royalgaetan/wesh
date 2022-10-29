import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:screenshot/screenshot.dart';
import '../../utils/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/providers/user.provider.dart';
import '../../models/forever.dart';
import '../../models/story.dart';
import '../../services/firestore.methods.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';

class ForeverStoriesPageViewer extends StatefulWidget {
  final List<Forever> foreversList;
  final int initialForeverIndex;

  const ForeverStoriesPageViewer(
      {Key? key, required this.foreversList, required this.initialForeverIndex})
      : super(key: key);

  @override
  State<ForeverStoriesPageViewer> createState() =>
      _ForeverStoriesPageViewerState();
}

class _ForeverStoriesPageViewerState extends State<ForeverStoriesPageViewer> {
  final storyController = StoryController();
  PageController controller = PageController();
  static dynamic currentPageValue = 0.0;
  List pageViewItem = [];

  @override
  void initState() {
    super.initState();
    currentPageValue = 0.0;

    controller = PageController(initialPage: widget.initialForeverIndex);

    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });

    // build All Forever Pages
    pageViewItem = widget.foreversList
        .map(
          (forever) => ForeversForeverStoriesPageViewerView(
            forever: forever,
            storyController: storyController,
            pageController: controller,
          ),
        )
        .toList();
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
        backgroundColor: Colors.black,
        body: SafeArea(
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
    );
  }
}

// Display Forever Stories MAIN_VIEW
class ForeversForeverStoriesPageViewerView extends StatefulWidget {
  const ForeversForeverStoriesPageViewerView({
    Key? key,
    required this.forever,
    required this.storyController,
    required this.pageController,
  }) : super(key: key);

  final Forever forever;
  final StoryController storyController;
  final PageController pageController;

  @override
  State<ForeversForeverStoriesPageViewerView> createState() =>
      _ForeversForeverStoriesPageViewerViewState();
}

class _ForeversForeverStoriesPageViewerViewState
    extends State<ForeversForeverStoriesPageViewerView>
    with WidgetsBindingObserver {
  ValueNotifier<int> currentStoryDisplayed = ValueNotifier<int>(0);
  late ValueNotifier<bool> isAllowedToJump;
  ValueNotifier<List<StoryItem?>> storiesItemList =
      ValueNotifier<List<StoryItem?>>([]);

  ScreenshotController storySreenshotController = ScreenshotController();
  ValueNotifier<bool> isStoryHeaderAndFooterVisible = ValueNotifier<bool>(true);

  gotToProfilePage({required BuildContext context, required String uid}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(uid: uid, showBackButton: true),
        ));
  }

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
    debugPrint('init forever stories page...');

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
    return FutureBuilder(
      future:
          Provider.of<UserProvider>(context).getFovererStories(widget.forever),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<Story> allStories = [];

          // Display All Stories
          for (Story storySelected in (snapshot.data as List<Story>)) {
            StoryItem storyWidgetToAdd =
                getStoryItemByType(storySelected, widget.storyController);

            allStories.add(storySelected);
          }

          // Sort Stories
          allStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          storiesItemList.value = allStories
              .map((story) => getStoryItemByType(story, widget.storyController))
              .toList();

          // Display All StoryItems

          // Get the First Story seen by currentUser
          List<Story> storiesListSeenByCurrentUser = allStories
              .where((story) => story.viewers
                  .contains(FirebaseAuth.instance.currentUser!.uid))
              .toList();

          //
          storiesListSeenByCurrentUser
              .sort((a, b) => a.createdAt.compareTo(b.createdAt));
          debugPrint('allStories: ${allStories.map((e) => e.storyId)}');
          debugPrint(
              'storiesListSeenByCurrentUser: ${storiesListSeenByCurrentUser.map((e) => e.storyId)}');

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
                          onComplete: () {
                            // Jump to next Forever
                            widget.pageController.nextPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn);
                          },
                          onStoryShow: (StoryItem) {
                            //
                            currentStoryDisplayed.value =
                                storiesItemList.value.indexOf(StoryItem);
                            // UPDATE : Add currentUserId to Story Viewers
                            FirestoreMethods().updateStoryViewersList(
                                context,
                                FirebaseAuth.instance.currentUser!.uid,
                                allStories[currentStoryDisplayed.value]
                                    .storyId);

                            debugPrint(
                                'INITIAL VALUE of Skip story : ${isAllowedToJump.value}');
                            // Jump to Next /if the currentUser has already seen this story
                            List storiesListSeenByCurrentUserWithOnlyStoriesId =
                                storiesListSeenByCurrentUser
                                    .map((e) => e.storyId)
                                    .toList();
                            String storyIdToCheck =
                                allStories[currentStoryDisplayed.value].storyId;

                            // Conditions to Skip story
                            if (isAllowedToJump.value &&
                                //
                                storiesListSeenByCurrentUserWithOnlyStoriesId
                                        .indexOf(storyIdToCheck) <
                                    storiesListSeenByCurrentUserWithOnlyStoriesId
                                            .length -
                                        1 &&
                                //
                                storiesListSeenByCurrentUser.contains(
                                    allStories[currentStoryDisplayed.value])) {
                              widget.storyController.next();
                              debugPrint(
                                  'Skip story : ${isAllowedToJump.value}');
                            }

                            // Else :
                            else {
                              isAllowedToJump.value = false;
                              debugPrint(
                                  'Don\'t skip story : ${isAllowedToJump.value}');
                            }
                          },

                          storyItems: storiesItemList.value,
                          controller: widget.storyController,
                          repeat: false,

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
                              uid: widget.forever.uid,
                              forever: widget.forever,
                              type: 'foreverStories',
                              isAllowedToJump: isAllowedToJump,
                              storiesItemList: storiesItemList,
                              storyController: widget.storyController,
                              storySreenshotController:
                                  storySreenshotController,
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
            child: Text('Une erreur s\'est produite',
                style: TextStyle(color: Colors.white)),
          );
        }

        // Display CircularProgressIndicator
        return Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Loader: Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: kGreyColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Container(
                          height: 10,
                          width: 200,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),

                // Loader: Body
                Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: double.infinity,
                    color: Colors.white60),

                // Loader: Footer
                Container(
                  height: 40,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

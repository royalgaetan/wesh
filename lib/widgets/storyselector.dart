import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/stories_handler.dart';
import 'package:wesh/models/story.dart';
import 'package:wesh/pages/in.pages/storiesViewer.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/functions.dart';
import '../models/user.dart' as usermodel;
import '../utils/constants.dart';
import 'buildWidgets.dart';

class StorySelector extends StatefulWidget {
  final usermodel.User userPoster;
  final List<String>? storiesIdsToExclude;
  const StorySelector({super.key, required this.userPoster, this.storiesIdsToExclude});

  @override
  State<StorySelector> createState() => _StorySelectorState();
}

class _StorySelectorState extends State<StorySelector> {
  List<Story> selectedStories = [];
  ValueNotifier<List<String>> storiesIdsSelected = ValueNotifier<List<String>>([]);

  List<Story> storiesItemList = [];

  void handleCTAButton() {
    // VIBRATE
    triggerVibration();

    if (selectedStories.isNotEmpty) {
      // Pop the page and return the selected stories
      Navigator.pop(context, selectedStories);
    } else {
      // Title error handler
      showSnackbar(context, 'Please select at least one story before continuing', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'storySelectorPageAppBar',
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 0.06.sw,
          onPressed: () {
            Navigator.pop(context, null);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Select Stories',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          // CTA Button Create or Edit Forever
          GestureDetector(
            onTap: () {
              if (storiesIdsSelected.value.isNotEmpty) {
                handleCTAButton();
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 15, 10),
              child: ValueListenableBuilder(
                  valueListenable: storiesIdsSelected,
                  builder: (context, value, child) {
                    return Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: storiesIdsSelected.value.isEmpty ? kSecondColor.withOpacity(.6) : kSecondColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
        child: StreamBuilder(
          stream: FirestoreMethods.getUserAllStories(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<Story> allStories = (snapshot.data as List<Story>);

              // of No Stories found : 0
              if (allStories.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(30),
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        height: 100,
                        empty,
                        width: double.infinity,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'No story found!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // if Stories found : > 0
              else {
                // Sort Stories by creation date
                allStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                // Display All Stories
                for (Story storySelected in allStories) {
                  // DO NOT ADD STORY IF EXCLUDED!
                  if (widget.storiesIdsToExclude != null &&
                      widget.storiesIdsToExclude!.isNotEmpty &&
                      widget.storiesIdsToExclude!.contains(storySelected.storyId)) {
                    storiesItemList.removeWhere((s) => s.storyId == storySelected.storyId);
                  }

                  // ELSE: ADD IT
                  else {
                    storiesItemList.add(storySelected);
                  }
                }

                return (() {
                  // If after removing excluded stories: nothing is left: then display empty handler
                  if (storiesItemList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(30),
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            height: 100,
                            empty,
                            width: double.infinity,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'All stories have already been selected\nThere\'s nothing left to choose',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Else display: GRID of remaining Stories
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 4 / 5,
                    ),
                    itemCount: storiesItemList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Add Story to Selected StoriesList

                          // Check if Story is already selected: if yes, remove it
                          List<String> storiesListIDsOnly = selectedStories.map((s) => s.storyId).toList();

                          if (storiesListIDsOnly.contains(storiesItemList[index].storyId)) {
                            selectedStories.removeWhere((story) => story.storyId == storiesItemList[index].storyId);
                            // Update also Value Notifier
                            storiesIdsSelected.value = List.from(storiesIdsSelected.value)
                              ..remove(storiesItemList[index].storyId);
                          }
                          // Else: Add it
                          else {
                            selectedStories.add(storiesItemList[index]);
                            // Update also Value Notifier
                            storiesIdsSelected.value = List.from(storiesIdsSelected.value)
                              ..add(storiesItemList[index].storyId);
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            // MAIN CONTENT
                            BuildStoryGridPreview(
                              footer: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [],
                              ),
                              story: storiesItemList[index],
                            ),

                            // SELECTED WRAPPER
                            ValueListenableBuilder(
                              valueListenable: storiesIdsSelected,
                              builder: (context, value, child) {
                                return storiesIdsSelected.value.contains(storiesItemList[index].storyId)
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54.withOpacity(.4),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        height: double.infinity,
                                        width: double.infinity,
                                        child: Center(
                                          child: CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.white,
                                            child: Text(
                                              '${storiesIdsSelected.value.indexOf(storiesItemList[index].storyId) + 1}',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            ),

                            // PREVIEW STORY BTN
                            IconButton(
                              splashRadius: 0.04.sw,
                              onPressed: () async {
                                // Build Story Handler
                                StoriesHandler storiesHandler = StoriesHandler(
                                  avatarPath: widget.userPoster.profilePicture,
                                  posterId: widget.userPoster.id,
                                  title: widget.userPoster.name,
                                  origin: 'singleStory',
                                  lastStoryDateTime: storiesItemList[index].createdAt,
                                  stories: [storiesItemList[index]],
                                );
                                // Preview Story
                                if (!mounted) return;
                                context.pushTransparentRoute(StoriesViewer(
                                  indexInStoriesHandlerList: 0,
                                  storiesHandlerList: [storiesHandler],
                                ));
                              },
                              icon: Icon(
                                CupertinoIcons.eye,
                                color: Colors.white,
                                size: 15.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }());
              }
            }

            if (snapshot.hasError) {
              // Handle error
              debugPrint('error: ${snapshot.error}');
              return const Center(
                child: BuildErrorWidget(onWhiteBackground: true),
              );
            }

            // Display CircularProgressIndicator
            return Center(
              child: Container(
                padding: const EdgeInsets.all(50),
                height: 100,
                child: const RepaintBoundary(child: CupertinoActivityIndicator()),
              ),
            );
          },
        ),
      ),
    );
  }
}

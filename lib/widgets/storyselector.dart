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
import '../models/user.dart' as usermodel;
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class StorySelector extends StatefulWidget {
  final usermodel.User userPoster;
  const StorySelector({super.key, required this.userPoster});

  @override
  State<StorySelector> createState() => _StorySelectorState();
}

class _StorySelectorState extends State<StorySelector> {
  Story? selectedStory;
  ValueNotifier<int> storySelectedIndex = ValueNotifier<int>(-1);

  List<Story> storiesItemList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
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
          'Selectionner une story',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
        child: StreamBuilder(
          stream: FirestoreMethods.getUserAllStories(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<Story> allStories = (snapshot.data as List<Story>);

              // No Stories found : 0
              if (allStories.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(30),
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        height: 150,
                        empty,
                        width: double.infinity,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Aucune story retrouvée !',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Stories found : > 0
              else {
                allStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                // Display All Stories
                for (Story storySelected in allStories) {
                  storiesItemList.add(storySelected);
                }

                // GRID : display stories in grid
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
                        // Select Story
                        storySelectedIndex.value = index;
                        selectedStory = storiesItemList[index];
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          // MAIN CONTENT
                          buildStoryGridPreview(
                              footer: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [],
                              ),
                              story: storiesItemList[index]),

                          // SELECTED WRAPPER
                          ValueListenableBuilder(
                            valueListenable: storySelectedIndex,
                            builder: (context, value, child) {
                              return value == index
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54.withOpacity(.4),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      height: double.infinity,
                                      width: double.infinity,
                                      child: Icon(
                                        Icons.done,
                                        color: kSecondColor,
                                        size: 40.sp,
                                      ),
                                    )
                                  : Container();
                            },
                          ),

                          // PREVIEW STORY BTN

                          IconButton(
                            splashRadius: 0.06.sw,
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
                              // ignore: use_build_context_synchronously
                              context.pushTransparentRoute(StoriesViewer(
                                indexInStoriesHandlerList: 0,
                                storiesHandlerList: [storiesHandler],
                              ));
                            },
                            icon: Icon(
                              CupertinoIcons.viewfinder,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }

            if (snapshot.hasError) {
              // Handle error
              debugPrint('error: ${snapshot.error}');
              return const Center(
                child: Text('Une erreur s\'est produite', style: TextStyle(color: Colors.white)),
              );
            }

            // Display CircularProgressIndicator
            return Center(
              child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.black54),
            );
          },
        ),
      ),
      floatingActionButton:
          // [ACTION BUTTON] Add Event Button
          FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: kSecondColor,
        child: Transform.translate(
            offset: const Offset(1, -1),
            child: const Icon(
              Icons.done,
              color: Colors.white,
            )),
        onPressed: () async {
          // VIBRATE
          triggerVibration();

          if (selectedStory != null) {
            // Pop the page and return the selected story
            Navigator.pop(context, selectedStory);
          } else {
            // Title error handler
            showSnackbar(context, 'Veuillez selectionner une story avant de continuer', null);
          }
        },
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/create_story.dart';
import 'package:wesh/pages/in.pages/storiesViewer.dart';
import '../../models/stories_handler.dart';
import '../../models/user.dart' as usermodel;
import '../../models/story.dart';
import '../../services/firestore.methods.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';

class NonExpiredStoriesListPage extends StatefulWidget {
  const NonExpiredStoriesListPage({super.key});

  @override
  State<NonExpiredStoriesListPage> createState() => _NonExpiredStoriesListPageState();
}

class _NonExpiredStoriesListPageState extends State<NonExpiredStoriesListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'NonExpiredStoriesListPageAppBar',
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 0.06.sw,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            splashRadius: 0.06.sw,
            onPressed: () async {
              // Redirect to Create a new story
              Navigator.push(
                  context,
                  SwipeablePageRoute(
                    builder: (context) => const CreateStory(),
                  ));
            },
            icon: const Icon(
              Icons.add,
              color: Colors.black87,
            ),
          )
        ],
        title: const Text(
          'Your Stories',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
        child: StreamBuilder(
          stream: FirestoreMethods.getNonExpiredStoriesByUserPosterIdInList([FirebaseAuth.instance.currentUser!.uid]),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<Story> allStories = (snapshot.data as List<Story>);
              // Sort Stories
              allStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
                        height: 100,
                        empty,
                        width: double.infinity,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'You haven\'t shared anything today yet!',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Redirect to Create a new story
                          Navigator.push(
                              context,
                              SwipeablePageRoute(
                                builder: (context) => const CreateStory(),
                              ));
                        },
                        child: const Text('+ Create a story'),
                      )
                    ],
                  ),
                );
              }

              // Stories found : > 0
              else {
                // GRID : display stories in grid
                return GridView.builder(
                  // physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 4 / 5,
                  ),
                  itemCount: allStories.length,
                  itemBuilder: (context, index) {
                    Story storyGet = allStories[index];
                    //
                    return GestureDetector(
                      onTap: () async {
                        //
                        showFullPageLoader(context: context, color: Colors.white);
                        //

                        usermodel.User? userPoster =
                            await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);

                        // Dismiss loader
                        if (!mounted) return;
                        Navigator.of(context).pop();

                        // Build Story Handler
                        StoriesHandler storiesHandler = StoriesHandler(
                          avatarPath: userPoster?.profilePicture ?? '',
                          posterId: userPoster?.id ?? '',
                          title: userPoster?.name ?? '',
                          origin: 'singleStory',
                          lastStoryDateTime: storyGet.createdAt,
                          stories: [storyGet],
                        );
                        // Preview Story
                        if (!mounted) return;
                        context.pushTransparentRoute(StoriesViewer(
                          indexInStoriesHandlerList: 0,
                          storiesHandlerList: [storiesHandler],
                        ));
                      },
                      child: BuildStoryGridPreview(
                        footer: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
                                // Delete Story

                                // Show Delete Decision Modal
                                List deleteDecision = await showModalDecision(
                                  context: context,
                                  header: 'Delete',
                                  content: 'Do you want to permanently delete this story?',
                                  firstButton: 'Cancel',
                                  secondButton: 'Delete',
                                );

                                if (deleteDecision[0] == true) {
                                  // Confirm story deletion...
                                  if (!mounted) return;
                                  bool result = await FirestoreMethods.deleteStory(
                                      context, storyGet, FirebaseAuth.instance.currentUser!.uid);
                                  if (result) {
                                    log('Story deleted !');

                                    if (!mounted) return;
                                    showSnackbar(context, 'Your story has been deleted successfully!', kSecondColor);
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        story: storyGet,
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
                child: Text('An error occured!', style: TextStyle(color: Colors.white)),
              );
            }

            // Display CircularProgressIndicator
            return Center(
              child: RepaintBoundary(child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.black54)),
            );
          },
        ),
      ),
    );
  }
}

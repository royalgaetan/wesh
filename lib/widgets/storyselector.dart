import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/story.dart';
import 'package:wesh/pages/in.pages/storyviewer_single_story.dart';
import '../models/user.dart' as UserModel;
import '../providers/user.provider.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class StorySelector extends StatefulWidget {
  const StorySelector({super.key});

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
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: StreamBuilder(
          stream: Provider.of<UserProvider>(context).getUserStories(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<Story> allStories = (snapshot.data as List<Story>);

              // No Stories found : 0
              if (allStories.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(30),
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        height: 150,
                        'assets/animations/112136-empty-red.json',
                        width: double.infinity,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Aucune story retrouvée !',
                        style: TextStyle(
                          fontSize: 14,
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
                  // Case : Story Text

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
                    return buildStoryGridPreview(
                        footer: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () {
                                // Select Story
                                storySelectedIndex.value = index;
                                selectedStory = storiesItemList[index];
                                debugPrint('storySelectedIndex: $index');
                              },
                              icon: Padding(
                                padding: const EdgeInsets.only(right: 8, bottom: 8),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.6),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.white,
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: storySelectedIndex,
                                          builder: (context, value, child) {
                                            return value == index
                                                ? Transform.scale(
                                                    scale: 0.7,
                                                    child: const Icon(
                                                      Icons.done,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                : Container();
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        story: storiesItemList[index]);
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
            return const Center(
              child: CupertinoActivityIndicator(color: Colors.black54, radius: 16),
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

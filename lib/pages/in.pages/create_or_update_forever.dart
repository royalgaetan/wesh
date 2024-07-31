// ignore_for_file: use_build_context_synchronously

import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/forever.dart';
import 'package:wesh/pages/in.pages/storiesViewer.dart';
import 'package:wesh/widgets/storyselector.dart';
import '../../models/stories_handler.dart';
import '../../models/story.dart';
import '../../services/firestore.methods.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../../widgets/textformfield.dart';
import '../../models/user.dart' as usermodel;

class CreateOrUpdateForeverPage extends StatefulWidget {
  final Forever? forever;
  const CreateOrUpdateForeverPage({super.key, this.forever});

  @override
  State<CreateOrUpdateForeverPage> createState() => _CreateOrUpdateForeverPageState();
}

class _CreateOrUpdateForeverPageState extends State<CreateOrUpdateForeverPage> {
  TextEditingController titleForeverController = TextEditingController();
  List<Story> foreverStoriesList = [];
  List<String> foreverStoriesListWithStoryIdOnly = [];
  Story? selectedStory;

  @override
  void initState() {
    //
    super.initState();
    titleForeverController.text = widget.forever == null ? '' : widget.forever!.title;
    foreverStoriesListWithStoryIdOnly =
        widget.forever == null ? [] : widget.forever!.stories.map((s) => s.toString()).toList();
  }

  @override
  void dispose() {
    //
    super.dispose();
    titleForeverController.dispose();
  }

  handleCTAButton() {
    // VIBRATE
    // triggerVibration();

    if (titleForeverController.text.isNotEmpty && titleForeverController.text.length < 45) {
      if (foreverStoriesListWithStoryIdOnly.isNotEmpty) {
        // CREATE OR UPDATE FOREVER
        debugPrint('creating/updating forever...');
        createOrUpdateForever();
      } else {
        // Stories List error handler
        if (!mounted) return;
        showSnackbar(context, 'Your Forever must contain at least one Story!', null);
      }
    } else {
      // Title error handler
      if (!mounted) return;
      showSnackbar(context, 'Please enter a valid title (less than 45 characters)', null);
    }
  }

  Future<bool> onWillPopHandler(context) async {
    List result = await showModalDecision(
      context: context,
      header: 'Discard?',
      content: 'If you exit, you will lose all your changes',
      firstButton: 'Cancel',
      secondButton: 'Discard',
    );
    if (result[0] == true) {
      Navigator.pop(context);
    }
    return false;
  }

  createOrUpdateForever() async {
    bool result = false;

    showFullPageLoader(context: context);

    // CREATE A NEW ONE
    if (widget.forever == null) {
      // Modeling an forever
      Map<String, dynamic> forever = Forever(
        foreverId: '',
        title: titleForeverController.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
        stories: foreverStoriesListWithStoryIdOnly,
        modifiedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ).toJson();

      //  Update Firestore Forevers Table
      result = await FirestoreMethods.createForever(context, FirebaseAuth.instance.currentUser!.uid, forever);
      debugPrint('Forever created (+notification) !');
    }

    // UPDATE AN EXISTING ONE
    if (widget.forever != null) {
      // Modeling a forever

      Map<String, dynamic> foreverToUpdate = Forever(
        foreverId: widget.forever!.foreverId,
        title: titleForeverController.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
        stories: foreverStoriesListWithStoryIdOnly,
        modifiedAt: DateTime.now(),
        createdAt: widget.forever!.createdAt,
      ).toJson();
      if (!mounted) return;
      result = await FirestoreMethods.updateForever(context, widget.forever!.foreverId, foreverToUpdate);
      debugPrint('Forever updated');
    }

    if (!mounted) return;
    Navigator.pop(context);
    // Pop the Screen once Forever is created/updated
    if (result) {
      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      showSnackbar(
        context,
        'Your Forever has been ${widget.forever == null ? 'created' : 'modified'} successfully!',
        kSuccessColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        onWillPopHandler(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'foreverPageAppBar',
          backgroundColor: Colors.white,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            splashRadius: 0.06.sw,
            onPressed: () async {
              bool result = await onWillPopHandler(context);
              if (result) {
                if (!mounted) return;
                Navigator.pop(context);
              } else {
                //
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          actions: [
            // CTA Button Create or Edit Forever
            GestureDetector(
              onTap: () {
                handleCTAButton();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 15, 10),
                child: Text(
                  widget.forever == null ? 'Create' : 'Save',
                  style: TextStyle(fontSize: 16.sp, color: kSecondColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          title: Text(
            widget.forever == null ? 'Create a Forever' : 'Edit Forever',
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 5,
            left: 10,
            right: 10,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // FIELDS
                // Add Forever Name
                BuildTextFormField(
                  controller: titleForeverController,
                  hintText: 'Add Forever title...',
                  icon: Icon(FontAwesomeIcons.alignJustify, size: 17.sp, color: Colors.grey.shade600),
                  validateFn: (title) {
                    return null;
                  },
                  onChanged: (value) async {
                    return await null;
                  },
                ),

                // Quick help: Forevers explaination
                Padding(
                  padding: const EdgeInsets.only(right: 6, bottom: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(FontAwesomeIcons.circleInfo, size: 18.sp, color: Colors.grey.shade400),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Wrap(
                            children: [
                              Text(
                                'Forevers help you save your stories beyond the 24-hour limit',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const BuildDivider(),
                // Add story inside forever
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.circleNotch, color: Colors.grey.shade600, size: 19.sp),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text('Stories', style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp)),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          // Redirect to Story selector Page and get the selected story
                          showFullPageLoader(context: context, color: Colors.white);
                          //
                          usermodel.User? userPoster =
                              await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);

                          // Dismiss loader
                          if (!mounted) return;
                          Navigator.of(context).pop();

                          if (userPoster != null) {
                            List<Story>? selectedStories = await Navigator.push(
                                context,
                                SwipeablePageRoute(
                                  builder: (context) => StorySelector(
                                    userPoster: userPoster,
                                    storiesIdsToExclude: foreverStoriesListWithStoryIdOnly,
                                  ),
                                ));

                            if (selectedStories != null && selectedStories.isNotEmpty) {
                              // Check each story returned
                              for (selectedStory in selectedStories) {
                                if (!foreverStoriesListWithStoryIdOnly.contains(selectedStory!.storyId)) {
                                  setState(() {
                                    foreverStoriesListWithStoryIdOnly.add(selectedStory!.storyId);
                                  });
                                }
                                // Else Handle: selected story already exists: Do nothing
                              }
                            }
                          }
                        },
                        child: const Text(
                          '+ Add',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),

                // Grid : all forever Stories
                foreverStoriesListWithStoryIdOnly.isNotEmpty
                    ? GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 4 / 5,
                        ),
                        itemCount: foreverStoriesListWithStoryIdOnly.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                            future: FirestoreMethods.getStoryByIdAsFuture(foreverStoriesListWithStoryIdOnly[index]),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                Story storyGotten = snapshot.data;
                                return GestureDetector(
                                  onTap: () async {
                                    //
                                    showFullPageLoader(context: context, color: Colors.white);
                                    //

                                    usermodel.User? userPoster = await FirestoreMethods.getUserByIdAsFuture(
                                        FirebaseAuth.instance.currentUser!.uid);

                                    // Dismiss loader
                                    if (!mounted) return;
                                    Navigator.of(context).pop();

                                    // Build Story Handler
                                    StoriesHandler storiesHandler = StoriesHandler(
                                      avatarPath: userPoster?.profilePicture ?? '',
                                      posterId: userPoster?.id ?? '',
                                      title: userPoster?.name ?? '',
                                      origin: 'singleStory',
                                      lastStoryDateTime: storyGotten.createdAt,
                                      stories: [storyGotten],
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
                                              // Remove Story from Forever
                                              // Show Delete Decision Modal
                                              List deleteDecision = await showModalDecision(
                                                context: context,
                                                header: 'Remove',
                                                content: 'Do you want to remove this story from this Forever?',
                                                firstButton: 'Cancel',
                                                secondButton: 'Remove',
                                              );

                                              if (deleteDecision[0] == true) {
                                                debugPrint('Story to remove : $index');
                                                setState(() {
                                                  foreverStoriesListWithStoryIdOnly.removeAt(index);
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      story: storyGotten),
                                );
                              }

                              if (snapshot.hasError) {
                                // Handle error
                                debugPrint('error: ${snapshot.error}');
                                return const Center(
                                  child: Text('An error occured!', style: TextStyle(color: Colors.white)),
                                );
                              }

                              // Display CircularProgressIndicator
                              return const Center(
                                child: RepaintBoundary(
                                    child: CupertinoActivityIndicator(color: Colors.white60, radius: 15)),
                              );
                            },
                          );
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 70,
                              width: double.infinity,
                              child: Center(
                                child: Icon(
                                  Icons.not_interested_rounded,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50),
                              child: Text(
                                'Your Forever must contain at least one Story!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      )
              ],
            ),
          ),
        ),
        floatingActionButton: widget.forever != null && widget.forever!.uid == FirebaseAuth.instance.currentUser!.uid
            ? FloatingActionButton.small(
                elevation: 0.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                foregroundColor: Colors.white,
                backgroundColor: kSecondColor,
                onPressed: () async {
                  // DELETE FOREVER
                  // Show Delete Decision Modal
                  List deleteDecision = await showModalDecision(
                    context: context,
                    header: 'Delete',
                    content: 'Do you want to permanently delete this Forever and everything it contains?',
                    firstButton: 'Cancel',
                    secondButton: 'Delete',
                  );

                  if (deleteDecision[0] == true) {
                    // Delete forever...
                    bool result = await FirestoreMethods.deleteForever(
                        context, widget.forever!.foreverId, FirebaseAuth.instance.currentUser!.uid);
                    if (result) {
                      debugPrint('Forever deleted !');
                      if (!mounted) return;
                      Navigator.pop(
                        context,
                      );
                      showSnackbar(context, 'Your forever has been deleted successfully!', kSecondColor);
                    }
                  }
                },
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}

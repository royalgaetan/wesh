import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/widgets/addtextmodal.dart';
import '../../models/event.dart';
import '../../models/story.dart';
import '../../services/firestorage.methods.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/eventselector.dart';
import '../../widgets/modal.dart';
import '../../widgets/videowidget.dart';

class CreateStory extends StatefulWidget {
  const CreateStory({super.key});

  @override
  State<CreateStory> createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> with SingleTickerProviderStateMixin {
  //
  TextEditingController storyTextController = TextEditingController();
  FocusNode storyFieldFocus = FocusNode();
  Event? eventAttached;

  String imageSelectedPath = '';
  String imageCaption = '';

  String videoSelectedPath = '';
  String videoCaption = '';
  bool isVideoPreviewLoading = false;

  bool isDefaultColorActivated = false;
  int storyFontIndex = Random().nextInt(storiesAvailableFontsList.length - 1);
  int storyBgColorIndex = Random().nextInt(storiesAvailableColorsList.length - 1);

  StreamController<String> togglePlayPauseVideo = StreamController.broadcast();
  late TabController tabController;
  int tabIndexSelected = 0;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 3, animationDuration: Duration.zero, initialIndex: 0);
    tabController.addListener(handleTabSelection);

    setSuitableStatusBarColor(Colors.black87);

    // Set text-story textfield focus
    storyFieldFocus.requestFocus();
  }

  void handleTabSelection() {
    // pause any video if playding
    togglePlayPauseVideo.sink.add('pause');
    setState(() {
      tabIndexSelected = tabController.index;
      // For story text
      if (tabIndexSelected == 0) {
        isDefaultColorActivated = false;
      }
      // For others story type
      else {
        isDefaultColorActivated = true;
        // Remove text-story Field Focus
        storyFieldFocus.unfocus();
      }
    });
  }

  @override
  void dispose() {
    storyTextController.dispose();
    tabController.dispose();
    super.dispose();

    setSuitableStatusBarColor(Colors.white);
  }

  attachEvent() async {
    // Get the selected event
    // Show Event Selector
    dynamic selectedEvent = await showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: ((context) => Modal(
            minHeightSize: MediaQuery.of(context).size.height / 1.4,
            maxHeightSize: MediaQuery.of(context).size.height,
            child: const EventSelector(),
          )),
    );

    // Check the Event Selected
    if (selectedEvent != null && selectedEvent != 'remove') {
      setState(() {
        eventAttached = selectedEvent;
      });
      debugPrint('selected event is: ${selectedEvent.title}');
    } else if (selectedEvent == 'remove') {
      setState(() {
        eventAttached = null;
      });
      debugPrint('selected event is: $selectedEvent');
    }
  }

  addImage({required ImageSource source}) async {
    XFile? filePicked = await picker.pickImage(source: source);

    debugPrint('Image picked is : $filePicked');
    if (filePicked != null) {
      setState(() {
        imageSelectedPath = filePicked.path;
        debugPrint('Image selected is :$imageSelectedPath');
      });
    } else {
      // showSnackbar(context, 'An error occured!', null);
    }
  }

  addVideo({required ImageSource source, context}) async {
    XFile? filePicked = await picker.pickVideo(source: source);

    debugPrint('Video picked is : $filePicked');
    if (filePicked != null) {
      setState(() {
        videoSelectedPath = '';
        isVideoPreviewLoading = true;
        debugPrint('Video selected [clean]: $videoSelectedPath');
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          videoSelectedPath = filePicked.path;

          isVideoPreviewLoading = false;
          debugPrint('Video selected is : $videoSelectedPath');
        });
      });
    } else {
      setState(() {
        isVideoPreviewLoading = false;
      });
      // showSnackbar(context, 'An error occured!', null);
    }
  }

  createStory() async {
    var isConnected = await InternetConnection.isConnected(context);

    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // CONTINUE

      // Create a story
      bool result = false;
      if (!mounted) return;
      showFullPageLoader(context: context, color: Colors.white);

      // Text Story Case
      if (tabController.index == 0) {
        debugPrint('Processing with Text story...');
        if (storyTextController.text.isNotEmpty) {
          // Modeling a new Text Story
          Map<String, dynamic> newTextStory = Story(
              storyId: '',
              content: storyTextController.text,
              uid: FirebaseAuth.instance.currentUser!.uid,
              bgColor: storyBgColorIndex,
              fontType: storyFontIndex,
              storyType: 'text',
              caption: '',
              videoThumbnail: '',
              eventId: eventAttached == null ? '' : eventAttached!.eventId,
              createdAt: DateTime.now(),
              endAt: DateTime.now().add(const Duration(hours: 24)),
              viewers: []).toJson();

          debugPrint('Story created : $newTextStory');

          //  Update Firestore Stories Table
          // ignore: use_build_context_synchronously
          result = await FirestoreMethods.createStory(context, FirebaseAuth.instance.currentUser!.uid, newTextStory);
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pop(
            context,
          );
          // ignore: use_build_context_synchronously
          showSnackbar(context, 'Please write something before continuing!', null);
          return;
        }
      }

      // Image Story Case
      if (tabController.index == 1) {
        debugPrint('Processing with Image story...');

        if (imageSelectedPath.isNotEmpty && imageSelectedPath.contains('/data/user/')) {
          // Upload StoryImage to Firestorage and getDownloadURL
          if (!mounted) return;
          List resultFromStoryImageFile =
              await FireStorageMethods.uploadStoryContent(context, imageSelectedPath, 'image');
          bool isAllowToContinue = resultFromStoryImageFile[0];
          String downloadUrl = resultFromStoryImageFile[1];

          if (isAllowToContinue && downloadUrl.isNotEmpty) {
            // Modeling a new Image Story
            Map<String, dynamic> newImageStory = Story(
                storyId: '',
                content: downloadUrl,
                uid: FirebaseAuth.instance.currentUser!.uid,
                bgColor: 0,
                fontType: 0,
                storyType: 'image',
                caption: imageCaption,
                videoThumbnail: '',
                eventId: eventAttached == null ? '' : eventAttached!.eventId,
                createdAt: DateTime.now(),
                endAt: DateTime.now().add(const Duration(hours: 24)),
                viewers: []).toJson();

            debugPrint('Story modelled : $newImageStory');

            //  Update Firestore Stories Table
            if (!mounted) return;
            result = await FirestoreMethods.createStory(context, FirebaseAuth.instance.currentUser!.uid, newImageStory);
          } else {
            if (!mounted) return;
            Navigator.pop(
              context,
            );
            return;
          }
        } else {
          if (!mounted) return;
          Navigator.pop(
            context,
          );
          showSnackbar(context, 'Please add an image before continuing!', null);
          return;
        }
      }

      // Video Story Case
      if (tabController.index == 2) {
        debugPrint('Processing with Video story...');
        if (videoSelectedPath.isNotEmpty && videoSelectedPath.contains('/data/user/')) {
          //
          // STORY VIDEO FILE
          //

          // Upload StoryVideo to Firestorage and getDownloadURL
          // ignore: use_build_context_synchronously
          List resultFromStoryVidFile =
              // ignore: use_build_context_synchronously
              await FireStorageMethods.uploadStoryContent(context, videoSelectedPath, 'video');
          bool isAllowToContinue = resultFromStoryVidFile[0];
          String downloadUrl = resultFromStoryVidFile[1];

          //
          // STORY VIDEO THUMBNAIL
          //

          // Upload StoryVideo Thumbnail to Firestorage and get Thumbnail downloadUrl
          if (!isAllowToContinue) {
            if (!mounted) return;
            Navigator.pop(
              context,
            );
            return;
          }
          String vidhumbnailInString = await getVideoThumbnail(videoSelectedPath) ?? '';
          if (!mounted) return;
          List resultFromStoryVidThumbnailFile =
              await FireStorageMethods.uploadStoryContent(context, vidhumbnailInString, 'vidThumbnail');
          isAllowToContinue = resultFromStoryVidThumbnailFile[0];
          String thumbnailVideoDownloadUrl = resultFromStoryVidThumbnailFile[1];

          //
          // CONTINUE THERE IS NO ERROR AFTER UPLOADING FILE
          //

          if (isAllowToContinue && downloadUrl.isNotEmpty && thumbnailVideoDownloadUrl.isNotEmpty) {
            // Modeling a new Video Story
            Map<String, dynamic> newVideoStory = Story(
                storyId: '',
                content: downloadUrl,
                uid: FirebaseAuth.instance.currentUser!.uid,
                bgColor: 0,
                fontType: 0,
                storyType: 'video',
                videoThumbnail: thumbnailVideoDownloadUrl,
                caption: videoCaption,
                eventId: eventAttached == null ? '' : eventAttached!.eventId,
                createdAt: DateTime.now(),
                endAt: DateTime.now().add(const Duration(hours: 24)),
                viewers: []).toJson();

            debugPrint('Story created : $newVideoStory');

            //  Update Firestore Stories Table
            // ignore: use_build_context_synchronously
            result =
                // ignore: use_build_context_synchronously
                await FirestoreMethods.createStory(context, FirebaseAuth.instance.currentUser!.uid, newVideoStory);
          } else {
            if (!mounted) return;
            Navigator.pop(
              context,
            );
            return;
          }
        } else {
          if (!mounted) return;
          Navigator.pop(
            context,
          );

          showSnackbar(context, 'Please add a video before continuing!', null);
          return;
        }
      }
      // Pop Screen once story has been created
      if (result) {
        if (!mounted) return;
        Navigator.pop(
          context,
        );
        Navigator.pop(
          context,
        );

        // ignore: use_build_context_synchronously
        showSnackbar(context, 'Your story has been successfully shared!', kSuccessColor);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'createStoryPageAppBar',
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: Container(
            padding: const EdgeInsets.only(left: 8, top: 5),
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashRadius: 0.06.sw,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
          leadingWidth: 35,
          actions: [
            // CTA Button Create Story
            GestureDetector(
              onTap: () {
                // VIBRATE
                triggerVibration();
                togglePlayPauseVideo.sink.add('pause');
                createStory();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: Text(
                  'Create',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          title: Container(
            padding: const EdgeInsets.only(top: 7),
            margin: EdgeInsets.zero,
            width: double.infinity,
            alignment: Alignment.center,
            height: 46,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  () {
                    // Text Story: Options
                    if (tabIndexSelected == 0) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Attach an Event
                          Tooltip(
                            message: 'Attach an event',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
                                attachEvent();
                              },
                              icon: Icon(
                                FontAwesomeIcons.splotch,
                                size: 19.sp,
                                color: eventAttached == null ? Colors.white : kSecondColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),

                          // Change Font
                          Tooltip(
                            message: 'Change the font',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () {
                                setState(() {
                                  if (storyFontIndex < storiesAvailableFontsList.length - 1) {
                                    storyFontIndex = storyFontIndex + 1;
                                  } else {
                                    storyFontIndex = 0;
                                  }
                                  debugPrint('Font selected: $storyFontIndex');
                                });
                              },
                              icon: Icon(
                                Icons.font_download_rounded,
                                size: 22.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),

                          // Change Bg color
                          Tooltip(
                            message: 'Change the background color',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () {
                                setState(() {
                                  if (storyBgColorIndex < storiesAvailableColorsList.length - 1) {
                                    storyBgColorIndex = storyBgColorIndex + 1;
                                  } else {
                                    storyBgColorIndex = 0;
                                  }
                                  debugPrint('Value: $storyBgColorIndex');
                                });
                              },
                              icon: Icon(
                                CupertinoIcons.paintbrush_fill,
                                color: Colors.white,
                                size: 19.sp,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    // Image Story: Options
                    else if (tabIndexSelected == 1) {
                      return
                          // IMAGE Options ROW
                          Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Attach an Event
                          Tooltip(
                            message: 'Attach an event',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
                                attachEvent();
                              },
                              icon: Icon(
                                FontAwesomeIcons.splotch,
                                size: 19.sp,
                                color: eventAttached == null ? Colors.white : kSecondColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Pick an image from Camera
                          Tooltip(
                            message: 'Add image from Camera',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () {
                                addImage(source: ImageSource.camera);
                              },
                              icon: Icon(FontAwesomeIcons.camera, size: 19.sp, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Pick an image from Gallery
                          Tooltip(
                            message: 'Add image from Gallery',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
                                addImage(source: ImageSource.gallery);
                              },
                              icon: Icon(FontAwesomeIcons.image, size: 19.sp, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Add Caption to Story Image
                          Tooltip(
                            message: 'Add caption',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
                                // Show AddTextModal
                                var textresult = await showModalBottomSheet(
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: ((context) => Scaffold(
                                        backgroundColor: Colors.transparent,
                                        body: Modal(
                                          minHeightSize: 190,
                                          maxHeightSize: 190,
                                          child: AddTextModal(
                                              hintText: 'Add your caption here...',
                                              modalTitle: 'Add caption',
                                              initialText: imageCaption),
                                        ),
                                      )),
                                );

                                if (textresult != null) {
                                  setState(() {
                                    imageCaption = textresult;
                                  });
                                }
                              },
                              icon: Icon(
                                imageCaption.isNotEmpty
                                    ? FontAwesomeIcons.solidClosedCaptioning
                                    : FontAwesomeIcons.closedCaptioning,
                                color: imageCaption.isNotEmpty ? kSecondColor : Colors.white,
                                size: 19.sp,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    // Video Story: Options
                    else if (tabIndexSelected == 2) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Attach an Event
                          Tooltip(
                            message: 'Attach an event',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
                                togglePlayPauseVideo.sink.add('pause');
                                attachEvent();
                              },
                              icon: Icon(
                                FontAwesomeIcons.splotch,
                                size: 19.sp,
                                color: eventAttached == null ? Colors.white : kSecondColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Pick a video from Camera
                          Tooltip(
                            message: 'Add video from Camera',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () {
                                togglePlayPauseVideo.sink.add('pause');
                                addVideo(source: ImageSource.camera, context: context);
                              },
                              icon: Icon(
                                FontAwesomeIcons.video,
                                size: 19.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Pick a video from Gallery
                          Tooltip(
                            message: 'Add video from Gallery',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
                                togglePlayPauseVideo.sink.add('pause');
                                addVideo(source: ImageSource.gallery, context: context);
                              },
                              icon: Icon(FontAwesomeIcons.clapperboard, size: 19.sp, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Add Caption to Story Video
                          Tooltip(
                            message: 'Add caption',
                            child: IconButton(
                              splashRadius: 0.06.sw,
                              onPressed: () async {
                                togglePlayPauseVideo.sink.add('pause');
                                // Show AddTextModal
                                var textresult = await showModalBottomSheet(
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: ((context) => Scaffold(
                                        backgroundColor: Colors.transparent,
                                        body: Modal(
                                          minHeightSize: 190,
                                          maxHeightSize: 190,
                                          child: AddTextModal(
                                              hintText: 'Add your caption here...',
                                              modalTitle: 'Add caption',
                                              initialText: videoCaption),
                                        ),
                                      )),
                                );

                                if (textresult != null) {
                                  setState(() {
                                    videoCaption = textresult;
                                  });
                                }
                              },
                              icon: Icon(
                                videoCaption.isNotEmpty
                                    ? FontAwesomeIcons.solidClosedCaptioning
                                    : FontAwesomeIcons.closedCaptioning,
                                size: 19.sp,
                                color: videoCaption.isNotEmpty ? kSecondColor : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }(),
                ],
              ),
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: isDefaultColorActivated ? Colors.black : storiesAvailableColorsList[storyBgColorIndex],
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            // EVENT ATTACHED: indicator
            Visibility(
              visible: eventAttached != null,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () {
                    attachEvent();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.fromLTRB(20, kToolbarHeight + 15, 20, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: kSecondColor),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        eventAttached != null
                            ? Icon(
                                FontAwesomeIcons.splotch,
                                size: 11.sp,
                                color: Colors.white,
                              )
                            : Container(),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            eventAttached != null ? eventAttached!.title : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // MAIN PAGE CONTENT
            TabBarView(
              // physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                // Text Page
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // MAIN: TEXT FIELD
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 40),
                                constraints: BoxConstraints(
                                  maxWidth: double.infinity,
                                  maxHeight: MediaQuery.of(context).size.height / 1.7,
                                ),
                                child: AutoSizeTextField(
                                  focusNode: storyFieldFocus,
                                  controller: storyTextController,
                                  // fullwidth: false,
                                  minFontSize: 15,
                                  maxLength: 500,
                                  maxFontSize: 40,
                                  maxLines: null,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: storiesAvailableFontsList[storyFontIndex],
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                  cursorColor: Colors.white,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: const InputDecoration(
                                      hintMaxLines: 3,
                                      counterText: '',
                                      hintText: 'Write something here...',
                                      hintStyle: TextStyle(
                                        color: Colors.white30,
                                        fontSize: 40,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(20)),
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bg Shadow
                    Container(
                        height: 100,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            colors: [
                              Colors.black38,
                              Colors.black26,
                              Colors.black12,
                              Colors.transparent,
                            ],
                          ),
                        )),
                  ],
                ),

                // Image Page
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // MAIN: Image Preview
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: double.infinity,
                                  maxHeight: MediaQuery.of(context).size.height / 1.5,
                                ),
                                child: imageSelectedPath == ''
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              // Add an Image
                                              addImage(source: ImageSource.gallery);
                                            },
                                            child: const Text(
                                              '+ Add an image',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : PhotoView(
                                        imageProvider: FileImage(File(imageSelectedPath)),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // CAPTION: Image Story
                    Visibility(
                      visible: imageCaption.isNotEmpty,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          15,
                        ),
                        margin: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.5),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              imageCaption,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                // Video Page
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // MAIN: Video Preview
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: double.infinity,
                                  maxHeight: MediaQuery.of(context).size.height / 1.5,
                                ),
                                child: videoSelectedPath == '' && !isVideoPreviewLoading
                                    ? TextButton(
                                        onPressed: () {
                                          // Add an Video
                                          addVideo(
                                            source: ImageSource.gallery,
                                            context: context,
                                          );
                                        },
                                        child: const Text(
                                          '+ Add a video',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      )
                                    // : VideoPlayerWidget(data: videoSelectedPath),
                                    : isVideoPreviewLoading
                                        ? const RepaintBoundary(
                                            child: CircularProgressIndicator(
                                              color: kSecondColor,
                                            ),
                                          )
                                        : VideoPlayerWidget(
                                            data: videoSelectedPath,
                                            togglePlayPause: togglePlayPauseVideo,
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // CAPTION: Video Story
                    Visibility(
                      visible: videoCaption.isNotEmpty,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.5),
                        ),
                        padding: const EdgeInsets.all(
                          15,
                        ),
                        margin: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                videoCaption,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottomSheet: Container(
          color: kDark,
          child: TabBar(
            onTap: (index) {
              setState(() {
                if (index == 0) {
                  isDefaultColorActivated = false;
                } else {
                  isDefaultColorActivated = true;
                }
              });
            },
            controller: tabController,
            indicatorColor: kSecondColor,
            unselectedLabelColor: Colors.white70,
            indicator: CircleTabIndicator(color: kSecondColor, radius: 3),
            indicatorPadding: const EdgeInsets.only(bottom: 6),
            labelPadding: const EdgeInsets.only(bottom: 4),
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            labelColor: kSecondColor,
            tabs: const [
              Tab(
                text: 'Texte',
              ),
              Tab(
                text: 'Image',
              ),
              Tab(
                text: 'Video',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CircleTabIndicator
class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color, required double radius}) : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset = offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

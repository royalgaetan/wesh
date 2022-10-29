import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uuid/uuid.dart';
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

class _CreateStoryState extends State<CreateStory>
    with SingleTickerProviderStateMixin {
  //
  TextEditingController storyTextController = TextEditingController();
  Event? eventAttached;

  String imageSelectedPath = '';
  String imageCaption = '';

  String videoSelectedPath = '';
  String videoCaption = '';
  bool isVideoPreviewLoading = false;

  bool isDefaultColorActivated = false;
  int storyFontIndex = Random().nextInt(storiesAvailableFontsList.length - 1);
  int storyBgColorIndex =
      Random().nextInt(storiesAvailableColorsList.length - 1);

  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: 3, animationDuration: Duration.zero);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      if (_tabController.index == 0) {
        isDefaultColorActivated = false;
      } else {
        isDefaultColorActivated = true;
      }
    });
  }

  @override
  void dispose() {
    storyTextController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  attachEvent() async {
    // Get the selected event
    // Show Event Selector
    Event? selectedEvent = await showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: ((context) => Modal(
            minChildSize: .4,
            child: const EventSelector(),
          )),
    );

    // Check the Event Selected
    if (selectedEvent != null) {
      setState(() {
        eventAttached = selectedEvent;
      });
      debugPrint('selected event is: ${selectedEvent.title}');
    } else if (selectedEvent == null) {
      setState(() {
        eventAttached = null;
      });
      debugPrint('selected event is: $selectedEvent');
    }
  }

  addImage({required ImageSource source}) async {
    XFile? filePicked = await _picker.pickImage(source: source);

    debugPrint('Image picked is : $filePicked');
    if (filePicked != null) {
      setState(() {
        imageSelectedPath = filePicked.path;
        debugPrint('Image selected is :$imageSelectedPath');
      });
    } else {
      // showSnackbar(context, 'Une erreur s\'est produite', null);
    }
  }

  addVideo({required ImageSource source, context}) async {
    XFile? filePicked = await _picker.pickVideo(source: source);

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
      // showSnackbar(context, 'Une erreur s\'est produite', null);
    }
  }

  createStory() async {
    var isConnected = await InternetConnection().isConnected(context);

    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // CONTINUE

      // Create a story
      bool result = false;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
        ),
      );

      // Text Story Case
      if (_tabController.index == 0) {
        debugPrint('Processing with Text story...');
        if (storyTextController.text.isNotEmpty) {
          // Modeling a new Text Story
          Map<String, Object?> newTextStory = Story(
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
          result = await FirestoreMethods().createStory(
              context, FirebaseAuth.instance.currentUser!.uid, newTextStory);
        } else {
          // Content Attached error handler
          result = false;
          showSnackbar(context,
              'Veuillez écrire quelque chose avant de continuer !', null);
        }
      }

      // Image Story Case
      if (_tabController.index == 1) {
        debugPrint('Processing with Image story...');
        if (imageSelectedPath.isNotEmpty &&
            imageSelectedPath.contains('/data/user/')) {
          // Upload StoryImage to Firestorage and getDownloadURL
          String downloadUrl = await FireStorageMethods()
              .uploadStoryContent(context, imageSelectedPath, 'image');
          if (downloadUrl.isEmpty) return;

          // Modeling a new Image Story
          Map<String, Object?> newImageStory = Story(
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
          result = await FirestoreMethods().createStory(
              context, FirebaseAuth.instance.currentUser!.uid, newImageStory);
        } else {
          // Content Attached error handler
          result = false;
          showSnackbar(
              context, 'Veuillez ajouter une image avant de continuer !', null);
        }
      }

      // Video Story Case
      if (_tabController.index == 2) {
        debugPrint('Processing with Video story...');
        if (videoSelectedPath.isNotEmpty &&
            videoSelectedPath.contains('/data/user/')) {
          // Upload StoryVideo to Firestorage and getDownloadURL
          String downloadUrl = await FireStorageMethods()
              .uploadStoryContent(context, videoSelectedPath, 'video');

          // Upload StoryVideo Thumbnail to Firestorage and get Thumbnail downloadUrl
          String vidhumbnailInString =
              await getVideoThumbnail(videoSelectedPath) ?? '';
          String thumbnailVideoDownloadUrl = await FireStorageMethods()
              .uploadStoryContent(context, vidhumbnailInString, 'vidThumbnail');

          if (downloadUrl.isNotEmpty && thumbnailVideoDownloadUrl.isNotEmpty) {
            // Modeling a new Video Story
            Map<String, Object?> newVideoStory = Story(
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
            result = await FirestoreMethods().createStory(
                context, FirebaseAuth.instance.currentUser!.uid, newVideoStory);
          } else {
            result = false;
          }
        } else {
          // Content Attached error handler
          result = false;
          showSnackbar(
              context, 'Veuillez ajouter une video avant de continuer !', null);
        }
      }
      // Pop Screen once story will be created

      if (result) {
        // ignore: use_build_context_synchronously
        Navigator.pop(
          context,
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(
          context,
        );

        // ignore: use_build_context_synchronously
        showSnackbar(
            context, 'Votre story a bien été partagée !', kSuccessColor);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Color.fromARGB(0, 95, 55, 55),
          centerTitle: true,
          // Tab bar
          title: TabBar(
              onTap: (index) {
                setState(() {
                  if (index == 0) {
                    isDefaultColorActivated = false;
                  } else {
                    isDefaultColorActivated = true;
                  }
                });
              },
              controller: _tabController,
              indicatorColor: kSecondColor,
              unselectedLabelColor: Colors.white70,
              indicator: CircleTabIndicator(color: kSecondColor, radius: 3),
              // labelPadding: EdgeInsets.only(top: 20),
              labelStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
              ]),
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: isDefaultColorActivated
            ? Colors.black
            : storiesAvailableColorsList[storyBgColorIndex],
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            // Text Page
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                // MAIN: TEXT FIELD
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 30),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: double.infinity,
                              maxHeight:
                                  MediaQuery.of(context).size.height / 1.8,
                            ),
                            child: AutoSizeTextField(
                              autofocus: true,
                              controller: storyTextController,
                              fullwidth: false,
                              minFontSize: 15,
                              maxLength: 500,
                              maxLines: null,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily:
                                      storiesAvailableFontsList[storyFontIndex],
                                  fontSize: 50,
                                  color: Colors.white),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Ecrivez quelque chose...',
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade400),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(20)),
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

                // Options TEXT STORY
                AnimatedPadding(
                  duration: const Duration(milliseconds: 120),
                  padding: EdgeInsets.only(
                      left: 20, bottom: eventAttached == null ? 15 : 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Attach an Event
                      Tooltip(
                        message: 'Attacher un évènement',
                        child: IconButton(
                          splashRadius: 25,
                          onPressed: () async {
                            attachEvent();
                          },
                          icon: Icon(
                            FontAwesomeIcons.splotch,
                            color: eventAttached == null
                                ? Colors.white
                                : kSecondColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Change Font
                      Tooltip(
                        message: 'Changer la police',
                        child: IconButton(
                          splashRadius: 25,
                          onPressed: () {
                            setState(() {
                              if (storyFontIndex <
                                  storiesAvailableFontsList.length - 1) {
                                storyFontIndex = storyFontIndex + 1;
                              } else {
                                storyFontIndex = 0;
                              }
                              debugPrint('Font selected: ${storyFontIndex}');
                            });
                          },
                          icon: const Icon(FontAwesomeIcons.font,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Change Bg color
                      Tooltip(
                        message: 'Changer la couleur de fond',
                        child: IconButton(
                          splashRadius: 25,
                          onPressed: () {
                            setState(() {
                              if (storyBgColorIndex <
                                  storiesAvailableColorsList.length - 1) {
                                storyBgColorIndex = storyBgColorIndex + 1;
                              } else {
                                storyBgColorIndex = 0;
                              }
                              debugPrint('Value: ${storyBgColorIndex}');
                            });
                          },
                          icon: const Icon(
                            FontAwesomeIcons.brush,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),

            // Image Page
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                // MAIN: Image Preview
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                        '+ Ajouter une image',
                                        style: TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : PhotoView(
                                  imageProvider:
                                      FileImage(File(imageSelectedPath)),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Options IMAGE STORY
                AnimatedPadding(
                  duration: const Duration(milliseconds: 120),
                  padding:
                      EdgeInsets.only(bottom: eventAttached == null ? 15 : 35),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // IMAGE Captions ROW
                      Visibility(
                        visible: imageCaption.isNotEmpty,
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
                                  imageCaption,
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

                      // IMAGE Options ROW
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Attach an Event
                            Tooltip(
                              message: 'Attacher un évènement',
                              child: IconButton(
                                splashRadius: 25,
                                onPressed: () async {
                                  attachEvent();
                                },
                                icon: Icon(
                                  FontAwesomeIcons.splotch,
                                  color: eventAttached == null
                                      ? Colors.white
                                      : kSecondColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Pick an image from Camera
                            Tooltip(
                              message: 'depuis la camera',
                              child: IconButton(
                                splashRadius: 25,
                                onPressed: () {
                                  addImage(source: ImageSource.camera);
                                },
                                icon: const Icon(FontAwesomeIcons.camera,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Pick an image from Gallery
                            Tooltip(
                              message: 'depuis la galerie',
                              child: IconButton(
                                splashRadius: 25,
                                onPressed: () async {
                                  addImage(source: ImageSource.gallery);
                                },
                                icon: const Icon(FontAwesomeIcons.image,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Add Caption to Story Image
                            Tooltip(
                              message: 'Ajouter une description',
                              child: IconButton(
                                splashRadius: 25,
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
                                            maxChildSize: .3,
                                            initialChildSize: .3,
                                            minChildSize: .3,
                                            child: AddTextModal(
                                                hintText:
                                                    'Votre description ici...',
                                                modalTitle:
                                                    'Ajouter une description',
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
                                  color: imageCaption.isNotEmpty
                                      ? kSecondColor
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: double.infinity,
                            maxHeight: MediaQuery.of(context).size.height / 1.5,
                          ),
                          child: videoSelectedPath == '' &&
                                  !isVideoPreviewLoading
                              ? TextButton(
                                  onPressed: () {
                                    // Add an Video
                                    addVideo(
                                      source: ImageSource.gallery,
                                      context: context,
                                    );
                                  },
                                  child: const Text(
                                    '+ Ajouter une video',
                                    style: TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                              // : VideoPlayerWidget(data: videoSelectedPath),
                              : isVideoPreviewLoading
                                  ? const CircularProgressIndicator(
                                      color: kSecondColor,
                                    )
                                  : VideoPlayerWidget(data: videoSelectedPath),
                        ),
                      ],
                    ),
                  ),
                ),

                // Options VIDEO STORY
                AnimatedPadding(
                  duration: const Duration(milliseconds: 120),
                  padding:
                      EdgeInsets.only(bottom: eventAttached == null ? 15 : 35),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // VIDEO Captions ROW
                      Visibility(
                        visible: videoCaption.isNotEmpty,
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

                      // VIDEO Options ROW
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Attach an Event
                            Tooltip(
                              message: 'Attacher un évènement',
                              child: IconButton(
                                splashRadius: 25,
                                onPressed: () async {
                                  attachEvent();
                                },
                                icon: Icon(
                                  FontAwesomeIcons.splotch,
                                  color: eventAttached == null
                                      ? Colors.white
                                      : kSecondColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Pick a video from Camera
                            Tooltip(
                              message: 'depuis la camera',
                              child: IconButton(
                                splashRadius: 25,
                                onPressed: () {
                                  addVideo(
                                      source: ImageSource.camera,
                                      context: context);
                                },
                                icon: const Icon(FontAwesomeIcons.video,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Pick a video from Gallery
                            Tooltip(
                              message: 'depuis la galerie',
                              child: IconButton(
                                splashRadius: 25,
                                onPressed: () async {
                                  addVideo(
                                      source: ImageSource.gallery,
                                      context: context);
                                },
                                icon: const Icon(FontAwesomeIcons.clapperboard,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Add Caption to Story Video
                            Tooltip(
                              message: 'Ajouter une description',
                              child: IconButton(
                                splashRadius: 25,
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
                                            maxChildSize: .3,
                                            initialChildSize: .3,
                                            minChildSize: .3,
                                            child: AddTextModal(
                                                hintText:
                                                    'Votre description ici...',
                                                modalTitle:
                                                    'Ajouter une description',
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
                                  color: videoCaption.isNotEmpty
                                      ? kSecondColor
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomSheet: // EVENT ATTACHED
            AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: eventAttached == null ? 0 : 30,
          child: Row(
            children: [
              eventAttached != null
                  ? const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    )
                  : Container(),
              const SizedBox(
                width: 7,
              ),
              Text(
                eventAttached != null ? eventAttached!.title : '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        floatingActionButton:
            // [ACTION BUTTON] Add Reminder Button
            FloatingActionButton(
          foregroundColor: Colors.white,
          backgroundColor: kSecondColor,
          child: Transform.translate(
            offset: const Offset(1, -1),
            child: Transform.rotate(
              angle: -pi / 4,
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () async {
            createStory();
          },
        ),
      ),
    );
  }
}

// CircleTabIndicator

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color, required double radius})
      : _painter = _CirclePainter(color, radius);

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
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

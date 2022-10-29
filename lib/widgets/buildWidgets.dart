import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shimmer/shimmer.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:wesh/widgets/story_more_options_modal.dart';
import '../models/event.dart';
import '../models/forever.dart';
import '../models/story.dart';
import '../models/user.dart' as UserModel;
import 'package:timeago/timeago.dart' as timeago;
import '../pages/in.pages/inbox.dart';
import '../pages/in.pages/storyviewer_single_story.dart';
import '../pages/profile.dart';
import '../providers/user.provider.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'eventview.dart';
import 'modal.dart';
import 'story_add_to_forever_modal.dart';
import 'story_all_viewers_modal.dart';

// BUILD AVATAR AND USERNAME
class buildAvatarAndUsername extends StatefulWidget {
  final String uidPoster;

  const buildAvatarAndUsername({super.key, required this.uidPoster});

  @override
  State<buildAvatarAndUsername> createState() => _buildAvatarAndUsernameState();
}

class _buildAvatarAndUsernameState extends State<buildAvatarAndUsername> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<UserModel.User?>(
        stream: getUserById(context, widget.uidPoster),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                CupertinoActivityIndicator(),
              ],
            );
          }

          if (snapshot.hasData) {
            UserModel.User currentUser = snapshot.data as UserModel.User;

            return Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: kGreyColor,
                  backgroundImage: NetworkImage(currentUser.profilePicture),
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(
                      currentUser.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}

// BUILD ATTACHED EVENT :for story header
class buildAttachedEventRow extends StatefulWidget {
  final String eventId;
  final StoryController? storyController;
  const buildAttachedEventRow(
      {super.key, required this.eventId, this.storyController});

  @override
  State<buildAttachedEventRow> createState() => _buildAttachedEventRowState();
}

class _buildAttachedEventRowState extends State<buildAttachedEventRow> {
  @override
  Widget build(BuildContext context) {
    return widget.eventId.isNotEmpty
        ? FutureBuilder(
            future:
                Provider.of<UserProvider>(context).getEventById(widget.eventId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.splotch,
                        color: kSecondColor,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Flexible(
                        child: Container(
                            margin: const EdgeInsets.only(right: 30),
                            height: 10,
                            width: double.infinity,
                            color: Colors.white60),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasData) {
                Event currentEvent = snapshot.data as Event;

                return InkWell(
                  onTap: () async {
                    widget.storyController!.pause();
                    // Show EventView Modal
                    bool? result = await showModalBottomSheet(
                      enableDrag: true,
                      isScrollControlled: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: ((context) => Modal(
                            maxChildSize: 1,
                            initialChildSize: .8,
                            minChildSize: .8,
                            child: EventView(event: currentEvent),
                          )),
                    );

                    if (result == null) {
                      widget.storyController!.play();
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.splotch,
                        color: kSecondColor,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Flexible(
                        child: Text(
                          currentEvent.title,
                          style: const TextStyle(
                              color: Colors.white60,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          )
        : Container();
  }
}

// BUILD USER PROFILE PICTURE
class buildUserProfilePicture extends StatefulWidget {
  final String userId;
  final String? heroTag;
  final double? radius;

  const buildUserProfilePicture(
      {super.key, required this.userId, this.radius, this.heroTag});

  @override
  State<buildUserProfilePicture> createState() =>
      _buildUserProfilePictureState();
}

class _buildUserProfilePictureState extends State<buildUserProfilePicture> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint('User entry is: ${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag ?? '',
      child: StreamBuilder<UserModel.User?>(
        stream: Provider.of<UserProvider>(context).getUserById(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CircleAvatar(
              radius: widget.radius ?? 22,
              backgroundColor: kGreyColor,
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            UserModel.User currentUser = snapshot.data as UserModel.User;

            return CircleAvatar(
              radius: widget.radius ?? 22,
              backgroundColor: kGreyColor,
              backgroundImage: NetworkImage(currentUser.profilePicture),
            );
          }
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade400,
            child: CircleAvatar(
              radius: widget.radius ?? 22,
            ),
          );
        },
      ),
    );
  }
}

// BUILD FOREVER COVER
class buildForeverCover extends StatefulWidget {
  final Forever forever;

  const buildForeverCover({super.key, required this.forever});

  @override
  State<buildForeverCover> createState() => _buildForeverCoverState();
}

class _buildForeverCoverState extends State<buildForeverCover> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint('Forever entry is: ${widget.forever.stories}');
  }

  @override
  Widget build(BuildContext context) {
    return widget.forever.stories.isNotEmpty
        ? FutureBuilder<Widget?>(
            future: Provider.of<UserProvider>(context)
                .getForeverCoverByFirstStoryId(widget.forever.stories.first),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const CircleAvatar(
                  radius: 22,
                  backgroundColor: kGreyColor,
                );
                ;
              }

              if (snapshot.hasData && snapshot.data != null) {
                Widget cover = snapshot.data as Widget;

                return CircleAvatar(
                  radius: 22,
                  backgroundColor: kGreyColor,
                  child: cover,
                );
              }
              return const CircleAvatar(
                radius: 22,
                backgroundColor: kGreyColor,
                child: CupertinoActivityIndicator(),
              );
            },
          )
        : const CircleAvatar(
            radius: 22,
            backgroundColor: kGreyColor,
          );
  }
}

// BUILD STORY VIEWER HEADER AND FOOTER
class buildStoryViewerHeaderAndFooter extends StatefulWidget {
  final Forever? forever;
  final UserModel.User? user;
  final String uid;
  final String type;
  final StoryController storyController;
  final List<Story> allStories;
  final ValueNotifier<int> currentStoryDisplayed;
  final ValueNotifier<bool> isAllowedToJump;
  final ValueNotifier<List<StoryItem?>> storiesItemList;

  final ScreenshotController storySreenshotController;

  const buildStoryViewerHeaderAndFooter(
      {super.key,
      this.user,
      this.forever,
      required this.storyController,
      required this.currentStoryDisplayed,
      required this.isAllowedToJump,
      required this.storiesItemList,
      required this.allStories,
      required this.storySreenshotController,
      required this.type,
      required this.uid});

  @override
  State<buildStoryViewerHeaderAndFooter> createState() =>
      _buildStoryViewerHeaderAndFooterState();
}

class _buildStoryViewerHeaderAndFooterState
    extends State<buildStoryViewerHeaderAndFooter> {
  gotToProfilePage({required BuildContext context, required String uid}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(uid: uid, showBackButton: true),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
          child: Row(
            children: [
              //
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Hero avatar
                    widget.type == 'userStories' && widget.user != null
                        ? GestureDetector(
                            onTap: () {
                              gotToProfilePage(
                                  context: context, uid: widget.user!.id);
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  NetworkImage(widget.user!.profilePicture),
                            ),
                          )
                        : Container(),

                    // Hero Forever Cover
                    widget.type == 'foreverStories' && widget.forever != null
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(width: 2, color: Colors.white70),
                            ),
                            child: buildForeverCover(
                              forever: widget.forever!,
                            ),
                          )
                        : Container(),

                    const SizedBox(
                      width: 10,
                    ),
                    // Forever title && Story info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 1st ROW : Forever title + Story time
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${(() {
                                    if (widget.type == 'foreverStories' &&
                                        widget.forever != null) {
                                      return widget.forever!.title;
                                    } else if (widget.type == 'userStories' &&
                                        widget.user != null) {
                                      return widget.user!.name;
                                    }
                                  }())}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              ValueListenableBuilder(
                                valueListenable: widget.currentStoryDisplayed,
                                builder: (context, value, child) {
                                  return Text(
                                    (() {
                                      timeago.setLocaleMessages(
                                          'fr', FrMessagesShortsform());
                                      return timeago.format(
                                          widget
                                              .allStories[widget
                                                  .currentStoryDisplayed.value]
                                              .createdAt,
                                          locale: 'fr');
                                    }()),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(.6),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          // 2nd ROW : Event Attached
                          ValueListenableBuilder(
                            valueListenable: widget.currentStoryDisplayed,
                            builder: (context, value, child) {
                              return buildAttachedEventRow(
                                  storyController: widget.storyController,
                                  eventId: widget
                                      .allStories[
                                          widget.currentStoryDisplayed.value]
                                      .eventId);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    // More options
                    IconButton(
                      splashRadius: 22,
                      onPressed: () async {
                        widget.storyController.pause();

                        //  show more story options
                        bool? result = await showModalBottomSheet(
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
                                  child: StoryMoreOptionsModal(
                                    story: widget.allStories[
                                        widget.currentStoryDisplayed.value],
                                    storySreenshotController:
                                        widget.storySreenshotController,
                                    isSuppressionBtnAllowed:
                                        widget.type == 'foreverStories'
                                            ? false
                                            : true,
                                  ),
                                ),
                              )),
                        );

                        if (result == null) {
                          widget.storyController.play();
                        }
                      },
                      icon: const Icon(Icons.more_vert_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // FOOTER
        Column(
          children: [
            // CAPTION
            ValueListenableBuilder(
              valueListenable: widget.currentStoryDisplayed,
              builder: (context, value, child) {
                return Visibility(
                  visible: widget.allStories[widget.currentStoryDisplayed.value]
                          .caption.isNotEmpty
                      ? true
                      : false,
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
                              widget
                                  .allStories[
                                      widget.currentStoryDisplayed.value]
                                  .caption,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),

            //ACTIONS BUTTONS

            ValueListenableBuilder(
              valueListenable: widget.currentStoryDisplayed,
              builder: (context, value, child) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  child: Row(
                    children: [
                      // LEFT BUTTONS

                      // ChipButton: Show stories viewers modal
                      Visibility(
                        visible: widget.uid ==
                            FirebaseAuth.instance.currentUser?.uid,
                        child: ActionChip(
                            onPressed: () async {
                              widget.storyController.pause();
                              // Show Modal : Story Viewers
                              bool? result = await showModalBottomSheet(
                                enableDrag: true,
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: ((context) => Scaffold(
                                      backgroundColor: Colors.transparent,
                                      body: Modal(
                                        maxChildSize: .9,
                                        initialChildSize: .4,
                                        minChildSize: .4,
                                        child: StoryAllViewerModal(
                                            story: widget.allStories[widget
                                                .currentStoryDisplayed.value]),
                                      ),
                                    )),
                              );

                              if (result == null) {
                                widget.storyController.play();
                              }
                            },
                            label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${widget.allStories[widget.currentStoryDisplayed.value].viewers.length} ${getSatTheEnd(widget.allStories[widget.currentStoryDisplayed.value].viewers.length, 'vue')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            backgroundColor: Colors.white),
                      ),

                      //
                      const Spacer(),
                      // RIGHT BUTTONS
                      // Add to Forevers OR Answer to the story

                      Visibility(
                        visible: widget.uid !=
                            FirebaseAuth.instance.currentUser?.uid,
                        child: InkWell(
                          onTap: () {
                            // Redirect to InboxPage +StoryAttached
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InboxPage(
                                      uid: '',
                                      storyAttached: widget.allStories[
                                          widget.currentStoryDisplayed.value]),
                                ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [
                                // Label
                                Text(
                                  'Repondre',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),

                                // Spacer
                                SizedBox(
                                  width: 6,
                                ),
                                // Icon
                                Icon(
                                  FontAwesomeIcons.angleRight,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                      //
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

// DIVIDER WITH LABEL
class buildDividerWithLabel extends StatelessWidget {
  final String label;
  const buildDividerWithLabel({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Container(
            color: Colors.grey.shade300,
            height: 1.7,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(label),
        ),
        Flexible(
          flex: 1,
          child: Container(
            color: Colors.grey.shade300,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

// DIVIDER
class buildDivider extends StatelessWidget {
  const buildDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Divider(
        color: Colors.grey.shade700,
        height: 1.7,
      ),
    );
  }
}

// INTRODUCTION PAGE CONTENT
class buildIntroductionPageContent extends StatelessWidget {
  final String animationPath;
  final String title;
  final String description;

  const buildIntroductionPageContent(
      {Key? key,
      required this.animationPath,
      required this.title,
      required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2,
          child: Center(
            child: Lottie.asset(
              animationPath,
              width: double.infinity,
            ),
          ),
        ),
        // const SizedBox(
        //   height: 30,
        // ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}

// BUTTON FILE PICKER
class buttonPicker extends StatelessWidget {
  final Widget icon;
  final Color widgetColor;
  final String label;
  final VoidCallback function;

  const buttonPicker({
    Key? key,
    required this.icon,
    required this.widgetColor,
    required this.label,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: InkWell(
          onTap: () async {
            // Return selected file
            function();
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: widgetColor,
                child: icon,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                  fontSize: 17,
                ),
              )
            ],
          )),
    );
  }
}

// BUILD STORY GRIDPREVIEW

class buildStoryGridPreview extends StatefulWidget {
  final Widget footer;
  final Story story;

  const buildStoryGridPreview(
      {super.key, required this.footer, required this.story});

  @override
  State<buildStoryGridPreview> createState() => _buildStoryGridPreviewState();
}

class _buildStoryGridPreviewState extends State<buildStoryGridPreview> {
  @override
  Widget build(BuildContext context) {
    return GridTile(
      footer: widget.footer,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          // Preview Story
          context.pushTransparentRoute(SingleStoryPageViewer(
            storyTodiplay: widget.story,
          ));
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Loader / Content

            Stack(
              alignment: Alignment.center,
              children: [
                const CupertinoActivityIndicator(
                  color: Colors.black54,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: getStoryGridPreviewByType(widget.story),
                ),
              ],
            ),
            // Bg Shadow
            Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
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
      ),
    );
  }
}

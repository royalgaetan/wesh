// ignore_for_file: file_names
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:widget_size/widget_size.dart';

import 'package:wesh/models/discussion.dart';
import 'package:wesh/models/payment.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/payment_viewer_modal.dart';

import '../models/event.dart';
import '../models/forever.dart';
import '../models/message.dart';
import '../models/stories_handler.dart';
import '../models/story.dart';
import '../models/user.dart' as usermodel;
import '../pages/profile.dart';
import '../pages/settings.pages/bug_report_page.dart';
import '../services/firestore.methods.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'datetimebutton.dart';
import 'eventview.dart';
import 'modal.dart';

// BUILD CACHED_NETWORK_IMAGE WIDGET

class BuildCachedNetworkImage extends StatelessWidget {
  final String url;
  final double? radius;
  final Color backgroundColor;
  final double paddingOfProgressIndicator;
  final double? strokeWidthOfProgressIndicator;
  final Color? colorOfProgressIndicator;
  final BlendMode? blendMode;

  const BuildCachedNetworkImage({
    super.key,
    required this.url,
    this.radius,
    required this.backgroundColor,
    required this.paddingOfProgressIndicator,
    this.strokeWidthOfProgressIndicator,
    this.colorOfProgressIndicator,
    this.blendMode,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      colorBlendMode: blendMode,
      imageUrl: url,
      imageBuilder: (context, imageProvider) => radius == null
          ? Image(image: imageProvider)
          : CircleAvatar(
              radius: radius,
              backgroundColor: backgroundColor,
              backgroundImage: imageProvider,
            ),
      //
      useOldImageOnUrlChange: true,
      //
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Padding(
          padding: EdgeInsets.all(paddingOfProgressIndicator),
          child: RepaintBoundary(
            child: CircularProgressIndicator(
              strokeWidth: strokeWidthOfProgressIndicator ?? 2,
              color: colorOfProgressIndicator ?? Colors.black54,
            ),
          ),
        ),
      ),
      //
      errorWidget: (context, url, error) => radius == null
          ? const Image(image: AssetImage(darkBackground))
          : CircleAvatar(
              radius: radius,
              backgroundColor: backgroundColor,
            ),
    );
  }
}

// BUILD ERROR WIDGET
class BuildErrorWidget extends StatelessWidget {
  final bool? onWhiteBackground;
  const BuildErrorWidget({
    this.onWhiteBackground,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
        decoration: onWhiteBackground != null && onWhiteBackground == true
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black87.withOpacity(0.3),
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Oops! An error occured',
              style: TextStyle(
                color: onWhiteBackground != null && onWhiteBackground == true ? Colors.grey.shade600 : Colors.white,
                fontSize: 13.sp,
              ),
            ),
            const SizedBox(height: 7),
            GestureDetector(
              onTap: () {
                // Redirect to BugReport Page
                Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => const BugReportPage(),
                    ));
              },
              child: Text(
                'Report this error',
                style: TextStyle(fontSize: 13.sp, color: kSecondColor, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//
//
// BUILD FOLLOW/UNFOLLOW OR REMOVE BUTTON
class BuildFollowUnfollowOrRemoveButton extends StatefulWidget {
  final usermodel.User user;
  final double? width;
  final double? height;
  final double? fontSize;
  final String status;
  final String? shape;
  final bool? isCentered;
  const BuildFollowUnfollowOrRemoveButton({
    super.key,
    required this.user,
    required this.status,
    this.shape,
    this.isCentered,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  State<BuildFollowUnfollowOrRemoveButton> createState() => BuildFollowUnfollowOrRemoveButtonState();
}

class BuildFollowUnfollowOrRemoveButtonState extends State<BuildFollowUnfollowOrRemoveButton> {
  bool isButtonLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Btn is loading
        isButtonLoading
            ? Button(
                height: widget.height ?? 0.1.sw,
                width: widget.width ?? 0.23.sw,
                prefixIsLoading: true,
                color: kSecondColor,
                loaderIconSize: Size(0.033.sw, 0.033.sw),
                prefixIconColor: widget.shape == 'inline' ? Colors.black54 : Colors.white,
                onTap: () {},
                shape: widget.shape,
                isCentered: widget.isCentered,
              )
            :

            // HANDLE FOLLOW/UNFOLLOW
            widget.status == 'followUnfollow' && widget.user.id != FirebaseAuth.instance.currentUser!.uid
                ? StreamBuilder(
                    stream: CombineLatestStream.list([
                      FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid),
                      FirestoreMethods.getUserById(widget.user.id)
                    ]),
                    builder: (context, snapshot) {
                      // Handle error
                      if (snapshot.hasError) {
                        log('error: ${snapshot.error}');
                        return Button(
                          text: 'Error...',
                          height: widget.height ?? 0.1.sw,
                          width: widget.width ?? 0.23.sw,
                          fontsize: widget.fontSize ?? 11.sp,
                          fontColor: Colors.grey.shade700,
                          color: Colors.grey.shade100,
                          isBordered: false,
                          onTap: () {},
                          shape: widget.shape,
                          isCentered: widget.isCentered,
                        );
                      }

                      // handle data
                      if (snapshot.hasData && snapshot.data != null) {
                        List<usermodel.User?> data = snapshot.data as List<usermodel.User>;
                        usermodel.User? currentUser = data[0];
                        usermodel.User? userGet = data[1];

                        if (currentUser != null &&
                            userGet != null &&
                            currentUser.followers != null &&
                            currentUser.followings != null &&
                            userGet.followers != null &&
                            userGet.followings != null) {
                          // CurrentUser Followers && Followings
                          currentUser.followers!.map((followerId) => followerId.toString()).toList();
                          List<String> currentUserFollowings =
                              currentUser.followings!.map((followingId) => followingId.toString()).toList();

                          // Get User Followers && Followings
                          List<String> getUserFollowers =
                              userGet.followers!.map((followerId) => followerId.toString()).toList();
                          userGet.followings!.map((followingId) => followingId.toString()).toList();

                          // Case 1: Unfollow
                          if (currentUserFollowings.contains(userGet.id) && getUserFollowers.contains(currentUser.id)) {
                            return Button(
                              text: 'Unfollow',
                              height: widget.height ?? 0.1.sw,
                              width: widget.width ?? 0.23.sw,
                              fontsize: widget.fontSize ?? 11.sp,
                              fontColor: Colors.black87,
                              color: Colors.grey.shade100,
                              isBordered: false,
                              shape: widget.shape,
                              isCentered: widget.isCentered,
                              onTap: () async {
                                //
                                setState(() {
                                  isButtonLoading = true;
                                });
                                await FirestoreMethods.unfollowUser(context, userGet.id);

                                // Dismiss loader
                                setState(() {
                                  isButtonLoading = false;
                                });
                              },
                            );
                          }

                          // Case 2: Follow
                          return Button(
                            text: 'Follow',
                            height: widget.height ?? 0.1.sw,
                            width: widget.width ?? 0.23.sw,
                            fontsize: widget.fontSize ?? 11.sp,
                            fontColor: widget.shape == 'inline' ? kSecondColor : Colors.white,
                            fontWeight: widget.shape == 'inline' ? FontWeight.bold : null,
                            color: kSecondColor,
                            shape: widget.shape,
                            isCentered: widget.isCentered,
                            onTap: () async {
                              //
                              if (mounted) {
                                setState(() {
                                  isButtonLoading = true;
                                });
                              }
                              await FirestoreMethods.followUser(context, userGet.id);
                              // Dismiss loader
                              if (mounted) {
                                setState(() {
                                  isButtonLoading = false;
                                });
                              }
                            },
                          );
                        }

                        return Button(
                          text: '...',
                          height: widget.height ?? 0.1.sw,
                          width: widget.width ?? 0.23.sw,
                          fontsize: widget.fontSize ?? 11.sp,
                          shape: widget.shape,
                          fontColor: Colors.black87,
                          color: Colors.grey.shade100,
                          isBordered: false,
                          isCentered: widget.isCentered,
                          onTap: () {},
                        );
                      }

                      // Diplay Loader
                      return Button(
                        height: widget.height ?? 0.1.sw,
                        width: widget.width ?? 0.23.sw,
                        prefixIsLoading: true,
                        color: kSecondColor,
                        loaderIconSize: Size(0.033.sw, 0.033.sw),
                        prefixIconColor: widget.shape == 'inline' ? Colors.black54 : Colors.white,
                        onTap: () {},
                        shape: widget.shape,
                        isCentered: widget.isCentered,
                      );
                    },
                  )
                : Container(),

        // HANDLE REMOVE A FOLLOWER
        widget.status == 'remove' && widget.user.id != FirebaseAuth.instance.currentUser!.uid
            ? StreamBuilder(
                stream: CombineLatestStream.list([
                  FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid),
                  FirestoreMethods.getUserById(widget.user.id)
                ]),
                builder: (context, snapshot) {
                  // Handle error
                  if (snapshot.hasError) {
                    log('error: ${snapshot.error}');
                    return Button(
                      text: 'Error...',
                      height: widget.height ?? 0.1.sw,
                      width: widget.width ?? 0.23.sw,
                      fontsize: widget.fontSize ?? 11.sp,
                      shape: widget.shape,
                      isCentered: widget.isCentered,
                      fontColor: Colors.grey.shade700,
                      color: Colors.grey.shade100,
                      isBordered: false,
                      onTap: () {},
                    );
                  }

                  // handle data
                  if (snapshot.hasData && snapshot.data != null) {
                    List<usermodel.User?> data = snapshot.data as List<usermodel.User>;
                    usermodel.User? currentUser = data[0];
                    usermodel.User? userGet = data[1];

                    if (currentUser != null &&
                        userGet != null &&
                        currentUser.followers != null &&
                        currentUser.followings != null &&
                        userGet.followers != null &&
                        userGet.followings != null) {
                      // CurrentUser Followers && Followings
                      List<String> currentUserFollowers =
                          currentUser.followers!.map((followerId) => followerId.toString()).toList();
                      currentUser.followings!.map((followingId) => followingId.toString()).toList();

                      // Get User Followers && Followings
                      userGet.followers!.map((followerId) => followerId.toString()).toList();
                      List<String> getUserFollowings =
                          userGet.followings!.map((followingId) => followingId.toString()).toList();

                      // Case : Remove
                      if (currentUserFollowers.contains(userGet.id) && getUserFollowings.contains(currentUser.id)) {
                        return Button(
                          text: 'Remove',
                          shape: widget.shape,
                          isCentered: widget.isCentered,
                          height: widget.height ?? 0.1.sw,
                          width: widget.width ?? 0.23.sw,
                          fontsize: widget.fontSize ?? 11.sp,
                          fontColor: Colors.black87,
                          color: Colors.grey.shade100,
                          isBordered: false,
                          onTap: () async {
                            //
                            await FirestoreMethods.removeUserAsFollower(context, userGet.id);
                          },
                        );
                      }
                    }

                    // Diplay Loader
                    return Button(
                      height: widget.height ?? 0.1.sw,
                      width: widget.width ?? 0.23.sw,
                      shape: widget.shape,
                      isCentered: widget.isCentered,
                      color: Colors.grey.shade100,
                      prefixIsLoading: true,
                      loaderIconSize: Size(0.033.sw, 0.033.sw),
                      prefixIconColor: Colors.black54,
                      onTap: () {},
                    );
                  }

                  return Button(
                    text: '...',
                    shape: widget.shape,
                    isCentered: widget.isCentered,
                    height: widget.height ?? 0.1.sw,
                    width: widget.width ?? 0.23.sw,
                    fontsize: widget.fontSize ?? 11.sp,
                    fontColor: Colors.black,
                    color: Colors.grey.shade100,
                    isBordered: false,
                    onTap: () {},
                  );
                },
              )
            : Container(),
      ],
    );
  }
}

//
//
// BUILD AVATAR AND USERNAME
class BuildAvatarAndUsername extends StatefulWidget {
  final String uidPoster;
  final Color? fontColor;
  final double? fontSize;
  final double? radius;
  final double? avatarUsernameSpace;
  final double? loaderRadius;

  const BuildAvatarAndUsername(
      {super.key,
      required this.uidPoster,
      this.radius,
      this.fontColor,
      this.fontSize,
      this.loaderRadius,
      this.avatarUsernameSpace});

  @override
  State<BuildAvatarAndUsername> createState() => BuildAvatarAndUsernameState();
}

class BuildAvatarAndUsernameState extends State<BuildAvatarAndUsername> {
  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<usermodel.User?>(
      stream: FirestoreMethods.getUserById(widget.uidPoster),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 30),
                height: widget.loaderRadius ?? 0.05.sw,
                width: widget.loaderRadius ?? 0.05.sw,
                child: RepaintBoundary(child: CircularProgressIndicator(strokeWidth: 1.6, color: widget.fontColor)),
              ),
            ],
          );
        }

        if (snapshot.hasData) {
          usermodel.User currentUser = snapshot.data as usermodel.User;

          return GestureDetector(
            onTap: () {
              // Redirect to Profile Page
              Navigator.push(
                  context,
                  SwipeablePageRoute(
                    builder: (context) => ProfilePage(uid: widget.uidPoster, showBackButton: true),
                  ));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: widget.avatarUsernameSpace ?? 6),
                  child: BuildCachedNetworkImage(
                    url: currentUser.profilePicture,
                    radius: widget.radius ?? 13,
                    backgroundColor: kGreyColor,
                    paddingOfProgressIndicator: 10,
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.only(right: 5),
                    child: Wrap(
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser!.uid == currentUser.id ? 'Me' : currentUser.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: widget.fontColor,
                              overflow: TextOverflow.ellipsis,
                              fontSize: widget.fontSize ?? 14.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

//
//
// BUILD ATTACHED EVENT :for story header
class BuildAttachedEventRow extends StatefulWidget {
  final String eventId;
  final StoryController? storyController;
  const BuildAttachedEventRow({super.key, required this.eventId, this.storyController});

  @override
  State<BuildAttachedEventRow> createState() => BuildAttachedEventRowState();
}

class BuildAttachedEventRowState extends State<BuildAttachedEventRow> {
  @override
  Widget build(BuildContext context) {
    return widget.eventId.isNotEmpty
        ? FutureBuilder(
            future: FirestoreMethods.getEventByIdAsFuture(widget.eventId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.splotch,
                      color: Colors.white60,
                      size: 10.sp,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(right: 30),
                        height: 10,
                        width: double.infinity,
                        child: Text(
                          '...',
                          style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                        ),
                      ),
                    ),
                  ],
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
                            minHeightSize: MediaQuery.of(context).size.height / 1.4,
                            maxHeightSize: MediaQuery.of(context).size.height,
                            child: EventView(eventId: currentEvent.eventId),
                          )),
                    );

                    if (result == null) {
                      widget.storyController!.play();
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.splotch,
                        color: Colors.white,
                        size: 10.sp,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Flexible(
                        child: Text(
                          currentEvent.title,
                          style: TextStyle(
                              fontSize: 10.sp,
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

//
//
// BUILD PAYMENT ROW WIDGET
class BuildPaymentRow extends StatefulWidget {
  final String paymentId;
  const BuildPaymentRow({super.key, required this.paymentId});

  @override
  State<BuildPaymentRow> createState() => BuildPaymentRowState();
}

class BuildPaymentRowState extends State<BuildPaymentRow> {
  @override
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Payment>(
      stream: FirestoreMethods.getPaymentByPaymentId(widget.paymentId),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('...'),
          );
        }

        if (snapshot.hasData) {
          Payment paymentGet = snapshot.data!;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Show Payment Modal Viewer
              showModalBottomSheet(
                enableDrag: true,
                isScrollControlled: true,
                context: context,
                backgroundColor: Colors.transparent,
                builder: ((context) => Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Modal(
                        minHeightSize: 300,
                        child: PaymentViewerModal(paymentId: widget.paymentId),
                      ),
                    )),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Trailing
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CircleAvatar(
                          radius: 0.045.sw,
                          backgroundColor: Colors.green.shade300,
                          child: Icon(FontAwesomeIcons.dollarSign, color: Colors.white, size: 0.04.sw),
                        ),
                      ),

                      // Payment content
                      Expanded(
                        child: Wrap(
                          children: [
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              text: TextSpan(
                                text:
                                    'Vous ${paymentGet.userSenderId == FirebaseAuth.instance.currentUser!.uid ? 'l\'avez envoyé ' : 'avez reçu '}',
                                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '${paymentGet.amount} '
                                          '${getPaymentMethodDevise(paymentGet.paymentMethod)} ',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: paymentGet.paymentMethod != mtnMobileMoneyLabel &&
                                              paymentGet.paymentMethod != airtelMoneyLabel
                                          ? 'au '
                                          : paymentGet.userSenderId == FirebaseAuth.instance.currentUser!.uid
                                              ? 'sur ce numéro '
                                              : 'à travers ce numero '),
                                  TextSpan(
                                      text: paymentGet.receiverPhoneNumber,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // Display Loader
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: IntrinsicHeight(
                child: Container(width: 3, color: Colors.green),
              ),
            ),
            const SizedBox(
              width: 3,
            ),
            const Column(
              children: [
                Text('...'),
                SizedBox(height: 8),
              ],
            ),
          ],
        );
      },
    );
  }
}

//
//
// BUILD USER NAME
class BuildUserNameToDisplay extends StatefulWidget {
  final String userId;
  final String? textAppend;
  final String? textSuffix;
  final bool? isMessagePreviewCard;
  final bool? hasShimmerLoader;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  const BuildUserNameToDisplay({
    super.key,
    required this.userId,
    this.isMessagePreviewCard,
    this.hasShimmerLoader,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.textAppend,
    this.textSuffix,
  });

  @override
  State<BuildUserNameToDisplay> createState() => BuildUserNameStateToDisplay();
}

class BuildUserNameStateToDisplay extends State<BuildUserNameToDisplay> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<usermodel.User?>(
      stream: FirestoreMethods.getUserById(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            '...',
            style: TextStyle(
              color: widget.textColor ?? Colors.black,
              fontWeight: widget.fontWeight ?? FontWeight.w700,
              fontSize: widget.fontSize ?? 14.sp,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          usermodel.User currentUser = snapshot.data as usermodel.User;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                children: [
                  Text(
                    widget.textAppend ?? '',
                    style: TextStyle(color: widget.textColor ?? Colors.black, fontSize: widget.fontSize ?? 14.sp),
                  ),
                  Text(
                    () {
                      if (widget.isMessagePreviewCard != null && widget.isMessagePreviewCard == true) {
                        if (widget.userId == FirebaseAuth.instance.currentUser!.uid) {
                          return 'Me';
                        } else {
                          return currentUser.name;
                        }
                      }

                      return currentUser.name;
                    }(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.textColor ?? Colors.black,
                      fontWeight: widget.fontWeight ?? FontWeight.w700,
                      fontSize: widget.fontSize ?? 14.sp,
                    ),
                  ),
                  Text(
                    widget.textSuffix ?? '',
                    style: TextStyle(color: widget.textColor ?? Colors.black, fontSize: widget.fontSize ?? 14.sp),
                  ),
                ],
              ),
            ],
          );
        }

        // Diplay Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.hasShimmerLoader != null && widget.hasShimmerLoader == true
              ? Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade300,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.only(bottom: 2),
                    width: 100,
                    height: 10,
                  ),
                )
              : Text(
                  '...',
                  style: TextStyle(
                    color: widget.textColor ?? Colors.black,
                    fontWeight: widget.fontWeight ?? FontWeight.w700,
                    fontSize: widget.fontSize ?? 14.sp,
                  ),
                );
        }

        return Container();
      },
    );
  }
}

//
//
// BUILD EVENT NAME
class BuildEventNameToDisplay extends StatefulWidget {
  final String eventId;
  final String? appendText;
  final bool? isMessagePreviewCard;
  final bool? hasShimmerLoader;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  const BuildEventNameToDisplay({
    super.key,
    required this.eventId,
    this.isMessagePreviewCard,
    this.hasShimmerLoader,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.appendText,
  });

  @override
  State<BuildEventNameToDisplay> createState() => BuildEventNameStateToDisplay();
}

class BuildEventNameStateToDisplay extends State<BuildEventNameToDisplay> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
      stream: FirestoreMethods.getEventById(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('...');
        }

        if (snapshot.hasData && snapshot.data != null) {
          Event currentEvent = snapshot.data as Event;

          return Expanded(
              child: GestureDetector(
            onTap: () {
              // Show EventView Modal
              showModalBottomSheet(
                enableDrag: true,
                isScrollControlled: true,
                context: context,
                backgroundColor: Colors.transparent,
                builder: ((context) => Modal(
                      minHeightSize: MediaQuery.of(context).size.height / 1.4,
                      maxHeightSize: MediaQuery.of(context).size.height,
                      child: EventView(eventId: widget.eventId),
                    )),
              );
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: widget.appendText ?? '',
                style: TextStyle(
                  color: widget.textColor ?? Colors.black,
                  fontSize: widget.fontSize ?? 14.sp,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: currentEvent.title,
                    style: TextStyle(
                      fontWeight: widget.fontWeight ?? FontWeight.w700,
                      fontSize: widget.fontSize ?? 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ));
        }

        // Diplay Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.hasShimmerLoader != null && widget.hasShimmerLoader == true
              ? Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade300,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    width: 180,
                    height: 15,
                    color: Colors.grey.shade300,
                  ))
              : const Text('...');
        }

        return Container();
      },
    );
  }
}

//
//
// BUILD NUMBER OF UNREAD MESSAGES IN DISCUSSION CARD
class BuildNumberOfUnreadMessages extends StatefulWidget {
  final Discussion discussion;
  const BuildNumberOfUnreadMessages({super.key, required this.discussion});

  @override
  State<BuildNumberOfUnreadMessages> createState() => BuildNumberOfUnreadMessagesState();
}

class BuildNumberOfUnreadMessagesState extends State<BuildNumberOfUnreadMessages> {
  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreMethods.getMessagesByDiscussionId(widget.discussion.discussionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.hasData && snapshot.data != null) {
          List<Message> discussionMessages = snapshot.data as List<Message>;

          List<Message> messagesList = [];
          int numberOfUnreadMesages = 0;
          // Get unread messages

          // Get messages by messageById
          for (Message message in discussionMessages) {
            // Check if message if Unread && Isn't mine && Status =! 0
            if (message.status != 0 &&
                !message.seen.contains(FirebaseAuth.instance.currentUser!.uid) &&
                message.receiverId == FirebaseAuth.instance.currentUser!.uid) {
              messagesList.add(message);
            }
          }
          numberOfUnreadMesages = messagesList.length;

          // DISPLAY NUMBER OF UNREAD MESSAGES
          return numberOfUnreadMesages > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                  decoration: BoxDecoration(
                    color: kSecondColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    numberOfUnreadMesages.toString(),
                    style: TextStyle(fontSize: 11.sp, color: Colors.white),
                  ),
                )
              : const Text('');
        }

        // Diplay Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade300,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade300,
                  ),
                  margin: const EdgeInsets.only(bottom: 2),
                  width: 15,
                  height: 15,
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}

//
//
// BUILD LAST MESSAGE IN DISCUSSION CARD
class BuildLastMessageInDiscussionCard extends StatefulWidget {
  final Discussion discussion;

  const BuildLastMessageInDiscussionCard({super.key, required this.discussion});

  @override
  State<BuildLastMessageInDiscussionCard> createState() => BuildLastMessageInDiscussionCardState();
}

class BuildLastMessageInDiscussionCardState extends State<BuildLastMessageInDiscussionCard> {
  @override
  void initState() {
    //
    super.initState();
    //
  }

  @override
  void dispose() {
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreMethods.getMessagesByDiscussionId(widget.discussion.discussionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.hasData && snapshot.data != null) {
          List<Message> discussionMessages = snapshot.data as List<Message>;
          Message? messageToDisplay = getLastMessageOfDiscussion(discussionMessages);
          //
          // DISPLAY LAST MESSAGE
          return messageToDisplay != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //
                    messageToDisplay.status != 0 && messageToDisplay.senderId == FirebaseAuth.instance.currentUser!.uid
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: getMessageStatusIcon(messageToDisplay),
                          )
                        : Container(),

                    Expanded(child: () {
                      // DISPLAY TEXT MESSAGE
                      if (messageToDisplay.type == 'text') {
                        return Wrap(
                          children: [
                            Text(
                              messageToDisplay.data,
                              maxLines: 1,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 12.sp,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        );
                      }
                      // DISPLAY NON-TEXT MESSAGE
                      if (messageToDisplay.type != 'text') {
                        return Row(
                          children: [
                            getMsgTypeIcon(
                                messageStatus: messageToDisplay.status, lastMessageType: messageToDisplay.type),
                            Expanded(
                              child: Text(
                                  messageToDisplay.caption.isNotEmpty
                                      ? messageToDisplay.caption
                                      : getDefaultMessageCaptionByType(messageToDisplay.type),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 12.sp,
                                      color: Colors.black.withOpacity(0.7))),
                            )
                          ],
                        );
                      }
                      return Container();
                    }()),
                    //
                    messageToDisplay.messageId.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              maxLines: 1,
                              getTimeAgoShortForm(messageToDisplay.createdAt),
                              style: TextStyle(fontSize: 12.sp, color: kSecondColor, fontWeight: FontWeight.bold),
                            ),
                          )
                        : const Text(''),
                  ],
                )
              : const Text('');
        }

        // Diplay Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade300,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: const EdgeInsets.only(bottom: 2, top: 3),
                  width: 70,
                  height: 8.5,
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}

//
//
// BUILD USER PROFILE PICTURE
class BuildUserProfilePicture extends StatefulWidget {
  final String userId;
  final String? heroTag;
  final double? radius;

  const BuildUserProfilePicture({super.key, required this.userId, this.radius, this.heroTag});

  @override
  State<BuildUserProfilePicture> createState() => BuildUserProfilePictureState();
}

class BuildUserProfilePictureState extends State<BuildUserProfilePicture> {
  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<usermodel.User?>(
      stream: FirestoreMethods.getUserById(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CircleAvatar(
            radius: widget.radius ?? 0.07.sw,
            backgroundColor: kGreyColor,
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          usermodel.User currentUser = snapshot.data as usermodel.User;

          return BuildCachedNetworkImage(
            url: currentUser.profilePicture,
            radius: widget.radius ?? 0.07.sw,
            backgroundColor: kGreyColor,
            paddingOfProgressIndicator: 10,
          );
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade300,
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            radius: widget.radius ?? 0.07.sw,
          ),
        );
      },
    );
  }
}

//
//
// BUILD FOREVER COVER
class BuildForeverCover extends StatefulWidget {
  final String foreverId;
  final double? radius;
  final double? contentPadding;
  final double? contentMinFontSize;
  final Size? contentSize;

  const BuildForeverCover({
    super.key,
    required this.foreverId,
    this.radius,
    this.contentSize,
    this.contentPadding,
    this.contentMinFontSize,
  });

  @override
  State<BuildForeverCover> createState() => BuildForeverCoverState();
}

class BuildForeverCoverState extends State<BuildForeverCover> {
  bool isLoading = false;

  Forever? forever;
  @override
  void initState() {
    //
    super.initState();

    getForeverData();
  }

  Future getForeverData() async {
    setState(() {
      isLoading = true;
    });

    forever = await FirestoreMethods.getForeverByIdAsFuture(widget.foreverId);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return forever != null && !isLoading
        ? FutureBuilder<Widget?>(
            future: FirestoreMethods.getForeverCoverByFirstStoryId(
              contentPadding: widget.contentPadding,
              contentMinFontSize: widget.contentMinFontSize,
              storyId: forever!.stories.first,
              height: widget.contentSize?.height,
              width: widget.contentSize?.height,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return CircleAvatar(
                  radius: widget.radius ?? 0.07.sw,
                  backgroundColor: kGreyColor,
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                Widget cover = snapshot.data as Widget;

                return CircleAvatar(
                  radius: widget.radius ?? 0.07.sw,
                  backgroundColor: kGreyColor,
                  child: ClipOval(
                    child: cover,
                  ),
                );
              }
              return CircleAvatar(
                  radius: widget.radius ?? 0.07.sw,
                  backgroundColor: kGreyColor,
                  child: const SizedBox(
                    height: 13,
                    width: 13,
                    child: RepaintBoundary(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                    ),
                  ));
            },
          )
        : CircleAvatar(
            radius: widget.radius ?? 0.07.sw,
            backgroundColor: kGreyColor,
          );
  }
}

//
//

//
//
// DIVIDER WITH LABEL
class BuildDividerWithLabel extends StatelessWidget {
  final String label;
  final Color? fontColor;
  const BuildDividerWithLabel({
    super.key,
    required this.label,
    this.fontColor,
  });

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
          child: Text(
            label,
            style: TextStyle(color: fontColor ?? Colors.black45, fontSize: 12.sp),
          ),
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

//
//
// DIVIDER
class BuildDivider extends StatelessWidget {
  final double? padding;
  const BuildDivider({
    super.key,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding ?? 13),
      child: Divider(
        color: Colors.grey.shade300,
        height: 1.7,
      ),
    );
  }
}

//
//
// GROUP DIVIDER
class BuildGroupSeparatorWidget extends StatelessWidget {
  final DateTime groupByValue;
  final bool simpleMode;
  const BuildGroupSeparatorWidget({
    super.key,
    required this.groupByValue,
    required this.simpleMode,
  });

  String getTextToDisplay() {
    if (groupByValue == DateUtils.dateOnly(DateTime.now())) {
      return 'Today';
    } else if (groupByValue == DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else if (groupByValue == DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 2)))) {
      return 'The day before yesterday';
    }

    return DateFormat('dd MMM yyyy', 'en_En').format(groupByValue);
  }

  @override
  Widget build(BuildContext context) {
    return simpleMode
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 10),
                child: Text(
                  getTextToDisplay(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoTheme(
                  data: const CupertinoThemeData(
                    primaryColor: kGreyColor,
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(15),
                    elevation: 2,
                    child: CupertinoButton.filled(
                      onPressed: () {},
                      borderRadius: BorderRadius.circular(15),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                      child: Text(
                        getTextToDisplay(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

//
//
// INTRODUCTION PAGE CONTENT
class BuildIntroductionPageContent extends StatelessWidget {
  final String animationPath;
  final String title;
  final String description;

  const BuildIntroductionPageContent(
      {super.key, required this.animationPath, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2.5,
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
          style: TextStyle(
            fontSize: 22.0.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 0.07.sw),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0.sp,
          ),
        ),
      ],
    );
  }
}

//
//
// BUTTON FILE PICKER
class ButtonPicker extends StatelessWidget {
  final Widget icon;
  final Color widgetColor;
  final String label;
  final VoidCallback function;

  const ButtonPicker({
    super.key,
    required this.icon,
    required this.widgetColor,
    required this.label,
    required this.function,
  });

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
                radius: 23.r,
                backgroundColor: widgetColor,
                child: icon,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontSize: 12.sp,
                ),
              )
            ],
          )),
    );
  }
}

//
//
// BUILD CIRCLE AVATAR STORIES WRAPPER GRIDPREVIEW
class BuildCircleAvatarStoriesWrapper extends StatelessWidget {
  final double? radius;
  final double? padding;
  final Widget child;
  const BuildCircleAvatarStoriesWrapper({
    super.key,
    required this.storiesHandler,
    this.radius,
    this.padding,
    required this.child,
  });

  final StoriesHandler storiesHandler;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: hasSeenAllStories(storiesHandler.stories) ? Colors.grey.shade500 : kSecondColor,
      radius: radius ?? 0.07.sw,
      child: Padding(
        padding: EdgeInsets.all(padding ?? 2),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: radius ?? 0.07.sw,
          child: Padding(
            padding: EdgeInsets.all(padding ?? 2),
            child: child,
          ),
        ),
      ),
    );
  }
}

//
//
// BUILD STORY GRIDPREVIEW
class BuildStoryGridPreview extends StatefulWidget {
  final Widget? header;
  final Widget? footer;
  final Story story;

  const BuildStoryGridPreview({super.key, this.footer, required this.story, this.header});

  @override
  State<BuildStoryGridPreview> createState() => BuildStoryGridPreviewState();
}

class BuildStoryGridPreviewState extends State<BuildStoryGridPreview> {
  Size gridSize = const Size(0, 0);
  @override
  Widget build(BuildContext context) {
    return WidgetSize(
      onChange: (Size size) {
        // your Widget size available here
        setState(() {
          gridSize = size;
        });
      },
      child: GridTile(
        header: widget.header,
        footer: widget.footer,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Content
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: getStoryGridPreviewThumbnail(
                storySelected: widget.story,
                height: gridSize.height,
                width: gridSize.width,
                contentPadding: 20,
                isForever: false,
              ),
            ),
            // Bg Shadow
            Container(
                height: gridSize.height / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
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

//
//
// BUILD EMOJI PICKER
class EmojiPickerOffstage extends StatelessWidget {
  const EmojiPickerOffstage({
    super.key,
    required this.showEmojiKeyboard,
    required this.textController,
    this.onBackspacePressed,
    this.onEmojiSelected,
  });

  final bool showEmojiKeyboard;
  final TextEditingController textController;
  final VoidCallback? onBackspacePressed;
  final Function(Category?, Emoji)? onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !showEmojiKeyboard,
      child: SizedBox(
          height: 250,
          child: EmojiPicker(
            onBackspacePressed: onBackspacePressed,
            onEmojiSelected: onEmojiSelected,
            textEditingController: textController,
            config: const Config(
              categoryViewConfig: CategoryViewConfig(
                showBackspaceButton: true,
                recentTabBehavior: RecentTabBehavior.RECENT,
                backgroundColor: Color(0xFFF2F2F2),
                indicatorColor: kSecondColor,
                iconColor: Colors.grey,
                iconColorSelected: kSecondColor,
                backspaceColor: kSecondColor,
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: CategoryIcons(),
              ),
            ),
          )),
    );
  }
}

//
//
// BUILD EVENT DURATION CARD
class BuildEventDurationCard extends StatefulWidget {
  const BuildEventDurationCard({
    super.key,
    required this.setDate,
    required this.setStartTime,
    required this.setEndTime,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAllTheDay,
    required this.setIsAllTheDay,
  });

  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAllTheDay;
  final Function() setDate;
  final Function() setStartTime;
  final Function() setEndTime;
  final Function(bool newValue) setIsAllTheDay;

  @override
  State<BuildEventDurationCard> createState() => BuildEventDurationCardState();
}

class BuildEventDurationCardState extends State<BuildEventDurationCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Body
        const SizedBox(
          height: 10,
        ),

        // Set Date
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 22.sp, color: Colors.white),
            const SizedBox(
              width: 5,
            ),
            Text(
              'Date',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
            const Spacer(),
            DateTimeButton(
              fontColor: Colors.white,
              hasBorder: false,
              date: widget.date,
              type: 'date',
              onTap: widget.setDate,
            )
          ],
        ),

        // Set IsAllTheDayEvent
        Row(
          children: [
            Icon(Icons.sunny, size: 22.sp, color: Colors.white),
            const SizedBox(
              width: 5,
            ),
            Text(
              'All-day',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
            const Spacer(),
            SwitchTheme(
                data: SwitchThemeData(
                  thumbColor: WidgetStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }

                      return Colors.white54;
                    },
                  ),
                  trackColor: WidgetStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return kSecondColor.withOpacity(.2);
                      }
                      return Colors.black26;
                    },
                  ),
                ),
                child: Switch(value: widget.isAllTheDay, onChanged: widget.setIsAllTheDay)),
          ],
        ),
        Visibility(visible: !widget.isAllTheDay, child: const BuildDivider(padding: 10)),

        Visibility(
          visible: !widget.isAllTheDay,
          child: Row(
            children: [
              // Add  Event Start Time
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      'Start time',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    DateTimeButton(
                      borderColor: Colors.white,
                      fontColor: Colors.white,
                      timeOfDay: widget.startTime,
                      type: 'time',
                      onTap: widget.setStartTime,
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              // Add Event End Time
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      'End time',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    DateTimeButton(
                      borderColor: Colors.white,
                      fontColor: Colors.white,
                      timeOfDay: widget.endTime,
                      type: 'time',
                      onTap: widget.setEndTime,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

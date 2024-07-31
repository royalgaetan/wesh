import 'dart:developer';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wesh/models/event.dart';
import 'package:wesh/models/forever.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/models/story.dart';
import 'package:wesh/pages/in.pages/create_or_update_forever.dart';
import 'package:wesh/pages/in.pages/people.dart';
import 'package:wesh/pages/in.pages/settings.dart';
import 'package:wesh/services/auth.methods.dart';
import 'package:wesh/widgets/forever_card.dart';
import 'package:wesh/widgets/remindercard.dart';
import '../models/stories_handler.dart';
import 'package:wesh/widgets/eventcard.dart';
import '../services/firestore.methods.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import '../widgets/buildWidgets.dart';
import 'in.pages/create_or_update_event.dart';
import 'in.pages/create_or_update_reminder.dart';
import '../models/user.dart' as usermodel;
import 'in.pages/fileviewer.dart';
import 'in.pages/inbox.dart';
import 'in.pages/storiesViewer.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final bool? showBackButton;
  final ValueNotifier<bool>? scrollToTop;

  const ProfilePage({super.key, required this.uid, this.showBackButton, this.scrollToTop});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // CANCEL ALL USER'EVENTS NOTIFICATIONS ONCE ON PROFILE PAGE
    log('[Cancel all ${widget.uid} events notifications]');
    setCurrentActivePageFromIndex(index: 4, userId: widget.uid);

    // Listen to scroll to top: from outside
    if (widget.scrollToTop != null) {
      widget.scrollToTop?.addListener(() {
        if (widget.scrollToTop!.value) {
          scrollToTop();
        }
      });
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return SafeArea(
      child: StreamBuilder(
        stream: FirestoreMethods.getUserById(widget.uid),
        builder: (context, snapshot) {
          // Handle Errors
          if (snapshot.hasError) {
            debugPrint('error: ${snapshot.error}');
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: MorphingAppBar(
                toolbarHeight: 46,
                scrolledUnderElevation: 0.0,
                backgroundColor: Colors.white,
                titleSpacing: 0,
                elevation: 0,
                leading: widget.showBackButton == true
                    ? IconButton(
                        splashRadius: 0.06.sw,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                        ),
                      )
                    : Container(),
                title: widget.showBackButton == true
                    ? const Text(
                        'Profile',
                        style: TextStyle(color: Colors.black),
                      )
                    : Container(),
                actions: [
                  // Display Logout button only if currentUser == [Me]
                  widget.uid == FirebaseAuth.instance.currentUser!.uid && widget.showBackButton != true
                      ? Tooltip(
                          message: 'Logout',
                          child: IconButton(
                            splashRadius: 0.06.sw,
                            onPressed: () async {
                              // Show Delete Decision Modal
                              List deleteDecision = await showModalDecision(
                                context: context,
                                header: 'Logout',
                                content: 'Do you really want to log out?',
                                firstButton: 'Cancel',
                                secondButton: 'Logout',
                              );

                              if (deleteDecision[0] == true) {
                                // Sign out
                                // ignore: use_build_context_synchronously
                                AuthMethods.signout(context);
                              }
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: kSecondColor,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BuildErrorWidget(onWhiteBackground: true),
                  ],
                ),
              ),
            );
          }

          // Data loaded successfully
          if (snapshot.hasData) {
            usermodel.User currentUser = snapshot.data as usermodel.User;
            return Scaffold(
              backgroundColor: Colors.white,
              body: DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  controller: scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    // APP BAR
                    MorphingSliverAppBar(
                      scrolledUnderElevation: 0.0,
                      heroTag: 'profilePageAppBar',
                      backgroundColor: Colors.white,
                      elevation: 0,
                      expandedHeight: 70,
                      pinned: false,
                      floating: false,
                      snap: false,
                      leading: Container(),
                      flexibleSpace: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            width: 200,
                            child: FlexibleSpaceBar(
                              centerTitle: false,
                              titlePadding: const EdgeInsets.only(bottom: 0, left: 15),
                              title: Text(
                                'Profile',
                                style: TextStyle(color: Colors.black, fontSize: 17.sp),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Navigator.of(context).canPop() &&
                                  widget.showBackButton != null &&
                                  widget.showBackButton == true
                              ? IconButton(
                                  splashRadius: 0.06.sw,
                                  onPressed: () {
                                    // Redirect to Settings Page
                                    Navigator.pop(context);
                                  },
                                  icon: Transform.scale(
                                    scale: 1.2,
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),

                    // TOP BODY
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // HEADER
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Picture
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        // Preview Profile Picture
                                        context.pushTransparentRoute(
                                          FileViewer(
                                              fileType: 'profilePicture',
                                              fileName: currentUser.id,
                                              data: currentUser.profilePicture,
                                              thumbnail: ''),
                                        );
                                      },
                                      child: BuildCachedNetworkImage(
                                        url: currentUser.profilePicture,
                                        radius: 0.10.sw,
                                        backgroundColor: kGreyColor,
                                        paddingOfProgressIndicator: 7,
                                      ),
                                    ),

                                    // Build StoriesViewer Btn
                                    FutureBuilder(
                                      future: FirestoreMethods.getUserNonExpiredStoriesAsFuture(currentUser.id),
                                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                                        // Handle error
                                        if (snapshot.hasError) {
                                          log('error: ${snapshot.error}');
                                          return Container();
                                        }

                                        // Display DATA
                                        if (snapshot.hasData) {
                                          List<Story> currentUserStories = snapshot.data!;

                                          if (currentUserStories.isNotEmpty) {
                                            // Manage first of all [My] Stories

                                            // Sort [My] Stories
                                            currentUserStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));

                                            // Build [My] StoriesHandler
                                            StoriesHandler storiesHandler = StoriesHandler(
                                              origin: 'userStories',
                                              posterId: currentUser.id,
                                              avatarPath: currentUser.profilePicture,
                                              title: currentUser.name,
                                              lastStoryDateTime:
                                                  getLastStoryOfStoriesList(currentUserStories).createdAt,
                                              stories: currentUserStories,
                                            );

                                            return InkWell(
                                              borderRadius: BorderRadius.circular(50),
                                              onTap: () async {
                                                //                       //
                                                // showFullPageLoader(context: context, color: Colors.white);
                                                // //

                                                // // Dismiss loader
                                                // if (!mounted) return;
                                                // Navigator.of(context).pop();

                                                // Story Page View
                                                if (!mounted) return;
                                                context.pushTransparentRoute(StoriesViewer(
                                                  storiesHandlerList: [storiesHandler],
                                                  indexInStoriesHandlerList: 0,
                                                ));
                                              },
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 0.04.sw,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2),
                                                  child: CircleAvatar(
                                                    backgroundColor: hasSeenAllStories(storiesHandler.stories)
                                                        ? Colors.grey.shade500
                                                        : kSecondColor,
                                                    radius: 0.04.sw,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(2),
                                                      child: Icon(
                                                        FontAwesomeIcons.circleNotch,
                                                        color: Colors.white,
                                                        size: 13.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }

                                        // Display Loader
                                        return Center(
                                          child: CircleAvatar(
                                            radius: 0.04.sw,
                                            backgroundColor: kGreyColor,
                                            child: const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 20,
                                ),

                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Name
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              currentUser.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),

                                      // Username
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.alternate_email_rounded,
                                            color: Colors.black54,
                                            size: 13.sp,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                              currentUser.username,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 5,
                                      ),

                                      // Birthday
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.cake_rounded,
                                            color: Colors.black54,
                                            size: 13.sp,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Expanded(
                                            child: Text(
                                              DateFormat('dd MMMM', 'en_En').format(currentUser.birthday),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Bio
                                      currentUser.bio.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(top: 5),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.tag,
                                                    color: Colors.black54,
                                                    size: 13.sp,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: Wrap(
                                                      children: [
                                                        Text(
                                                          currentUser.bio,
                                                          style: TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 12.sp,
                                                              fontWeight: FontWeight.w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),

                                      // Link in Bio
                                      currentUser.linkinbio.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () async {
                                                Uri urlToLaunch = Uri.parse(currentUser.linkinbio);

                                                if (!currentUser.linkinbio.startsWith("http://") &&
                                                    !currentUser.linkinbio.startsWith("https://")) {
                                                  urlToLaunch = Uri.parse("http://${currentUser.linkinbio}");
                                                }

                                                if (!await launchUrl(urlToLaunch)) {
                                                  // ignore: use_build_context_synchronously
                                                  showSnackbar(context, 'Impossible de lancer cette url', null);
                                                  throw 'Could not launch $urlToLaunch';
                                                }
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      FontAwesomeIcons.link,
                                                      color: Colors.black54,
                                                      size: 10.sp,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        formatUrlToSlug(currentUser.linkinbio),
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: kInfoColor,
                                                            fontSize: 12.sp,
                                                            fontWeight: FontWeight.w400),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),

                                      // [anyUser different from [Me] PROFILE BUTTONS] : Follow/Unfollow button
                                      Visibility(
                                        visible: widget.uid != FirebaseAuth.instance.currentUser!.uid,
                                        child: Container(
                                            margin: const EdgeInsets.only(top: 8, bottom: 5),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // FOLLOW/UNFOLLOW OR REMOVE
                                                BuildFollowUnfollowOrRemoveButton(
                                                  isCentered: true,
                                                  height: 0.09.sw,
                                                  width: 0.3.sw,
                                                  user: currentUser,
                                                  status: 'followUnfollow',
                                                ),
                                              ],
                                            )),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          // PROFILE STATS
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            child: FittedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // ProfileStat(
                                  //   icon: const Icon(FontAwesomeIcons.splotch, color: Colors.black54),
                                  //   nb: currentUser.events!.length,
                                  //   label: 'Events',
                                  //   onTap: () {
                                  //     // Active Tab : Events
                                  //     // ...
                                  //   },
                                  // ),
                                  ProfileStat(
                                    icon: Icon(FontAwesomeIcons.userGroup, color: Colors.grey.shade600, size: 11.sp),
                                    nb: currentUser.followers!.length,
                                    label: 'Followers',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SwipeablePageRoute(
                                            builder: (_) => PeoplePage(
                                                  uid: currentUser.id,
                                                  initialPageIndex: 0,
                                                )),
                                      );
                                    },
                                  ),
                                  ProfileStat(
                                    icon: Icon(Icons.person_add_rounded, color: Colors.grey.shade600, size: 16.sp),
                                    nb: currentUser.followings!.length,
                                    label: 'Followings',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SwipeablePageRoute(
                                            builder: (_) => PeoplePage(
                                                  uid: currentUser.id,
                                                  initialPageIndex: 1,
                                                )),
                                      );
                                    },
                                  ),

                                  // Display: "Settings Button" for currentUser
                                  widget.uid == FirebaseAuth.instance.currentUser!.uid
                                      ? ProfileStat(
                                          icon: Icon(Icons.settings, color: Colors.grey.shade600, size: 16.sp),
                                          label: 'Settings',
                                          onTap: () {
                                            // Redirect to Settings
                                            Navigator.push(
                                                context,
                                                SwipeablePageRoute(
                                                  builder: (context) => SettingsPage(user: currentUser),
                                                ));
                                          },
                                        )
                                      :
                                      // Otherwise: display "Message Button" for [anyUser]
                                      ProfileStat(
                                          icon:
                                              Icon(Icons.chat_bubble_rounded, color: Colors.grey.shade600, size: 16.sp),
                                          label: 'Message',
                                          onTap: () {
                                            // Redirect to InboxPage
                                            Navigator.push(
                                              context,
                                              SwipeablePageRoute(
                                                builder: (_) => (InboxPage(
                                                  userReceiverId: currentUser.id,
                                                )),
                                              ),
                                            );
                                          },
                                        ),
                                ],
                              ),
                            ),
                          ),

                          // Spacer
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                  body: Column(
                    children: [
                      // TAB BAR
                      TabBar(
                        labelColor: kSecondColor,
                        unselectedLabelColor: Colors.black45,
                        indicatorColor: kSecondColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.grey.shade300,
                        splashFactory: NoSplash.splashFactory,
                        tabs: <Widget>[
                          Tooltip(
                            message: '${currentUser.events!.length} event${currentUser.events!.length > 1 ? 's' : ''}',
                            child: Tab(
                              icon: Icon(FontAwesomeIcons.splotch, size: 16.sp),
                              // text: "Vos Evénements",
                            ),
                          ),
                          Tooltip(
                            message: widget.uid == FirebaseAuth.instance.currentUser!.uid
                                ? '${currentUser.reminders!.length} reminder${currentUser.reminders!.length > 1 ? 's' : ''}'
                                : '',
                            child: Tab(
                              icon: Icon(FontAwesomeIcons.clockRotateLeft, size: 16.sp),
                              // text: "Vos Rappels",
                            ),
                          ),
                          Tooltip(
                            message:
                                '${currentUser.forevers!.length} forever${currentUser.forevers!.length > 1 ? 's' : ''}',
                            child: Tab(
                              icon: Icon(FontAwesomeIcons.circleNotch, size: 16.sp),
                              // text: "Vos Forevers",
                            ),
                          ),
                        ],
                      ),

                      //  TAB BAR CONTENT
                      Expanded(
                        child: TabBarView(
                          children: [
                            // TabBarSection 1 : Events
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: StreamBuilder<List<Event>>(
                                stream: FirestoreMethods.getUserEvents(currentUser.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Event>? eventsList = snapshot.data;
                                    eventsList!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                                    if (eventsList.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(30),
                                        height: 200,
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
                                              widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                  ? 'You have no Event'
                                                  : 'No Event found!',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                ? GestureDetector(
                                                    onTap: () {
                                                      // Redirect to Create an event Page
                                                      Navigator.push(
                                                          context,
                                                          SwipeablePageRoute(
                                                            builder: (context) => CreateOrUpdateEventPage(),
                                                          ));
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      child: const Text(
                                                        '+ Create one here',
                                                        style: TextStyle(fontSize: 14, color: kSecondColor),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      );
                                    }

                                    return ListView(
                                      children: eventsList.map((event) {
                                        return EventCard(event: event);
                                      }).toList(),
                                    );
                                  }
                                  return const SizedBox(
                                    height: 100,
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                              ),
                            ),

                            // TabBarSection 2 : Reminders
                            widget.uid == FirebaseAuth.instance.currentUser!.uid
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: StreamBuilder<List<Reminder>>(
                                      stream: FirestoreMethods.getUserReminders(currentUser.id),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          List<Reminder> listReminder = snapshot.data as List<Reminder>;

                                          listReminder.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                                          if (listReminder.isEmpty) {
                                            return Container(
                                              padding: const EdgeInsets.all(30),
                                              height: 200,
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
                                                    widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                        ? 'You have no Reminder'
                                                        : 'No Reminder found!',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                                  widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            // Redirect to Create a Reminder Page
                                                            Navigator.push(
                                                              context,
                                                              SwipeablePageRoute(
                                                                builder: (context) =>
                                                                    const CreateOrUpdateReminderPage(),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.all(8),
                                                            child: const Text(
                                                              "+ Create one here",
                                                              style: TextStyle(fontSize: 14, color: kSecondColor),
                                                            ),
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                            );
                                          }

                                          return ListView(
                                            children: listReminder.map((reminder) {
                                              return ReminderCard(reminder: reminder);
                                            }).toList(),
                                          );
                                        }
                                        return const SizedBox(
                                          height: 100,
                                          child: CupertinoActivityIndicator(),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(30),
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
                                              Icons.lock_person,
                                              size: 40,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: currentUser.name,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                              height: 1.5,
                                            ),
                                            children: const <TextSpan>[
                                              TextSpan(
                                                text: '\'s reminders\nare private',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                            //  TabBarSection 3 : Forever
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: StreamBuilder<List<Forever>>(
                                stream: FirestoreMethods.getUserForevers(currentUser.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Forever> foreversList = snapshot.data!;
                                    // Sort forevers List
                                    foreversList.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));

                                    //

                                    // No forever found
                                    if (foreversList.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(30),
                                        height: 200,
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
                                              widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                  ? 'You have no Forever'
                                                  : 'No Forever found!',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                ? GestureDetector(
                                                    onTap: () {
                                                      // Redirect to Create a Forever Page
                                                      Navigator.push(
                                                          context,
                                                          SwipeablePageRoute(
                                                            builder: (context) => const CreateOrUpdateForeverPage(),
                                                          ));
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      child: const Text(
                                                        "+ Create one here",
                                                        style: TextStyle(fontSize: 14, color: kSecondColor),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      );
                                    }

                                    // Display all forevers
                                    return ListView(
                                      padding: const EdgeInsets.all(0),
                                      children: [
                                        // Create a new forever
                                        widget.uid == FirebaseAuth.instance.currentUser!.uid
                                            ? InkWell(
                                                onTap: () {
                                                  //
                                                  Navigator.push(
                                                    context,
                                                    SwipeablePageRoute(
                                                      builder: (context) => const CreateOrUpdateForeverPage(),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                                                  child: Row(
                                                    children: [
                                                      // Trailing Avatar
                                                      CircleAvatar(
                                                        radius: 0.07.sw,
                                                        backgroundColor: kSecondColor,
                                                        child: const Icon(FontAwesomeIcons.circleNotch,
                                                            color: Colors.white),
                                                      ),

                                                      //
                                                      const SizedBox(
                                                        width: 15,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          'Create a Forever',
                                                          style:
                                                              TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                      // Edit Forever

                                                      IconButton(
                                                        splashRadius: 0.06.sw,
                                                        onPressed: null,
                                                        icon: Icon(
                                                          Icons.add,
                                                          color: Colors.black54,
                                                          size: 17.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),

                                        // All forevers
                                        ...foreversList.map((forever) {
                                          return ForeverCard(forever: forever, foreversList: foreversList);
                                        })
                                      ],
                                    );
                                  }
                                  return const SizedBox(
                                    height: 100,
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Display Loading while waiting
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: MorphingAppBar(
              toolbarHeight: 46,
              scrolledUnderElevation: 0.0,
              backgroundColor: Colors.white,
              titleSpacing: 0,
              elevation: 0,
              leading: widget.showBackButton == true
                  ? IconButton(
                      splashRadius: 0.06.sw,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.black,
                      ),
                    )
                  : Container(),
              title: widget.showBackButton == true
                  ? const Text(
                      'Profile',
                      style: TextStyle(color: Colors.black),
                    )
                  : Container(),
            ),
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(50),
                height: 100,
                child: const CupertinoActivityIndicator(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final int? nb;
  final String? label;
  final Widget icon;
  final VoidCallback onTap;
  final bool? isIconOnly;

  const ProfileStat({
    super.key,
    this.nb,
    this.label,
    required this.icon,
    required this.onTap,
    this.isIconOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // Label
          label != null
              ? Text(
                  label!,
                  style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w400, color: Colors.grey.shade600),
                )
              : Container(),
          const SizedBox(
            height: 5,
          ),

          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: Container(
              height: 0.082.sw,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  icon,

                  // Number
                  Visibility(
                    visible: isIconOnly == null && nb != null,
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      child: Text(
                        '$nb',
                        style: TextStyle(fontSize: 10.sp, color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

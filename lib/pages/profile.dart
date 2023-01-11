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
import 'package:wesh/widgets/forever_card.dart';
import 'package:wesh/widgets/remindercard.dart';
import '../models/stories_handler.dart';
import 'package:wesh/widgets/eventcard.dart';
import '../services/firestore.methods.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import '../widgets/buildWidgets.dart';
import '../widgets/button.dart';
import 'in.pages/create_or_update_event.dart';
import 'in.pages/create_or_update_reminder.dart';
import '../models/user.dart' as usermodel;
import 'in.pages/fileviewer.dart';
import 'in.pages/inbox.dart';
import 'in.pages/storiesViewer.dart';
import 'settings.pages/feedback_modal.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final bool? showBackButton;

  const ProfilePage({Key? key, required this.uid, this.showBackButton}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // CANCEL ALL USER'EVENTS NOTIFICATIONS ONCE ON PROFILE PAGE
    log('[Cancel all ${widget.uid} events notifications]');
    setCurrentActivePageFromIndex(index: 4, userId: widget.uid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
          stream: FirestoreMethods.getUserById(widget.uid),
          builder: (context, snapshot) {
            // Handle Errors
            if (snapshot.hasError) {
              debugPrint('error: ${snapshot.error}');
              return const Center(
                child: buildErrorWidget(onWhiteBackground: true),
              );
            }

            // Data loaded
            if (snapshot.hasData) {
              usermodel.User currentUser = snapshot.data as usermodel.User;
              return DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    // APP BAR
                    MorphingSliverAppBar(
                      heroTag: 'profilePageAppBar',
                      backgroundColor: Colors.white,
                      elevation: 0,
                      expandedHeight: 70,
                      pinned: true,
                      floating: true,
                      snap: true,
                      leading: Container(),
                      flexibleSpace: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            width: 200,
                            child: FlexibleSpaceBar(
                              centerTitle: false,
                              titlePadding: const EdgeInsets.only(bottom: 10, left: 15),
                              title: Text(
                                'Profil',
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
                                      child: buildCachedNetworkImage(
                                        url: currentUser.profilePicture,
                                        radius: 0.12.sw,
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
                                            StoriesHandler _storiesHandler = StoriesHandler(
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
                                                // // ignore: use_build_context_synchronously
                                                // Navigator.of(context).pop();

                                                // Story Page View
                                                // ignore: use_build_context_synchronously
                                                context.pushTransparentRoute(StoriesViewer(
                                                  storiesHandlerList: [_storiesHandler],
                                                  indexInStoriesHandlerList: 0,
                                                ));
                                              },
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 0.04.sw,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2),
                                                  child: CircleAvatar(
                                                    backgroundColor: hasSeenAllStories(_storiesHandler.stories)
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
                                      Wrap(
                                        children: [
                                          Text(
                                            currentUser.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
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
                                          Text(
                                            currentUser.username,
                                            style: TextStyle(
                                                color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 8,
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
                                            width: 5,
                                          ),
                                          Text(
                                            DateFormat('dd MMMM', 'fr_Fr').format(currentUser.birthday),
                                            style: TextStyle(
                                                color: Colors.black54, fontSize: 12.sp, fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),

                                      // Bio
                                      currentUser.bio.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(top: 13),
                                              child: Text(
                                                currentUser.bio,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.black.withOpacity(0.8),
                                                ),
                                              ),
                                            )
                                          : Container(),

                                      // Link in Bio
                                      currentUser.linkinbio.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(top: 10),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  Uri urlToLaunch = Uri.parse(currentUser.linkinbio);

                                                  if (!currentUser.linkinbio.startsWith("http://") &&
                                                      !currentUser.linkinbio.startsWith("https://")) {
                                                    urlToLaunch = Uri.parse("http://${currentUser.linkinbio}");
                                                  }

                                                  if (!await launchUrl(urlToLaunch)) {
                                                    showSnackbar(context, 'Impossible de lancer cette url', null);
                                                    throw 'Could not launch $urlToLaunch';
                                                  }
                                                },
                                                child: Text(
                                                  currentUser.linkinbio,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.lightBlue.shade600,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),

                                      // [My] PROFILE BUTTONS : Settings, Feedback
                                      widget.uid == FirebaseAuth.instance.currentUser!.uid
                                          ? FittedBox(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 20, bottom: 30),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    // SETTINGS
                                                    Button(
                                                      text: 'Paramètres',
                                                      height: 0.12.sw,
                                                      width: 0.27.sw,
                                                      prefixIcon: Icons.settings,
                                                      prefixIconSize: 15.sp,
                                                      color: kSecondColor,
                                                      onTap: () async {
                                                        // Redirect to Settings
                                                        Navigator.push(
                                                            context,
                                                            SwipeablePageRoute(
                                                              builder: (context) => SettingsPage(user: currentUser),
                                                            ));
                                                      },
                                                    ),

                                                    const SizedBox(
                                                      width: 7,
                                                    ),

                                                    // FEEDBACK
                                                    Button(
                                                      text: 'Plus',
                                                      height: 0.12.sw,
                                                      width: 0.27.sw,
                                                      prefixIcon: Icons.auto_awesome_rounded,
                                                      prefixIconSize: 15.sp,
                                                      prefixIconColor: Colors.black87,
                                                      fontColor: Colors.black,
                                                      color: const Color(0xFFF0F0F0),
                                                      isBordered: true,
                                                      onTap: () async {
                                                        // Show to Feedback Modal
                                                        await showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10)),
                                                              child: const FeedBackModal(),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )

                                          // [anyUser] PROFILE BUTTONS : Follow/Unfollow, Message
                                          : Container(
                                              constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
                                              padding: const EdgeInsets.only(top: 20, bottom: 30),
                                              child: Row(
                                                children: [
                                                  // FOLLOW/UNFOLLOW OR REMOVE
                                                  Expanded(
                                                    child: buildFollowUnfollowOrRemoveButton(
                                                      user: currentUser,
                                                      status: 'followUnfollow',
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 7,
                                                  ),

                                                  // MESSAGE BUTTON
                                                  Button(
                                                    height: 0.12.sw,
                                                    width: 0.27.sw,
                                                    prefixIcon: FontAwesomeIcons.message,
                                                    prefixIconSize: 17.sp,
                                                    prefixIconColor: Colors.black87,
                                                    fontColor: Colors.black,
                                                    color: const Color(0xFFF0F0F0),
                                                    isBordered: true,
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
                                              ))
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
                                  profileStat(
                                    icon: const Icon(FontAwesomeIcons.splotch, color: Colors.black54),
                                    nb: currentUser.events!.length,
                                    label: 'Evénements',
                                    onTap: () {
                                      // Active Tab : Events
                                      // ...
                                    },
                                  ),
                                  profileStat(
                                    icon: const Icon(FontAwesomeIcons.userCheck, color: Colors.black54),
                                    nb: currentUser.followers!.length,
                                    label: 'Abonnés',
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
                                  profileStat(
                                    icon: const Icon(FontAwesomeIcons.userGroup, color: Colors.black54),
                                    nb: currentUser.followings!.length,
                                    label: 'Abonnements',
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
                                ],
                              ),
                            ),
                          ),

                          // Divider
                          const SizedBox(height: 10),
                          const SizedBox(
                            width: double.infinity,
                            child: Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  body: Column(
                    children: [
                      // TAB BAR
                      TabBar(
                        labelColor: kSecondColor,
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorColor: kSecondColor,
                        tabs: <Widget>[
                          Tooltip(
                            message: 'Evènements',
                            child: Tab(
                              icon: Icon(FontAwesomeIcons.splotch, size: 16.sp),
                              // text: "Vos Evénements",
                            ),
                          ),
                          Tooltip(
                            message: 'Rappels',
                            child: Tab(
                              icon: Icon(FontAwesomeIcons.clockRotateLeft, size: 16.sp),
                              // text: "Vos Rappels",
                            ),
                          ),
                          Tooltip(
                            message: 'Forevers',
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
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                              child: StreamBuilder<List<Event>>(
                                stream: FirestoreMethods.getUserEvents(currentUser.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Event>? eventsList = snapshot.data;
                                    eventsList!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                                    if (eventsList.isEmpty) {
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
                                              widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                  ? 'Vous n\'avez aucun évènement'
                                                  : 'Aucun évènement trouvé !',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                ? TextButton(
                                                    onPressed: () {
                                                      // Redirect to Create an event Page
                                                      Navigator.push(
                                                          context,
                                                          SwipeablePageRoute(
                                                            builder: (context) => CreateOrUpdateEventPage(),
                                                          ));
                                                    },
                                                    child: const Text('+ Créer un évènement'),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                    child: StreamBuilder<List<Reminder>>(
                                      stream: FirestoreMethods.getUserReminders(currentUser.id),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          List<Reminder> listReminder = snapshot.data as List<Reminder>;

                                          listReminder.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                                          if (listReminder.isEmpty) {
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
                                                    widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                        ? 'Vous n\'avez aucun rappel'
                                                        : 'Aucun rappel trouvé !',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                      ? TextButton(
                                                          onPressed: () {
                                                            // Redirect to Create a Reminder Page
                                                            Navigator.push(
                                                                context,
                                                                SwipeablePageRoute(
                                                                  builder: (context) =>
                                                                      const CreateOrUpdateReminderPage(),
                                                                ));
                                                          },
                                                          child: const Text('+ Créer un rappel'),
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
                                    height: 300,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 100,
                                          width: double.infinity,
                                          child: Center(
                                            child: Icon(
                                              Icons.lock_person,
                                              size: 50,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: 'Les rappels de ',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black45,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: currentUser.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                                              const TextSpan(text: ' sont privés !'),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                            //  TabBarSection 3 : Forever
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
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
                                              widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                  ? 'Vous n\'avez aucun forever'
                                                  : 'Aucun forever trouvé !',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            widget.uid == FirebaseAuth.instance.currentUser!.uid
                                                ? TextButton(
                                                    onPressed: () {
                                                      // Redirect to Create an event Page
                                                      Navigator.push(
                                                          context,
                                                          SwipeablePageRoute(
                                                            builder: (context) => const CreateOrUpdateForeverPage(),
                                                          ));
                                                    },
                                                    child: const Text('+ Créer un forever'),
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
                                                          'Créer un forever',
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
                                        }).toList()
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
              );
            }

            // Display Loading while waiting
            return Center(
              child: Container(
                padding: const EdgeInsets.all(50),
                height: 100,
                child: const CupertinoActivityIndicator(),
              ),
            );
          }),
    );
  }
}

class profileStat extends StatelessWidget {
  final int nb;
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const profileStat({
    Key? key,
    required this.nb,
    required this.label,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // Label
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey.shade700),
          ),
          const SizedBox(
            height: 5,
          ),

          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(255, 234, 234, 234).withOpacity(.6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Row(
                children: [
                  // Icon
                  Transform.scale(
                    scale: 0.8,
                    child: icon,
                  ),
                  const SizedBox(
                    width: 13,
                  ),

                  // Number
                  Text(
                    '$nb',
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
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

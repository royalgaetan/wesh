import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wesh/pages/in.pages/searchpage.dart';
import 'package:wesh/pages/settings.pages/invite_someone_page.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/usercard.dart';
import '../../services/firestore.methods.dart';
import '../../models/user.dart' as usermodel;
import '../../widgets/buildWidgets.dart';

class PeoplePage extends StatefulWidget {
  final String uid;
  final int? initialPageIndex;

  const PeoplePage({super.key, this.initialPageIndex, required this.uid});

  @override
  State<PeoplePage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<PeoplePage> {
  late var status = 'isfollowing';
  late var status2 = 'follower';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialPageIndex ?? 0,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
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
          title: const Text(
            'People',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            widget.uid != FirebaseAuth.instance.currentUser!.uid
                ? Container()
                : IconButton(
                    splashRadius: 22,
                    onPressed: () {
                      //
                      Navigator.push(
                        context,
                        SwipeablePageRoute(
                          builder: (_) => const SearchPage(
                            initialPageIndex: 1,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black87,
                    ),
                  )
          ],

          // Tab bar
          bottom: TabBar(
            padding: const EdgeInsets.only(bottom: 10),
            indicatorColor: Colors.black87,
            labelPadding: const EdgeInsets.only(bottom: 0),
            unselectedLabelColor: Colors.black87,
            // labelPadding: EdgeInsets.only(top: 20),
            unselectedLabelStyle: TextStyle(fontSize: 14.sp),
            dividerColor: Colors.grey.shade300,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            labelColor: Colors.black,
            splashFactory: NoSplash.splashFactory,
            tabs: const [
              Tab(
                text: 'Followers',
              ),
              Tab(
                text: 'Followings',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Followers Section
            SingleChildScrollView(
              child: StreamBuilder<usermodel.User>(
                stream: FirestoreMethods.getUserById(widget.uid),
                builder: (context, snapshot) {
                  // Handle Errors
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: BuildErrorWidget(onWhiteBackground: true),
                      ),
                    );
                  }

                  // Handle Data and perform search
                  if (snapshot.hasData) {
                    usermodel.User? currentUser = snapshot.data!;

                    // CurrentUser Followers
                    List<String> currentUserFollowers =
                        currentUser.followers!.map((followerId) => followerId.toString()).toList();

                    // DATA FOUND
                    if (currentUserFollowers.isNotEmpty) {
                      return Column(
                        children: currentUserFollowers.map((userId) {
                          return StreamBuilder<usermodel.User>(
                              stream: FirestoreMethods.getUserById(userId),
                              builder: (context, snapshot) {
                                // Handle Errors
                                if (snapshot.hasError) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 23,
                                          backgroundColor: kGreyColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'An error occured!',
                                          style: TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Handle Data
                                if (snapshot.hasData) {
                                  usermodel.User? currentUser = snapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                    child: UserCard(
                                      user: currentUser,
                                      status: widget.uid == FirebaseAuth.instance.currentUser!.uid
                                          ? 'remove'
                                          : 'followUnfollow',
                                      onTap: () {},
                                    ),
                                  );
                                }

                                // Loader
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.grey.shade400,
                                        child: const CircleAvatar(
                                          radius: 23,
                                          backgroundColor: kGreyColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Shimmer.fromColors(
                                              baseColor: Colors.grey.shade200,
                                              highlightColor: Colors.grey.shade400,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: kGreyColor,
                                                  borderRadius: BorderRadius.circular(7),
                                                ),
                                                margin: const EdgeInsets.only(bottom: 2),
                                                width: 150,
                                                height: 15,
                                              )),
                                          const SizedBox(height: 5),
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey.shade200,
                                            highlightColor: Colors.grey.shade400,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade400,
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                              margin: const EdgeInsets.only(bottom: 2),
                                              width: 100,
                                              height: 10,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }).toList(),
                      );
                    }

                    // NO DATA FOUND
                    else {
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(50),
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
                                    ? 'You have no followers! \n Invite your friends to increase your number of followers'
                                    : 'No followers found!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black45,
                                ),
                              ),
                              widget.uid == FirebaseAuth.instance.currentUser!.uid
                                  ? TextButton(
                                      onPressed: () {
                                        // Redirect to Create a Reminder Page
                                        Navigator.push(
                                            context,
                                            SwipeablePageRoute(
                                              builder: (context) => const InviteSomeonePage(),
                                            ));
                                      },
                                      child: const Text('+ Invite someone'),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  // Display Loading while waiting
                  return Container(
                    padding: const EdgeInsets.all(50),
                    height: 100,
                    child: const CupertinoActivityIndicator(),
                  );
                },
              ),
            ),

            // Following Section
            SingleChildScrollView(
              child: FutureBuilder<usermodel.User?>(
                future: FirestoreMethods.getUser(widget.uid),
                builder: (context, snapshot) {
                  // Handle Errors
                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 23,
                            backgroundColor: kGreyColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'An error occured!',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }

                  // Handle Data and perform search
                  if (snapshot.hasData && snapshot.data != null) {
                    usermodel.User? currentUser = snapshot.data!;

                    // CurrentUser Followings
                    List<String> currentUserFollowings =
                        currentUser.followings!.map((followingId) => followingId.toString()).toList();

                    // DATA FOUND
                    if (currentUserFollowings.isNotEmpty) {
                      return Column(
                        children: currentUserFollowings.map((userId) {
                          return StreamBuilder<usermodel.User>(
                              stream: FirestoreMethods.getUserById(userId),
                              builder: (context, snapshot) {
                                // Handle Errors
                                if (snapshot.hasError) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 23,
                                          backgroundColor: Colors.grey.shade200,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text('An error occured!'),
                                      ],
                                    ),
                                  );
                                }

                                if (snapshot.hasData) {
                                  usermodel.User? currentUser = snapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                                    child: UserCard(
                                      user: currentUser,
                                      status: 'followUnfollow',
                                      onTap: () {},
                                    ),
                                  );
                                }

                                // Loader
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.grey.shade400,
                                        child: const CircleAvatar(
                                          radius: 23,
                                          backgroundColor: kGreyColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Shimmer.fromColors(
                                              baseColor: Colors.grey.shade200,
                                              highlightColor: Colors.grey.shade400,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: kGreyColor,
                                                  borderRadius: BorderRadius.circular(7),
                                                ),
                                                margin: const EdgeInsets.only(bottom: 2),
                                                width: 150,
                                                height: 15,
                                              )),
                                          const SizedBox(height: 5),
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey.shade200,
                                            highlightColor: Colors.grey.shade400,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade400,
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                              margin: const EdgeInsets.only(bottom: 2),
                                              width: 100,
                                              height: 10,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }).toList(),
                      );
                    }

                    // NO DATA FOUND
                    else {
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(50),
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
                                    ? 'You are not subscribed to anyone!'
                                    : 'No subscriptions found!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  // Display Loading while waiting
                  return Container(
                    padding: const EdgeInsets.all(50),
                    height: 100,
                    child: const CupertinoActivityIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

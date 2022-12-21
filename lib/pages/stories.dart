import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/story.dart';
import 'package:wesh/widgets/storycard.dart';
import '../models/stories_handler.dart';
import '../models/user.dart' as usermodel;
import '../services/firestore.methods.dart';
import '../utils/functions.dart';
import 'in.pages/create_story.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({Key? key}) : super(key: key);

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  //
  List<String> currentUserFollowingsIds = [FirebaseAuth.instance.currentUser!.uid];
  usermodel.User? currentUser;
  List<usermodel.User> currentUserFollowingsUser = [];
  List<Story> storiesList = [];
  List<StoriesHandler> storiesHandlerList = [];

  //
  late Stream<usermodel.User> streamCurrentUser;
  late Stream<List<usermodel.User>> streamCurrentUserFollowingsUser;
  late Stream<List<Story>> streamStories;

  StreamSubscription<usermodel.User>? streamCurrentUserSubscription;
  StreamSubscription<List<usermodel.User>>? streamCurrentUserFollowingsUserSubscription;
  StreamSubscription<List<Story>>? streamStoriesSubscription;

  @override
  void initState() {
    //
    super.initState();
    //

    // INIT STORIES /+ Listen to incoming events
    streamCurrentUser = FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid);
    streamCurrentUserSubscription = streamCurrentUser.asBroadcastStream().listen((event) {
      currentUser = event;
      //
      // Get current User Stories : first of all
      FirestoreMethods.getNonExpiredStoriesByUserPosterIdInList([FirebaseAuth.instance.currentUser!.uid])
          .asBroadcastStream()
          .listen(((currentUserStories) {
        initStories(storiesList: currentUserStories, currentUser: currentUser, currentUserFollowingsUser: []);
      }));

      currentUserFollowingsIds = event.followings?.map((userId) => userId.toString()).toList() ?? [];

      //  Get Users data in FollowingsList
      streamCurrentUserFollowingsUser = FirestoreMethods.getUserByIdInList(currentUserFollowingsIds);

      streamCurrentUserFollowingsUserSubscription = streamCurrentUserFollowingsUser.listen((event) {
        currentUserFollowingsUser = event;
      });

      // Add [Me] in Following --> to display also my Stories
      currentUserFollowingsIds.insert(0, FirebaseAuth.instance.currentUser!.uid);
      streamStories = FirestoreMethods.getNonExpiredStoriesByUserPosterIdInList(currentUserFollowingsIds);

      streamStoriesSubscription = streamStories.listen((event) {
        // Remove outdated stories

        storiesList = event;
        // .where((event) => !hasStoryExpired(event.endAt)).toList();

        initStories(
            storiesList: storiesList, currentUser: currentUser, currentUserFollowingsUser: currentUserFollowingsUser);
      });
    });
  }

  initStories(
      {required List<Story> storiesList,
      required usermodel.User? currentUser,
      required List<usermodel.User> currentUserFollowingsUser}) {
    List<StoriesHandler> _storiesHandlerList = [];

    // Manage first of all [My] Stories
    List<Story> myStories = storiesList.where((story) => story.uid == FirebaseAuth.instance.currentUser!.uid).toList();

    if (myStories.isNotEmpty) {
      // Sort [My] Stories
      myStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Build [My] StoriesHandler
      _storiesHandlerList = [
        StoriesHandler(
          origin: 'userStories',
          posterId: FirebaseAuth.instance.currentUser!.uid,
          avatarPath: currentUser?.profilePicture ?? '',
          title: currentUser?.name ?? '',
          lastStoryDateTime: getLastStoryOfStoriesList(myStories).createdAt,
          stories: myStories,
        )
      ];
    } else {
      // Build [ADD STORY] StoriesHandler
      _storiesHandlerList = [
        StoriesHandler(
          origin: 'addStories',
          posterId: FirebaseAuth.instance.currentUser!.uid,
          avatarPath: currentUser?.profilePicture ?? '',
          title: currentUser?.name ?? '',
          lastStoryDateTime: DateTime.now(),
          stories: [],
        )
      ];
    }

    //
    List<StoriesHandler> storiesHandlerWithStoriesUnseenList = [];
    List<StoriesHandler> storiesHandlerWithStoriesSeenList = [];

    // Build [Others] StoriesHandler
    for (usermodel.User userGet in currentUserFollowingsUser) {
      // Manage [UserGet] Stories

      List<Story> userGetStories = storiesList.where((story) => story.uid == userGet.id).toList();

      if (userGetStories.isNotEmpty) {
        // Sort [UserGet] Stories
        userGetStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // Build [UserGet] StoriesHandler
        StoriesHandler userStoriesHandler = StoriesHandler(
          origin: 'userStories',
          posterId: userGet.id,
          avatarPath: userGet.profilePicture,
          title: userGet.name,
          lastStoryDateTime: getLastStoryOfStoriesList(userGetStories).createdAt,
          stories: userGetStories,
        );
        // Add: as Seen or Unseen
        if (hasSeenAllStories(userGetStories)) {
          storiesHandlerWithStoriesSeenList.add(userStoriesHandler);
        } else {
          storiesHandlerWithStoriesUnseenList.add(userStoriesHandler);
        }
      }
    }

    // Sort StoriesHandler by already seen

    //

    setState(() {
      storiesHandlerList =
          _storiesHandlerList + storiesHandlerWithStoriesUnseenList + storiesHandlerWithStoriesSeenList;
    });
  }

  @override
  void dispose() {
    super.dispose();
    //
    streamCurrentUserSubscription != null ? streamCurrentUserSubscription!.cancel() : null;
    streamCurrentUserFollowingsUserSubscription != null ? streamCurrentUserFollowingsUserSubscription!.cancel() : null;
    streamStoriesSubscription != null ? streamStoriesSubscription!.cancel() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          MorphingSliverAppBar(
            heroTag: 'storiesPageAppBar',
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 70,
            // pinned: true,
            floating: true,
            snap: true,
            flexibleSpace: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: 200,
                  child: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 15, bottom: 10),
                    title: Text(
                      'Stories',
                      style: TextStyle(color: Colors.black, fontSize: 17.sp),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  splashRadius: 0.06.sw,
                  onPressed: () {
                    // Create story
                    Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => const CreateStory(),
                      ),
                    );
                  },
                  icon: const Icon(
                    FontAwesomeIcons.plus,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
        body: ListView.builder(
          itemCount: storiesHandlerList.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                () {
                  if (storiesHandlerList[index].posterId == FirebaseAuth.instance.currentUser!.uid) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: Text('Ma story', style: TextStyle(color: Colors.grey.shade600, fontSize: 11.sp)),
                    );
                  }
                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: Text('Stories récentes', style: TextStyle(color: Colors.grey.shade600, fontSize: 11.sp)),
                    );
                  }
                  return Container();
                }(),

                // STORY CARD
                StoryCard(storiesHandler: storiesHandlerList[index], storiesHandlerList: storiesHandlerList),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/stories_handler.dart';
import 'package:wesh/pages/in.pages/nonexpired_stories_list.dart';
import 'package:wesh/pages/in.pages/storiesViewer.dart';
import 'package:wesh/utils/functions.dart';
import '../pages/in.pages/create_story.dart';
import '../utils/constants.dart';
import 'buildWidgets.dart';

class StoryCard extends StatelessWidget {
  final StoriesHandler storiesHandler;
  final List<StoriesHandler> storiesHandlerList;

  const StoryCard({Key? key, required this.storiesHandler, required this.storiesHandlerList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (storiesHandler.origin == 'addStories') {
          Navigator.push(
            context,
            SwipeablePageRoute(
              builder: (context) => const CreateStory(),
            ),
          );
        } else {
          // Story Page View
          context.pushTransparentRoute(StoriesViewer(
            storiesHandlerList: storiesHandlerList,
            indexInStoriesHandlerList: storiesHandlerList.indexOf(storiesHandler),
          ));
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 5),
        child: Row(
          children: [
            // Trailing Avatar

            storiesHandler.origin == 'userStories'
                ? buildCircleAvatarStoriesWrapper(
                    storiesHandler: storiesHandler, child: buildUserProfilePicture(userId: storiesHandler.posterId))
                : Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      buildCachedNetworkImage(
                        url: storiesHandler.avatarPath,
                        radius: 0.07.sw,
                        backgroundColor: kGreyColor,
                        paddingOfProgressIndicator: 10,
                      ),

                      // Add btn
                      CircleAvatar(
                        radius: 0.025.sw,
                        backgroundColor: kSecondColor,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 12.sp,
                        ),
                      ),
                    ],
                  ),
            // Username + Last Story Sent
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: [
                      Text(
                        storiesHandler.posterId == FirebaseAuth.instance.currentUser!.uid
                            ? 'Moi'
                            : storiesHandler.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // Last Message Row
                  storiesHandler.lastStoryDateTime != DateTime(0)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            storiesHandler.origin == 'addStories'
                                ? 'Ajouter'
                                : getTimeAgoLongForm(storiesHandler.lastStoryDateTime),
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis, fontSize: 12.sp, color: Colors.black.withOpacity(0.7)),
                          ),
                        )
                      : Container()
                ],
              ),
            ),

            // Edit Forever
            storiesHandler.posterId == FirebaseAuth.instance.currentUser!.uid
                ? IconButton(
                    splashRadius: 0.06.sw,
                    onPressed: () {
                      //
                      Navigator.push(
                        context,
                        SwipeablePageRoute(
                          builder: (context) => const NonExpiredStoriesListPage(),
                        ),
                      );
                    },
                    icon: Icon(
                      FontAwesomeIcons.circleNotch,
                      color: kSecondColor,
                      size: 20.sp,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

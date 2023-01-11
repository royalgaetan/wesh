import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/create_or_update_forever.dart';
import '../models/forever.dart';
import '../models/stories_handler.dart';
import '../models/story.dart';
import '../pages/in.pages/storiesViewer.dart';
import '../services/firestore.methods.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class ForeverCard extends StatefulWidget {
  final Forever forever;
  final List<Forever> foreversList;
  const ForeverCard({super.key, required this.forever, required this.foreversList});

  @override
  State<ForeverCard> createState() => _ForeverCardState();
}

class _ForeverCardState extends State<ForeverCard> {
  Future<List<Story>> getStoriesFromStoriesIdList(List<String> storiesIdList) async {
    List<Story> storiesData = [];

    for (String storyId in storiesIdList) {
      Story? storyGet = await FirestoreMethods.getStoryByIdAsFuture(storyId);
      if (storyGet != null) {
        storiesData.add(storyGet);
      }
    }
    //
    return storiesData;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        //
        showFullPageLoader(context: context, color: Colors.white);
        //

        //
        List<StoriesHandler> storiesHandlerList = [];
        if (widget.foreversList.isNotEmpty) {
          // Build StoriesHandler - for Forevers
          for (Forever forever in widget.foreversList) {
            // Build [My] StoriesHandler

            List<Story> storiesGet =
                await getStoriesFromStoriesIdList(forever.stories.map((storyId) => storyId.toString()).toList());

            storiesHandlerList.add(
              StoriesHandler(
                origin: 'foreverStories',
                posterId: forever.foreverId,
                avatarPath: forever.foreverId,
                title: forever.title,
                lastStoryDateTime: forever.createdAt,
                stories: storiesGet,
              ),
            );
          }

          // Dismiss loader
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();

          // Story Page View
          StoriesHandler currentForeverStoriesHandler =
              storiesHandlerList.where((storiesHandler) => storiesHandler.posterId == widget.forever.foreverId).first;
          // ignore: use_build_context_synchronously
          context.pushTransparentRoute(StoriesViewer(
            storiesHandlerList: storiesHandlerList,
            indexInStoriesHandlerList: storiesHandlerList.indexOf(currentForeverStoriesHandler),
          ));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: Row(
          children: [
            // Trailing Avatar
            buildForeverCover(
              foreverId: widget.forever.foreverId,
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
                  Text(
                    widget.forever.title,
                    style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),

                  // Last Message Row
                  widget.forever.modifiedAt != DateTime(0)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            getTimeAgoShortForm(widget.forever.modifiedAt),
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12.sp,
                              color: Colors.black45,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),

            // Edit Forever
            widget.forever.uid == FirebaseAuth.instance.currentUser!.uid
                ? IconButton(
                    splashRadius: 0.06.sw,
                    onPressed: () {
                      //
                      Navigator.push(
                        context,
                        SwipeablePageRoute(
                          builder: (context) => CreateOrUpdateForeverPage(forever: widget.forever),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.black54,
                      size: 17.sp,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

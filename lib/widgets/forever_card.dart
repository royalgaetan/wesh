import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/create_or_update_forever.dart';
import 'package:wesh/utils/constants.dart';
import '../models/forever.dart';
import '../pages/in.pages/storyviewer_forever_stories.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class ForeverCard extends StatefulWidget {
  final List<Forever> foreversList;
  final int initialForeverIndex;

  const ForeverCard({super.key, required this.foreversList, required this.initialForeverIndex});

  @override
  State<ForeverCard> createState() => _ForeverCardState();
}

class _ForeverCardState extends State<ForeverCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Preview Story

        context.pushTransparentRoute(ForeverStoriesPageViewer(
          foreversList: widget.foreversList,
          initialForeverIndex: widget.initialForeverIndex,
        ));
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Trailing Avatar
            buildForeverCover(
              forever: widget.foreversList[widget.initialForeverIndex],
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
                    widget.foreversList[widget.initialForeverIndex].title,
                    style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  // Last Message Row
                  widget.foreversList[widget.initialForeverIndex].modifiedAt != DateTime(0)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(getTimeAgoShortForm(widget.foreversList[widget.initialForeverIndex].modifiedAt),
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 14,
                                color: Colors.black45,
                              )),
                        )
                      : Container()
                ],
              ),
            ),

            // Edit Forever
            widget.foreversList[widget.initialForeverIndex].uid == FirebaseAuth.instance.currentUser!.uid
                ? IconButton(
                    splashRadius: 0.06.sw,
                    onPressed: () {
                      //
                      Navigator.push(
                        context,
                        SwipeablePageRoute(
                          builder: (context) =>
                              CreateOrUpdateForeverPage(forever: widget.foreversList[widget.initialForeverIndex]),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.black54,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

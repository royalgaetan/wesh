import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wesh/pages/in.pages/storyviewer_user_stories.dart';
import '../../models/user.dart' as UserModel;
import '../utils/constants.dart';

class StoryCard extends StatelessWidget {
  final UserModel.User user;
  final String? type;

  const StoryCard({Key? key, required this.user, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const CreateStory(),
        //   ),
        // );

        // Story Page View
        context.pushTransparentRoute(StoryPage(
          user: user,
        ));
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Trailing Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: kGreyColor,
              backgroundImage: NetworkImage(user.profilePicture),
            ),

            // Username + Last Story Sent
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.name}',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  // Last Message Row
                  user.lastStoryUpdateDateTime != DateTime(0)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            (() {
                              timeago.setLocaleMessages(
                                  'fr', timeago.FrMessages());
                              return timeago.format(
                                  user.lastStoryUpdateDateTime,
                                  locale: 'fr');
                            }()),
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

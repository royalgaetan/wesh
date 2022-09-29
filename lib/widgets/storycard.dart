import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wesh/pages/in.pages/storypage.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/imagewrapper.dart';

class StoryCard extends StatelessWidget {
  final String profilePicture;
  final String username;
  final DateTime lastStoryTime;
  final String? type;

  const StoryCard(
      {required this.profilePicture,
      required this.username,
      required this.lastStoryTime,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Story Page View
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryPage(username: username),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Trailing Avatar
            Hero(
              tag: '$username',
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  type != 'addstory'
                      ? ImageWrapper(
                          type: 'hasStories',
                          picture: profilePicture,
                          borderradius: 3,
                          borderpadding: 3,
                          bordercolor:
                              type == "unread" ? kSecondColor : Colors.grey,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(profilePicture),
                          ),
                        )
                      : Container(),
                  type == 'addstory'
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(profilePicture),
                        )
                      : Container(),
                  type == "addstory"
                      ? const CircleAvatar(
                          radius: 10,
                          backgroundColor: kSecondColor,
                          child: Icon(
                            FontAwesomeIcons.plus,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : Container()
                ],
              ),
            ),

            // Username + Last Story Sent
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$username',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 6,
                  ),

                  // Last Message Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${DateFormat('hh:mm').format(lastStoryTime)}',
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}

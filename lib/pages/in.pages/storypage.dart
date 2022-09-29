import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import 'package:story_view/widgets/story_view.dart';

class StoryPage extends StatefulWidget {
  final String username;
  StoryPage({Key? key, required this.username}) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final controller = StoryController();

  List<StoryItem> storyItems = [
    StoryItem.text(
        title: 'Hello here', backgroundColor: Colors.orange.shade300),
    StoryItem.pageProviderImage(
        const AssetImage('assets/images/picture 4.jpg')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: [
            // Page 1
            Expanded(
                child: Container(
              width: double.infinity,
              color: Colors.green.shade200,
              child: Center(
                child: Text('Story 1'),
              ),
            )),

            // Page 2

            Stack(
              alignment: Alignment.topLeft,
              children: [
                StoryView(
                    storyItems: storyItems,
                    controller: controller, // pass controller here too
                    repeat: true, // should the stories be slid forever
                    // onStoryShow: (s) {notifyServer(s)},

                    onComplete: () {},
                    onVerticalSwipeComplete: (direction) {
                      if (direction == Direction.down) {
                        Navigator.pop(context);
                      }
                    } // To disable vertical swipe gestures, ignore this parameter.
                    // Preferrably for inline story view.
                    ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: '${widget.username}',
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage:
                              AssetImage('assets/images/avatar 13.jpg'),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Username',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  'À l\'instant',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
}

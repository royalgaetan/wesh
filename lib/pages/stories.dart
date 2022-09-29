import 'package:flutter/material.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/widgets/storycard.dart';
// import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage({Key? key}) : super(key: key);

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  List<Widget> getStories() {
    List<Widget> _storiesWidgets = [];

    late StoryCard story;

    for (story in storiesList) {
      var _StoriesWidget = StoryCard(
          profilePicture: story.profilePicture,
          username: story.username,
          lastStoryTime: story.lastStoryTime,
          type: story.type);

      _storiesWidgets.add(_StoriesWidget);
    }

    return _storiesWidgets;
  }

  List<Widget> getStoriesSeen() {
    List<Widget> _storiesSeenWidgets = [];

    late StoryCard storySeen;

    for (storySeen in storiesSeenList) {
      var _StoriesWidget = StoryCard(
          profilePicture: storySeen.profilePicture,
          username: storySeen.username,
          lastStoryTime: storySeen.lastStoryTime,
          type: storySeen.type);

      _storiesSeenWidgets.add(_StoriesWidget);
    }

    return _storiesSeenWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 85,
            // pinned: true,
            floating: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 15, bottom: 10),
              title: Text(
                'Stories',
                style: TextStyle(color: Colors.black, fontSize: 21),
              ),
            ),
          ),
        ],
        body: Expanded(
            child: SingleChildScrollView(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add To My Stories Header
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 10),
                  child: Text('Ajouter à votre story',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ),
                StoryCard(
                    profilePicture: 'assets/images/avatar 1.jpeg',
                    username: 'Ma Story',
                    type: 'addstory',
                    lastStoryTime: DateTime.now().subtract(Duration(hours: 3))),
              ],
            ),

            // Recent Stories  Header
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text('Stories récentes',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
            Column(
              children: getStories(),
            ),

            // Stories Seen Header
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text('Stories déjà vues',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
            Column(
              children: getStoriesSeen(),
            ),
          ],
        ))),
      ),
    );
  }
}

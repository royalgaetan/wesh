import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wesh/widgets/storycard.dart';
import '../models/user.dart' as UserModel;
import '../utils/functions.dart';
import 'in.pages/create_story.dart';
// import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage({Key? key}) : super(key: key);

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // List<Widget> getStories() {
  //   List<Widget> _storiesWidgets = [];

  //   late StoryCard story;

  //   for (story in storiesList) {
  //     var _StoriesWidget = StoryCard(
  //         profilePicture: story.profilePicture,
  //         username: story.username,
  //         lastStoryTime: story.lastStoryTime,
  //         type: story.type);

  //     _storiesWidgets.add(_StoriesWidget);
  //   }

  //   return _storiesWidgets;
  // }

  // List<Widget> getStoriesSeen() {
  //   List<Widget> _storiesSeenWidgets = [];

  //   late StoryCard storySeen;

  //   for (storySeen in storiesSeenList) {
  //     var _StoriesWidget = StoryCard(
  //         profilePicture: storySeen.profilePicture,
  //         username: storySeen.username,
  //         lastStoryTime: storySeen.lastStoryTime,
  //         type: storySeen.type);

  //     _storiesSeenWidgets.add(_StoriesWidget);
  //   }

  //   return _storiesSeenWidgets;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 85,
            // pinned: true,
            floating: true,
            snap: true,
            flexibleSpace: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 200,
                  child: const FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 15, bottom: 10),
                    title: Text(
                      'Stories',
                      style: TextStyle(color: Colors.black, fontSize: 21),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  splashRadius: 25,
                  onPressed: () {
                    // Create story
                    Navigator.push(
                      context,
                      MaterialPageRoute(
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
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add To My Stories Header
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text('Ajouter à votre story',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),

            Column(
              children: [
                //
                StreamBuilder(
                  stream: getUserById(context, ''),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return StoryCard(
                        user: (snapshot.data! as UserModel.User),
                        type: 'addstory',
                      );
                    } else if (snapshot.hasError) {
                      //probably an error occured
                      debugPrint('Erreur: ${snapshot.error}');
                      return const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text('Une erreur s\'est produite'),
                      );
                    }
                    // your waiting Widget Ex: CircularLoadingIndicator();
                    // TODO
                    return Container();
                  }),
                ),
              ],
            ),

            // Recent Stories : Header
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text('Stories récentes',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
            Column(
                // children: getStories(),
                ),

            // Stories Seen  : Header
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text('Stories déjà vues',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
            Column(
                // children: getStoriesSeen(),
                ),
          ],
        )),
      ),
    );
  }
}

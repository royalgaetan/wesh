import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
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

class _StoriesPageState extends State<StoriesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    //Notice the super-call here.
    super.build(context);

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
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add To My Stories Header
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text('Ajouter à ma story', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
              child: Text('Stories récentes', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ),
            Column(
                // children: getStories(),
                ),

            // Stories Seen  : Header
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: Text('Stories déjà vues', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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

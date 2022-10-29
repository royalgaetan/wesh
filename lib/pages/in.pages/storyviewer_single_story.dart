import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:story_view/widgets/story_view.dart';
import 'package:wesh/utils/functions.dart';
import '../../models/story.dart';
import '../../utils/constants.dart';

class SingleStoryPageViewer extends StatefulWidget {
  final Story? storyTodiplay;

  const SingleStoryPageViewer({super.key, required this.storyTodiplay});

  @override
  State<SingleStoryPageViewer> createState() => _SingleStoryPageViewerState();
}

class _SingleStoryPageViewerState extends State<SingleStoryPageViewer> {
  final storyController = StoryController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    storyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
        onDismissed: () {
          Navigator.of(context).pop();
          storyController.pause();
          storyController.dispose();
        },
        // Note that scrollable widget inside DismissiblePage might limit the functionality
        // If scroll direction matches DismissiblePage direction
        direction: DismissiblePageDismissDirection.vertical,
        backgroundColor: Colors.transparent,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: widget.storyTodiplay!.bgColor != 0
              ? storiesAvailableColorsList[widget.storyTodiplay!.bgColor]
              : Colors.black,
          body: SafeArea(
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                StoryView(
                  storyItems: [
                    getStoryItemByType(widget.storyTodiplay!, storyController)
                  ],
                  controller: storyController, // pass controller here too
                  repeat: false, // should the stories be slid forever
                  onStoryShow: (s) {},
                  onComplete: () {},
                ),

                // Other story options : Header, Add to Forevers, Answer to story, Take a Screenchot, etc.
                // HEADER
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeago.format(
                                      widget.storyTodiplay!.createdAt,
                                      locale: 'fr'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(.6),
                                  ),
                                ),
                                //
                                // ADD EVENT SELECTED : if available
                                // TODO:
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
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/create_or_update_event.dart';
import 'package:wesh/pages/in.pages/create_or_update_reminder.dart';
import 'package:wesh/pages/in.pages/create_story.dart';
import '../utils/constants.dart';
import '../widgets/button.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return Scaffold(
      appBar: MorphingAppBar(
        scrolledUnderElevation: 0.0,
        heroTag: 'addPageAppBar',
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        title: Text(
          'Create',
          style: TextStyle(color: Colors.black, fontSize: 25.sp),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.2.sw),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CREATE EVENT BUTTON
              Button(
                text: 'Create an event',
                height: 0.12.sw,
                width: double.infinity,
                prefixIcon: FontAwesomeIcons.splotch,
                prefixIconSize: 15.sp,
                color: kSecondColor,
                onTap: () async {
                  // Open Create Event Page
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => CreateOrUpdateEventPage(),
                      ));
                },
              ),

              const SizedBox(
                height: 14,
              ),

              // CREATE REMINDER BUTTON
              Button(
                text: 'Create a reminder',
                height: 0.12.sw,
                width: double.infinity,
                // prefixIcon: FontAwesomeIcons.clockRotateLeft,
                // prefixIconSize: 15.sp,
                // prefixIconColor: Colors.black87,
                fontColor: Colors.black,
                color: const Color(0xFFF0F0F0),
                isBordered: true,
                onTap: () async {
                  // Open Create Reminder Page
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => const CreateOrUpdateReminderPage(),
                      ));
                },
              ),

              const SizedBox(
                height: 14,
              ),

              // CREATE STORY BUTTON
              Button(
                text: 'Create a story',
                height: 0.12.sw,
                width: double.infinity,
                // prefixIcon: FontAwesomeIcons.plus,
                // prefixIconSize: 15.sp,
                // prefixIconColor: Colors.black87,
                fontColor: Colors.black,
                color: const Color(0xFFF0F0F0),
                isBordered: true,
                onTap: () async {
                  // Create story
                  Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => const CreateStory(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

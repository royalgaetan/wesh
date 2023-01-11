import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/create_or_update_event.dart';
import 'package:wesh/pages/in.pages/create_or_update_reminder.dart';
import '../utils/constants.dart';
import '../widgets/button.dart';

// import 'dart:developer';
// import '../services/notifications_api.dart';
// import '../utils/functions.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // NotificationApi.init(initScheduled: true);
  }

  @override
  Widget build(BuildContext context) {
    //Notice the super-call here.
    super.build(context);

    return Scaffold(
      appBar: MorphingAppBar(
        heroTag: 'addPageAppBar',
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        title: Text(
          'Créer',
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
                text: 'Créer un évènement',
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
                text: 'Créer un rappel',
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

              // TEST BTN
              // const SizedBox(
              //   height: 14,
              // ),

              // Button(
              //   text: 'Scheduled One task',
              //   height: 0.12.sw,
              //   width: double.infinity,
              //   fontColor: Colors.white,
              //   color: kWarningColor,
              //   isBordered: true,
              //   onTap: () async {
              //     //
              //     NotificationApi.init(initScheduled: true);

              //     tz.TZDateTime toUse = tz.TZDateTime(
              //       tz.local,
              //       DateTime.now().year,
              //       DateTime.now().month,
              //       DateTime.now().day,
              //       DateTime.now().hour,
              //       DateTime.now().minute,
              //       DateTime.now().second,
              //     ).add(const Duration(seconds: 10));
              //     log('At: $toUse');

              //     NotificationApi.showScheduledNotification(
              //       id: 19889,
              //       title: 'Another',
              //       body: '🤓 Cool nah ?!',
              //       payload: '',
              //       channel: notificationsChannelList[2],
              //       largeIconPath: '',
              //       tzDateTime: scheduleDaily(toUse),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

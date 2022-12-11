import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/create_or_update_event.dart';
import 'package:wesh/pages/in.pages/create_or_update_reminder.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

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
        padding: EdgeInsets.all(0.24.sw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 3),
              borderRadius: BorderRadius.circular(10),
              child: Text(
                'Créer un événement',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.sp),
              ),
              onPressed: () {
                // Open Create Event Page
                Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => CreateOrUpdateEventPage(),
                    ));
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoButton(
              color: const Color(0xFFF0F0F0),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 3),
              borderRadius: BorderRadius.circular(10),
              child: Text(
                'Créer un rappel',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 12.sp),
              ),
              onPressed: () {
                // Open Create Reminder Page
                Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => CreateOrUpdateReminderPage(),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

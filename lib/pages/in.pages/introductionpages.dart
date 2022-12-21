import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/utils/constants.dart';
import '../../services/sharedpreferences.service.dart';
import '../auth.pages/add_profile_picture.dart';

class IntroductionScreensPage extends StatefulWidget {
  const IntroductionScreensPage({Key? key}) : super(key: key);

  @override
  State<IntroductionScreensPage> createState() => _LoginPageState();
}

nextPage(context) {
  UserSimplePreferences.setShowIntroductionPagesHandler(false);

  SchedulerBinding.instance.addPostFrameCallback((_) {
    Navigator.push(
      context,
      SwipeablePageRoute(
        builder: (context) => const AddProfilePicture(),
      ),
    );
  });
}

class _LoginPageState extends State<IntroductionScreensPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: IntroductionScreen(
            pages: listPagesViewModel,
            onDone: () {
              // When done button is press
              nextPage(context);
            },
            onSkip: () {
              // On Skip

              nextPage(context);
            },
            showBackButton: false,
            showSkipButton: true,
            skip: const Text('Ignorer tout', style: TextStyle(color: Colors.black54)),
            next: const Text('Suivant'),
            done: const Text("Commencer", style: TextStyle(fontWeight: FontWeight.w600)),
            dotsDecorator: DotsDecorator(
                size: const Size.square(10.0),
                activeSize: const Size(20.0, 10.0),
                activeColor: kSecondColor,
                color: Colors.black26,
                spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
          ),
        ),
      ),
    );
  }
}

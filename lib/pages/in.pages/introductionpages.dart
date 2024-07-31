import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/utils/constants.dart';
import '../../services/sharedpreferences.service.dart';
import '../auth.pages/add_profile_picture.dart';

class IntroductionScreensPage extends StatefulWidget {
  const IntroductionScreensPage({super.key});

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
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: IntroductionScreen(
            bodyPadding: const EdgeInsets.symmetric(horizontal: 20),
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
            skip: const Text('Skip All', style: TextStyle(color: Colors.black54)),
            next: const Text('Next', style: TextStyle(fontWeight: FontWeight.w600)),
            done: const Text("Get Started", style: TextStyle(fontWeight: FontWeight.w600)),
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

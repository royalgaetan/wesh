import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wesh/pages/addpage.dart';
import 'package:wesh/pages/homePage.dart';
import 'package:wesh/pages/discussions.dart';
import 'package:wesh/pages/in.pages/introductionpages.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/pages/stories.dart';
import 'package:wesh/utils/constants.dart';

import '../services/sharedpreferences.service.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int _currentPageIndex = 0;
  int previousPageIndex = 0;
  bool showIntroductionPages = false;

  final List<Widget> _pages = [
    HomePage(),
    MessagesPage(),
    AddPage(),
    StoriesPage(),
    profilePage(uid: '2')
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Check Introduction Pages Handler
    showIntroductionPages =
        UserSimplePreferences.getShowIntroductionPagesHandler() ?? false;

    if (showIntroductionPages) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IntroductionScreensPage(),
          ),
        );
      });
    }
  }

  void navigateThroughPage(int index) async {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: _pages[_currentPageIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: navigateThroughPage,
        selectedItemColor: kSecondColor,
        unselectedItemColor: Colors.grey.shade600,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.house,
                size: 19,
              ),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.message,
                size: 19,
              ),
              label: 'Messages'),
          BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.plus,
                size: 19,
              ),
              label: 'Stories'),
          BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.circleNotch,
                size: 19,
              ),
              label: 'Stories'),
          BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.user,
                size: 19,
              ),
              label: 'Profil'),
        ],
      ),
    );
  }
}

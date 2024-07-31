// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wesh/pages/settings.pages/ask_us_question.dart';
import 'package:wesh/pages/settings.pages/bug_report_page.dart';
import 'package:wesh/pages/settings.pages/help_center_page.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/setting_card.dart';
import '../../models/user.dart' as usermodel;

class HelpPage extends StatefulWidget {
  final usermodel.User user;

  const HelpPage({super.key, required this.user});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'helpPageAppBar',
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 0.06.sw,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Help',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Help Center
            SettingCard(
              onTap: () {
                // Redirect to Help Center Page
                Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => const HelpCenterPage(),
                    ));
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 0.08.sw,
                backgroundColor: kGreyColor,
                child: Icon(
                  Icons.help_outline_outlined,
                  color: Colors.black87.withOpacity(.7),
                  size: 24.sp,
                ),
              ),
              settingTitle: 'Help Center',
              settingSubTitle: '',
            ),

            // Report a problem
            SettingCard(
              onTap: () {
                // Redirect to Bug Report Page
                Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => const BugReportPage(),
                    ));
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 0.08.sw,
                backgroundColor: kGreyColor,
                child: Icon(
                  Icons.bug_report_outlined,
                  color: Colors.black87.withOpacity(.7),
                  size: 24.sp,
                ),
              ),
              settingTitle: 'Report an issue',
              settingSubTitle: '',
            ),

            // Privacy Policy
            SettingCard(
              onTap: () async {
                // Go to Privacy Policy Link [ONLINE]
                Uri urlToLaunch = Uri.parse(privacyPolicyUrl);

                if (!await launchUrl(urlToLaunch)) {
                  showSnackbar(context, 'Unable to open this URL', null);
                  throw 'Could not launch $urlToLaunch';
                }
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 0.08.sw,
                backgroundColor: kGreyColor,
                child: Icon(
                  Icons.file_open_outlined,
                  color: Colors.black87.withOpacity(.7),
                  size: 24.sp,
                ),
              ),
              settingTitle: 'Privacy Policy (EN)',
              settingSubTitle: '',
            ),

            // Ask a question
            SettingCard(
              onTap: () {
                // Redirect to Ask a question
                Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => const AskUsQuestionPage(),
                    ));
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 0.08.sw,
                backgroundColor: kGreyColor,
                child: Icon(
                  Icons.support_agent_rounded,
                  color: Colors.black87.withOpacity(.7),
                  size: 24.sp,
                ),
              ),
              settingTitle: 'Ask us a question',
              settingSubTitle: '',
            ),
          ],
        ),
      ),
    );
  }
}

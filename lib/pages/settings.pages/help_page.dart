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
import 'feedback_modal.dart';

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
          'Aide',
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
                  size: 23.sp,
                ),
              ),
              settingTitle: 'Centre d\'aide',
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
                  size: 23.sp,
                ),
              ),
              settingTitle: 'Reporter un problème',
              settingSubTitle: '',
            ),

            // Privacy Policy
            SettingCard(
              onTap: () async {
                // Go to Privacy Policy Link [ONLINE]
                Uri urlToLaunch = Uri.parse(privacyPolicyUrl);

                if (!await launchUrl(urlToLaunch)) {
                  showSnackbar(context, 'Impossible de lancer cette url', null);
                  throw 'Could not launch $urlToLaunch';
                }
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 0.08.sw,
                backgroundColor: kGreyColor,
                child: Icon(
                  Icons.file_copy_rounded,
                  color: Colors.black87.withOpacity(.7),
                  size: 23.sp,
                ),
              ),
              settingTitle: 'Politique de confidentialité (en)',
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
                  Icons.person_pin_rounded,
                  color: Colors.black87.withOpacity(.7),
                  size: 23.sp,
                ),
              ),
              settingTitle: 'Posez-nous une question',
              settingSubTitle: '',
            ),

            // Feedback
            SettingCard(
              onTap: () async {
                // Show to Feedback Modal
                await showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: const FeedBackModal(),
                    );
                  },
                );
              },
              trailing: Container(),
              leading: CircleAvatar(
                radius: 0.08.sw,
                backgroundColor: kGreyColor,
                child: Icon(
                  Icons.feedback_outlined,
                  color: Colors.black87.withOpacity(.7),
                  size: 23.sp,
                ),
              ),
              settingTitle: 'Feedback',
              settingSubTitle: '',
            ),
          ],
        ),
      ),
    );
  }
}

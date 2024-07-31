import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/auth.pages/add_email.dart';
import 'package:wesh/pages/auth.pages/createpassword_and_confirm.dart';
import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';
import '../../widgets/setting_card.dart';

class ChangeEmailOrPasswordPage extends StatefulWidget {
  const ChangeEmailOrPasswordPage({super.key});

  @override
  State<ChangeEmailOrPasswordPage> createState() => _ChangeEmailOrPasswordPageState();
}

class _ChangeEmailOrPasswordPageState extends State<ChangeEmailOrPasswordPage> {
  User? user;
  @override
  void initState() {
    //
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });

    // REDIRECT
    redirectToChangeEmailPage();
    redirectToChangePasswordPage();
  }

  Future redirectToChangeEmailPage() async {
    var valueToRedirect = UserSimplePreferences.getRedirectToAddEmailPageValue() ?? false;
    debugPrint("Redirect to Change Email Page [CHANGE EMAIL or PASSWORD PAGE]: $valueToRedirect ");
    if (valueToRedirect) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const AddEmailPage(),
          ),
        );
      });
    }
  }

  Future redirectToChangePasswordPage() async {
    var valueToRedirect = UserSimplePreferences.getRedirectToUpdatePasswordPageValue() ?? false;
    debugPrint("Redirect to Update Email Page [CHANGE EMAIL or PASSWORD PAGE]: $valueToRedirect ");
    if (valueToRedirect) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const CreatePassword(isUpdatingEmail: true),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'changeEmailOrPasswordPageAppBar',
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
          'Email et Password',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Update Email
                SettingCard(
                  onTap: () {
                    // Redirect to Add Email Page
                    Navigator.push(
                        context,
                        SwipeablePageRoute(
                          builder: (context) => const AddEmailPage(),
                        ));
                  },
                  trailing: Container(),
                  leading: CircleAvatar(
                    radius: 0.08.sw,
                    backgroundColor: kGreyColor,
                    child: Icon(
                      FontAwesomeIcons.envelopeCircleCheck,
                      color: Colors.black87.withOpacity(.7),
                      size: 19.sp,
                    ),
                  ),
                  settingTitle: 'Change your current Email',
                  settingSubTitle: '',
                ),

                // Update Password
                SettingCard(
                  onTap: () {
                    // Redirect to Create Password Page
                    Navigator.push(
                        context,
                        SwipeablePageRoute(
                          builder: (context) => const CreatePassword(isUpdatingEmail: true),
                        ));
                  },
                  trailing: Container(),
                  leading: CircleAvatar(
                    radius: 0.08.sw,
                    backgroundColor: kGreyColor,
                    child: Icon(
                      FontAwesomeIcons.lock,
                      color: Colors.black87.withOpacity(.7),
                      size: 19.sp,
                    ),
                  ),
                  settingTitle: 'Change your current Password',
                  settingSubTitle: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

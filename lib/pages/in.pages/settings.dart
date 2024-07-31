// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/settings.pages/about_the_app.dart';
import 'package:wesh/pages/settings.pages/account_security_settings.dart';
import 'package:wesh/pages/settings.pages/feedback_modal.dart';
import 'package:wesh/pages/settings.pages/help_page.dart';
import 'package:wesh/pages/settings.pages/invite_someone_page.dart';
import 'package:wesh/widgets/modal.dart';
import 'package:wesh/widgets/setting_card.dart';
import '../../services/auth.methods.dart';
import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';
import '../settings.pages/create_or_update_personal_informations.dart';
import '../settings.pages/notifications_settings_page.dart';
import '../../models/user.dart' as usermodel;

class SettingsPage extends StatefulWidget {
  final usermodel.User user;

  const SettingsPage({super.key, required this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  usermodel.User? updatedUser;

  @override
  void initState() {
    //
    super.initState();
    updatedUser = widget.user;

    // Redirect to Account Security Settings Page
    redirectToAccountSecuritySettingsPage();
  }

  Future redirectToAccountSecuritySettingsPage() async {
    var valueToRedirect = UserSimplePreferences.getRedirectToAddEmailandPasswordPageValue() ?? false;
    debugPrint("Redirect to Account Security Settings Page [SETTINGS PAGE]: $valueToRedirect ");
    if (valueToRedirect) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const AccountSecuritySettingsPage(),
          ),
        );
      });
    }

    //
    var valueToRedirect2 = UserSimplePreferences.getRedirectToAddEmailPageValue() ?? false;
    debugPrint("Redirect to Account Security Settings Page [SETTINGS PAGE]: $valueToRedirect2");
    if (valueToRedirect2) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const AccountSecuritySettingsPage(),
          ),
        );
      });
    }

    //
    var valueToRedirect3 = UserSimplePreferences.getRedirectToUpdatePasswordPageValue() ?? false;
    debugPrint("Redirect to Account Security Settings Page [SETTINGS PAGE]: $valueToRedirect3");
    if (valueToRedirect3) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => const AccountSecuritySettingsPage(),
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
        heroTag: 'settingsPageAppBar',
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
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Tooltip(
            message: 'Logout',
            child: IconButton(
              splashRadius: 0.06.sw,
              onPressed: () async {
                // Show Delete Decision Modal
                List deleteDecision = await showModalDecision(
                  context: context,
                  header: 'Logout',
                  content: 'Do you really want to log out?',
                  firstButton: 'Cancel',
                  secondButton: 'Logout',
                );

                if (deleteDecision[0] == true) {
                  // Sign out
                  AuthMethods.signout(context);
                }
              },
              icon: const Icon(
                Icons.logout,
                color: kSecondColor,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Profile setting : Personal info /Name /Birthday /ProfilePicture /Bio /LinkinBio
              SettingCard(
                onTap: () async {
                  // Redirect to Edit_Personal_Informations
                  usermodel.User? result = await Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => CreateOrUpdatePersonalInformations(user: updatedUser!),
                      ));
                  if (result != null) {
                    setState(() {
                      updatedUser = result;
                    });
                  }
                },
                trailing: Container(),
                leading: Hero(
                  tag: 'setting_profile_picture_tag_${FirebaseAuth.instance.currentUser!.uid}',
                  child: BuildCachedNetworkImage(
                    url: updatedUser!.profilePicture,
                    radius: 0.08.sw,
                    backgroundColor: kGreyColor,
                    paddingOfProgressIndicator: 13,
                  ),
                ),
                settingTitle: 'My Account',
                settingSubTitle: 'Edit your personal information',
              ),

              // Notifications: /All /Events /Reminders /Story /Messages
              SettingCard(
                onTap: () async {
                  // Redirect to NotificationsSettingsPage
                  usermodel.User? result = await Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => NotificationsSettingsPage(user: updatedUser!),
                      ));
                  if (result != null) {
                    setState(() {
                      updatedUser = result;
                    });
                  }
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kSecondColor,
                  child: Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                settingTitle: 'Notifications',
                settingSubTitle: 'Stay informed about messages, events, etc.',
              ),

              // Security setting : /Signup Methods /Phone /Email /Password
              SettingCard(
                onTap: () {
                  // Redirect to AccountSecuritySettingsPage
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => const AccountSecuritySettingsPage(),
                      ));
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kSecondColor,
                  child: Icon(
                    Icons.security_rounded,
                    color: Colors.white,
                    size: 23.sp,
                  ),
                ),
                settingTitle: 'Security',
                settingSubTitle: 'Protect your account',
              ),

              // Help setting : /Help Center /Report a problem /CGU /Ask a question /Feedback
              SettingCard(
                onTap: () {
                  // Redirect to HelpPage
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => HelpPage(user: updatedUser!),
                      ));
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kSecondColor,
                  child: Icon(
                    Icons.live_help_outlined,
                    color: Colors.white,
                    size: 23.sp,
                  ),
                ),
                settingTitle: 'Help',
                settingSubTitle: 'Report a bug, ask questions, etc.',
              ),

              // Invite someone :[dynamic link]
              SettingCard(
                onTap: () {
                  // Redirect to InviteSomeone_Page
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => const InviteSomeonePage(),
                      ));
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kSecondColor,
                  child: Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 23.sp,
                  ),
                ),
                settingTitle: 'Invite a Friend',
                settingSubTitle: 'Invite a close one to join you',
              ),

              // Rate the app : ...
              SettingCard(
                onTap: () async {
                  // Show Feedback Modal
                  await showModalBottomSheet(
                    enableDrag: true,
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Modal(
                        minHeightSize: 190,
                        maxHeightSize: 190,
                        child: FeedBackModal(),
                      ),
                    ),
                  );
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kSecondColor,
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                settingTitle: 'Your feedback',
                settingSubTitle: 'Share your thoughts and feedback',
              ),

              // About the app : ...
              SettingCard(
                onTap: () {
                  // Redirect to About the App Page
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => const AboutTheAppPage(),
                      ));
                },
                trailing: Container(),
                leading: CircleAvatar(
                  radius: 0.08.sw,
                  backgroundColor: kSecondColor,
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 25.sp,
                  ),
                ),
                settingTitle: 'About the App',
                settingSubTitle: 'Version, Licenses, etc.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

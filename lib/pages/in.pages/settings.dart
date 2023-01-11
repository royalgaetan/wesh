import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/settings.pages/about_the_app.dart';
import 'package:wesh/pages/settings.pages/account_security_settings.dart';
import 'package:wesh/pages/settings.pages/help_page.dart';
import 'package:wesh/pages/settings.pages/invite_someone_page.dart';
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

  const SettingsPage({Key? key, required this.user}) : super(key: key);

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
          'Paramètres',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Tooltip(
            message: 'Se déconnecter',
            child: IconButton(
              splashRadius: 0.06.sw,
              onPressed: () async {
                // Show Delete Decision Modal
                List deleteDecision = await showModalDecision(
                  context: context,
                  header: 'Déconnexion',
                  content: 'Voulez-vous réellement vous déconnecter ?',
                  firstButton: 'Annuler',
                  secondButton: 'Déconnexion',
                );

                if (deleteDecision[0] == true) {
                  // Sign out
                  // ignore: use_build_context_synchronously
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
                  child: buildCachedNetworkImage(
                    url: updatedUser!.profilePicture,
                    radius: 0.08.sw,
                    backgroundColor: kGreyColor,
                    paddingOfProgressIndicator: 13,
                  ),
                ),
                settingTitle: 'Mon Compte',
                settingSubTitle: 'Modifier vos informations personnelles',
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
                    size: 23.sp,
                  ),
                ),
                settingTitle: 'Notifications',
                settingSubTitle: 'Être informer sur les messages, les évènements, etc.',
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
                settingTitle: 'Sécurité',
                settingSubTitle: 'Proteger votre compte',
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
                settingTitle: 'Aide',
                settingSubTitle: 'Reporter un bug, poser vos questions, etc.',
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
                    size: 23.sp,
                  ),
                ),
                settingTitle: 'À propos de l\'application',
                settingSubTitle: 'Version, Licences, etc.',
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
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 23.sp,
                  ),
                ),
                settingTitle: 'Inviter un.e ami.e',
                settingSubTitle: 'Dites à un de vos proches de vous rejoindre',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

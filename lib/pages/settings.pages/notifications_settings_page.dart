import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import '../../models/user.dart' as usermodel;
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';

class NotificationsSettingsPage extends StatefulWidget {
  final usermodel.User user;

  const NotificationsSettingsPage({super.key, required this.user});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool isLoading = false;

  bool showAllNotifications = false;
  bool showEventsNotifications = false;
  bool showRemindersNotifications = false;
  bool showStoriesNotifications = false;
  bool showMessagesNotifications = false;

  @override
  void initState() {
    super.initState();

    // init user notifications settings
    setState(() {
      showEventsNotifications = widget.user.settingShowEventsNotifications;
      showRemindersNotifications = widget.user.settingShowRemindersNotifications;
      showStoriesNotifications = widget.user.settingShowStoriesNotifications;
      showMessagesNotifications = widget.user.settingShowMessagesNotifications;
    });

    // init showAllNotifications
    updateShowAllNotifications();
  }

  updateShowAllNotifications() {
    if (showEventsNotifications &&
        showRemindersNotifications &&
        showStoriesNotifications &&
        showMessagesNotifications) {
      setState(() {
        showAllNotifications = true;
      });
    } else {
      setState(() {
        showAllNotifications = false;
      });
    }
  }

  updateProfileWithNotificationsPreferences() async {
    bool result = false;

    //
    showFullPageLoader(context: context, color: Colors.white);
    //

    // UPDATE USER
    if (widget.user.id.isNotEmpty) {
      // Modeling an user with notifications preferences
      Map<String, dynamic> userFieldToUpdate = {
        'settingShowEventsNotifications': showEventsNotifications,
        'settingShowRemindersNotifications': showRemindersNotifications,
        'settingShowStoriesNotifications': showStoriesNotifications,
        'settingShowMessagesNotifications': showMessagesNotifications,
      };

      // ignore: use_build_context_synchronously
      result = await FirestoreMethods.updateUserWithSpecificFields(context, widget.user.id, userFieldToUpdate);
      log('Profile updated (with Notifications Preferences)');
    }

    if (!mounted) return;
    usermodel.User? user = await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);
    if (!mounted) return;
    Navigator.pop(
      context,
    );

    Navigator.pop(context, user);
    // Pop the Screen once profile updated
    if (result) {
      if (!mounted) return;
      showSnackbar(context, 'Notification settings updated successfully!', kSuccessColor);
    }
  }

  handleCTAButton() async {
    // VIBRATE
    triggerVibration();

    // Update user notifications settings
    setState(() {
      isLoading = true;
    });
    var isConnected = await InternetConnection.isConnected(context);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    if (isConnected) {
      log("Has connection : $isConnected");
      // CONTINUE
      updateProfileWithNotificationsPreferences();
    } else {
      log("Has connection : $isConnected");
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // MAIN CONTENT
        Scaffold(
          backgroundColor: Colors.white,
          appBar: MorphingAppBar(
            toolbarHeight: 46,
            scrolledUnderElevation: 0.0,
            heroTag: 'notificationsSettingsPageAppBar',
            backgroundColor: Colors.white,
            titleSpacing: 0,
            elevation: 0,
            leading: IconButton(
              splashRadius: 0.06.sw,
              onPressed: () async {
                //
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black,
              ),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              // CTA Button Create or Edit Reminder
              GestureDetector(
                onTap: () {
                  handleCTAButton();
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 15, 10),
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16.sp, color: kSecondColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),

                  // Enable or Disable all notifications
                  SwitchListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                    title: Text(
                      'All Notifications',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    visualDensity: VisualDensity.compact,
                    subtitle: Text('Receive all notifications',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                    value: showAllNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        showAllNotifications = value;
                        showEventsNotifications = value;
                        showRemindersNotifications = value;
                        showStoriesNotifications = value;
                        showMessagesNotifications = value;
                      });
                    },
                    secondary: const CircleAvatar(
                      backgroundColor: kSecondColor,
                      child: Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
                    ),
                  ),

                  // Divider
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Divider(height: 0.8, color: Colors.grey.shade200),
                  ),

                  // Enable or Disable Events notifications
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                    title: Text(
                      'Events',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Receive notifications for event creations and updates',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                    value: showEventsNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        showEventsNotifications = value;
                      });
                      updateShowAllNotifications();
                    },
                    visualDensity: VisualDensity.compact,
                    secondary: const CircleAvatar(
                      backgroundColor: kSecondColor,
                      child: Icon(FontAwesomeIcons.splotch, color: Colors.white, size: 19),
                    ),
                  ),

                  // Enable or Disable Reminders notifications
                  const SizedBox(height: 15),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                    title: Text(
                      'Reminders',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Receive notifications for your various reminders',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                    value: showRemindersNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        showRemindersNotifications = value;
                      });
                      updateShowAllNotifications();
                    },
                    visualDensity: VisualDensity.compact,
                    secondary: const CircleAvatar(
                      backgroundColor: kSecondColor,
                      child: Icon(FontAwesomeIcons.clockRotateLeft, color: Colors.white, size: 19),
                    ),
                  ),

                  // Enable or Disable Stories notifications
                  const SizedBox(height: 15),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                    title: Text(
                      'Stories',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Receive notifications for story updates',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                    value: showStoriesNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        showStoriesNotifications = value;
                      });
                      updateShowAllNotifications();
                    },
                    visualDensity: VisualDensity.compact,
                    secondary: const CircleAvatar(
                      backgroundColor: kSecondColor,
                      child: Icon(FontAwesomeIcons.circleNotch, color: Colors.white, size: 19),
                    ),
                  ),

                  // Divider
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Divider(height: 0.8, color: Colors.grey.shade200),
                  ),

                  // Enable or Disable Messages notifications
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                    title: Text(
                      'Chat',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Receive notifications for chat messages',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                    value: showMessagesNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        showMessagesNotifications = value;
                      });
                      updateShowAllNotifications();
                    },
                    secondary: const CircleAvatar(
                      backgroundColor: kSecondColor,
                      child: Icon(FontAwesomeIcons.message, color: Colors.white, size: 19),
                    ),
                  ),

                  const SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          ),
        ),

        // LOADER
        isLoading
            ? Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
                ),
              )
            : Container(),
      ],
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart' as UserModel;
import '../../providers/user.provider.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';

class NotificationsSettingsPage extends StatefulWidget {
  final UserModel.User user;

  const NotificationsSettingsPage({super.key, required this.user});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
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
    // TODO: implement initState
    super.initState();

    // init user notifications settings
    setState(() {
      showEventsNotifications = widget.user.settingShowEventsNotifications;
      showRemindersNotifications =
          widget.user.settingShowRemindersNotifications;
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    // UPDATE USER
    if (widget.user != null) {
      // Modeling an user with notifications preferences
      Map<String, Object?> userFieldToUpdate = {
        'settingShowEventsNotifications': showEventsNotifications,
        'settingShowRemindersNotifications': showRemindersNotifications,
        'settingShowStoriesNotifications': showStoriesNotifications,
        'settingShowMessagesNotifications': showMessagesNotifications,
      };

      // ignore: use_build_context_synchronously
      result = await FirestoreMethods().updateUserWithSpecificFields(
          context, widget.user.id, userFieldToUpdate);
      debugPrint('Profile updated (with Notifications Preferences)');
    }

    UserModel.User? user =
        // ignore: use_build_context_synchronously
        await Provider.of<UserProvider>(context, listen: false)
            .getFutureUserById(FirebaseAuth.instance.currentUser!.uid);

    // ignore: use_build_context_synchronously
    Navigator.pop(
      context,
    );

    // ignore: use_build_context_synchronously
    Navigator.pop(context, user);
    // Pop the Screen once profile updated
    if (result) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Votre profil à bien été modifié !', kSuccessColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 25,
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 27,
              ),

              // Enable or Disable all notifications
              SwitchListTile(
                title: const Text('Toutes les notifications'),
                subtitle: const Text('Afficher toutes les notifications'),
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
                secondary: const Icon(FontAwesomeIcons.bell),
              ),

              // Divider
              const SizedBox(height: 10),
              const SizedBox(
                width: double.infinity,
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                ),
              ),

              // Enable or Disable Events notifications
              const SizedBox(
                height: 20,
              ),
              SwitchListTile(
                title: const Text('Evènements'),
                subtitle: const Text(
                    'Afficher les notifications sur la création d\'évènements'),
                value: showEventsNotifications,
                onChanged: (bool value) {
                  setState(() {
                    showEventsNotifications = value;
                  });
                  updateShowAllNotifications();
                },
                secondary: const Icon(FontAwesomeIcons.splotch),
              ),

              // Enable or Disable Reminders notifications
              const SizedBox(
                height: 20,
              ),
              SwitchListTile(
                title: const Text('Rappel'),
                subtitle: const Text(
                    'Afficher les notifications sur vos différents rappels'),
                value: showRemindersNotifications,
                onChanged: (bool value) {
                  setState(() {
                    showRemindersNotifications = value;
                  });
                  updateShowAllNotifications();
                },
                secondary: const Icon(FontAwesomeIcons.clockRotateLeft),
              ),

              // Enable or Disable Stories notifications
              const SizedBox(
                height: 20,
              ),
              SwitchListTile(
                title: const Text('Stories'),
                subtitle:
                    const Text('Afficher les notifications sur les stories'),
                value: showStoriesNotifications,
                onChanged: (bool value) {
                  setState(() {
                    showStoriesNotifications = value;
                  });
                  updateShowAllNotifications();
                },
                secondary: const Icon(FontAwesomeIcons.circleNotch),
              ),

              // Divider
              const SizedBox(height: 10),
              const SizedBox(
                width: double.infinity,
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                ),
              ),

              // Enable or Disable Messages notifications
              const SizedBox(
                height: 20,
              ),
              SwitchListTile(
                title: const Text('Messages'),
                subtitle: const Text(
                    'Afficher les notifications sur les messages entrants'),
                value: showMessagesNotifications,
                onChanged: (bool value) {
                  setState(() {
                    showMessagesNotifications = value;
                  });
                  updateShowAllNotifications();
                },
                secondary: const Icon(FontAwesomeIcons.message),
              ),

              const SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          // [ACTION BUTTON] Add Event Button
          FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: kSecondColor,
        child: Transform.translate(
            offset: const Offset(1, -1),
            child: const Icon(
              Icons.done,
              color: Colors.white,
            )),
        onPressed: () async {
          // Update user notifications settings
          setState(() {
            isLoading = true;
          });
          var isConnected = await InternetConnection().isConnected(context);
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          if (isConnected) {
            debugPrint("Has connection : $isConnected");
            // CONTINUE
            updateProfileWithNotificationsPreferences();
          } else {
            debugPrint("Has connection : $isConnected");
            // ignore: use_build_context_synchronously
            showSnackbar(
                context, 'Veuillez vérifier votre connexion internet', null);
          }
        },
      ),
    );
  }
}
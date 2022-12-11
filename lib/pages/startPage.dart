import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_information/device_information.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:telephony/telephony.dart';
import 'package:wesh/pages/addpage.dart';
import 'package:wesh/pages/homePage.dart';
import 'package:wesh/pages/discussions.dart';
import 'package:wesh/pages/in.pages/introductionpages.dart';
import 'package:wesh/pages/in.pages/settings.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/pages/stories.dart';
import 'package:wesh/utils/constants.dart';
import '../models/message.dart';
import '../models/user.dart' as UserModel;
import '../providers/user.provider.dart';
import '../services/firestore.methods.dart';
import '../services/notifications_api.dart';
import '../services/sharedpreferences.service.dart';
import '../utils/functions.dart';
import 'in.pages/forward_to.dart';

class StartPage extends StatefulWidget {
  final int? initTabIndex;
  final BuildContext context;
  const StartPage({Key? key, this.initTabIndex, required this.context}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with WidgetsBindingObserver {
  int currentPageIndex = 4;
  bool showIntroductionPages = false;
  bool _shouldRequestPermission = true;
  late PageController pageController;

  final Telephony telephony = Telephony.instance;

  final List<Widget> _pages = [
    HomePage(),
    MessagesPage(),
    const AddPage(),
    StoriesPage(),
    ProfilePage(uid: FirebaseAuth.instance.currentUser!.uid, showBackButton: false),
  ];

  //
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles = [];
  String _sharedText = '';

  listenNotification() {
    NotificationApi.onNotification.stream.listen((payload) {
      log('Payload: ${payload ?? ''}');
    });
  }

  Future listenToIncomingMessages() async {
    // Get Current Active Page
    String currentActivePage = UserSimplePreferences.getCurrentActivePageHandler() ?? '';
    log('currentActivePage: $currentActivePage');

    // DON'T SHOW INCOMING MESSAGE NOTIFICATIONS WHEN MESSAGEPAGE IS ACTIVE
    if (currentActivePage != 'MessagesPage') {
      // Listen to Incoming Messages
      FirebaseFirestore.instance.collection('messages').snapshots().listen((event) async {
        // Remove unexistent messages
        event.docChanges.where((change) {
          return change.doc.exists;
        });
        List<Message> receivedMessagesList =
            event.docChanges.map((change) => Message.fromJson(change.doc.data()!)).toList();

        // Sort Received Messages
        receivedMessagesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        // Get Last Message
        Message lastMessage = receivedMessagesList.first;

        // Trigger Notification for that message
        // Get Current User | + Infos, settings
        UserModel.User? currentUser = await FirestoreMethods().getUser(FirebaseAuth.instance.currentUser!.uid);

        // Filter Message received
        if (currentUser != null && currentUser.settingShowMessagesNotifications == true) {
          // Get User Sender Name
          UserModel.User? userSender = await FirestoreMethods().getUser(lastMessage.senderId);

          if (userSender != null &&
              lastMessage.status == 1 &&
              lastMessage.receiverId == FirebaseAuth.instance.currentUser!.uid) {
            // SenderUser is not [ME]

            String payload = 'inbox:${lastMessage.senderId}';
            String largeIconPath = await getMessageNotificationLargeIconPath(
                filename: '${userSender.id}.png', url: userSender.profilePicture, type: 'thumbnail');
            log('Payload from: $payload && largeIconPath: $largeIconPath');
            log('Body is: ${getMessageNotificationBody(lastMessage)}');
            NotificationApi.showSimpleNotification(
              id: userSender.id.hashCode,
              title: userSender.name,
              body: getMessageNotificationBody(lastMessage),
              payload: payload,
              channel: notificationsChannelList[0],
              largeIconPath: largeIconPath,
            );
          }

          //
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    listenToIncomingMessages();
    //
    NotificationApi.init();
    listenNotification();

    //
    pageController = PageController(initialPage: 4);
    widget.initTabIndex != null ? navigateThroughTab(widget.initTabIndex!) : null;
    //
    WidgetsBinding.instance.addObserver(this);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      requestNeededPermissions(context);
    });

    //Check Introduction Pages Handler
    showIntroductionPages = UserSimplePreferences.getShowIntroductionPagesHandler() ?? false;
    if (showIntroductionPages) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => IntroductionScreensPage(),
          ),
        );
      });
    }

    //  Redirect To SettingPage [IF RedirectToAddEmailandPasswordPageValue == true]
    //  Redirect To SettingPage [OR IF RedirectToAddEmailPageValue == true]
    //  Redirect To SettingPage [OR IF RedirectToUpdatePasswordPageValue == true]
    redirectToSettingPage();

    // Redirect To ForwardToPage : IF THERE IS SHARED CONTENT
    redirectToForwardPage();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _intentDataStreamSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  redirectToForwardPage() {
    // For sharing files coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      _sharedFiles = value;

      List<Map<String, Object>> mediaSharedList =
          _sharedFiles.map((file) => {'data': file.path, 'type': file.type}).toList();
      print('get shared files [WHILE THE APP IS OPEN] : $mediaSharedList');

      if (mediaSharedList.isNotEmpty) {
        // Redirect to ForwardToPage
        Navigator.pushAndRemoveUntil(widget.context, SwipeablePageRoute(
          builder: (context) {
            return ForwardToPage(
                previousPageName: 'startPage', typeToForward: 'contentShared', mediaSharedToForward: mediaSharedList);
          },
        ), (route) => false);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing files coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      _sharedFiles = value;

      List<Map<String, Object>> mediaSharedList =
          _sharedFiles.map((file) => {'data': file.path, 'type': file.type}).toList();
      print('get shared files [APP INITIALLY CLOSED] : $mediaSharedList');

      if (mediaSharedList.isNotEmpty) {
        // Redirect to ForwardToPage
        Navigator.pushAndRemoveUntil(widget.context, SwipeablePageRoute(
          builder: (context) {
            return ForwardToPage(
                previousPageName: 'startPage', typeToForward: 'contentShared', mediaSharedToForward: mediaSharedList);
          },
        ), (route) => false);
      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      _sharedText = value;
      String textShared = _sharedText;
      print('get shared text : $textShared');

      // Redirect to ForwardToPage
      if (textShared.isNotEmpty) {
        Navigator.pushAndRemoveUntil(widget.context, SwipeablePageRoute(
          builder: (context) {
            return ForwardToPage(
              previousPageName: 'startPage',
              typeToForward: 'contentShared',
              textSharedToForward: textShared,
            );
          },
        ), (route) => false);
      }
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      _sharedText = value ?? '';
      String textShared = _sharedText;
      print('get shared text [APP INITIALLY CLOSED] : $textShared');
      if (textShared.isNotEmpty && value != null) {
        // Redirect to ForwardToPage
        Navigator.pushAndRemoveUntil(widget.context, SwipeablePageRoute(
          builder: (context) {
            return ForwardToPage(
              previousPageName: 'startPage',
              typeToForward: 'contentShared',
              textSharedToForward: textShared,
            );
          },
        ), (route) => false);
      }
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // this will be loop after back from openAppSettings()
    // and when calling requestPermission();
    print('#didChangeApplifeCycleState $state');
    if (state == AppLifecycleState.resumed) {
      print('#didChangeApplifeCycleState state is resume');
      if (_shouldRequestPermission) {
        _shouldRequestPermission = false;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          requestNeededPermissions(context);
        });
      }
    }
  }

  Future requestNeededPermissions(context) async {
    // bool? requestPhoneAndSmsPermissions = await telephony.requestPhoneAndSmsPermissions;
    // Create App Folders

    if (Platform.isAndroid) {
      if (await Permission.phone.request().isGranted) {
        try {
          String platformVersion = await DeviceInformation.platformVersion;
          dynamic apiLevel = await DeviceInformation.apiLevel;

          print('Device platformVersion: $platformVersion');

          if (int.parse((platformVersion.split(' ')[1]).split('.').first) >= 11) {
            if (await Permission.manageExternalStorage.request().isGranted) {
              //
              log(' MANAGE_EXTERNAL_STORAGE GRANTED !');
            } else {
              _shouldRequestPermission = true;
              await openAppSettings();
            }
          }
        } on PlatformException {
          var platformVersion = 'Impossible d\'obtenir la version de la plate forme';
        }
      }
    }

    if (await Permission.storage.request().isGranted &&
        await Permission.phone.request().isGranted &&
        await Permission.sms.request().isGranted &&
        await Permission.microphone.request().isGranted) {
      try {
        List directories = await getDirectories();
        // Stories
        await File('${directories[0]}/$appName/${getSpecificDirByType('story')}/.nomedia').create(recursive: true);

        // Thumbnails
        await File('${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/.nomedia').create(recursive: true);

        // Messages Files
        await File('${directories[0]}/$appName/${getSpecificDirByType('image')}/.nomedia').create(recursive: true);
        await File('${directories[0]}/$appName/${getSpecificDirByType('video')}/.nomedia').create(recursive: true);
        await File('${directories[0]}/$appName/${getSpecificDirByType('voicenote')}/.nomedia').create(recursive: true);
        await File('${directories[0]}/$appName/${getSpecificDirByType('music')}/.nomedia').create(recursive: true);

        log('.nomedia files [+ related directories] created !');
      } catch (e) {
        log('Error while creating .nomedia files [+ related directories] : $e');
      }

      _shouldRequestPermission = false;
    } else if (await Permission.storage.request().isPermanentlyDenied ||
        await Permission.phone.request().isPermanentlyDenied ||
        await Permission.sms.request().isPermanentlyDenied ||
        await Permission.microphone.request().isPermanentlyDenied) {
      _shouldRequestPermission = true;
      Navigator.pop(context);
      await openAppSettings();
    } else {
      // Show Modal Decision
      List requestPermissionDecision = await showModalDecision(
        barrierDismissible: false,
        context: context,
        header: 'Permissions',
        content: '$appName a besoin de votre permission pour continuer',
        firstButton: 'Sortir',
        secondButton: 'Continuer',
      );

      if (requestPermissionDecision[0] == true) {
        _shouldRequestPermission = true;
        Navigator.pop(context);
        await openAppSettings();
      } else {
        log('Exit from the app !');
        exit(0);
      }
    }
  }

  Future redirectToSettingPage() async {
    var valueToRedirect1 = UserSimplePreferences.getRedirectToAddEmailandPasswordPageValue() ?? false;
    debugPrint("Redirect to Setting Page [START PAGE]: $valueToRedirect1 ");
    if (valueToRedirect1) {
      UserModel.User? user = await Provider.of<UserProvider>(context, listen: false)
          .getFutureUserById(FirebaseAuth.instance.currentUser!.uid);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => SettingsPage(user: user!),
          ),
        );
      });
    }

    //
    var valueToRedirect2 = UserSimplePreferences.getRedirectToAddEmailPageValue() ?? false;
    debugPrint("Redirect2 to Setting Page [START PAGE]: $valueToRedirect2 ");
    if (valueToRedirect2) {
      UserModel.User? user =
          // ignore: use_build_context_synchronously
          await Provider.of<UserProvider>(context, listen: false)
              .getFutureUserById(FirebaseAuth.instance.currentUser!.uid);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => SettingsPage(user: user!),
          ),
        );
      });
    }

    //
    var valueToRedirect3 = UserSimplePreferences.getRedirectToUpdatePasswordPageValue() ?? false;
    debugPrint("Redirect3 to Setting Page [START PAGE]: $valueToRedirect3 ");
    if (valueToRedirect3) {
      UserModel.User? user =
          // ignore: use_build_context_synchronously
          await Provider.of<UserProvider>(context, listen: false)
              .getFutureUserById(FirebaseAuth.instance.currentUser!.uid);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          SwipeablePageRoute(
            builder: (context) => SettingsPage(user: user!),
          ),
        );
      });
    }
  }

  void navigateThroughTab(int index) async {
    log('Index: $index');
    setState(() {
      currentPageIndex = index;
      pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: _pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 0.09.sh,
        child: BottomNavigationBar(
          currentIndex: currentPageIndex,
          onTap: navigateThroughTab,
          selectedItemColor: kSecondColor,
          unselectedItemColor: Colors.grey.shade600,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.house,
                  size: 17.sp,
                ),
                label: 'Accueil'),
            BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.message,
                  size: 17.sp,
                ),
                label: 'Messages'),
            BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.plus,
                  size: 17.sp,
                ),
                label: 'Créer'),
            BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.circleNotch,
                  size: 17.sp,
                ),
                label: 'Stories'),
            BottomNavigationBarItem(
                icon: Icon(
                  FontAwesomeIcons.user,
                  size: 17.sp,
                ),
                label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

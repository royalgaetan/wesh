// ignore: file_names
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:device_information/device_information.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as localnotification;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:telephony/telephony.dart';
import 'package:timezone/timezone.dart';
import 'package:wesh/models/celebration.dart';
import 'package:wesh/models/stories_handler.dart';
import 'package:wesh/pages/addpage.dart';
import 'package:wesh/pages/homePage.dart';
import 'package:wesh/pages/discussions.dart';
import 'package:wesh/pages/in.pages/happy_birthday_page.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/pages/in.pages/introductionpages.dart';
import 'package:wesh/pages/in.pages/settings.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/pages/stories.dart' as storiespage;
import 'package:wesh/utils/constants.dart';
import '../models/event.dart';
import '../models/feedback.dart';
import '../models/reminder.dart';
import '../models/story.dart';
import '../models/user.dart' as usermodel;
import '../services/background.service.dart';
import '../services/firestore.methods.dart';
import '../services/notifications_api.dart';
import '../services/sharedpreferences.service.dart';
import '../utils/functions.dart';
import '../widgets/eventview.dart';
import '../widgets/modal.dart';
import '../widgets/reminderView.dart';
import 'in.pages/forward_to.dart';
import 'in.pages/storiesViewer.dart';
import 'package:timezone/timezone.dart' as tz;

class StartPage extends StatefulWidget {
  final int? initTabIndex;
  final BuildContext context;
  const StartPage({Key? key, this.initTabIndex, required this.context}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with WidgetsBindingObserver {
  int currentPageIndex = 0;
  bool showIntroductionPages = false;
  bool _shouldRequestPermission = true;
  late PageController pageController;

  final Telephony telephony = Telephony.instance;

  final List<Widget> _pages = [
    const HomePage(),
    const MessagesPage(),
    const AddPage(),
    const storiespage.StoriesPage(),
    ProfilePage(uid: FirebaseAuth.instance.currentUser!.uid, showBackButton: false),
  ];

  //
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles = [];
  String _sharedText = '';
  //
  late Stream<usermodel.User> streamCurrentUser;
  late StreamSubscription<usermodel.User> streamCurrentUserSubscription;
  usermodel.User? currentUser;
  List<String> currentUserFollowings = [];

  late StreamSubscription<String?> streamNotificationSubscription;

  listenNotification() {
    streamNotificationSubscription = NotificationApi.onNotification.stream.listen((payloadReceived) async {
      String payload = payloadReceived ?? '';
      log('Payload: $payload');

      // CELEBRATIONS CASE
      if (payload.contains('celebration')) {
        // String payloadCelebrationId = payload.split(':').last;

        // ...

      }

      // EVENTS CASE
      if (payload.contains('event')) {
        String payloadEventId = payload.split(':').last;
        log('EventViewer with: $payloadEventId');
        showFullPageLoader(context: context);

        // Show EventView Modal
        Navigator.pop(context);
        showModalBottomSheet(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          backgroundColor: Colors.transparent,
          builder: ((context) => Modal(
                minHeightSize: MediaQuery.of(context).size.height / 1.4,
                maxHeightSize: MediaQuery.of(context).size.height,
                child: EventView(eventId: payloadEventId),
              )),
        );
      }

      // REMINDERS CASE
      if (payload.contains('reminder')) {
        String payloadReminderId = payload.split(':').last;
        log('ReminderViewer with: $payloadReminderId');
        showFullPageLoader(context: context);

        // Show ReminderView Modal
        Navigator.pop(context);
        showModalBottomSheet(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          backgroundColor: Colors.transparent,
          builder: ((context) => Scaffold(
                backgroundColor: Colors.transparent,
                body: Modal(
                  child: ReminderView(reminderId: payloadReminderId),
                ),
              )),
        );
      }

      // MESSAGES CASE
      if (payload.contains('inbox')) {
        String payloadUserId = payload.split(':').last;
        log('Inbox with: $payloadUserId');
        showFullPageLoader(context: context);
        // Redirect to the InboxPage

        Navigator.pop(context);
        context.pushTransparentRoute(InboxPage(
          userReceiverId: payloadUserId,
        ));
      }

      // STORIES CASE
      if (payload.contains('storiespage')) {
        String payloadUserId = payload.split(':').last;
        log('Show Stories of: $payloadUserId');

        // Sort [UserGet] Stories
        showFullPageLoader(context: context);
        usermodel.User? userGet = await FirestoreMethods.getUser(payloadUserId);
        if (userGet != null) {
          List<Story> userGetStories =
              await FirestoreMethods.getNonExpiredStoriesByUserPosterIdInList([userGet.id]).first;

          userGetStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          userGetStories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          if (userGetStories.isNotEmpty) {
            // Build [UserGet] StoriesHandler
            StoriesHandler userStoriesHandler = StoriesHandler(
              origin: 'userStories',
              posterId: userGet.id,
              avatarPath: userGet.profilePicture,
              title: userGet.name,
              lastStoryDateTime: getLastStoryOfStoriesList(userGetStories).createdAt,
              stories: userGetStories,
            );

            // Story Page View
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            // ignore: use_build_context_synchronously
            context.pushTransparentRoute(StoriesViewer(
              storiesHandlerList: [userStoriesHandler],
              indexInStoriesHandlerList: 0,
            ));
          } else {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        } else {
          // ignore: use_build_context_synchronously
          // Navigator.pop(context);
        }
      }
    });
  }

  Future initAllCelebrationsAndReminders() async {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Build Celebrations
    List<Celebration> allYearlyCelebrations = [];
    usermodel.User? currentUser = await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);

    // Add Common Celebrations
    if (currentUser != null) {
      // Happy New Year
      Celebration happyNewYear = Celebration(
          title: appName,
          description: '🎉 Bonne année, de la part de $appName 🎈🎊',
          type: 'happynewyear',
          id: 'happynewyear',
          userPoster: currentUser,
          dateTime: DateTime(now.year, 1, 1));

      // Merry Christmas
      Celebration merryChristmas = Celebration(
          title: appName,
          description: '🎉 Joyeux Noël, de la part de $appName 🎈🎄',
          type: 'merrychristmas',
          id: 'merrychristmas',
          userPoster: currentUser,
          dateTime: DateTime(now.year, 12, 25));

      allYearlyCelebrations.addAll([happyNewYear, merryChristmas]);
      log('Celebration [With Commons]: $allYearlyCelebrations');

      // Get all User Birthdays
      List<String> allConcernedUsersIds = [];

      allConcernedUsersIds.add(currentUser.id);

      if (currentUser.followings != null && currentUser.followings!.isNotEmpty) {
        List<String> currentUserFollowings = currentUser.followings!.map((id) => id.toString()).toList();
        allConcernedUsersIds.addAll(currentUserFollowings);
        log('currentUserFollowings: $currentUserFollowings');
      }

      log('Trigger Celebration of: $currentUserFollowings');

      // Get Users data
      List<usermodel.User> allConcernedUsers = [];
      if (allConcernedUsersIds.isNotEmpty) {
        allConcernedUsers = await FirestoreMethods.getUserByIdInList(allConcernedUsersIds).first;
      }

      // Users birthdays --> to Celebrations
      if (allConcernedUsers.isNotEmpty) {
        for (usermodel.User user in allConcernedUsers) {
          Celebration userBirthday = Celebration(
            id: user.id,
            title: FirebaseAuth.instance.currentUser!.uid == user.id ? 'Aujourd\'hui c\'est votre jour 🤩' : user.name,
            description: FirebaseAuth.instance.currentUser!.uid == user.id
                ? '🎉 Joyeux anniversaire ${user.name} 🎈🎁 de la part de $appName'
                : 'C\'est l\'anniversaire de ${user.name}\n▶ Envoyez lui un message 💬 ou un cadeau 🎁',
            type: 'birthday',
            userPoster: user,
            dateTime: user.birthday,
          );
          //
          allYearlyCelebrations.add(userBirthday);
        }
      }

      //
      log('########### LOG CELEBRATIONS ###########\n${allYearlyCelebrations.map((c) => '${c.toJson()}\n')}');

      // UserSimplePreferences.setNotificationList([]);
      List<String> notificationList = UserSimplePreferences.getNotificationList() ?? [];
      log('########### LOG NOTIFICATIONLIST ###########\n${notificationList.map((s) => '$s \n')}');

      // Create local_notifications for Celebrations
      for (Celebration celebration in allYearlyCelebrations) {
        // Check if Celebration already exist
        String notifMatch = '${FirebaseAuth.instance.currentUser!.uid}:celebration:${celebration.id}';

        if (notificationList.isEmpty || !notificationList.any((element) => element.startsWith(notifMatch))) {
          // GENERATE NOTIFICATION
          List result = [true, generateNotificationToUse(notifMatch)];

          log('Engine: $result');

          if (result[0] == true) {
            // NEW [SCHEDULED] NOTIFICATION

            String payload = 'celebration:${celebration.id}';
            String largeIconPath = await getNotificationLargeIconPath(
              url: '',
              type: 'celebration',
              uid: '',
            );

            log('Payload from: $payload && largeIconPath: $largeIconPath');
            // tz.TZDateTime now = tz.TZDateTime.now(tz.local);
            int randomHour = getRandomNumberBetween(7, 10);
            int randomMinute = getRandomNumberBetween(0, 59);

            tz.TZDateTime scheduledDate = TZDateTime(
              tz.local,
              celebration.dateTime.year,
              celebration.dateTime.month,
              celebration.dateTime.day,
              now.hour,
              now.minute,
              randomHour,
              randomMinute,
            );

            NotificationApi.showScheduledNotification(
              id: int.parse((result[1] as String).split(':').last),
              title: celebration.title,
              body: celebration.description,
              payload: payload,
              channel: notificationsChannelList[2],
              largeIconPath: largeIconPath,
              tzDateTime: scheduleDaily(scheduledDate),
              dateTimeComponents: localnotification.DateTimeComponents.dateAndTime,
            );
          }
        } else {
          log('[Already exist] Skip: $notifMatch');
        }
      }

      //
      // PROCESS WITH USER REMINDERS
      //
      List<Reminder> userReminders = await FirestoreMethods.getUserReminders(currentUser.id).first;
      log('########### LOG USER REMINDERS ###########\n${userReminders.map((r) => '${r.toJson()}\n')}');

      // Create local_notifications for Reminders
      for (Reminder reminder in userReminders) {
        // Check if Reminder already exist
        String notifMatch = '${FirebaseAuth.instance.currentUser!.uid}:reminder:${reminder.reminderId}';

        if (notificationList.isEmpty || !notificationList.any((element) => element.startsWith(notifMatch))) {
          // GENERATE NOTIFICATION
          List result = [true, generateNotificationToUse(notifMatch)];

          log('Engine: $result');

          if (result[0] == true) {
            // NEW [SCHEDULED] NOTIFICATION

            String payload = 'reminder:${reminder.reminderId}';
            String largeIconPath = await getNotificationLargeIconPath(
              url: '',
              type: 'reminder',
              uid: '',
            );

            // Get Attached Event
            Event? eventAttached;
            if (reminder.eventId.isNotEmpty) {
              eventAttached = await FirestoreMethods.getEventByIdAsFuture(reminder.eventId);
            }
            String reminderBody = await getReminderNotificationBody(reminder, eventAttached);

            log('Payload from: $payload && largeIconPath: $largeIconPath');
            // tz.TZDateTime now = tz.TZDateTime.now(tz.local);

            NotificationApi.showScheduledNotification(
              id: int.parse((result[1] as String).split(':').last),
              title: reminder.title,
              body: reminderBody,
              payload: payload,
              channel: notificationsChannelList[2],
              largeIconPath: largeIconPath,
              tzDateTime: scheduleDaily(
                TZDateTime(
                  tz.local,
                  reminder.remindAt.year,
                  reminder.remindAt.month,
                  reminder.remindAt.day,
                  reminder.remindAt.hour,
                  reminder.remindAt.minute,
                ),
              ),
              dateTimeComponents: getDateTimeComponentsFromRecurrence(reminder.recurrence),
            );
          }
        } else {
          log('[Already exist] Skip: $notifMatch');
        }
      }
    }
  }

  @override
  void initState() {
    //

    super.initState();
    //
    setSuitableStatusBarColor(Colors.white);
    //

    //
    wishHappyBirthday();
    //
    streamCurrentUser = FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid);
    streamCurrentUserSubscription = streamCurrentUser.asBroadcastStream().listen((event) {
      //  Assign values
      currentUser = event;
      currentUserFollowings = event.followings?.map((userId) => userId.toString()).toList() ?? [];
    });
    //
    FlutterBackgroundService().invoke(BackgroundTaskHandler.initBackgroundTasks);
    //
    NotificationApi.init(initScheduled: true);
    listenNotification();

    //
    pageController = PageController(initialPage: widget.initTabIndex ?? 0);
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
            builder: (context) => const IntroductionScreensPage(),
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
    //
    super.dispose();
    //
    streamCurrentUserSubscription.cancel();
    streamNotificationSubscription.cancel();
    //

    _intentDataStreamSubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future wishHappyBirthday() async {
    // log('DDD: ${UserSimplePreferences.getHappyBirthdayDateTimeWish()}');

    usermodel.User? currentUser = await FirestoreMethods.getUser(FirebaseAuth.instance.currentUser!.uid);
    // Check UserPreferences
    int? happyBirthdayDateTimeSaved = UserSimplePreferences.getHappyBirthdayDateTimeWish();
    log('Birthday DateTime Saved: $happyBirthdayDateTimeSaved');

    // Check if the today is the birthday of the current user
    if (currentUser != null &&
        currentUser.birthday.month == DateTime.now().month &&
        currentUser.birthday.day == DateTime.now().day) {
      //
      if (happyBirthdayDateTimeSaved != null && happyBirthdayDateTimeSaved == DateTime.now().year) {
        log('Has already received Birthday Wishes');
      } else {
        //  Redirect to HappyBirthday Page
        // ignore: use_build_context_synchronously
        bool? result = await Navigator.push(
            context,
            SwipeablePageRoute(
              builder: (context) => HappyBirthdayPage(currentUser: currentUser),
            ));
        log('Finished');
        //

        if (result == true) {
          // Send 'THANK YOU AS FEEDBACK'

          // Modeling a new feedback model
          Map<String, dynamic> feedbackToSend = FeedBack(
            feedbackId: '',
            uid: FirebaseAuth.instance.currentUser!.uid,
            name: currentUser.name,
            content: 'Merci beaucoup d\'avoir pensé à moi le jour de mon anniversaire',
            reactionTitle: 'Excellent',
            reactionEmoji: '🥰',
            createdAt: DateTime.now(),
          ).toJson();

          // ignore: use_build_context_synchronously
          result = await FirestoreMethods.sendFeedback(context, feedbackToSend);
          log('Feedback [FOR MY BIRTHDAY] sent : $feedbackToSend');
        }
      }
    }
  }

  redirectToForwardPage() {
    // For sharing files coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      _sharedFiles = value;

      List<Map<String, Object>> mediaSharedList =
          _sharedFiles.map((file) => {'data': file.path, 'type': file.type}).toList();
      debugPrint('get shared files [WHILE THE APP IS OPEN] : $mediaSharedList');

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
      debugPrint("getIntentDataStream error: $err");
    });

    // For sharing files coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      _sharedFiles = value;

      List<Map<String, Object>> mediaSharedList =
          _sharedFiles.map((file) => {'data': file.path, 'type': file.type}).toList();
      debugPrint('get shared files [APP INITIALLY CLOSED] : $mediaSharedList');

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
      debugPrint('get shared text : $textShared');

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
      debugPrint("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      _sharedText = value ?? '';
      String textShared = _sharedText;
      debugPrint('get shared text [APP INITIALLY CLOSED] : $textShared');
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
    debugPrint('#didChangeApplifeCycleState $state');
    if (state == AppLifecycleState.resumed) {
      debugPrint('#didChangeApplifeCycleState state is resume');
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

          debugPrint('Device platformVersion: $platformVersion');

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

    if (await Permission.storage.request().isGranted && await Permission.phone.request().isGranted) {
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
        await Permission.phone.request().isPermanentlyDenied) {
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
      usermodel.User? user = await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);
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
      usermodel.User? user =
          // ignore: use_build_context_synchronously
          await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);
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
      usermodel.User? user =
          // ignore: use_build_context_synchronously
          await FirestoreMethods.getUserByIdAsFuture(FirebaseAuth.instance.currentUser!.uid);
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

    setCurrentActivePageFromIndex(index: index);
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

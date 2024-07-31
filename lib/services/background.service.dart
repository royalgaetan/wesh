import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/utils/constants.dart';
import '../models/event.dart';
import '../models/event_duration_type.dart';
import '../models/message.dart';
import '../models/story.dart';
import '../models/user.dart' as usermodel;
import '../services/notifications_api.dart';
import '../services/sharedpreferences.service.dart';
import '../utils/functions.dart';

class BackgroundTaskHandler {
  //
  @pragma('vm:entry-point')
  static final firebaseInstance = Firebase.initializeApp();

  static listenServerChanges() async {
    log('ListenServerChanges Started');

    // INITS
    await Firebase.initializeApp();
    await UserSimplePreferences.init();
    initializeDateFormatting();
    //
    try {
      log('ListenServerChanges is listening...');
      listenToCreatedOrUpdatedEvents();
      listenToIncomingMessages();
      listenToUnseenStories();
    } catch (e) {
      log('ListenServerChanges has error: $e !');
    }
  }

  static const initBackgroundTasks = 'initBackgroundTasks';

  // OTHERS BACKGROUND FUNCTIONS HANDLER
  static Future listenToCreatedOrUpdatedEvents() async {
    // Listen to created or updated events
    FirebaseFirestore.instance.collection('events').snapshots().listen((event) async {
      List<DocumentChange> listOfChanges = event.docChanges.where((change) => change.doc.exists).toList();
      //
      List<Map<Event, DocumentChangeType>> eventsReceived = listOfChanges.map((eventChange) {
        Event event = Event.fromJson(eventChange.doc.data()! as Map<String, dynamic>);
        DocumentChangeType eventChangeType = eventChange.type;

        //
        return {event: eventChangeType};
        //
      }).toList();

      //
      // CHECK EVENTS NOTIFICATION SETTINGS && CURRENT PAGE DISPLAYED
      // Get Current User | + Infos, settings
      usermodel.User? currentUser = await FirestoreMethods.getUser(FirebaseAuth.instance.currentUser!.uid);
      // String currentActivePage = UserSimplePreferences.getCurrentActivePageHandler() ?? '';

      if (currentUser != null && currentUser.followings != null && currentUser.settingShowEventsNotifications) {
        // Retain only if
        // [To review] #######--> currentActivePage != homepage #######
        // --> userPoster != [Me]
        // --> It belongs to one of my followings

        log('Settings: ${currentUser.settingShowEventsNotifications}');

        eventsReceived = eventsReceived
            .where((eventAndChange) =>
                eventAndChange.keys.first.uid != FirebaseAuth.instance.currentUser!.uid &&
                currentUser.followings!.contains(eventAndChange.keys.first.uid))
            .toList();

        log('eventsReceived: $eventsReceived');

        // Get corresponding users : remove redundant ones
        List<String> correspondingUsers = eventsReceived.map((e) => e.keys.first.uid).toList().toSet().toList();

        log('correspondingUsers: $correspondingUsers');
        // Build Notification --> forEach User
        for (String userId in correspondingUsers) {
          usermodel.User? user = await FirestoreMethods.getUserByIdAsFuture(userId);
          if (user != null) {
            List<Map<Event, DocumentChangeType>> userEventsReceived =
                eventsReceived.where((s) => s.keys.first.uid == user.id).toList();
            // Sort User Event Received
            // AND Retain only events that will happen in 3-7 days
            if (userEventsReceived.isNotEmpty) {
              userEventsReceived.sort((a, b) => b.keys.first.createdAt.compareTo(a.keys.first.createdAt));
              //
              userEventsReceived = userEventsReceived.where((element) {
                // For birthday only
                List<int> randomNumbersForDateSuggestion = [1, 3, 7];
                bool isEventDateInsideRandomNumbersForDateSuggestion = randomNumbersForDateSuggestion.contains(
                    daysBetween(
                        DateTime.now(),
                        getDatetimeToUseFromDatetimeWithRecurrence(EventDurationType.fromJson(
                            element.keys.first.eventDurations.first as Map<String, dynamic>))));
                //
                log('Watching: ${element.keys.first.title}: in ${daysBetween(DateTime.now(), getDatetimeToUseFromDatetimeWithRecurrence(EventDurationType.fromJson(element.keys.first.eventDurations.first as Map<String, dynamic>)))} days | From: ${user.name}\n --> \nIs user birthday: ${isUserBirthday(element.keys.first, user)}\nIs outdated: ${isOutdatedEvent(element.keys.first)} \nInside randomNumbersForDateSuggestion: $isEventDateInsideRandomNumbersForDateSuggestion');

                // Skip Outdated | IsHappening | Isn't inside randomNumbersForDateSuggestion : Event
                if (!isHappeningEvent(element.keys.first) &&
                    !isOutdatedEvent(element.keys.first) &&
                    isEventDateInsideRandomNumbersForDateSuggestion == true) {
                  log('C:So keep it');
                  return true;
                } else {
                  log('B: So remove it');
                  return false;
                }
              }).toList();
              log('userEventsReceived: ${userEventsReceived.map((e) => e.keys.first.title).toList()}');
            }

            if (userEventsReceived.isNotEmpty) {
              // log('User to notif: ${user.name}');
              // log('contentId: ${userNotSeenStories.first.storyId}');
              // log('length: ${userNotSeenStories.length}');

              // NOTIFICATION ID ENGINE | WHEN CREATED, MODIFIED, DELETED
              List result = notificationIdEngine(
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  type: 'event',
                  notifUserId: user.id,
                  contentId: userEventsReceived.first.keys.first.eventId);

              log('Engine: $result');

              if (result[0] == true && userEventsReceived.isNotEmpty) {
                // NEW NOTIFICATION
                String payload = 'event:${userEventsReceived.first.keys.first.eventId}';
                String largeIconPath = await getNotificationLargeIconPath(
                  url: user.profilePicture,
                  eventAttached: userEventsReceived.first.keys.first,
                  type: 'event',
                  uid: userEventsReceived.first.keys.first.eventId,
                );
                String eventBody =
                    await getEventBodyNotification(userEventsReceived: userEventsReceived, userPoster: user);

                log('Payload from: $payload && largeIconPath: $largeIconPath');

                NotificationApi.showSimpleNotification(
                  id: int.parse((result[1] as String).split(':').last),
                  title: user.name,
                  body: eventBody,
                  payload: payload,
                  channel: notificationsChannelList[1],
                  largeIconPath: largeIconPath,
                );
              }
            }
          }
        }
      }
    });
  }

  static Future listenToIncomingMessages() async {
    // Listen to Incoming Messages
    FirebaseFirestore.instance.collection('messages').snapshots().listen((event) async {
      List<DocumentChange> listOfChanges = event.docChanges
          .where((change) =>
              change.type == DocumentChangeType.modified ||
              change.type == DocumentChangeType.added && change.doc.exists)
          .toList();
      List<Message> messagesReceived = listOfChanges
          .map((messageChange) => Message.fromJson(messageChange.doc.data()! as Map<String, dynamic>))
          .toList();

      //
      // CHECK MESSAGES NOTIFICATION SETTINGS && CURRENT PAGE DISPLAYED
      // Get Current User | + Infos, settings
      usermodel.User? currentUser = await FirestoreMethods.getUser(FirebaseAuth.instance.currentUser!.uid);
      String currentActivePage = UserSimplePreferences.getCurrentActivePageHandler() ?? '';

      if (currentUser != null &&
          currentUser.settingShowMessagesNotifications &&
          currentActivePage != 'discussionpage') {
        // Retain only if
        // --> currentActivePage != discussionpage
        // --> userPoster != [Me]
        // --> userReceiver == [Me]
        // --> status != 0
        // --> I haven't read it yet
        // --> I haven't seen it yet
        log('Settings: ${currentUser.settingShowMessagesNotifications}');

        messagesReceived = messagesReceived
            .where((message) =>
                message.senderId != FirebaseAuth.instance.currentUser!.uid &&
                message.receiverId == FirebaseAuth.instance.currentUser!.uid &&
                message.status != 0 &&
                !message.read.contains(FirebaseAuth.instance.currentUser!.uid) &&
                !message.seen.contains(FirebaseAuth.instance.currentUser!.uid))
            .toList();

        // Get corresponding users : remove redundant ones
        List<String> correspondingUsers = messagesReceived.map((m) => m.senderId).toList().toSet().toList();

        // Build Notification --> forEach User
        for (String userId in correspondingUsers) {
          usermodel.User? user = await FirestoreMethods.getUserByIdAsFuture(userId);

          // DON'T SHOW NOTIFICATION IF --> currentActivePage != inbox:userId
          if (user != null && currentActivePage != 'inbox:${user.id}') {
            List<Message> userNotSeenMessages = messagesReceived.where((m) => m.senderId == user.id).toList();
            // Sort User Unseen Messages
            if (userNotSeenMessages.length > 1) {
              userNotSeenMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            }

            // log('User to notif: ${user.name}');
            // log('userNotSeenMessages zz: ${userNotSeenMessages.map((e) => e.messageId).toList()}');
            // log('contentId: ${userNotSeenMessages.first.storyId}');
            // log('length: ${userNotSeenMessages.length}');

            // NOTIFICATION ID ENGINE
            List result = notificationIdEngine(
                currentUserId: FirebaseAuth.instance.currentUser!.uid,
                type: 'discussion',
                notifUserId: user.id,
                contentId: userNotSeenMessages.first.messageId);
            log('Engine: $result');
            //
            //
            if (result[0] == true) {
              // NEW NOTIFICATION
              String payload = 'inbox:${user.id}';
              String largeIconPath = await getNotificationLargeIconPath(
                url: user.profilePicture,
                type: 'discussion',
                uid: user.id,
              );
              log('Payload from: $payload && largeIconPath: $largeIconPath');

              NotificationApi.showSimpleNotification(
                id: int.parse((result[1] as String).split(':').last),
                title:
                    '${user.name} ${userNotSeenMessages.length > 1 ? '(${userNotSeenMessages.length} messages)' : ''}',
                body: getMessageNotificationBody(userNotSeenMessages.first),
                payload: payload,
                channel: notificationsChannelList[0],
                largeIconPath: largeIconPath,
              );
            }
          }
        }
      }
    });
  }

  static Future listenToUnseenStories() async {
    // Listen to unseen stories

    FirebaseFirestore.instance.collection('stories').snapshots().listen((event) async {
      List<DocumentChange> listOfChanges =
          event.docChanges.where((change) => change.type == DocumentChangeType.added && change.doc.exists).toList();
      List<Story> storiesReceived =
          listOfChanges.map((storyChange) => Story.fromJson(storyChange.doc.data()! as Map<String, dynamic>)).toList();

      //
      // CHECK STORIES NOTIFICATION SETTINGS && CURRENT PAGE DISPLAYED
      // Get Current User | + Infos, settings

      usermodel.User? currentUser = await FirestoreMethods.getUser(FirebaseAuth.instance.currentUser!.uid);
      String currentActivePage = UserSimplePreferences.getCurrentActivePageHandler() ?? '';

      if (currentActivePage != 'storiespage' &&
          currentUser != null &&
          currentUser.followings != null &&
          currentUser.settingShowStoriesNotifications) {
        // Retain only if
        // --> currentActivePage != storiespage
        // --> userPoster != [Me]
        // --> It belongs to one of my followings
        // --> Non-expired Story
        // --> I haven't seen it yet
        log('Settings: ${currentUser.settingShowStoriesNotifications}');

        storiesReceived = storiesReceived
            .where((story) =>
                story.uid != FirebaseAuth.instance.currentUser!.uid &&
                currentUser.followings!.contains(story.uid) &&
                !hasStoryExpired(story.endAt) &&
                !story.viewers.contains(FirebaseAuth.instance.currentUser!.uid))
            .toList();

        // Get corresponding users : remove redundant ones
        List<String> correspondingUsers = storiesReceived.map((s) => s.uid).toList().toSet().toList();

        // Build Notification --> forEach User
        for (String userId in correspondingUsers) {
          usermodel.User? user = await FirestoreMethods.getUserByIdAsFuture(userId);
          if (user != null) {
            List<Story> userNotSeenStories = storiesReceived.where((s) => s.uid == user.id).toList();
            // Sort User Unseen stories
            if (userNotSeenStories.length > 1) {
              userNotSeenStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            }
            // log('User to notif: ${user.name}');
            // log('userNotSeenStories zz: ${userNotSeenStories.map((e) => e.storyId).toList()}');
            // log('contentId: ${userNotSeenStories.first.storyId}');
            // log('length: ${userNotSeenStories.length}');
            // NOTIFICATION ID ENGINE

            List result = notificationIdEngine(
                currentUserId: FirebaseAuth.instance.currentUser!.uid,
                type: 'story',
                notifUserId: user.id,
                contentId: userNotSeenStories.first.storyId);
            log('Engine: $result');
            if (result[0] == true) {
              // NEW NOTIFICATION
              String payload = 'storiespage:${user.id}';
              String largeIconPath = await getNotificationLargeIconPath(
                url: user.profilePicture,
                type: 'story',
                uid: user.id,
              );
              log('Payload from: $payload && largeIconPath: $largeIconPath');

              NotificationApi.showSimpleNotification(
                id: int.parse((result[1] as String).split(':').last),
                title: user.name,
                body: userNotSeenStories.length == 1
                    ? '❤ ${user.name} has posted a story'
                    : '❤ ${user.name} has posted ${userNotSeenStories.length} ${userNotSeenStories.length > 1 ? 'stories' : 'story'} that you haven\'t seen yet',
                payload: payload,
                channel: notificationsChannelList[3],
                largeIconPath: largeIconPath,
              );
            }
          }
        }
      }
    });
  }
}

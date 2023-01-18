// ignore_for_file: unnecessary_brace_in_string_interps
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:image/image.dart' as img;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:external_path/external_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wesh/models/event_duration_type.dart';
import 'package:wesh/models/eventtype.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/services/notifications_api.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:xid/xid.dart';
import '../models/event.dart';
import '../models/message.dart' as messagemodel;
import '../models/stories_handler.dart';
import '../models/story.dart';
import '../pages/in.pages/storiesViewer.dart';
import '../services/firestore.methods.dart';
import '../services/sharedpreferences.service.dart';
import 'constants.dart';
import '../models/user.dart' as usermodel;
import 'package:timezone/timezone.dart' as tz;

// GET UNIQUE ID
getUniqueId() {
  var xid = Xid();
  log('generated id: $xid');

  return xid;
}

Future setSuitableStatusBarColor(Color color) async {
  // change the status bar color
  await FlutterStatusbarcolor.setStatusBarColor(color);
  if (color == Colors.black87) {
    log('Status bar FOREGROUNG to: White');
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
  } else if (color == Colors.white) {
    log('Status bar FOREGROUNG to: Black');
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  } else {
    log('Status bar FOREGROUNG to: OTHERWISE');
    if (useWhiteForeground(color)) {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    } else {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    }
  }

  log('Has change status bar color to: $color');
}

// SHOW FULLPAGE LOADER
showFullPageLoader({required BuildContext context, double? radius, Color? color}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: CupertinoActivityIndicator(radius: radius ?? 12.sp, color: color ?? Colors.white),
    ),
  );
}

// VIBRATE
Future triggerVibration({int? duration}) async {
  if (await Vibration.hasVibrator() == true) {
    Vibration.vibrate(duration: duration ?? 100);
  }
}

// SET CURRENT ACTIVE PAGE
setCurrentActivePageFromIndex({required int? index, String? userId}) async {
  String page = '';
  switch (index) {
    case 0:
      page = 'homepage';
      // notificationCancelEngine(notifMatchToCancel: '${FirebaseAuth.instance.currentUser!.uid}:event');
      break;
    case 1:
      page = 'discussionpage';
      // Cancel all Discussion Notifications
      notificationCancelEngine(notifMatchToCancel: '${FirebaseAuth.instance.currentUser!.uid}:discussion');

      break;
    case 2:
      page = 'addpage';
      break;
    case 3:
      page = 'storiespage';
      // Cancel all Stories Notifications
      notificationCancelEngine(notifMatchToCancel: '${FirebaseAuth.instance.currentUser!.uid}:story');

      break;
    case 4:
      page = 'profilepage';
      notificationCancelEngine(notifMatchToCancel: '${FirebaseAuth.instance.currentUser!.uid}:event:$userId');
      break;
    case 5:
      page = 'inboxpage:$userId';
      notificationCancelEngine(notifMatchToCancel: '${FirebaseAuth.instance.currentUser!.uid}:discussion:$userId');
      break;
    case 6:
      page = 'event:$userId';
      notificationCancelEngine(notifMatchToCancel: '${FirebaseAuth.instance.currentUser!.uid}:event:$userId');
      break;
    case 7:
      page = 'reminder:$userId';
      notificationCancelEngine(notifMatchToCancel: '${FirebaseAuth.instance.currentUser!.uid}:reminder:$userId');
      break;
    case null:
      page = '';
      break;
    default:
      page = '';
      break;
  }
  // Set Current Active Page
  UserSimplePreferences.setCurrentActivePageHandler(page);
  log('Current active page: $page');
}

// NOTIFICATION CANCEL ENGINE
void notificationCancelEngine({required String notifMatchToCancel}) {
  List<String> notificationList = UserSimplePreferences.getNotificationList() ?? [];
  log('[CANCEL FROM] \n ########### LOG NOTIFICATIONLIST ###########\n${notificationList.map((s) => '$s \n')}');

  if (notificationList.isNotEmpty) {
    //
    List usernotificationList = notificationList.where((match) => match.startsWith(notifMatchToCancel)).toList();
    //
    if (usernotificationList.isNotEmpty) {
      // Retrieve Id inside usernotificationList
      usernotificationList = usernotificationList.map((notifmatch) => (notifmatch as String).split(':').last).toList();
      log('Usernotification [Ids Only] List: $usernotificationList');

      // Cancel All User Related Notifications for this $type [Notification API]
      for (int id in usernotificationList.map((id) => int.parse(id))) {
        log('Cancelling notification $id [Notification API]');
        NotificationApi.notification.cancel(id);
      }

      // Delete All User Related Notifications for this $type [Shared Preferences]
      log('Deleting notification [Shared Preferences]');
      log('notificationList.length: ${notificationList.length}');
      for (var i = 0; i < notificationList.length; i++) {
        log('Loop $i...');
        String match = notificationList[i];
        if ((usernotificationList.map((id) => int.parse(id))).contains(int.parse(match.split(':').last))) {
          log('match to delete: $match');
          int indexOfMatch = notificationList.indexOf(match);
          log('match index: $indexOfMatch');
          notificationList.removeAt(indexOfMatch);
          log('Remaining: $notificationList');
        }
      }
    }
    UserSimplePreferences.setNotificationList(notificationList);
    log('Remaining notificationList [Shared Preferences]: \n########### LOG NOTIFICATIONLIST ###########\n${UserSimplePreferences.getNotificationList()?.map((s) => '$s \n') ?? []}');
  }
}

// NOTIFICATION ID ENGINE
List notificationIdEngine({
  required String currentUserId,
  required String type,
  required String notifUserId,
  required String contentId,
}) {
  String notifMatch = '$currentUserId:$type:$notifUserId';
  log('notifMatch: ${notifMatch}');

  // UserSimplePreferences.setNotificationList([]);

  // log('currentUserId: ${currentUserId}');
  // log('type: ${type}');
  // log('notifUserId: ${notifUserId}');
  // log('contentId: ${contentId}');
  List<String> notificationList = UserSimplePreferences.getNotificationList() ?? [];
  log('[START WITH] notificationList: ${notificationList}');

  // IF NotificationList is EMPTY
  if (notificationList.isEmpty) {
    log('A: Creating a new notification, because notificationList was empty...');
    return [true, generateNotificationToUse(notifMatch)];
  } else {
    // Cancel User Notification for this $type
    notificationCancelEngine(notifMatchToCancel: notifMatch);

    //  DON'T SHOW THE NOTIFICATION
    if (notificationList.isNotEmpty && notificationList.contains(notifMatch)) {
      return [false, ''];
    }
    // CREATE A NEW ONE
    else {
      log('B: Creating a new notification...');
      return [true, generateNotificationToUse(notifMatch)];
    }

    // switch (type) {
    //   case 'story':

    //   // DON'T SHOW THE NOTIFICATION
    //   // if (matchResult) {
    //   //   return [false, ''];
    //   // }
    //   // // CREATE A NEW ONE
    //   // else {
    //   //   log('B: Creating a new notification...');
    //   //   return [true, generateNotificationToUse(notifMatch)];
    //   // }

    //   default:
    //     return [false, ''];
    // }
  }
}

// GENERATE NOTIFICATION ID TO USE
String generateNotificationToUse(String notifMatch) {
  int idtoUse = 0;
  log('Generate a new notif Id with: $notifMatch');

  List<String> notificationList = UserSimplePreferences.getNotificationList() ?? [];
  log('notificationList : $notificationList');

  if (notificationList.isEmpty) {
    idtoUse = 1;
  }
  //
  else {
    List<int> notificationListWithNotificationIdsOnly =
        notificationList.map((notif) => int.parse(notif.split(':').last)).toList();

    // Sort notificationListWithNotificationIdsOnly
    notificationListWithNotificationIdsOnly.sort((a, b) => a.compareTo(b));

    log('notificationList [ID ONLY]: $notificationListWithNotificationIdsOnly');
    int lastNotificationIdInList = notificationListWithNotificationIdsOnly.last;
    log('lastNotificationIdInList: $lastNotificationIdInList');

    // Checking for missing number
    for (int i = 1; i < lastNotificationIdInList; i++) {
      // log('LOOP: $i');
      if (!notificationListWithNotificationIdsOnly.contains(i)) {
        idtoUse = i;
        log('Id to use (after loop): $i');
      }
    }
    if (idtoUse == 0) {
      idtoUse = lastNotificationIdInList + 1;
    }
  }

  String notifToAdd = '$notifMatch:$idtoUse';

  log('[GEN] Final notifToAdd: $notifToAdd');
  notificationList.add(notifToAdd);
  UserSimplePreferences.setNotificationList(notificationList);
  log('[GEN] Final notificationList: $notificationList');

  return notifToAdd;
}

// Create or Update the Local Notification
Future createOrUpdateReminderLocalNotification({required String action, required String reminderId}) async {
  // NOTIFICATION ID ENGINE | WHEN CREATED, MODIFIED
  NotificationApi.init(initScheduled: true);
  tz.initializeTimeZones();
  // Get reminder
  Reminder? reminder = await FirestoreMethods.getReminderByIdAsFuture(reminderId);

  if (reminder != null) {
    List result = notificationIdEngine(
        currentUserId: FirebaseAuth.instance.currentUser!.uid,
        type: 'reminder',
        notifUserId: reminder.reminderId,
        contentId: reminder.reminderId);
    log('Engine: $result');

    // Get Attached Event
    Event? eventAttached;
    if (reminder.eventId.isNotEmpty) {
      eventAttached = await FirestoreMethods.getEventByIdAsFuture(reminder.eventId);
    }

    if (result[0] == true) {
      // NEW [SCHEDULED] NOTIFICATION
      String payload = 'reminder:${reminder.reminderId}';
      String largeIconPath = await getNotificationLargeIconPath(
        url: '',
        eventAttached: eventAttached,
        type: 'reminder',
        uid: reminder.reminderId,
      );
      String reminderBody = await getReminderNotificationBody(reminder, eventAttached);

      log('Payload from: $payload && largeIconPath: $largeIconPath');

      NotificationApi.showScheduledNotification(
        id: int.parse((result[1] as String).split(':').last),
        title: reminder.title,
        body: reminderBody,
        payload: payload,
        channel: notificationsChannelList[2],
        largeIconPath: largeIconPath,
        tzDateTime: scheduleDaily(
          recalibrateDateTimeToFuture(
            type: 'reminder',
            dateTimeToRecalibrate: tz.TZDateTime(
              tz.local,
              reminder.remindAt.year,
              reminder.remindAt.month,
              reminder.remindAt.day,
              reminder.remindAt.hour,
              reminder.remindAt.minute,
            ),
            reminderToRecalibrate: reminder,
          ),
        ),
        dateTimeComponents:
            reminder.recurrence.isEmpty ? null : getDateTimeComponentsFromRecurrence(reminder.recurrence),
      );
    }
  }
}

// Get Reminder Notification Body
Future<String> getReminderNotificationBody(Reminder reminder, Event? eventAttached) async {
  String defaultMessage = '🔔 Rappel';
  if (eventAttached == null) {
    return defaultMessage;
  } else {
    usermodel.User? userPoster = await FirestoreMethods.getUserByIdAsFuture(eventAttached.uid);
    if (userPoster != null) {
      String eventName = isUserBirthday(eventAttached, userPoster)
          ? userPoster.id == FirebaseAuth.instance.currentUser!.uid
              ? 'Votre anniversaire'
              : 'L\'anniversaire de ${userPoster.name}'
          : eventAttached.title;
      List<String> eventStartTime = getRemainingTimeBeforeEventStartFromDelay(reminder.reminderDelay);
      String prefix = eventStartTime.length == 2 ? eventStartTime[0] : '';
      String suffix = eventStartTime.length == 2 ? eventStartTime[1] : '';

      return '🔔 $prefix$eventName$suffix';
    }

    return defaultMessage;
  }
}

// Get Message Notification Body
String getMessageNotificationBody(messagemodel.Message message) {
  // Switch
  switch (message.type) {
    case "text":
      return message.data;
    case "image":
      return '📷 Image ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "video":
      return '🎬 Video ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "voicenote":
      return '🎤 Note vocale ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "music":
      return '🎵 Audio ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "gift":
      return '🎁 Cadeau ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "payment":
      return '💳 Argent ${message.data.isNotEmpty ? '• ${message.data}' : ''}';

    default:
      return '';
  }
}

// Check whether it's User birthday
bool isUserBirthday(Event? event, usermodel.User? user) {
  if (event != null &&
      user != null &&
      event.uid == user.id &&
      event.type == 'birthday' &&
      DateUtils.dateOnly(user.birthday) ==
          DateUtils.dateOnly((event.eventDurations[0]['date'] as Timestamp).toDate().toLocal())) {
    return true;
  }
  return false;
}

// Get Event Notification Body
Future<String> getEventBodyNotification({
  required List<Map<Event, DocumentChangeType>> userEventsReceived,
  required usermodel.User userPoster,
}) async
//
{
  // Sort User Event Received
  if (userEventsReceived.length > 1) {
    userEventsReceived.sort((a, b) => b.keys.first.createdAt.compareTo(a.keys.first.createdAt));
  }

  // RECALIBRATE NEW EVENT CREATED  : remove ModifiedTag to AddedTag
  if (userEventsReceived.isNotEmpty) {
    for (Map<Event, DocumentChangeType> eventMapToDisplay in userEventsReceived) {
      int diff = eventMapToDisplay.keys.first.modifiedAt.difference(eventMapToDisplay.keys.first.createdAt).inMinutes;
      log('Diff between CreatedAt and ModifiedAt: $diff min');
      if (diff <= 1) {
        eventMapToDisplay.update(eventMapToDisplay.keys.first, (value) => DocumentChangeType.added,
            ifAbsent: () => DocumentChangeType.added);
        log('RECALIBRATE: $eventMapToDisplay');
      }
      //
      log('Checking ${eventMapToDisplay.values.first.name}: ${eventMapToDisplay.keys.first.title}');
    }
  }

  // Get first event to display
  Event firstEvent = userEventsReceived.first.keys.first;

  //
  String message = '';
  String eventsChangedMessage = '';

  // MODIFIED CASE OR REMOVED CASE
  for (Map<Event, DocumentChangeType> eventMapToDisplay in userEventsReceived) {
    log('All about event ${eventMapToDisplay.values.first.name}: ${eventMapToDisplay.keys.first.title}');

    if (eventMapToDisplay.values.first == DocumentChangeType.modified ||
        eventMapToDisplay.values.first == DocumentChangeType.removed) {
      if (message.isNotEmpty) {
        eventsChangedMessage = '\n${eventsChangedMessage}';
      }
      if (eventsChangedMessage.isNotEmpty) {
        eventsChangedMessage = '${eventsChangedMessage}\n';
      }
      //
      DocumentChangeType currentChangedType = eventMapToDisplay.values.first;
      Event currentEventChanged = eventMapToDisplay.keys.first;
      bool hasRemindersAttachedToThisCurrentEventChanged = false;

      // Get All [My] Reminders attached to the current Event
      List<Reminder> listOfMyRemindersAttached = await FirestoreMethods.getEventRemindersById(
              currentEventChanged.eventId, FirebaseAuth.instance.currentUser!.uid)
          .first;
      log('### listOfMyRemindersAttached: ${listOfMyRemindersAttached.map((r) => r.title)}');

      if (listOfMyRemindersAttached.isEmpty) {
        hasRemindersAttachedToThisCurrentEventChanged = false;
      }
      // MODIFY OR DELETE ALL REMINDERS ATTACHED
      else {
        hasRemindersAttachedToThisCurrentEventChanged = true;

        // MODIFY ALL
        if (currentChangedType == DocumentChangeType.modified) {
          for (Reminder reminder in listOfMyRemindersAttached) {
            // Modeling a reminder
            Map<String, dynamic> reminderToUpdate = Reminder(
              title: reminder.title,
              uid: FirebaseAuth.instance.currentUser!.uid,
              reminderId: reminder.reminderId,
              reminderDelay: reminder.reminderDelay,
              eventId: reminder.eventId,
              remindAt: getCompleteDateTimeFromFirstEventDuration(currentEventChanged)
                  .subtract(getDurationFromDelay(reminder.reminderDelay)),
              recurrence: isEventWithRecurrence(currentEventChanged) ? reminder.recurrence : 'Aucune récurrence',
              remindFrom: getCompleteDateTimeFromFirstEventDuration(currentEventChanged),
              createdAt: reminder.createdAt,
              modifiedAt: DateTime.now(),
              status: '',
            ).toJson();
            FirestoreMethods.updateReminder(null, reminder.reminderId, reminderToUpdate);
          }
        }

        // DELETE ALL
        else if (currentChangedType == DocumentChangeType.removed) {
          for (Reminder reminder in listOfMyRemindersAttached) {
            // Delete reminder...
            FirestoreMethods.deleteReminder(null, reminder.reminderId, FirebaseAuth.instance.currentUser!.uid);
          }
        }
      }

      String verbToUse = currentChangedType == DocumentChangeType.modified ? 'modifié' : 'supprimé';
      String messageOfcurrentEventModifiedOrDelete =
          '📌 ${userPoster.name} a $verbToUse ${isUserBirthday(currentEventChanged, userPoster) ? 'son anniversaire' : 'l\'évènement ${currentEventChanged.title}'}${hasRemindersAttachedToThisCurrentEventChanged ? '. Vos rappels ont aussi été $verbToUse' : ''}';

      eventsChangedMessage = '${eventsChangedMessage}${messageOfcurrentEventModifiedOrDelete}';
    }
  }

  // CREATED CASE
  if (userEventsReceived.any((element) => element.values.first == DocumentChangeType.added)) {
    String eventName =
        isUserBirthday(firstEvent, userPoster) ? 'fête son anniversaire' : 'organise ${firstEvent.title}';
    //
    String eventDate = !isOutdatedEvent(firstEvent) && !isHappeningEvent(firstEvent)
        ? getEventRelativeStartTime(firstEvent)
        : 'le ${DateFormat(isEventWithRecurrence(firstEvent) ? 'dd MMMM' : 'EEE, d MMM yyyy', 'fr_Fr').format((firstEvent.eventDurations[0]['date'] as Timestamp).toDate().toLocal())}';
    //
    message = userEventsReceived.length == 1
        ? '${isUserBirthday(firstEvent, userPoster) ? '🎉🎈 ' : '📅'} ${userPoster.name} $eventName, $eventDate'
        : '📅 ${userPoster.name} organise ${userEventsReceived.where((element) => !isUserBirthday(element.keys.first, userPoster) && !isOutdatedEvent(element.keys.first)).toList().length} ${userEventsReceived.where((element) => !isUserBirthday(element.keys.first, userPoster) && !isOutdatedEvent(element.keys.first)).toList().length > 1 ? 'évènements qui peuvent' : 'évènement qui peut'} vous intéresser';
  }

  // COMBINE ALL MESSAGES AND RETURN
  return '${message}${eventsChangedMessage}';
}

// void fillCircle_bresenham_wo_alpha(img.Image image, int x0, int y0, int radius, int color) {
//   int radiusSquared = radius * radius;
//   for (int y = -radius; y <= radius; y++) {
//     int ySquared = y * y;
//     for (int x = -radius; x <= radius; x++) {
//       int xSquared = x * x;
//       if (xSquared + ySquared <= radiusSquared) {
//         image.setPixel(x0 + x, y0 + y, color);
//       }
//     }
//   }
// }

// Get Message Notification largeIconPath
Future<String> getNotificationLargeIconPath({
  required String url,
  Event? eventAttached,
  required String type,
  required String uid,
}) async
//
{
  Uint8List? bytes;
  if (type == 'reminder') {
    File bellPicture = await getImageFileFromAssets(bell);
    return bellPicture.path;
  }

  // FOR CELEBRATIONS ONLY
  if (type == 'celebration') {
    File ballonsPicture = await getImageFileFromAssets(ballons);

    return ballonsPicture.path;
  }

  // Check file existence
  File mainImageFile = File('');

  if (url.isNotEmpty) {
    mainImageFile = await DefaultCacheManager().getSingleFile(url);
    log('mainImageFile: $mainImageFile');
  }

  // FOR STORIES ONLY
  if (type == 'story') {
    try {
      // // Draw Colored Circle
      // img.Image circle = img.Image(101, 101);
      // fillCircle_bresenham_wo_alpha(circle, 50, 50, 50, img.getColor(224, 47, 102));
      // img.copyResize(circle, width: 100, height: 100);
      // log('circle: $circle');

      // // Draw 2nd Circle : Padding
      // img.Image circlePadding = img.Image(101, 101);
      // fillCircle_bresenham_wo_alpha(circlePadding, 50, 50, 50, img.getColor(255, 255, 255));
      // img.copyResize(circlePadding, width: 90, height: 90);
      // log('circlePadding: $circlePadding');
      // img.drawImage(circlePadding, circle, dstX: circle.width, blend: false);
      // log('mergedImage: $circle');

      final image = img.copyCropCircle(img.decodeImage(mainImageFile.readAsBytesSync())!);
      mainImageFile.writeAsBytesSync(img.encodePng(image));
      return mainImageFile.path;
    } catch (e) {
      //
      log('Err: $e');
    }
  }
  // FOR MESSAGE ONLY
  else if (type == 'discussion') {
    try {
      final image = img.copyCropCircle(img.decodeImage(mainImageFile.readAsBytesSync())!);
      mainImageFile.writeAsBytesSync(img.encodePng(image));
      return mainImageFile.path;
    } catch (e) {
      //
      log('Err: $e');
    }
  }

  // FOR EVENTS ONLY
  else if (type == 'event' && eventAttached != null) {
    try {
      if (eventAttached.trailing.isEmpty) {
        File eventDefaultIcon = await getImageFileFromAssets('assets/images/eventtype.icons/${eventAttached.type}.png');
        return eventDefaultIcon.path;
      } else {
        final eventPicture = img.copyCropCircle(img.decodeImage(mainImageFile.readAsBytesSync())!);
        mainImageFile.writeAsBytesSync(img.encodePng(eventPicture));
        return mainImageFile.path;
      }
    } catch (e) {
      //
      log('Err: $e');
    }
  }

  try {
    log('Build Circle avatar to display...');

    // bytes = null;

    if (bytes != null) {
      // File fileGet = await File(path).writeAsBytes(bytes);
      // return fileGet.path;
      return '';
    } else {
      log('Error while building avatar: with bytes');
      return mainImageFile.path;
    }
  }
  //
  catch (e) {
    log('Error while building avatar: $e');
    return mainImageFile.path;
  }
}

// COMPRESS/RESIZE IMAGE FILE
Future resizeImageFile({required String filePath, int? imageWidth}) async {
  log('COMPRESSING FILE [BECAUSE IT\'S TOO HEAVY]...');

  ImageProperties properties = await FlutterNativeImage.getImageProperties(filePath);
  int targetWidth = imageWidth ?? 600;

  File compressedImageFile = await FlutterNativeImage.compressImage(filePath,
      quality: 80,
      percentage: 60,
      targetWidth: targetWidth,
      targetHeight: (properties.height! * targetWidth / properties.width!).round());
  log('File resized is: ${compressedImageFile.path}');
  return compressedImageFile;
}

tz.TZDateTime scheduleDaily(tz.TZDateTime dateTime) {
  final now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute, dateTime.second);

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

tz.TZDateTime scheduleWeekly(tz.TZDateTime dateTime, {required List<int> days}) {
  tz.TZDateTime scheduledDate = scheduleDaily(dateTime);

  while (!days.contains(scheduledDate.weekday)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

// RECALIBRATE DATETIME TO THE FUTURE
tz.TZDateTime recalibrateDateTimeToFuture(
    {required String type, required tz.TZDateTime dateTimeToRecalibrate, Reminder? reminderToRecalibrate}) {
  final now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = dateTimeToRecalibrate;

  if (type == 'celebration') {
    log('>> Recalibrate datetime as CELEBRATION');
    while (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year + 1, scheduledDate.month, scheduledDate.day,
          scheduledDate.hour, scheduledDate.minute, scheduledDate.second);
    }
  } else if (type == 'reminder' && reminderToRecalibrate != null) {
    log('>> Recalibrate datetime as REMINDER');

    switch (reminderToRecalibrate.recurrence) {
      case 'Aucune récurrence':
        break;

      case 'Chaque jour':
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        break;
      case 'Chaque semaine':
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }

        break;
      case 'Chaque mois':
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 31));
        }

        break;

      case 'Chaque année':
        while (scheduledDate.isBefore(now)) {
          scheduledDate = tz.TZDateTime(tz.local, scheduledDate.year + 1, scheduledDate.month, scheduledDate.day,
              scheduledDate.hour, scheduledDate.minute, scheduledDate.second);
        }

        break;
      default:
        break;
    }
  }
  log('Recalibrate DateTime to Future:${DateFormat('EEE, d MMM yyyy HH:mm', 'fr_Fr').format(dateTimeToRecalibrate)} --> ${DateFormat('EEE, d MMM yyyy HH:mm', 'fr_Fr').format(scheduledDate)} | $type\n--> ${reminderToRecalibrate?.recurrence ?? ''}');
  return scheduledDate;
}

//
DateTime getDatetimeToUseFromDatetimeWithRecurrence(EventDurationType eventDuration) {
  return DateTime(
    DateTime.now().year,
    eventDuration.date.month,
    eventDuration.date.day,
    eventDuration.startTime.hour,
    eventDuration.startTime.minute,
  );
}

// DAYS BETWEEN TWO DATES
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

// RANDOM NUMBER BETWEEN
int getRandomNumberBetween(int min, int max) {
  int randomNumber = min + math.Random().nextInt(max - min);
  log('## Settled $randomNumber as random number');
  return randomNumber;
}

// GET DURATION FROM DELAY
DateTimeComponents? getDateTimeComponentsFromRecurrence(String recurrence) {
  switch (recurrence) {
    case 'Aucune récurrence':
      return null;

    case 'Chaque jour':
      return DateTimeComponents.time;

    case 'Chaque semaine':
      return DateTimeComponents.dayOfWeekAndTime;

    case 'Chaque mois':
      return DateTimeComponents.dayOfMonthAndTime;

    case 'Chaque année':
      return DateTimeComponents.dateAndTime;

    default:
      return null;
  }
}

// GET DURATION FROM DELAY
Duration getDurationFromDelay(String delay) {
  switch (delay) {
    case 'dès qu\'il commence':
      return const Duration();

    case '10min avant':
      return const Duration(minutes: 10);

    case '1h avant':
      return const Duration(hours: 1);

    case '1 jour avant':
      return const Duration(days: 1);

    case '3 jours avant':
      return const Duration(days: 3);

    case '1 semaine avant':
      return const Duration(days: 7);

    case '1 mois avant':
      return const Duration(days: 30);

    default:
      return const Duration();
  }
}

// GET REMAINING TIME BEFORE EVENT START
List<String> getRemainingTimeBeforeEventStartFromDelay(String delay) {
  switch (delay) {
    case 'dès qu\'il commence':
      return ['', ' a commencé 🔥'];

    case '10min avant':
      return ['Dans 10 minutes c\'est ', ''];

    case '1h avant':
      return ['Dans 1 heure c\'est ', ''];

    case '1 jour avant':
      return ['Dans 1 jour c\'est ', ''];

    case '3 jours avant':
      return ['Dans 3 jours c\'est ', ''];

    case '1 semaine avant':
      return ['Dans 1 semaine c\'est ', ''];

    case '1 mois avant':
      return ['Dans 1 mois c\'est ', ''];

    default:
      return ['', ''];
  }
}

// COMPLETE DATETIME FROM FIRST EVENT DURATION
DateTime getCompleteDateTimeFromFirstEventDuration(Event? eventController) {
  EventDurationType eventDurationGet = EventDurationType.fromJson(eventController!.eventDurations[0]);

  return DateTime(
    isEventWithRecurrence(eventController) ? DateTime.now().year : eventDurationGet.date.year,
    eventDurationGet.date.month,
    eventDurationGet.date.day,
    eventDurationGet.startTime.hour,
    eventDurationGet.startTime.minute,
  );
}

// Debouncer
class Debouncer {
  final int milliseconds;

  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

// Get event relative start time
String getEventRelativeStartTime(Event event) {
  if (event.eventDurations.isNotEmpty) {
    // Build DateTime for first EventDuration : add The current year as the lastEventDuration's year [For Event with reccurence]
    EventDurationType firstEventDuration = EventDurationType.fromJson(event.eventDurations[0]);

    DateTime firstEventDurationDateTime = DateTime(
      eventAvailableTypeList.where((e) => e.key == event.type).first.recurrence == true
          ? DateTime.now().year
          : firstEventDuration.date.year,
      firstEventDuration.date.month,
      firstEventDuration.date.day,
      firstEventDuration.startTime.hour,
      firstEventDuration.startTime.minute,
    );

    //
    if (isOutdatedEvent(event)) {
      return 'Déjà passé !';
    }
    //
    else if (isHappeningEvent(event)) {
      return 'a déjà commencé !';
    }
    //
    else {
      //
      num diffInDays = daysBetween(DateTime.now(), firstEventDurationDateTime);
      if (diffInDays == 0) {
        int diffInHours = firstEventDurationDateTime.difference(DateTime.now()).inHours;
        //

        if (diffInHours > 0 && diffInHours <= 23) {
          return 'dans ${diffInHours.toString()} heure${diffInHours > 1 ? 's' : ''}';
        }
        // Less than 1 hour
        else {
          int diffInMinutes = firstEventDurationDateTime.difference(DateTime.now()).inMinutes;
          //
          if (diffInMinutes > 0 && diffInMinutes < 60) {
            return 'dans ${diffInMinutes.toString()} minute${diffInMinutes > 1 ? 's' : ''}';
          }
          return 'bientôt !';
        }
      }
      return 'dans ${diffInDays.toString()} jour${diffInDays > 1 ? 's' : ''}';
    }
  }
  return '';
}

// Check whether event is outdated or not
bool isOutdatedEvent(Event event) {
  if (event.eventDurations.isNotEmpty) {
    EventDurationType lastEventDuration =
        EventDurationType.fromJson(event.eventDurations[event.eventDurations.length - 1]);

    // Build DateTime for lastEventDuration : add The current year as the lastEventDuration's year [For Event with reccurence]
    DateTime lastEventDurationDateTime = DateTime(
      eventAvailableTypeList.where((e) => e.key == event.type).first.recurrence == true
          ? DateTime.now().year
          : lastEventDuration.date.year,
      lastEventDuration.date.month,
      lastEventDuration.date.day,
      lastEventDuration.endTime.hour,
      lastEventDuration.endTime.minute,
    );

    //
    if (lastEventDurationDateTime.isBefore(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }
  return false;
}

// Check whether event is outdated or not
bool isHappeningEvent(Event event) {
  if (event.eventDurations.isNotEmpty) {
    // Build DateTime for first EventDuration : add The current year as the lastEventDuration's year [For Event with reccurence]
    EventDurationType firstEventDuration = EventDurationType.fromJson(event.eventDurations[0]);

    DateTime firstEventDurationDateTime = DateTime(
      eventAvailableTypeList.where((e) => e.key == event.type).first.recurrence == true
          ? DateTime.now().year
          : firstEventDuration.date.year,
      firstEventDuration.date.month,
      firstEventDuration.date.day,
      firstEventDuration.startTime.hour,
      firstEventDuration.startTime.minute,
    );

    // Build DateTime for lastEventDuration : add The current year as the lastEventDuration's year [For Event with reccurence]
    EventDurationType lastEventDuration =
        EventDurationType.fromJson(event.eventDurations[event.eventDurations.length - 1]);

    DateTime lastEventDurationDateTime = DateTime(
      eventAvailableTypeList.where((e) => e.key == event.type).first.recurrence == true
          ? DateTime.now().year
          : lastEventDuration.date.year,
      lastEventDuration.date.month,
      lastEventDuration.date.day,
      lastEventDuration.startTime.hour,
      lastEventDuration.startTime.minute,
    );

    //
    if (firstEventDurationDateTime.isBefore(DateTime.now()) ||
        firstEventDurationDateTime.isAtSameMomentAs(DateTime.now()) &&
            lastEventDurationDateTime.isAfter(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }
  return false;
}

bool isEventWithRecurrence(Event? event) {
  if (event == null) return false;
  return eventAvailableTypeList.where((e) => e.key == event.type).first.recurrence;
}

// Have I seen all stories
bool hasSeenAllStories(List<Story> storiesList) {
  List<bool> results = [];
  // Sort messages : by the latest
  for (Story story in storiesList) {
    if (story.viewers.contains(FirebaseAuth.instance.currentUser!.uid)) {
      results.add(true);
    } else {
      results.add(false);
    }
  }
  //
  if (results.contains(false)) {
    return false;
  } else {
    return true;
  }
}

// Check whether story has expired or not
bool hasStoryExpired(DateTime endAt) {
  if (endAt.isBefore(DateTime.now())) {
    return true;
  }
  return false;
}

// Get Timeago : Long form
String getTimeAgoLongForm(DateTime dateTime) {
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  return timeago.format(dateTime, locale: 'fr');
}

// Get Timeago : Short form
String getTimeAgoShortForm(DateTime dateTime) {
  timeago.setLocaleMessages('fr', FrMessagesShortsform());
  return timeago.format(dateTime, locale: 'fr');
}

// Get Last Story of StoriesList
Story getLastStoryOfStoriesList(List<Story> storiesList) {
  // Sort messages : by the latest
  storiesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return storiesList.first;
}

//
bool isAudio(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType?.startsWith('audio/') ?? false;
}

// Get Last Message of Discussion
messagemodel.Message? getLastMessageOfDiscussion(List<messagemodel.Message> discussionMessages) {
  messagemodel.Message? messageToDisplay;
  List<messagemodel.Message> messagesList = [];

  // Sort messages : by the latest
  discussionMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Remove: DeleteForMe messages
  for (messagemodel.Message message in discussionMessages) {
    if (!message.deleteFor.contains(FirebaseAuth.instance.currentUser!.uid)) {
      messagesList.add(message);
    }
  }

  for (int i = 0; i < messagesList.length; i++) {
    if (messagesList[i].status != 0) {
      messageToDisplay = messagesList[i];
      return messageToDisplay;
    } else if (messagesList[i].status == 0 && messagesList[i].senderId == FirebaseAuth.instance.currentUser!.uid) {
      messageToDisplay = messagesList[i];
      return messageToDisplay;
    }
  }
  return null;
}

// Get Directories
Future<List> getDirectories() async {
  List dirList = await ExternalPath.getExternalStorageDirectories();
  Directory appDirectory = await getApplicationDocumentsDirectory();
  // 0: [/storage/emulated/0]
  // 1: [/storage/15FD-3004]
  // 2: [/data/user/0/packageName/app_flutter]

  return [dirList[0], '', appDirectory.path];
}

// Get Message Type Icon
Widget getMsgTypeIcon(int? messageStatus, String lastMessageType) {
  if (messageStatus != null && messageStatus == 0) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Icon(FontAwesomeIcons.clock, color: Colors.grey, size: 13.sp),
    );
  } else {
    // if MessageType.text
    // if (lastMessageType == MessageType.text) {
    //   return Padding(
    //     padding: const EdgeInsets.only(right: 5),
    //     child: CircleAvatar(
    //       radius: 11,
    //       backgroundColor: Colors.lightBlue.shade200,
    //       child: Icon(FontAwesomeIcons.comment, color: Colors.white, size: 13),
    //     ),
    //   );
    // }

    // if MessageType.image
    if (lastMessageType == 'image') {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Icon(FontAwesomeIcons.image, color: Colors.grey, size: 15.sp),
      );
    }

    // if MessageType.video
    else if (lastMessageType == 'video') {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Icon(FontAwesomeIcons.play, color: Colors.red, size: 15.sp),
      );
    }

    // if MessageType.music
    else if (lastMessageType == 'music') {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Icon(FontAwesomeIcons.itunesNote, color: Colors.purple.shade300, size: 15.sp),
      );
    }

    // if MessageType.voicenote
    else if (lastMessageType == 'voicenote') {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Icon(FontAwesomeIcons.microphone, color: Colors.black87, size: 15.sp),
      );
    }

    // if MessageType.gift
    else if (lastMessageType == 'gift') {
      return const Padding(
        padding: EdgeInsets.only(right: 7),
        child: CircleAvatar(
          radius: 11,
          backgroundColor: Colors.orangeAccent,
          child: Icon(FontAwesomeIcons.gift, color: Colors.white, size: 13),
        ),
      );
    }

    // if MessageType.payment
    else if (lastMessageType == 'payment') {
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Icon(FontAwesomeIcons.dollarSign, color: Colors.green.shade300, size: 13),
      );
    }

    // Default
    return Container();
  }
}

// Get Message Status : seen, read, sent, pending
Widget getMessageStatusIcon(messagemodel.Message message) {
  if (message.seen.contains(message.receiverId)) {
    return Icon(
      FontAwesomeIcons.checkDouble,
      color: kSecondColor,
      size: 12.sp,
    );
  } else if (message.read.contains(message.receiverId)) {
    return Icon(
      FontAwesomeIcons.checkDouble,
      color: Colors.black54,
      size: 12.sp,
    );
  } else if (message.status == 0) {
    return Icon(
      FontAwesomeIcons.clock,
      color: Colors.black54,
      size: 12.sp,
    );
  }
  return Icon(
    FontAwesomeIcons.check,
    color: Colors.black54,
    size: 11.sp,
  );
}

// Get PaymentMethod Device
String getPaymentMethodDevise(String paymentMethod) {
  // Switch
  switch (paymentMethod) {
    case mtnMobileMoneyLabel:
      return 'XAF';

    case airtelMoneyLabel:
      return 'XAF';

    default:
      return '';
  }
}

// Get PaymentMethod Device
String getPaymentMethodLogo(String paymentMethod) {
  // Switch
  switch (paymentMethod) {
    case mtnMobileMoneyLabel:
      return mtnMobileMoneyLogo;

    case airtelMoneyLabel:
      return airtelMoneyLogo;

    default:
      return '';
  }
}

// Get Default Caption by messageType
String getDefaultMessageCaptionByType(messageType) {
  // Switch
  switch (messageType) {
    case "image":
      return 'Image';

    case "video":
      return 'Video';

    case "voicenote":
      return 'Note vocale';

    case "music":
      return 'Audio';

    case "gift":
      return 'Cadeau';

    case "payment":
      return 'Argent';

    default:
      return '';
  }
}

// Get Specific Directories by type
String getSpecificDirByType(messageType) {
  // Switch
  switch (messageType) {
    case "image":
      return '$appName Images';

    case "video":
      return '$appName Videos';

    case "voicenote":
      return '$appName Notes Vocales';

    case "music":
      return '$appName Audio';

    case "story":
      return '$appName Stories';

    case "thumbnail":
      return '$appName thumbnails';
    default:
      return '';
  }
}

Future deleteMessageAssociatedFiles(messagemodel.Message message) async {
  List directories = await getDirectories();

  File correspondingFile = File('${directories[0]}/$appName/${getSpecificDirByType(message.type)}/${message.filename}');
  if (correspondingFile.existsSync()) {
    await correspondingFile.delete();
    log('File deleted at ${correspondingFile.path}');
  }
}

// Show DecisionModal
Future<List> showModalDecision({
  context,
  header,
  content,
  firstButton,
  secondButton,
  barrierDismissible,
  String? checkBoxCaption,
  bool? checkBoxValue,
}) async
//
{
  bool? result = await showDialog(
    barrierDismissible: barrierDismissible ?? true,
    context: context,
    builder: ((context) {
      return StatefulBuilder(builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // HEADER
                Text(
                  header,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
                ),
                const SizedBox(height: 20),

                // CONTENT
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp),
                ),
                const SizedBox(height: 20),

                // CHECK BOX : if possible
                checkBoxCaption != null
                    ? CheckboxListTile(
                        value: checkBoxValue,
                        onChanged: (bool? value) {
                          setState(() {
                            checkBoxValue = !checkBoxValue!;
                          });
                        },
                        title: Text(
                          checkBoxCaption,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                        ),
                      )
                    : Container(),

                checkBoxCaption != null ? const SizedBox(height: 7) : Container(),

                // ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //
                    TextButton(
                      onPressed: () {
                        // Stay on the page
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        firstButton,
                        style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Pop the screen
                    TextButton(
                      onPressed: () {
                        //
                        Navigator.pop(context, true);
                      },
                      child: Text(secondButton),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
    }),
  );

  if (result == true) {
    return [true, checkBoxValue ?? false];
  }

  return [false, checkBoxValue ?? false];
}

// DATE PICKER
Future<DateTime?> pickDate(
    {required BuildContext context, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
  final newDate = await showDatePicker(
    cancelText: 'ANNULER',
    helpText: 'Selectionner une date',
    fieldLabelText: 'Entrer une date',
    errorInvalidText: 'Date invalide, veuillez réessayer !',
    errorFormatText: 'Date invalide, veuillez réessayer !',
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime.now(),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    lastDate: lastDate ?? DateTime(3000),
  );
  return newDate;
}

// CREATE STRING CASE VARIATIONS
// List<String> getStringCaseVariation(String text) {
//   return [
//     text,
//     text.toLowerCase(),
//     text.toUpperCase(),
//     text.camelCase,
//     text.pascalCase,
//     text.sentenceCase,
//     text.titleCase,
//   ];
// }

String removeDiacritics(String str) {
  var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

// COMPARE TWO DATES
bool isEndTimeSuperiorThanStartTime(TimeOfDay startTime, TimeOfDay endTime) {
  if (endTime.hour > startTime.hour) {
    return true;
  } else if (endTime.hour == startTime.hour) {
    if (endTime.minute > startTime.minute) {
      return true;
    } else {
      return false;
    }
  }
  return false;
}

// ADD 's depending on number
String getSatTheEnd(int number, String radical) {
  if (number > 1) {
    return '${radical}s';
  }
  return radical;
}

// FORMAT TIMEOFDAY
DateTime formatTimeOfDay(TimeOfDay tod) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
}

// TIME PICKER
//
//
//
//
//

// GET THUMBNAIL EXTENSION : from a filename

String transformExtensionToThumbnailExt(String filename) {
  String withoutExt = filename.split('.').first;
  return '$withoutExt.png';
}

double getMessagePreviewCardHeight(messageType) {
  // Switch
  switch (messageType) {
    case "image":
      return 0.45.sh;
    case "video":
      return 0.3.sh;
    case "voicenote":
      return 0.08.sh;
    case "music":
      return 0.08.sh;
    default:
      return 0;
  }
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load(path);

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.create(recursive: true);
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

// Send Message
Future sendMessage({
  required BuildContext context,
  required String userReceiverId,
  required String messageType,
  required String discussionId,
  required String eventId,
  required String storyId,
  required String messageTextValue,
  required String messageCaptionText,
  required String voiceNotePath,
  required String imagePath,
  required String videoPath,
  required String musicPath,
  required bool isPaymentMessage,
  required int amount,
  required String paymentMethod,
  required String transactionId,
  required String receiverPhoneNumber,
  required String messageToReplyId,
  required String messageToReplyType,
  required String messageToReplyData,
  required String messageToReplyFilename,
  required String messageToReplyThumbnail,
  required String messageToReplyCaption,
  required String messageToReplySenderId,
}) async
//
{
  List directories = await getDirectories();
  bool result = false;
  String data = '';
  int status = 0;
  String thumbnail = '';
  String filename = '';
  // String discussionId = 'AcuUnKLwEIxG7xdINKMJ';
  String userSenderId = FirebaseAuth.instance.currentUser!.uid;
  // String userReceiverId = 'NxghAin2gKaAHYCatY2c2Vty17n1';

  File voicenoteMoved = File('');
  File imageMoved = File('');
  File thumbnailFileMoved = File('');
  File videoMoved = File('');
  File musicMoved = File('');

  // Process with Text, Payment
  if (messageType == 'text' || messageType == 'payment') {
    data = messageTextValue;
    status = 1;
  }

  // Process with Message File: voicenote, image, video, music

  // Check WRITE_EXTERNAL_STORAGE permission
  if (await Permission.storage.request().isGranted) {
    //
    //
    if (messageType == 'voicenote') {
      // Voicenote filename
      final voiceNoteFilename = '${appName}_voicenote_msg_${getUniqueId()}.aac';
      filename = voiceNoteFilename;

      voicenoteMoved = await copyFile(
          File(voiceNotePath), '${directories[0]}/$appName/${getSpecificDirByType(messageType)}/$voiceNoteFilename');
      log('Voicenote file : $voicenoteMoved');
    }
    //
    else if (messageType == 'music') {
      // Music filename
      final musicFilename = '${appName}_music_msg_${getUniqueId()}.mp3';
      filename = musicFilename;

      musicMoved = await copyFile(
          File(musicPath), '${directories[0]}/$appName/${getSpecificDirByType(messageType)}/$musicFilename');
      log('Music file : $musicMoved');
    }
    //
    else if (messageType == 'image') {
      // Image filename
      final imageFilename = '${appName}_image_msg_${getUniqueId()}.png';
      filename = imageFilename;

      imageMoved = await copyFile(
          File(imagePath), '${directories[0]}/$appName/${getSpecificDirByType(messageType)}/$imageFilename');
      log('Image file : $imageMoved');

      // Create image thumbnail
      ImageProperties properties = await FlutterNativeImage.getImageProperties(imageMoved.path);
      File compressedImageFile = await FlutterNativeImage.compressImage(imageMoved.path,
          quality: 80, targetWidth: 100, targetHeight: (properties.height! * 100 / properties.width!).round());

      // Move thumbnail
      thumbnailFileMoved = await copyFile(compressedImageFile,
          '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(imageFilename)}');
      log('Thumbnail file moved : $thumbnailFileMoved');
    }
    //
    else if (messageType == 'video') {
      // Video filename
      final videoFilename = '${appName}_video_msg_${getUniqueId()}.mp4';
      filename = videoFilename;

      videoMoved = await copyFile(
          File(videoPath), '${directories[0]}/$appName/${getSpecificDirByType(messageType)}/$videoFilename');
      log('Video file : $videoMoved');

      // Create Video thumbnail
      String vidhumbnailPath = await getVideoThumbnail(videoMoved.path) ?? '';

      // Move thumbnail
      thumbnailFileMoved = await copyFile(File(vidhumbnailPath),
          '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(videoFilename)}');
      log('Thumbnail file moved : $thumbnailFileMoved');
    }

    if (messageType != 'text' && messageType != 'voicenote' && messageType != 'music' && messageType != 'payment') {
      // init info
      data = '';
      status = 0;
      thumbnail = '';
      //
    }
  } else {
    log('Permission isn\'t  granted !');

    // ignore: use_build_context_synchronously
    Navigator.pop(
      context,
    );
    // ignore: use_build_context_synchronously
    showSnackbar(context, 'Nous avons besoin d\'une permission pour continuer !', null);
    return;
  }

  //
  // MODELING A NEW MESSAGE
  //

  Map<String, Object> newMessage = messagemodel.Message(
    messageId: '',
    type: messageType,
    createdAt: DateTime.now(),
    discussionId: discussionId,
    data: data,
    thumbnail: thumbnail,
    filename: filename,
    caption: messageCaptionText,
    eventId: eventId,
    storyId: storyId,
    receiverId: userReceiverId,
    senderId: userSenderId,
    status: status,
    deleteFor: [],
    read: [],
    seen: [],
    paymentId: '',
    messageToReplyId: messageToReplyId,
    messageToReplyType: messageToReplyType,
    messageToReplyData: messageToReplyData,
    messageToReplyFilename: messageToReplyFilename,
    messageToReplyThumbnail: messageToReplyThumbnail,
    messageToReplyCaption: messageToReplyCaption,
    messageToReplySenderId: messageToReplySenderId,
  ).toJson();

  log('Message is: $newMessage');

  //
  // CREATE MESSAGE IN FIRESTORE
  //
  // ignore: use_build_context_synchronously
  List messageResult = await FirestoreMethods.createMessage(
    context: context,
    userSenderId: userSenderId,
    userReceiverId: userReceiverId,
    message: newMessage,
    isPaymentMessage: isPaymentMessage,
    amount: amount,
    receiverPhoneNumber: receiverPhoneNumber,
    paymentMethod: paymentMethod,
    transactionId: transactionId,
  );
  result = messageResult[0];

  if (result) {
    log('Message created !');
    return true;
  }
  // else {
  //   // ignore: use_build_context_synchronously
  //   showSnackbar(context, 'Une erreur s\'est produite !', null);
  //   log('Error while creating a message !');
  //   return false;
  // }
}

// Launch URL (External Browser)
Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}

// Get Video Thumbnail
Future<String?> getVideoThumbnail(data) async {
  final result = await VideoThumbnail.thumbnailFile(
    video: data,
    imageFormat: ImageFormat.PNG,
    maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    quality: 25,
  );

  // log("Vid Thumbnail is: $uint8list");
  return result;
}

// Download File
Future<String> downloadFile({required String url, required String fileName, required String type}) async {
  List directories = await getDirectories();
  String filePath =
      '${directories[0]}/$appName/${getSpecificDirByType(type)}/${transformExtensionToThumbnailExt(fileName)}';
  final response = await http.get(Uri.parse(url));
  final file = File(filePath);

  await file.writeAsBytes(response.bodyBytes);

  return file.path;
}

// Copy file
Future<File> copyFile(File sourceFile, String newPath) async {
  try {
    return await sourceFile.copy(newPath);
  } on FileSystemException catch (e) {
    log('Error while copying file: $e');
    throw Exception('An error occured while copying file');
  }
}

// Move file
Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (e) {
    log('Error: $e');
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}

// Get MessageToReply GridPreview by Type
Widget getMessageToReplyGridPreview({
  required String messageToReplyId,
  required String messageToReplyType,
  required String messageToReplyData,
  required String messageToReplyFilename,
  required String messageToReplyThumbnail,
  required String messageToReplyCaption,
  required String messageToReplySenderId,
  bool? hasDivider,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trailing
          messageToReplyType == 'image' || messageToReplyType == 'video'
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(1, 1, 0, 1),
                  child: FutureBuilder(
                    future: getDirectories(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      // Display DATA
                      if (snapshot.hasData) {
                        var directories = snapshot.data;
                        File thumbnailFile = File(
                            '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(messageToReplyFilename)}');

                        return FittedBox(
                          child: Container(
                            height: 45,
                            width: 45,
                            margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black87.withOpacity(0.3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Thumbnail
                                  ProgressiveImage(
                                    height: 45,
                                    width: 45,
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage(darkBackground),
                                    //
                                    thumbnail: thumbnailFile.existsSync()
                                        ? FileImage(thumbnailFile)
                                        : NetworkImage(messageToReplyThumbnail) as ImageProvider,
                                    //
                                    image: thumbnailFile.existsSync()
                                        ? FileImage(thumbnailFile)
                                        : NetworkImage(messageToReplyThumbnail) as ImageProvider,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Display Loader
                      return Container(
                        height: 45,
                        width: 45,
                        margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black87.withOpacity(0.3),
                          image: const DecorationImage(
                            image: AssetImage(darkBackground),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(),

          // Message content
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MESSAGE SENDER USERNAME
              Padding(
                padding: messageToReplyType == 'video' || messageToReplyType == 'image'
                    ? const EdgeInsets.only(bottom: 10, top: 10)
                    : const EdgeInsets.only(left: 15, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildUserNameToDisplay(
                      userId: messageToReplySenderId,
                      isMessagePreviewCard: true,
                      hasShimmerLoader: hasDivider,
                    ),
                  ],
                ),
              ),

              // MESSAGE BODY
              () {
                // DISPLAY TEXT MESSAGE
                if (messageToReplyType == 'text') {
                  return Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                        child: Text(
                          messageToReplyData,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12.sp,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                // DISPLAY PAYMENT
                else if (messageToReplyType == 'payment') {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                    child: Row(
                      children: [
                        getMsgTypeIcon(null, messageToReplyType),
                        Expanded(
                          child: Text(
                            messageToReplyData.isNotEmpty
                                ? messageToReplyData
                                : getDefaultMessageCaptionByType(messageToReplyType),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12.sp,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                // DISPLAY MUSIC OR VOICENOTE
                else if (messageToReplyType == 'music' || messageToReplyType == 'voicenote') {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                    child: Row(
                      children: [
                        getMsgTypeIcon(null, messageToReplyType),
                        Expanded(
                          child: Text(
                            messageToReplyCaption.isNotEmpty
                                ? messageToReplyCaption
                                : getDefaultMessageCaptionByType(messageToReplyType),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12.sp,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }

                // DISPLAY VIDEO OR IMAGE
                if (messageToReplyType == 'video' || messageToReplyType == 'image') {
                  return Row(
                    children: [
                      getMsgTypeIcon(null, messageToReplyType),
                      Expanded(
                        child: Text(
                          messageToReplyCaption.isNotEmpty
                              ? messageToReplyCaption
                              : getDefaultMessageCaptionByType(messageToReplyType),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12.sp,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      )
                    ],
                  );
                }
                return Container();
              }(),
            ],
          )),
        ],
      ),

      // Divider
      hasDivider != null && hasDivider == true
          ? Container(
              margin: const EdgeInsets.only(top: 10),
              width: double.infinity,
              child: const Divider(
                height: 1,
                color: Colors.grey,
              ),
            )
          : Container(),
    ],
  );
}

// Get StoryItem by Type
StoryItem getStoryItemByType(Story storySelected, StoryController storyController) {
  // Case : Story Text
  if (storySelected.storyType == 'text') {
    return StoryItem.text(
      title: storySelected.content,
      textStyle:
          TextStyle(fontFamily: storiesAvailableFontsList[storySelected.fontType], fontSize: 50, color: Colors.white),
      backgroundColor: storiesAvailableColorsList[storySelected.bgColor],
    );
  }

  // Case : Story Image
  else if (storySelected.storyType == 'image') {
    return StoryItem.pageImage(
      url: storySelected.content,
      controller: storyController,
      // caption: storySelected.caption.isNotEmpty
      //     ? storySelected.caption
      //     : null,
    );
  }

  // Case : Story Video
  else {
    return StoryItem.pageVideo(
      storySelected.content,
      controller: storyController,
      // caption: storySelected.caption.isNotEmpty
      //     ? storySelected.caption
      //     : null,
    );
  }
}

// Get story GridPreview by Type
Widget getStoryGridPreviewThumbnail({required Story storySelected, double? height, double? width, bool? isForever}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isForever != null && isForever == true ? 50 : 15), color: kGreyColor),
        margin: const EdgeInsets.only(bottom: 2),
        height: height ?? 45,
        width: width ?? 45,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black54,
            ),
          ),
        ),
      ),
      (() {
        // Case : Story Text
        if (storySelected.storyType == 'text') {
          return Container(
            height: height ?? 45,
            width: width ?? 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isForever != null && isForever == true ? 50 : 15),
              color: storiesAvailableColorsList[storySelected.bgColor],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Text(
                  storySelected.content,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: storiesAvailableFontsList[storySelected.fontType], color: Colors.white),
                ),
              ),
            ),
          );
        }

        // Case : Story Video/Image
        else {
          return ClipRRect(
            borderRadius: BorderRadius.circular(isForever != null && isForever == true ? 50 : 15),
            child: ProgressiveImage(
              height: height ?? 45,
              width: width ?? 45,
              fit: BoxFit.cover,
              placeholder: const AssetImage(darkBackground),
              //
              thumbnail: NetworkImage(
                  storySelected.storyType == 'image' ? storySelected.content : storySelected.videoThumbnail),
              //
              image: NetworkImage(
                  storySelected.storyType == 'image' ? storySelected.content : storySelected.videoThumbnail),
            ),
          );
        }
      }())
    ],
  );
}

// Get Story GridPreview
Widget getStoryGridPreview({
  required String storyId,
  bool? hasDivider,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: StreamBuilder<Story>(
      stream: FirestoreMethods.getStoryById(storyId),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.hasData && snapshot.data != null) {
          Story storyGet = snapshot.data!;

          return InkWell(
            onTap: () async {
              // View Story
              if (!hasStoryExpired(storyGet.endAt)) {
                //
                showFullPageLoader(context: context, color: Colors.white);
                //

                usermodel.User? userPoster = await FirestoreMethods.getUserByIdAsFuture(storyGet.uid);

                // Dismiss loader
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                if (userPoster != null) {
                  // Build Story Handler
                  StoriesHandler storiesHandler = StoriesHandler(
                    avatarPath: userPoster.profilePicture,
                    posterId: userPoster.id,
                    title: userPoster.name,
                    origin: 'singleStory',
                    lastStoryDateTime: storyGet.createdAt,
                    stories: [storyGet],
                  );
                  // Preview Story
                  // ignore: use_build_context_synchronously
                  context.pushTransparentRoute(StoriesViewer(
                    indexInStoriesHandlerList: 0,
                    storiesHandlerList: [storiesHandler],
                  ));
                }
              }
            },
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Trailing
                    getStoryGridPreviewThumbnail(storySelected: storyGet),
                    const SizedBox(
                      width: 10,
                    ),

                    // Event content
                    Expanded(
                      child: Wrap(
                        children: [
                          hasStoryExpired(storyGet.endAt)
                              ? FittedBox(
                                  child: Text(
                                    'Cette story a expiré',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.circleNotch,
                                          size: 13.sp,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          'Story',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Wrap(
                                      children: [
                                        Text(
                                          storyGet.storyType == 'text'
                                              ? storyGet.content
                                              : storyGet.caption.isNotEmpty
                                                  ? storyGet.caption
                                                  : storyGet.storyType == 'image'
                                                      ? 'Image'
                                                      : storyGet.storyType == 'video'
                                                          ? 'Video'
                                                          : '',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Divider
                hasDivider != null && hasDivider == true
                    ? Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: double.infinity,
                        child: const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
              ],
            ),
          );
        }

        // Diplay Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade400,
                child: const CircleAvatar(
                  radius: 22,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                children: [
                  const Text('...'),
                  const SizedBox(height: 5),
                  hasDivider != null && hasDivider == true
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              width: 50,
                              height: 15,
                              color: Colors.grey.shade400),
                        )
                      : const Text('...'),
                ],
              ),
            ],
          );
        }

        return Container();
      },
    ),
  );
}

// Get Event GridPreview by Type
Widget getEventGridPreview({required String eventId, bool? hasDivider}) {
  return StreamBuilder<Event>(
    stream: FirestoreMethods.getEventById(eventId),
    builder: (context, snapshot) {
      // Handle error
      if (snapshot.hasError) {
        return Container();
      }

      if (snapshot.hasData && snapshot.data != null) {
        Event eventGet = snapshot.data!;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Trailing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: ProgressiveImage(
                      height: 0.1.sw,
                      width: 0.1.sw,
                      fit: BoxFit.cover,
                      placeholder: const AssetImage(darkBackground),
                      //
                      thumbnail: AssetImage('assets/images/eventtype.icons/${eventGet.type}.png'),
                      //
                      image: eventGet.trailing.isNotEmpty
                          ? NetworkImage(eventGet.trailing)
                          : AssetImage('assets/images/eventtype.icons/${eventGet.type}.png') as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),

                // Event content
                Expanded(
                  child: Wrap(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              buildUserNameToDisplay(
                                userId: eventGet.uid,
                                isMessagePreviewCard: true,
                                hasShimmerLoader: hasDivider,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            eventGet.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Divider
            hasDivider != null && hasDivider == true
                ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    child: const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  )
                : Container(),
          ],
        );
      }

      // Diplay Loader
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade400,
                child: CircleAvatar(
                  radius: 0.04.sw,
                ),
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            Column(
              children: [
                const Text('...'),
                const SizedBox(height: 2),
                hasDivider != null && hasDivider == true
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade400,
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            width: 50,
                            height: 12,
                            color: Colors.grey.shade400),
                      )
                    : const Text('...'),
              ],
            ),
          ],
        );
      }

      return Container();
    },
  );
}

// Get Duration Label
String getDurationLabel(DateTime eventStartedDate, DateTime reminderDate) {
  Duration duration = eventStartedDate.difference(reminderDate);

  if (duration == const Duration()) {
    return 'dès qu\'il commence';
  } else if (duration == const Duration(minutes: 10)) {
    return '10min avant';
  } else if (duration == const Duration(hours: 1)) {
    return '1h avant';
  } else if (duration == const Duration(days: 1)) {
    return '1 jour avant';
  } else if (duration == const Duration(days: 3)) {
    return '3 jours avant';
  } else if (duration == const Duration(days: 7)) {
    return '1 semaine avant';
  } else if (duration == const Duration(days: 30)) {
    return '1 mois avant';
  }

  return 'Aucun rappel';
}

// Get Event Icon from type
String getEventIconPath(key) {
  EventType eventresult = eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.iconPath;
}

// Get Event Title from type
String getEventTitle(key) {
  EventType eventresult = eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.name;
}

// Get Event Recurrence from type
bool getEventRecurrence(key) {
  EventType eventresult = eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.recurrence;
}

// Show Snackbar
showSnackbar(context, message, color) {
  var snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 13.sp),
    ),
    backgroundColor: color ?? Colors.black87,
  );
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
}

// Check Phone Number validity
Future<bool> isPhoneNumberValid({
  required BuildContext context,
  required String phoneContent,
  required String phoneCode,
  required String countryName,
  required String regionCode,
}) async
//
{
// Validate
  bool isValid = await PhoneNumberUtil().validate(phoneContent, regionCode: regionCode).onError(
        (error, stackTrace) => showSnackbar(context, 'Votre numéro est incorrect !', null),
      );
  log('Is phone number valid: $isValid');

  if (isValid) {
    await UserSimplePreferences.setPhone('+${phoneCode}${phoneContent}');
    await UserSimplePreferences.setCountry(countryName);

    return true;
  } else {
    return false;
  }
}

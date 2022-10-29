import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:wesh/models/notification.dart' as NotificationModel;
import '../models/event.dart';
import '../models/forever.dart';
import '../models/reminder.dart';
import '../models/user.dart' as UserModel;
import '../utils/functions.dart';

class FirestoreMethods {
  // Create a new user
  Future createUser(context, uid, Map<String, Object?> user) async {
    debugPrint('CREATING NEW USER...');
    try {
      // Ref to doc
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      debugPrint('DOC USER IS: $docUser');

      // Create document and write it to the database
      await docUser.set(user);
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite : $e', null);
    }
  }

  // Update user with specific fields
  Future<bool> updateUserWithSpecificFields(
      context, uid, Map<String, Object?> fieldsToUpload) async {
    debugPrint('UPDATING USER...');
    try {
      // Ref to doc
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      debugPrint('DOC USER IS: $docUser');

      // Update user fields
      await docUser.update(fieldsToUpload);
      return true;
    } catch (e) {
      debugPrint('Error: $e');
      showSnackbar(context, 'Une erreur s\'est produite', null);
      return false;
    }
  }

  //////////////////  EVENT
  //////////////////
  //////////////////

  // Create a new event
  Future<bool> createEvent(context, uid, Map<String, Object?> event) async
  //
  {
    debugPrint('CREATING NEW EVENT...');
    try {
      // Create event and write it to the database : Events Table
      final refEvent = FirebaseFirestore.instance.collection('events').doc();
      await refEvent.set(event);

      // Update EventId Field
      var eventid = refEvent.id;
      var refEventCreated =
          FirebaseFirestore.instance.collection('events').doc(eventid);
      await refEventCreated.update({'eventId': eventid});
      debugPrint('Event id is: $eventid');

      // Update User_creator Events Table
      debugPrint('Updating User "Events field"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'events': FieldValue.arrayUnion([eventid])
      });

      // Create a new notification
      await createNotification(context, uid, eventid, 'eventCreated');

      return true;
    } catch (e) {
      showSnackbar(
          context,
          'Une erreur s\'est produite lors de la création de l\'évènement',
          null);
      return false;
    }
  }

  // Update an existing event
  Future<bool> updateEvent(
      context, eventId, Map<String, Object?> eventToUpdate) async
  //
  {
    debugPrint('UPDATING EXISTING EVENT...');
    try {
      // Update event and write it to the database : Events Table
      final refEvent =
          FirebaseFirestore.instance.collection('events').doc(eventId);
      await refEvent.update(eventToUpdate);

      // UPDATE ALL RELATED REMINDERS: if event is not user birthday
      // TODO

      // Create a new notification : updated
      await createNotification(context, FirebaseAuth.instance.currentUser!.uid,
          eventId, 'eventUpdated');
      return true;
    } catch (e) {
      showSnackbar(
          context,
          'Une erreur s\'est produite lors de la modification de l\'évènement',
          null);
      return false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(context, eventId, userPosterId) async {
    debugPrint('DELETING EVENT...');
    try {
      // Delete Event : in Events Table
      final refEvent =
          FirebaseFirestore.instance.collection('events').doc(eventId);
      await refEvent.delete();

      // Delete Event : in UserPoster Events Table
      var refUser =
          FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'events': FieldValue.arrayRemove([eventId])
      });
      return true;
    } catch (e) {
      showSnackbar(
          context,
          'Une erreur s\'est produite lors de la suppression de l\'évènement',
          null);
      return false;
    }
  }

  ////////////////// REMINDER
  //////////////////
  //////////////////

  // Create a new reminder
  Future createReminder(context, uid, Map<String, Object?> reminder) async
  //
  {
    debugPrint('CREATING NEW REMINDER...');
    try {
      // Create reminder and write it to the database : Reminders Table
      final refReminder =
          FirebaseFirestore.instance.collection('reminders').doc();
      await refReminder.set(reminder);

      // Update ReminderId Field
      var reminderid = refReminder.id;
      var refReminderCreated =
          FirebaseFirestore.instance.collection('reminders').doc(reminderid);
      await refReminderCreated.update({'reminderId': reminderid});
      debugPrint('ReminderId is: $reminderid');

      // Update User_creator Reminders Table
      debugPrint('Updating User "Reminders field"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'reminders': FieldValue.arrayUnion([reminderid])
      });

      // Create a new notification
      await createNotification(context, uid, reminderid, 'reminderCreated');

      //
      debugPrint('Reminder created (+notification) !');
      return true;
    } catch (e) {
      showSnackbar(context,
          'Une erreur s\'est produite lors de la création du rappel', null);
      return false;
    }
  }

  // Update an existing event
  Future<bool> updateReminder(
      context, reminderId, Map<String, Object?> reminderToUpdate) async
  //
  {
    debugPrint('UPDATING EXISTING REMINDER...');
    try {
      // Update reminder and write it to the database : Reminders Table
      final refReminder =
          FirebaseFirestore.instance.collection('reminders').doc(reminderId);
      await refReminder.update(reminderToUpdate);

      // Create a new notification : updated
      await createNotification(context, FirebaseAuth.instance.currentUser!.uid,
          reminderId, 'reminderUpdated');

      //
      debugPrint('Reminder updated !');
      return true;
    } catch (e) {
      showSnackbar(context,
          'Une erreur s\'est produite lors de la modification du rappel', null);
      return false;
    }
  }

  // Delete reminder
  Future<bool> deleteReminder(context, reminderId, userPosterId) async {
    debugPrint('DELETING REMINDER...');
    try {
      // Delete Reminder : in Reminders Table
      final refReminder =
          FirebaseFirestore.instance.collection('reminders').doc(reminderId);
      await refReminder.delete();

      // Delete Reminder : in UserPoster Reminders Table
      var refUser =
          FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'reminders': FieldValue.arrayRemove([reminderId])
      });
      return true;
    } catch (e) {
      showSnackbar(context,
          'Une erreur s\'est produite lors de la suppression du rappel', null);
      return false;
    }
  }

  ////////////////// STORY
  //////////////////
  //////////////////

  // Create a new story
  Future<bool> createStory(context, uid, Map<String, Object?> story) async {
    debugPrint('CREATING NEW STORY...');
    try {
      // Create story and write it to the database : Stories Table
      final refStory = FirebaseFirestore.instance.collection('stories').doc();
      await refStory.set(story);

      // Update StoryId Field
      var storyId = refStory.id;
      var refStoryCreated =
          FirebaseFirestore.instance.collection('stories').doc(storyId);
      await refStoryCreated.update({'storyId': storyId});
      debugPrint('Event id is: $storyId');

      // Update User_creator Stories Array
      debugPrint('Updating User "Stories field"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'stories': FieldValue.arrayUnion([storyId])
      });

      // Update User_creator lastStoryUpdateDateTime field
      debugPrint('Updating User "Last Story UpdateDateTime field"...');
      await refUser.update({
        'lastStoryUpdateDateTime': DateTime.now().toIso8601String(),
      });

      // Create a new notification
      await createNotification(context, uid, storyId, 'storyCreated');

      return true;
    } catch (e) {
      showSnackbar(context,
          'Une erreur s\'est produite lors de la création de la story', null);
      return false;
    }
  }

  // Update Story Viewers List
  Future updateStoryViewersList(context, uid, storyId) async {
    debugPrint('UPDATING STORY VIEWERS LIST...');
    try {
      debugPrint('Updating "Story viewers array"...');
      var refStory =
          FirebaseFirestore.instance.collection('stories').doc(storyId);
      await refStory.update({
        'viewers': FieldValue.arrayUnion([uid])
      });
      //
      debugPrint('Story viewers list updated !');
      return true;
    } catch (e) {
      debugPrint('Error with story update: $e');
      // showSnackbar(context, 'Une erreur s\'est produite', null);
      return false;
    }
  }

  // Delete story
  Future<bool> deleteStory(context, storyId, userPosterId) async {
    debugPrint('DELETING STORY...');
    try {
      // Delete story : in Stories Table
      final refStory =
          FirebaseFirestore.instance.collection('stories').doc(storyId);
      await refStory.delete();

      // Delete story : in UserPoster Stories array
      var refUser =
          FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'stories': FieldValue.arrayRemove([storyId])
      });

      // Delete story : in all containing forevers

      final ref = FirebaseFirestore.instance.collection('forevers');
      final snapshot = await ref.get();
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.map((doc) {
          Forever forever = Forever.fromJson(doc.data());

          var refForever = FirebaseFirestore.instance
              .collection('forevers')
              .doc(forever.foreverId);
          List foreverStories = [];
          FirebaseFirestore.instance
              .collection('forevers')
              .doc(forever.foreverId)
              .get()
              .then((value) async {
            // Check if Stories array exists
            if (value.data()!.containsKey('stories')) {
              //
              foreverStories = value.data()!["stories"];

              // Check if the storyId already exists, then Add
              if (foreverStories.contains(storyId)) {
                await refForever.update({
                  'stories': FieldValue.arrayRemove([storyId])
                });
                debugPrint('Story removed to the Forever !');
              }

              debugPrint('Forever stories list updated !');
            }
          });
        }).toList();
      }

      return true;
    } catch (e) {
      showSnackbar(
          context,
          'Une erreur s\'est produite lors de la suppression de la story',
          null);
      return false;
    }
  }

  ////////////////// FOREVER
  //////////////////
  //////////////////

  // Create forever
  Future createForever(context, uid, Map<String, Object?> forever) async {
    debugPrint('CREATING NEW FOREVER...');
    try {
      // Create forever and write it to the database : Forevers Table
      final refForever =
          FirebaseFirestore.instance.collection('forevers').doc();
      await refForever.set(forever);

      // Update ForeverId Field
      var foreverid = refForever.id;
      var refForeverCreated =
          FirebaseFirestore.instance.collection('forevers').doc(foreverid);
      await refForeverCreated.update({'foreverId': foreverid});
      debugPrint('Forever Id is: $foreverid');

      // Update User_creator Forevers array
      debugPrint('Updating User "Forevers array"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'forevers': FieldValue.arrayUnion([foreverid])
      });

      // Create a new notification
      await createNotification(context, uid, foreverid, 'foreverCreated');

      //
      debugPrint('Forever created (+notification) !');
      return true;
    } catch (e) {
      showSnackbar(context,
          'Une erreur s\'est produite lors de la création du forever', null);
      return false;
    }
  }

  // Update forever
  Future<bool> updateForever(
      context, foreverId, Map<String, Object?> foreverToUpdate) async
  //
  {
    debugPrint('UPDATING EXISTING FOREVER...');
    try {
      // Update forever and write it to the database : Forevers Table
      final refForever =
          FirebaseFirestore.instance.collection('forevers').doc(foreverId);
      await refForever.update(foreverToUpdate);

      // Create a new notification : updated
      // await createNotification(context, FirebaseAuth.instance.currentUser!.uid,
      //     foreverId, 'foreverUpdated');

      //
      debugPrint('Forever updated !');
      return true;
    } catch (e) {
      showSnackbar(
          context,
          'Une erreur s\'est produite lors de la modification du forever',
          null);
      return false;
    }
  }

  // Add/Delete story inside Forever
  Future AddOrDeleteStoryInsideForever(context, storyId, foreverId) async {
    debugPrint('UPDATING FOREVER.STORIES LIST...');
    try {
      debugPrint('Updating "Forever Stories array"...');
      var refForever =
          FirebaseFirestore.instance.collection('forevers').doc(foreverId);
      List foreverStories = [];
      FirebaseFirestore.instance
          .collection('forevers')
          .doc(foreverId)
          .get()
          .then((value) async {
        // Check if Stories array exists
        if (value.data()!.containsKey('stories')) {
          //
          foreverStories = value.data()!["stories"];

          // Check if the storyId already exists, then Add
          if (foreverStories.contains(storyId)) {
            await refForever.update({
              'stories': FieldValue.arrayRemove([storyId])
            });
            debugPrint('Story removed to the Forever !');
          } else {
            await refForever.update({
              'stories': FieldValue.arrayUnion([storyId])
            });

            debugPrint('Story added from Forever !');
          }

          debugPrint('Forever stories list updated !');
          return true;
        } else {
          await refForever.set({
            'stories': FieldValue.arrayUnion([storyId])
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      debugPrint('Error: $e');
      debugPrint('Error while updating Forever stories array:');
      // showSnackbar(context, 'Une erreur s\'est produite', null);
      return false;
    }
  }

  // Delete forever
  Future<bool> deleteForever(context, foreverId, userPosterId) async {
    debugPrint('DELETING FOREVER...');
    try {
      // Delete forever : in Forevers Table
      final refForever =
          FirebaseFirestore.instance.collection('forevers').doc(foreverId);
      await refForever.delete();

      // Delete forever : in UserPoster Forevers array
      var refUser =
          FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'forevers': FieldValue.arrayRemove([foreverId])
      });
      return true;
    } catch (e) {
      showSnackbar(context,
          'Une erreur s\'est produite lors de la suppression du forever', null);
      return false;
    }
  }

  ////////////////// NOTIFICATION
  //////////////////
  //////////////////

  // Create Notification and Update Followers Notification Fields
  Future<String> createNotification(context, uid, contentId, type) async {
    try {
      // Modeling a new notification
      NotificationModel.Notification newNotification =
          NotificationModel.Notification(
        notificationId: '',
        uid: uid,
        type: type,
        contentId: contentId,
        createdAt: DateTime.now(),
      );

      // Create Notifications : in Notifications Table
      final refNotif =
          FirebaseFirestore.instance.collection('notifications').doc();
      refNotif.set(newNotification.toJson());

      // Update NotificationId Field
      var notificationId = refNotif.id;
      var refNotificationCreated = FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId);
      refNotificationCreated.update({'notificationId': notificationId});
      debugPrint('Notification id is: $notificationId');

      // Update Followers Notifications Table
      // TODO:
      //
      //

      return refNotif.id;
    } catch (e) {
      showSnackbar(
          context,
          'Une erreur s\'est produite lors de la création de la notification',
          null);
      return '';
    }
  }

  ////////////////// BUG REPORT, QUESTION, FEEDBACK
  //////////////////
  //////////////////

  // Send bug report
  Future sendBugReport(context, Map<String, Object?> reportToSend) async {
    debugPrint('SENDING BUG REPORT...');
    try {
      // Create a bug report and write it down to the database : BugReports Table
      final refBugReport =
          FirebaseFirestore.instance.collection('bugreports').doc();
      await refBugReport.set(reportToSend);

      // Update bugReportId Field
      var bugReportId = refBugReport.id;
      var refBugReportCreated =
          FirebaseFirestore.instance.collection('bugreports').doc(bugReportId);
      await refBugReportCreated.update({'bugReportId': bugReportId});
      debugPrint('Bug Report Id is: $bugReportId');

      //
      debugPrint('Bug Report sent !');
      return true;
    } catch (e) {
      showSnackbar(context,
          'Une erreur s\'est produite lors de la création du rapport', null);
      return false;
    }
  }

  // Send question
  Future sendQuestion(context, Map<String, Object?> questionToSend) async {
    debugPrint('SENDING QUESTION...');
    try {
      // Create a question and write it down to the database : Questions Table
      final refQuestion =
          FirebaseFirestore.instance.collection('questions').doc();
      await refQuestion.set(questionToSend);

      // Update questionId Field
      var questionId = refQuestion.id;
      var refQuestionCreated =
          FirebaseFirestore.instance.collection('questions').doc(questionId);
      await refQuestionCreated.update({'questionId': questionId});
      debugPrint('Question Id is: $questionId');

      //
      debugPrint('Question sent !');
      return true;
    } catch (e) {
      showSnackbar(
          context, 'Une erreur s\'est produite avec votre question', null);
      return false;
    }
  }

  // Send feedback
  Future sendFeedback(context, Map<String, Object?> feedbackToSend) async {
    debugPrint('SENDING FEEDBACK...');
    try {
      // Create a feedback and write it down to the database : Feedbacks Table
      final refFeedback =
          FirebaseFirestore.instance.collection('feedbacks').doc();
      await refFeedback.set(feedbackToSend);

      // Update feedbackId Field
      var feedbackId = refFeedback.id;
      var refFeedbackCreated =
          FirebaseFirestore.instance.collection('feedbacks').doc(feedbackId);
      await refFeedbackCreated.update({'feedbackId': feedbackId});
      debugPrint('Feedback Id is: $feedbackId');

      //
      debugPrint('Feedback sent !');
      return true;
    } catch (e) {
      showSnackbar(
          context, 'Une erreur s\'est produite avec votre feedback', null);
      return false;
    }
  }

  ////////////////// OTHERS
  //////////////////
  //////////////////

  // Get user info | Check if User exist
  Future<UserModel.User?> getUser(uid) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      UserModel.User user = UserModel.User.fromJson(snapshot.data()!);
      return user;
    }
    return null;
  }

  // Get all events
  Stream<List<Event>> getAllEvents() {
    debugPrint('Fetching all events...');

    return FirebaseFirestore.instance.collection('events').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList());
  }

  // Get event by EventId
  Future<Event?> getEventById(eventId) async {
    debugPrint('Fetching event with EventId...');

    var ref = FirebaseFirestore.instance.collection('events').doc(eventId);
    var snapshot = await ref.get();
    if (snapshot.exists) {
      Event event = Event.fromJson(snapshot.data()!);
      return event;
    }
    return null;
  }

  // Get reminder by ReminderId
  Future<Reminder?> getReminderById(reminderId) async {
    debugPrint('Fetching reminder with ReminderId...');

    var ref =
        FirebaseFirestore.instance.collection('reminders').doc(reminderId);
    var snapshot = await ref.get();
    if (snapshot.exists) {
      Reminder reminder = Reminder.fromJson(snapshot.data()!);
      return reminder;
    }
    return null;
  }

  // Update Current User Name
  Future updateCurrentUserName(context, String name) async {
    final String finalName = name.trim();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await ref.update({'name': name});
      return name;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite : $e', null);
    }
  }

  // Update Current User Name
  Future updateCurrentUserBirthday(context, DateTime date) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await ref.update({'birthday': date.toIso8601String()});
      return date;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite : $e', null);
    }
  }

  // Update Current User Profile Picture to DB
  Future updateCurrentUserProfilePictureToDB(context, dowloadurl) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await ref.update({'profilePicture': dowloadurl});
      return dowloadurl;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite : $e', null);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wesh/models/notification.dart' as NotificationModel;
import '../models/user.dart' as UserModel;
import '../utils/functions.dart';

class FirestoreMethods {
  // Create a new user
  Future createUser(context, uid, Map<String, Object?> user) async {
    print('CREATING NEW USER...');
    try {
      // Ref to doc
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      print('DOC USER IS: $docUser');

      // Create document and write it to the database
      docUser.set(user);
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite : $e', null);
    }
  }

  // Create a new event
  Future createEvent(context, uid, Map<String, Object?> event) async {
    print('CREATING NEW EVENT...');
    try {
      // Create event and write it to the database : Events Table
      final refEvent = FirebaseFirestore.instance.collection('events').doc();
      refEvent.set(event);

      // Update EventId Field
      var eventid = refEvent.id;
      var refEventCreated =
          FirebaseFirestore.instance.collection('events').doc(eventid);
      refEventCreated.update({'eventId': eventid});
      print('Event id is: $eventid');

      // Update User_creator Events Table
      print('Updating User "Events field"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      refUser.update({
        'events': FieldValue.arrayUnion([eventid])
      });

      // Create a new notification
      await createNotification(context, uid, eventid, 'eventCreated');
    } catch (e) {
      showSnackbar(
          context,
          'Une erreur s\'est produite lors de la création de l\'événement',
          null);
    }
  }

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
      print('Notification id is: $notificationId');

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

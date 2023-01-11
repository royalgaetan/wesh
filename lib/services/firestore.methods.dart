import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import '../models/discussion.dart';
import '../models/event.dart';
import '../models/forever.dart';
import '../models/message.dart';
import '../models/payment.dart';
import '../models/reminder.dart';
import '../models/story.dart';
import '../models/user.dart' as usermodel;
import '../utils/functions.dart';

class FirestoreMethods {
  // Create a new user
  static Future createUser(context, uid, Map<String, dynamic> user) async {
    log('CREATING NEW USER...');
    try {
      // Ref to doc
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      log('DOC USER IS: $docUser');

      // Create document and write it to the database
      await docUser.set(user);
    } catch (e) {
      log('Error: $e');
      showSnackbar(context, 'Une erreur s\'est produite', null);
    }
  }

  // Update user with specific fields
  static Future<bool> updateUserWithSpecificFields(context, uid, Map<String, dynamic> fieldsToUpload) async {
    log('UPDATING USER...');
    try {
      // Ref to doc
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      log('DOC USER IS: $docUser');

      // Update user fields
      await docUser.update(fieldsToUpload);
      return true;
    } catch (e) {
      log('Error: $e');
      showSnackbar(context, 'Une erreur s\'est produite', null);
      return false;
    }
  }

  // Follow a User
  static Future<bool> followUser(BuildContext context, String userIdToFollow) async {
    log('FOLLOWING A USER...');
    try {
      // Ref to docUserToFollow
      final docUserToFollow = FirebaseFirestore.instance.collection('users').doc(userIdToFollow);
      // Add [Me] as Follower
      await docUserToFollow.update({
        'followers': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });

      // Ref to [My] doc
      final docMe = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      // Add [userToFollow] as [My] Following
      await docMe.update({
        'followings': FieldValue.arrayUnion([userIdToFollow])
      });

      return true;
    } catch (e) {
      log('Error: $e');
      showSnackbar(context, 'Impossible de suivre cette personne !', null);
      return false;
    }
  }

  // Unfollow a User
  static Future<bool> unfollowUser(BuildContext context, String userIdToUnfollow) async {
    log('UNFOLLOWING A USER...');
    try {
      // Ref to docUserToUnfollow
      final docUserToUnfollow = FirebaseFirestore.instance.collection('users').doc(userIdToUnfollow);
      // Remove [Me] as Follower
      await docUserToUnfollow.update({
        'followers': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });

      // Ref to [My] doc
      final docMe = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      // Remove [userToUnfollow] as [My] Following
      await docMe.update({
        'followings': FieldValue.arrayRemove([userIdToUnfollow])
      });

      return true;
    } catch (e) {
      log('Error: $e');
      showSnackbar(context, 'Impossible d\'arrêter de suivre cette personne !', null);
      return false;
    }
  }

  // Remove a User as [My] Follower
  static Future<bool> removeUserAsFollower(BuildContext context, String userIdToRemove) async {
    log('REMOVE A USER AS [MY] FOLLOWER...');
    try {
      // Ref to docMe
      final docMe = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      // Remove [userToRemove] as [My] Follower
      await docMe.update({
        'followers': FieldValue.arrayRemove([userIdToRemove])
      });

      // Ref to [userToRemove] doc
      final docUserToRemove = FirebaseFirestore.instance.collection('users').doc(userIdToRemove);
      // Remove [Me] as [userToRemove] Following
      await docUserToRemove.update({
        'followings': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });

      return true;
    } catch (e) {
      log('Error: $e');
      showSnackbar(context, 'Impossible de retirer cette personne !', null);
      return false;
    }
  }

  //////////////////  EVENT
  //////////////////
  //////////////////

  // Create a new event
  static Future<bool> createEvent(context, uid, Map<String, dynamic> event) async
  //
  {
    log('CREATING NEW EVENT...');
    try {
      // Create event and write it to the database : Events Table
      final refEvent = FirebaseFirestore.instance.collection('events').doc();
      await refEvent.set(event);

      // Update EventId Field
      var eventid = refEvent.id;
      var refEventCreated = FirebaseFirestore.instance.collection('events').doc(eventid);
      await refEventCreated.update({'eventId': eventid});
      log('Event id is: $eventid');

      // Update User_creator Events Table
      log('Updating User "Events field"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'events': FieldValue.arrayUnion([eventid])
      });

      // Create a new notification
      await createNotification(context, uid, eventid, 'eventCreated');

      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la création de l\'évènement', null);
      return false;
    }
  }

  // Update an existing event
  static Future<bool> updateEvent(context, eventId, Map<String, dynamic> eventToUpdate) async
  //
  {
    log('UPDATING EXISTING EVENT...');
    try {
      // Update event and write it to the database : Events Table
      final refEvent = FirebaseFirestore.instance.collection('events').doc(eventId);
      await refEvent.update(eventToUpdate);

      // UPDATE ALL RELATED REMINDERS: if event is not user birthday

      // Create a new notification : updated
      await createNotification(context, FirebaseAuth.instance.currentUser!.uid, eventId, 'eventUpdated');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la modification de l\'évènement', null);
      return false;
    }
  }

  // Delete event
  static Future<bool> deleteEvent(context, eventId, userPosterId) async {
    log('DELETING EVENT...');
    try {
      // Delete Event : in Events Table
      final refEvent = FirebaseFirestore.instance.collection('events').doc(eventId);
      await refEvent.delete();

      // Delete Event : in UserPoster Events Table
      var refUser = FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'events': FieldValue.arrayRemove([eventId])
      });
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la suppression de l\'évènement', null);
      return false;
    }
  }

  ////////////////// REMINDER
  //////////////////
  //////////////////

  // Create a new reminder
  static Future createReminder(context, uid, Map<String, dynamic> reminder) async
  //
  {
    log('CREATING NEW REMINDER...');
    try {
      // Create reminder and write it to the database : Reminders Table
      final refReminder = FirebaseFirestore.instance.collection('reminders').doc();
      await refReminder.set(reminder);

      // Update ReminderId Field
      var reminderid = refReminder.id;
      var refReminderCreated = FirebaseFirestore.instance.collection('reminders').doc(reminderid);
      await refReminderCreated.update({'reminderId': reminderid});
      log('ReminderId is: $reminderid');

      // Update User_creator Reminders Table
      log('Updating User "Reminders field"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'reminders': FieldValue.arrayUnion([reminderid])
      });

      // Create the local_notification [A Scheduled Notification one]
      log('Creating the local_notification [A Scheduled Notification one]');
      try {
        createOrUpdateReminderLocalNotification(action: 'create', reminderId: reminderid);
      } catch (e) {
        //
        log('Err: $e');
      }

      // Create a new notification
      // await createNotification(context, uid, reminderid, 'reminderCreated');

      //
      log('Reminder created (+notification) !');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la création du rappel', null);
      return false;
    }
  }

  // Update an existing event
  static Future<bool> updateReminder(context, reminderId, Map<String, dynamic> reminderToUpdate) async
  //
  {
    log('UPDATING EXISTING REMINDER...');
    try {
      // Update reminder and write it to the database : Reminders Table
      final refReminder = FirebaseFirestore.instance.collection('reminders').doc(reminderId);
      await refReminder.update(reminderToUpdate);

      // Update the local_notification [That Scheduled Notification]
      log('Updating the local_notification [That Scheduled Notification one]');
      try {
        createOrUpdateReminderLocalNotification(action: 'update', reminderId: reminderId);
      } catch (e) {
        //
        log('Err: $e');
      }

      // Create a new notification : updated
      // await createNotification(context, FirebaseAuth.instance.currentUser!.uid, reminderId, 'reminderUpdated');

      //
      log('Reminder updated !');
      return true;
    } catch (e) {
      if (context != null) {
        showSnackbar(context, 'Une erreur s\'est produite lors de la modification du rappel', null);
      }
      return false;
    }
  }

  // Delete reminder
  static Future<bool> deleteReminder(context, reminderId, userPosterId) async {
    log('DELETING REMINDER...');
    try {
      // Delete Reminder : in Reminders Table
      final refReminder = FirebaseFirestore.instance.collection('reminders').doc(reminderId);
      await refReminder.delete();

      // Delete Reminder : in UserPoster Reminders Table
      var refUser = FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'reminders': FieldValue.arrayRemove([reminderId])
      });

      // Delete the local_notification [That Scheduled Notification]
      log('Deleting the local_notification [That Scheduled Notification one]');
      notificationCancelEngine(notifMatchToCancel: '${FirebaseAuth.instance.currentUser!.uid}:reminder:$reminderId');

      //
      return true;
    } catch (e) {
      if (context != null) {
        showSnackbar(context, 'Une erreur s\'est produite lors de la suppression du rappel', null);
      }

      return false;
    }
  }

  ////////////////// STORY
  //////////////////
  //////////////////

  // Create a new story
  static Future<bool> createStory(context, uid, Map<String, dynamic> story) async {
    log('CREATING NEW STORY...');
    try {
      // Create story and write it to the database : Stories Table
      final refStory = FirebaseFirestore.instance.collection('stories').doc();
      await refStory.set(story);

      // Update StoryId Field
      var storyId = refStory.id;
      var refStoryCreated = FirebaseFirestore.instance.collection('stories').doc(storyId);
      await refStoryCreated.update({'storyId': storyId});
      log('Story id is: $storyId');

      // Update User_creator Stories Array
      log('Updating User "Stories field"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'stories': FieldValue.arrayUnion([storyId])
      });

      // Create a new notification
      await createNotification(context, uid, storyId, 'storyCreated');

      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la création de la story', null);
      return false;
    }
  }

  // Update Story Viewers List
  static Future updateStoryViewersList(context, uid, storyId) async {
    log('UPDATING STORY VIEWERS LIST...');
    try {
      log('Updating "Story viewers array"...');
      var refStory = FirebaseFirestore.instance.collection('stories').doc(storyId);
      await refStory.update({
        'viewers': FieldValue.arrayUnion([uid])
      });
      //
      log('Story viewers list updated !');
      return true;
    } catch (e) {
      log('Error with story update: $e');
      // showSnackbar(context, 'Une erreur s\'est produite', null);
      return false;
    }
  }

  // Delete story
  static Future<bool> deleteStory(BuildContext context, Story story, String userPosterId) async {
    log('DELETING STORY...');
    try {
      // Delete story : in Stories Table
      final refStory = FirebaseFirestore.instance.collection('stories').doc(story.storyId);
      await refStory.delete();

      // Delete story : in UserPoster Stories array
      var refUser = FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'stories': FieldValue.arrayRemove([story.storyId])
      });

      // Delete story : in all containing forevers
      final ref = FirebaseFirestore.instance.collection('forevers');
      final snapshot = await ref.get();
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.map((doc) {
          Forever forever = Forever.fromJson(doc.data());

          var refForever = FirebaseFirestore.instance.collection('forevers').doc(forever.foreverId);
          List foreverStories = [];
          FirebaseFirestore.instance.collection('forevers').doc(forever.foreverId).get().then((value) async {
            // Check if Stories array exists
            if (value.data()!.containsKey('stories')) {
              //
              foreverStories = value.data()!["stories"];

              // Check if the storyId already exists, then Delete
              if (foreverStories.contains(story.storyId)) {
                await refForever.update({
                  'stories': FieldValue.arrayRemove([story.storyId])
                });
                log('Story removed to the Forever !');
              }

              log('Forever stories list updated !');
            }
          });
        }).toList();
      }

      // Delete Story's attached file /+ Thumbnail in Firestorage
      if (story.storyType != 'text') {
        var refFile = FirebaseStorage.instance.refFromURL(story.content);

        await refFile.delete();
        // Delete thumbnail
        if (story.storyType == 'video') {
          var refThumbnail = FirebaseStorage.instance.refFromURL(story.videoThumbnail);

          await refThumbnail.delete();
        }
      }

      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la suppression de la story', null);
      return false;
    }
  }

  ////////////////// FOREVER
  //////////////////
  //////////////////

  // Get Users Forevers
  static Stream<List<Forever>> getForevers(String uid) {
    return FirebaseFirestore.instance
        .collection('forevers')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // Get Forevers
              return Forever.fromJson(doc.data());
            }).toList());
  }

  // Get Forever Cover /to build Cover+Title
  static Future<Widget?> getForeverCoverByFirstStoryId(storyId) async {
    final ref = FirebaseFirestore.instance.collection('stories').where('storyId', isEqualTo: storyId);
    final snapshot = await ref.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        Story story = Story.fromJson(doc.data());
        return getStoryGridPreviewThumbnail(isForever: true, storySelected: story);
      }).first;
    }
    return null;
  }

  // Get user by id : As Future
  static Future<Forever?> getForeverByIdAsFuture(foreverId) async {
    log('Fetching forever with foreverId...');

    var ref = FirebaseFirestore.instance.collection('forevers').doc(foreverId);
    var snapshot = await ref.get();
    if (snapshot.exists) {
      return Forever.fromJson(snapshot.data()!);
    }
    return null;
  }

  // Create forever
  static Future createForever(context, uid, Map<String, dynamic> forever) async {
    log('CREATING NEW FOREVER...');
    try {
      // Create forever and write it to the database : Forevers Table
      final refForever = FirebaseFirestore.instance.collection('forevers').doc();
      await refForever.set(forever);

      // Update ForeverId Field
      var foreverid = refForever.id;
      var refForeverCreated = FirebaseFirestore.instance.collection('forevers').doc(foreverid);
      await refForeverCreated.update({'foreverId': foreverid});
      log('Forever Id is: $foreverid');

      // Update User_creator Forevers array
      log('Updating User "Forevers array"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'forevers': FieldValue.arrayUnion([foreverid])
      });

      // Create a new notification
      await createNotification(context, uid, foreverid, 'foreverCreated');

      //
      log('Forever created (+notification) !');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la création du forever', null);
      return false;
    }
  }

  // Update forever
  static Future<bool> updateForever(context, foreverId, Map<String, dynamic> foreverToUpdate) async
  //
  {
    log('UPDATING EXISTING FOREVER...');
    try {
      // Update forever and write it to the database : Forevers Table
      final refForever = FirebaseFirestore.instance.collection('forevers').doc(foreverId);
      await refForever.update(foreverToUpdate);

      // Create a new notification : updated
      // await createNotification(context, FirebaseAuth.instance.currentUser!.uid,
      //     foreverId, 'foreverUpdated');

      //
      log('Forever updated !');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la modification du forever', null);
      return false;
    }
  }

  // Add/Delete story inside Forever
  static Future AddOrDeleteStoryInsideForever(context, storyId, foreverId) async {
    log('UPDATING FOREVER.STORIES LIST...');
    try {
      log('Updating "Forever Stories array"...');
      var refForever = FirebaseFirestore.instance.collection('forevers').doc(foreverId);
      List foreverStories = [];
      FirebaseFirestore.instance.collection('forevers').doc(foreverId).get().then((value) async {
        // Check if Stories array exists
        if (value.data()!.containsKey('stories')) {
          //
          foreverStories = value.data()!["stories"];

          // Check if the storyId already exists, then Add
          if (foreverStories.contains(storyId)) {
            await refForever.update({
              'stories': FieldValue.arrayRemove([storyId])
            });
            log('Story removed to the Forever !');
          } else {
            await refForever.update({
              'stories': FieldValue.arrayUnion([storyId])
            });

            log('Story added from Forever !');
          }

          log('Forever stories list updated !');
          return true;
        } else {
          await refForever.set({
            'stories': FieldValue.arrayUnion([storyId])
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      log('Error: $e');
      log('Error while updating Forever stories array:');
      // showSnackbar(context, 'Une erreur s\'est produite', null);
      return false;
    }
  }

  // Delete forever
  static Future<bool> deleteForever(context, foreverId, userPosterId) async {
    log('DELETING FOREVER...');
    try {
      // Delete forever : in Forevers Table
      final refForever = FirebaseFirestore.instance.collection('forevers').doc(foreverId);
      await refForever.delete();

      // Delete forever : in UserPoster Forevers array
      var refUser = FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'forevers': FieldValue.arrayRemove([foreverId])
      });
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la suppression du forever', null);
      return false;
    }
  }

  ////////////////// DISCUSSION
  //////////////////
  //////////////////

  // Get any Discussion by Id
  static Stream<Discussion>? getDiscussionById(String discussionId) {
    if (discussionId == '') return null;
    return FirebaseFirestore.instance
        .collection('discussions')
        .doc(discussionId)
        .snapshots()
        .map((snapshot) => Discussion.fromJson(snapshot.data()!));
  }

  // Get current user discussions
  static Stream<List<Discussion>> getCurrentUserDiscussions() {
    return FirebaseFirestore.instance
        .collection('discussions')
        .where('participants', arrayContainsAny: [FirebaseAuth.instance.currentUser!.uid])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => Discussion.fromJson(
                doc.data(),
              ),
            )
            .toList());
  }

  // Get [Future] all User from My Discussion
  static Future<List<usermodel.User>> getAllUsersFromMyDiscussions() async {
    List discussionsIDs = [];
    List<Discussion> listOfDiscussions = [];
    List<String> usersInsideMessagesList = [];
    List<usermodel.User> users = [];

    List<Map<String, Object>> listOfUsersWithLastMessageDateTimeInDiscussion = [];

    // Get All My Discussions IDs
    final ref = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      usermodel.User user = usermodel.User.fromJson(snapshot.data()!);
      discussionsIDs = user.discussions ?? [];
    }
    // Loop AllDiscussionId and retrieve Related Discussions Data
    for (String discussionID in discussionsIDs) {
      final refDiscussion =
          FirebaseFirestore.instance.collection('discussions').where('discussionId', isEqualTo: discussionID);
      final snapshot = await refDiscussion.get();
      if (snapshot.size > 0) {
        for (var element in snapshot.docs) {
          if (element.exists) {
            Discussion disc = Discussion.fromJson(element.data());
            listOfDiscussions.add(disc);
          }
        }
      }
    }

    for (Discussion discussion in listOfDiscussions) {
      List<Map<String, Object>> discussionMessages =
          await FirestoreMethods.getMessagesFromListOfDiscussionAsFuture(listOfDiscussions);

      List<Message> discussionMessagesUsedToGetLastMessage = discussionMessages
          .where((map) => map['discussionId'] == discussion.discussionId)
          .map((map) => (map['message'] as Message))
          .toList();

      Message? lastMessage = getLastMessageOfDiscussion(discussionMessagesUsedToGetLastMessage);

      if (lastMessage != null) {
        String userIdToUse = lastMessage.senderId != FirebaseAuth.instance.currentUser!.uid
            ? lastMessage.senderId
            : lastMessage.receiverId;
        listOfUsersWithLastMessageDateTimeInDiscussion
            .add({'lastMessageDateTime': lastMessage.createdAt, 'userId': userIdToUse});
      }
    }

    // Sort messages : by the latest
    listOfUsersWithLastMessageDateTimeInDiscussion
        .sort((a, b) => (b['lastMessageDateTime'] as DateTime).compareTo(a['lastMessageDateTime'] as DateTime));

    // Remove [Me] from [usersInsideMessagesList]
    usersInsideMessagesList = listOfUsersWithLastMessageDateTimeInDiscussion
        .where((map) => (map['userId'] as String) != FirebaseAuth.instance.currentUser!.uid)
        .map((map) => (map['userId'] as String))
        .toList();

    // Get UserData
    for (String userId in usersInsideMessagesList) {
      final refUser = FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await refUser.get();
      if (snapshot.exists) {
        usermodel.User user = usermodel.User.fromJson(snapshot.data()!);
        users.add(user);
      }
    }
    //

    return users;
  }

  ////////////////// MESSAGE
  //////////////////
  //////////////////

  // Get [Future] any Message by Id
  static Future<Message?> getMessageByIdAsFuture(messageId) async {
    final ref = FirebaseFirestore.instance.collection('messages').doc(messageId);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return Message.fromJson(snapshot.data()!);
    }
    return null;
  }

  // Get list of Existing Discussions
  static Future<List<Discussion>> getListOfExistingDiscussions(
      {required String userSenderId, required String userReceiverId}) async {
    List<Discussion> listOfExistingDiscussions = [];

    List<String> participantMatch1 = [
      userSenderId,
      userReceiverId,
      '${userSenderId}_$userReceiverId',
      '${userReceiverId}_$userSenderId'
    ];
    List<String> participantMatch2 = [
      userReceiverId,
      userSenderId,
      '${userReceiverId}_$userSenderId',
      '${userSenderId}_$userReceiverId'
    ];
    final refDiscussions = FirebaseFirestore.instance
        .collection('discussions')
        .where('participants', whereIn: [participantMatch1, participantMatch2]);
    final snapshot = await refDiscussions.get();
    if (snapshot.size > 0) {
      for (var element in snapshot.docs) {
        if (element.exists) {
          Discussion discussion = Discussion.fromJson(element.data());
          listOfExistingDiscussions.add(discussion);
        }
      }
    }
    return listOfExistingDiscussions;
  }

  // Get Messages by discussionId
  static Stream<List<Message>?> getMessagesByDiscussionId(String discussionId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('discussionId', isEqualTo: discussionId)
        // .where('status', whereIn: [1, 2, 3])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              if (doc.data()['id'] == null) {
                var refMessageCreated = FirebaseFirestore.instance.collection('messages').doc(doc.id);
                refMessageCreated.update({'messageId': doc.id});
              }
              Message messageToDisplay = Message.fromJson(doc.data());

              return messageToDisplay;
            }).toList());
  }

  // Get Messages From List of discussionId
  static Stream<List<Map<String, Object>>> getMessagesFromListOfDiscussion(List<Discussion> discussionList) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('discussionId', whereIn: discussionList.map((d) => d.discussionId).toList())
        // .where('status', whereIn: [1, 2, 3])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              if (doc.data()['id'] == null) {
                var refMessageCreated = FirebaseFirestore.instance.collection('messages').doc(doc.id);
                refMessageCreated.update({'messageId': doc.id});
              }
              Message message = Message.fromJson(doc.data());

              return {
                'discussionId': message.discussionId,
                'message': message,
              };
            }).toList());
  }

  // Get Messages by discussionId
  static Future<List<Map<String, Object>>> getMessagesFromListOfDiscussionAsFuture(
      List<Discussion> discussionList) async {
    final ref = FirebaseFirestore.instance
        .collection('messages')
        .where('discussionId', whereIn: discussionList.map((d) => d.discussionId).toList());
    final snapshot = await ref.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        Message message = Message.fromJson(doc.data());

        return {
          'discussionId': message.discussionId,
          'message': message,
        };
      }).toList();
    }
    return [];
  }

  // Create a new message
  static Future<List> createMessage({
    required context,
    required userSenderId,
    required userReceiverId,
    required Map<String, Object> message,
    required bool isPaymentMessage,
    required int amount,
    required String receiverPhoneNumber,
    required String transactionId,
    required String paymentMethod,
  }) async {
    log('CREATING NEW MESSAGE (+/CHATS)...');
    try {
      bool result = true;
      // Create message and write it to the database : Messages Table
      final refMessage = FirebaseFirestore.instance.collection('messages').doc();
      await refMessage.set(message);

      // Update messageId Field
      var messageId = refMessage.id;
      var refMessageCreated = FirebaseFirestore.instance.collection('messages').doc(messageId);
      await refMessageCreated.update({'messageId': messageId});
      log('Message id is: $messageId');

      // IF DiscussionId is empty, then
      // Create Discussion and write message to the discussionMessages array : Discussions Table
      if ((message['discussionId'] as String) == '') {
        //
        // Get existing discussion between these users
        List<Discussion> listOfExistingDiscussions =
            await getListOfExistingDiscussions(userSenderId: userSenderId, userReceiverId: userReceiverId);

        // IF THERE IS ALREADY AN EXISTING DISCUSSION FOR THESE USERS
        if (listOfExistingDiscussions.isNotEmpty) {
          log('[GO] Continue because there is an existing discussion between these users...');
          String discussionIdToConsider = listOfExistingDiscussions.first.discussionId;

          // Update messageDiscussionId field
          log('messageDiscussionId is: $discussionIdToConsider');
          await refMessageCreated.update({'discussionId': discussionIdToConsider});
        }

        // ELSE IF NO DISCUSSION EXIST BETWEEN THESE USERS
        else {
          log('Creating a new Discussion in Discussion Table (+ add message inside)"...');
          var refNewDiscussion = FirebaseFirestore.instance.collection('discussions').doc();

          // Modeling a new discussion
          Map<String, Object> newDiscussion = Discussion(
            discussionId: refNewDiscussion.id,
            discussionType: '1to1',
            isTypingList: [],
            isRecordingVoiceNoteList: [],
            participants: [
              userSenderId,
              userReceiverId,
              '${userSenderId}_$userReceiverId',
              '${userReceiverId}_$userSenderId'
            ],
            messages: [messageId],
          ).toJson();

          // Set new discussion to Firestore
          refNewDiscussion.set(newDiscussion);

          // Update userReceiverId Discussions Array
          // Update userSenderId Discussions Array
          updateUserSenderAndUserReceiverDiscussionsArray(
            context: context,
            userSenderId: userSenderId,
            userReceiverId: userReceiverId,
            discussionIdtoAdd: refNewDiscussion.id,
          );

          // Update messageDiscussionId field
          log('messageDiscussionId is: ${refNewDiscussion.id}');
          await refMessageCreated.update({'discussionId': refNewDiscussion.id});
        }
      }

      // IF DiscussionId is notEmpty, then
      // Update Discussion and add message to the discussionMessages array : Discussions Table
      else {
        log('Updating Discussion in Discussion Table (+ add message inside)"...');
        var refDiscussionToUpdate =
            FirebaseFirestore.instance.collection('discussions').doc((message['discussionId'] as String));
        await refDiscussionToUpdate.update({
          'messages': FieldValue.arrayUnion([messageId])
        });

        // Update userReceiverId Discussions Array
        // Update userSenderId Discussions Array
        updateUserSenderAndUserReceiverDiscussionsArray(
          context: context,
          userSenderId: userSenderId,
          userReceiverId: userReceiverId,
          discussionIdtoAdd: (message['discussionId'] as String),
        );
      }

      // HANDLE PAYMENT MESSAGE
      //
      if (isPaymentMessage) {
        result = await createPaymentMessage(
          context: context,
          messageId: messageId,
          userReceiverId: userReceiverId,
          userSenderId: userSenderId,
          receiverPhoneNumber: receiverPhoneNumber,
          amount: amount,
          paymentMethod: paymentMethod,
          transactionId: transactionId,
        );
      }

      // Create a new notification
      await createNotification(context, userSenderId, messageId, 'messageCreated');

      if (result == false) {
        showSnackbar(context, 'Une erreur s\'est produite lors de l\'envoi de votre message', null);
        return [false, messageId];
      }

      return [true, messageId];
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de l\'envoi de votre message', null);
      return [false, ''];
    }
  }

  static Future<bool> createPaymentMessage({
    required context,
    required String messageId,
    required String userSenderId,
    required String userReceiverId,
    required int amount,
    required String transactionId,
    required String paymentMethod,
    required String receiverPhoneNumber,
  }) async {
    //
    log('CREATING NEW PAYMENT...');
    try {
      // Modeling a new payment
      Map<String, dynamic> newPayment = Payment(
        paymentId: '',
        messageId: messageId,
        receiverPhoneNumber: receiverPhoneNumber,
        userSenderId: userSenderId,
        userReceiverId: userReceiverId,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        createdAt: DateTime.now(),
        amount: amount,
      ).toJson();

      // Create payment and write it to the database : Payment Table
      final refPayment = FirebaseFirestore.instance.collection('payments').doc();
      await refPayment.set(newPayment);

      // Update paymentId Field
      var paymentId = refPayment.id;
      var refPaymentCreated = FirebaseFirestore.instance.collection('payments').doc(paymentId);
      await refPaymentCreated.update({'paymentId': paymentId});
      log('Payment id is: $paymentId');

      // Update [Related Message] messageId Field
      var refRelatedMessage = FirebaseFirestore.instance.collection('messages').doc(messageId);
      await refRelatedMessage.update({'paymentId': paymentId});
      log('Message [paymentId] is: $paymentId');

      // Create a new notification
      await createNotification(context, userSenderId, messageId, 'paymentCreated');

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future updateUserSenderAndUserReceiverDiscussionsArray(
      {context, userSenderId, userReceiverId, discussionIdtoAdd}) async
  //
  {
    try {
      // Update userSenderId Discussions Array
      log('Updating UserSender "Discussions array"...');
      var refUserSender = FirebaseFirestore.instance.collection('users').doc(userSenderId);
      await refUserSender.update({
        'discussions': FieldValue.arrayUnion([discussionIdtoAdd])
      });

      // Update userReceiverId Discussions Array
      log('Updating UserReceiver "Discussions array"...');
      var refUserReceiver = FirebaseFirestore.instance.collection('users').doc(userReceiverId);
      await refUserReceiver.update({
        'discussions': FieldValue.arrayUnion([discussionIdtoAdd])
      });
    } catch (e) {
      log('Error : $e');
      showSnackbar(context, 'Une erreur s\'est produite lors de l\'envoi de votre message', null);
      return false;
    }
  }

  static Future deleteMessages(
      context, Map<String, Message> messagesSelectedList, bool souldAlsoDeleteAssociatedMessageFiles) async
  //
  {
    log('Messages to delete: $messagesSelectedList');
    try {
      messagesSelectedList.forEach((key, currentMessage) async {
        // IF [My] Message
        if (currentMessage.senderId == FirebaseAuth.instance.currentUser!.uid) {
          //
          log('Deleting [My] message "[+ Related file/thumbnail]"...');

          // Delete message in Firestore
          var refMessage = FirebaseFirestore.instance.collection('messages').doc(currentMessage.messageId);
          await refMessage.delete();

          // Delete attached file in Firestorage
          var refFile = FirebaseStorage.instance.ref('messages/${currentMessage.filename}');
          await refFile.delete();

          // Delete attached thumbnail in Firestorage
          var refThumbnail =
              FirebaseStorage.instance.ref('thumbnails/${transformExtensionToThumbnailExt(currentMessage.filename)}');
          await refThumbnail.delete();
        }
        // IF [Your] Message
        else {
          //
          log('Deleting [Your] message"...');
          var refMessage = FirebaseFirestore.instance.collection('messages').doc(currentMessage.messageId);
          refMessage.update({
            'deleteFor': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
          });
        }

        // Delete Associated Files
        if (souldAlsoDeleteAssociatedMessageFiles) {
          deleteMessageAssociatedFiles(currentMessage);
        }
      });

      return;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite de la suppression', null);
      return;
    }
  }

  //
  static updateMessagesAsRead(List<Message> messagesList) async {
    try {
      // CHECK IF MESSAGE IS UNREAD AND UPDATE IT AND CHECK STATUS
      for (Message message in messagesList) {
        if (message.status != 0 &&
            message.receiverId == FirebaseAuth.instance.currentUser!.uid &&
            !message.read.contains(FirebaseAuth.instance.currentUser!.uid)) {
          debugPrint('Message targetted: ${message.data}');
          // Update message status to 2
          final refMessage = FirebaseFirestore.instance.collection('messages').doc(message.messageId);
          await refMessage.update({
            'read': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
          });
        }
      }
    } catch (e) {
      log('Error in background: $e');
    }
  }

  static updateMessagesAsSeen(Message message) async {
    try {
      // CHECK IF MESSAGE IS UNREAD AND UPDATE IT AND CHECK STATUS

      if (message.status != 0 &&
          message.receiverId == FirebaseAuth.instance.currentUser!.uid &&
          !message.read.contains(FirebaseAuth.instance.currentUser!.uid)) {
        debugPrint('Message targetted: ${message.data}');
        // Update message status to 2
        final refMessage = FirebaseFirestore.instance.collection('messages').doc(message.messageId);
        await refMessage.update({
          'read': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
        });
      }

      // CHECK IF MESSAGE IS UNSEEN AND UPDATE IT AND CHECK STATUS
      if (message.status != 0 &&
          message.receiverId == FirebaseAuth.instance.currentUser!.uid &&
          !message.seen.contains(FirebaseAuth.instance.currentUser!.uid)) {
        debugPrint('Message targetted: ${message.data}');
        // Update message status to 2
        final refMessage = FirebaseFirestore.instance.collection('messages').doc(message.messageId);
        await refMessage.update({
          'seen': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
        });
      }
    } catch (e) {
      debugPrint('Error in background: $e');
    }
  }

  static Future updateIsTypingOrIsRecordingVoiceNoteList(
      {required String discussionId, required String type, required String action}) async {
    // Is TYPING
    // if (type == 'isTyping') {
    //   switch (action) {
    //     case 'add':
    //       //
    //       log('Add to IsTypingList"...');
    //       var refMessage = FirebaseFirestore.instance.collection('discussions').doc(discussionId);
    //       refMessage.update({
    //         'isTypingList': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    //       });
    //       return;
    //     case 'remove':
    //       //
    //       log('Remove from IsTypingList"...');
    //       var refMessage = FirebaseFirestore.instance.collection('discussions').doc(discussionId);
    //       refMessage.update({
    //         'isTypingList': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    //       });
    //       return;
    //   }
    // }

    // Is RecordingVoiceNote
    // else if (type == 'isRecordingVoiceNote') {
    //   switch (action) {
    //     case 'add':
    //       //
    //       log('Add to isRecordingVoiceNoteList"...');
    //       var refMessage = FirebaseFirestore.instance.collection('discussions').doc(discussionId);
    //       refMessage.update({
    //         'isRecordingVoiceNoteList': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    //       });
    //       return;
    //     case 'remove':
    //       //
    //       log('Remove from isRecordingVoiceNoteList"...');
    //       var refMessage = FirebaseFirestore.instance.collection('discussions').doc(discussionId);
    //       refMessage.update({
    //         'isRecordingVoiceNoteList': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    //       });
    //       return;
    //   }
    // }
  }

  ////////////////// NOTIFICATION
  //////////////////
  //////////////////

  // Create Notification and Update Followers Notification Fields
  static Future createNotification(context, uid, contentId, type) async {
    // try {
    //   // Modeling a new notification
    //   NotificationModel.Notification newNotification = NotificationModel.Notification(
    //     notificationId: '',
    //     uid: uid,
    //     type: type,
    //     contentId: contentId,
    //     createdAt: DateTime.now(),
    //   );

    //   // Create Notifications : in Notifications Table
    //   final refNotif = FirebaseFirestore.instance.collection('notifications').doc();
    //   refNotif.set(newNotification.toJson());

    //   // Update NotificationId Field
    //   var notificationId = refNotif.id;
    //   var refNotificationCreated = FirebaseFirestore.instance.collection('notifications').doc(notificationId);
    //   refNotificationCreated.update({'notificationId': notificationId});
    //   log('Notification id is: $notificationId');

    //   // Update Followers Notifications Table
    //   //
    //   //
    //   //

    //   return refNotif.id;
    // } catch (e) {
    //   showSnackbar(context, 'Une erreur s\'est produite lors de la création de la notification', null);
    //   return '';
    // }
  }

  ////////////////// PAYMENT
  //////////////////
  //////////////////

  // Get Payment by paymentId
  static Stream<Payment> getPaymentByPaymentId(String paymentId) {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('paymentId', isEqualTo: paymentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Payment p = Payment.fromJson(doc.data());

              return p;
            }).first);
  }

  ////////////////// REPORT, QUESTION, FEEDBACK
  //////////////////
  //////////////////

  // Send bug report
  static Future sendBugReport(context, Map<String, dynamic> reportToSend) async {
    log('SENDING BUG REPORT...');
    try {
      // Create a bug report and write it down to the database : BugReports Table
      final refBugReport = FirebaseFirestore.instance.collection('bugreports').doc();
      await refBugReport.set(reportToSend);

      // Update bugReportId Field
      var bugReportId = refBugReport.id;
      var refBugReportCreated = FirebaseFirestore.instance.collection('bugreports').doc(bugReportId);
      await refBugReportCreated.update({'bugReportId': bugReportId});
      log('Bug Report Id is: $bugReportId');

      //
      log('Bug Report sent !');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la création du rapport', null);
      return false;
    }
  }

  // Send question
  static Future sendQuestion(context, Map<String, dynamic> questionToSend) async {
    log('SENDING QUESTION...');
    try {
      // Create a question and write it down to the database : Questions Table
      final refQuestion = FirebaseFirestore.instance.collection('questions').doc();
      await refQuestion.set(questionToSend);

      // Update questionId Field
      var questionId = refQuestion.id;
      var refQuestionCreated = FirebaseFirestore.instance.collection('questions').doc(questionId);
      await refQuestionCreated.update({'questionId': questionId});
      log('Question Id is: $questionId');

      //
      log('Question sent !');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite avec votre question', null);
      return false;
    }
  }

  // Send feedback
  static Future sendFeedback(context, Map<String, dynamic> feedbackToSend) async {
    log('SENDING FEEDBACK...');
    try {
      // Create a feedback and write it down to the database : Feedbacks Table
      final refFeedback = FirebaseFirestore.instance.collection('feedbacks').doc();
      await refFeedback.set(feedbackToSend);

      // Update feedbackId Field
      var feedbackId = refFeedback.id;
      var refFeedbackCreated = FirebaseFirestore.instance.collection('feedbacks').doc(feedbackId);
      await refFeedbackCreated.update({'feedbackId': feedbackId});
      log('Feedback Id is: $feedbackId');

      //
      log('Feedback sent !');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite avec votre feedback', null);
      return false;
    }
  }

  ////////////////// OTHERS
  //////////////////
  //////////////////

  // Get user info | Check if User exist
  static Future<usermodel.User?> getUser(uid) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      usermodel.User user = usermodel.User.fromJson(snapshot.data()!);
      return user;
    }
    return null;
  }

  // Get User By Id
  static Stream<usermodel.User> getUserById(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => usermodel.User.fromJson(doc.data())).first);
  }

  // Get user by id : As Future
  static Future<usermodel.User?> getUserByIdAsFuture(userId) async {
    log('Fetching user with userId...');

    var ref = FirebaseFirestore.instance.collection('users').doc(userId);
    var snapshot = await ref.get();
    if (snapshot.exists) {
      return usermodel.User.fromJson(snapshot.data()!);
    }
    return null;
  }

  // Get All User
  static Stream<List<usermodel.User>> getAllUsers() {
    log('Fetching all users...');

    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => usermodel.User.fromJson(doc.data())).toList());
  }

  // Get All User : As Future
  static Future<List<usermodel.User>> getAllUsersAsFuture() async {
    log('Fetching all users...');

    List<usermodel.User> listOfUsers = [];
    final refUsers = FirebaseFirestore.instance.collection('users');
    //
    final snapshot = await refUsers.get();
    if (snapshot.size > 0) {
      for (var element in snapshot.docs) {
        if (element.exists) {
          usermodel.User user = usermodel.User.fromJson(element.data());
          listOfUsers.add(user);
        }
      }
    }
    return listOfUsers;
  }

  // Get All Users : without [ME]
  static Stream<List<usermodel.User>> getAllUsersWithoutMe() {
    debugPrint('Fetching all users...');
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', whereNotIn: [FirebaseAuth.instance.currentUser!.uid])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // Get Users
              return usermodel.User.fromJson(doc.data());
            }).toList());
  }

  // Get User events
  static Stream<List<Event>> getUserEvents(String userId) {
    log('Fetching user events...');

    return FirebaseFirestore.instance
        .collection('events')
        .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList());
  }

  // Get User Reminders
  static Stream<List<Reminder>> getUserReminders(String userId) {
    log('Fetching user reminders...');

    return FirebaseFirestore.instance
        .collection('reminders')
        .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Reminder.fromJson(doc.data())).toList());
  }

  // Get User Forevers
  static Stream<List<Forever>> getUserForevers(String userId) {
    log('Fetching user forevers...');

    return FirebaseFirestore.instance
        .collection('forevers')
        .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Forever.fromJson(doc.data())).toList());
  }

  // Get all events
  static Stream<List<Event>> getAllEvents() {
    log('Fetching all events...');

    return FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList());
  }

  // Get user by userPosterId in List
  static Stream<List<usermodel.User>> getUserByIdInList(List<String> userIdList) {
    log('Fetching [Reminders] by userPosterId in List...');

    return FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: userIdList)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => usermodel.User.fromJson(doc.data())).toList());
  }

  // Get event by userPosterId in List
  static Stream<List<Event>> getEventsByUserPosterIdInList(List<String> userPosterIdList) {
    log('Fetching [Events] by userPosterId in List...');

    return FirebaseFirestore.instance
        .collection('events')
        .where('uid', whereIn: userPosterIdList)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList());
  }

  // Get reminder by userPosterId in List
  static Stream<List<Reminder>> getRemindersByUserPosterIdInList(List<String> userPosterIdList) {
    log('Fetching [Reminders] by userPosterId in List...');

    return FirebaseFirestore.instance
        .collection('reminders')
        .where('uid', whereIn: userPosterIdList)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Reminder.fromJson(doc.data())).toList());
  }

  // Get story by [Non-expired] userPosterId in List
  static Stream<List<Story>> getNonExpiredStoriesByUserPosterIdInList(List<String> userPosterIdList) {
    log('Fetching [Non-Expired Stories] by userPosterId in List...');

    return FirebaseFirestore.instance.collection('stories').where('uid', whereIn: userPosterIdList).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Story.fromJson(doc.data()))
            .toList()
            .where((story) => !hasStoryExpired(story.endAt))
            .toList());
  }

  // Get event by id
  static Stream<Event> getEventById(String eventId) {
    return FirebaseFirestore.instance
        .collection('events')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromJson(doc.data())).first);
  }

  // Get event by EventId : As Future
  static Future<Event?> getEventByIdAsFuture(eventId) async {
    log('Fetching event with EventId...');

    var ref = FirebaseFirestore.instance.collection('events').doc(eventId);
    var snapshot = await ref.get();
    if (snapshot.exists) {
      Event event = Event.fromJson(snapshot.data()!);
      return event;
    }
    return null;
  }

  // Get event reminders by id
  static Stream<List<Reminder>> getEventRemindersById(String eventId, String userId) {
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('eventId', isEqualTo: eventId)
        .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Reminder.fromJson(doc.data())).toList());
  }

  // Get event by id
  static Stream<Reminder> getReminderById(String reminderId) {
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('reminderId', isEqualTo: reminderId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Reminder.fromJson(doc.data())).first);
  }

// Get Reminder by Id : As Future
  static Future<Reminder?> getReminderByIdAsFuture(reminderId) async {
    log('Fetching reminder with ReminderId...');

    var ref = FirebaseFirestore.instance.collection('reminders').doc(reminderId);
    var snapshot = await ref.get();
    if (snapshot.exists) {
      Reminder reminder = Reminder.fromJson(snapshot.data()!);
      return reminder;
    }
    return null;
  }

  // Get any User Stories : As Future
  static Future<List<Story>> getUserNonExpiredStoriesAsFuture(uid) async {
    List<Story> listOfNonExpiredStories = [];
    final refNonExpiredStories = FirebaseFirestore.instance.collection('stories').where('uid', isEqualTo: uid);
    //
    final snapshot = await refNonExpiredStories.get();
    if (snapshot.size > 0) {
      for (var element in snapshot.docs) {
        if (element.exists) {
          Story story = Story.fromJson(element.data());

          if (!hasStoryExpired(story.endAt)) {
            listOfNonExpiredStories.add(story);
          }
        }
      }
    }
    return listOfNonExpiredStories;
  }

  // Get any User Stories []
  static Stream<List<Story>> getUserAllStories(uid) {
    return FirebaseFirestore.instance
        .collection('stories')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Story.fromJson(doc.data())).toList());
  }

  // Get Story by id
  static Stream<Story> getStoryById(String storyId) {
    return FirebaseFirestore.instance
        .collection('stories')
        .where('storyId', isEqualTo: storyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Story.fromJson(doc.data())).first);
  }

  // Get Story by Id : As Future
  static Future<Story?> getStoryByIdAsFuture(String storyId) async {
    final ref = FirebaseFirestore.instance.collection('stories').where('storyId', isEqualTo: storyId);
    final snapshot = await ref.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        return Story.fromJson(doc.data());
      }).first;
    }
    return null;
  }

  // Get Payment by senderId
  static Stream<List<Payment>> getPaymentBySenderId(String userId) {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('userSenderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Payment.fromJson(doc.data())).toList());
  }

  // Get Payment by receiverId
  static Stream<List<Payment>> getPaymentByReceiverId(String userId) {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('userReceiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Payment.fromJson(doc.data())).toList());
  }

  // Update Current User Name
  Future updateCurrentUserName(context, String name) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await ref.update({'name': name});
      return name;
    } catch (e) {
      log('Error: $e');
      showSnackbar(context, 'Une erreur s\'est produite', null);
    }
  }

  // Update Current User Name
  Future updateCurrentUserBirthday(context, DateTime date) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await ref.update({'birthday': date});
      return date;
    } catch (e) {
      log('Error: $e');
      showSnackbar(context, 'Une erreur s\'est produite', null);
    }
  }

  // Update Current User Profile Picture to DB
  static Future updateCurrentUserProfilePictureToDB(context, dowloadurl) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await ref.update({'profilePicture': dowloadurl});
      return dowloadurl;
    } catch (e) {
      log('Error: $e');
      showSnackbar(context, 'Une erreur s\'est produite', null);
    }
  }
}

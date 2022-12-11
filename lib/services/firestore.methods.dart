import 'dart:developer';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:provider/provider.dart';
import 'package:wesh/models/notification.dart' as NotificationModel;
import 'package:wesh/providers/user.provider.dart';
import 'package:wesh/services/internet_connection_checker.dart';
import '../main.dart';
import '../models/discussion.dart';
import '../models/event.dart';
import '../models/forever.dart';
import '../models/message.dart';
import '../models/payment.dart';
import '../models/reminder.dart';
import '../models/story.dart';
import '../models/user.dart' as UserModel;
import '../utils/functions.dart';
import '../utils/globals.dart' as globals;

class FirestoreMethods {
  // Create a new user
  Future createUser(context, uid, Map<String, Object?> user) async {
    log('CREATING NEW USER...');
    try {
      // Ref to doc
      final docUser = FirebaseFirestore.instance.collection('users').doc(uid);
      log('DOC USER IS: $docUser');

      // Create document and write it to the database
      await docUser.set(user);
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite : $e', null);
    }
  }

  // Update user with specific fields
  Future<bool> updateUserWithSpecificFields(context, uid, Map<String, Object?> fieldsToUpload) async {
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

  //////////////////  EVENT
  //////////////////
  //////////////////

  // Create a new event
  Future<bool> createEvent(context, uid, Map<String, Object?> event) async
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
  Future<bool> updateEvent(context, eventId, Map<String, Object?> eventToUpdate) async
  //
  {
    log('UPDATING EXISTING EVENT...');
    try {
      // Update event and write it to the database : Events Table
      final refEvent = FirebaseFirestore.instance.collection('events').doc(eventId);
      await refEvent.update(eventToUpdate);

      // UPDATE ALL RELATED REMINDERS: if event is not user birthday
      // TODO

      // Create a new notification : updated
      await createNotification(context, FirebaseAuth.instance.currentUser!.uid, eventId, 'eventUpdated');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la modification de l\'évènement', null);
      return false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(context, eventId, userPosterId) async {
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
  Future createReminder(context, uid, Map<String, Object?> reminder) async
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

      // Create a new notification
      await createNotification(context, uid, reminderid, 'reminderCreated');

      //
      log('Reminder created (+notification) !');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la création du rappel', null);
      return false;
    }
  }

  // Update an existing event
  Future<bool> updateReminder(context, reminderId, Map<String, Object?> reminderToUpdate) async
  //
  {
    log('UPDATING EXISTING REMINDER...');
    try {
      // Update reminder and write it to the database : Reminders Table
      final refReminder = FirebaseFirestore.instance.collection('reminders').doc(reminderId);
      await refReminder.update(reminderToUpdate);

      // Create a new notification : updated
      await createNotification(context, FirebaseAuth.instance.currentUser!.uid, reminderId, 'reminderUpdated');

      //
      log('Reminder updated !');
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la modification du rappel', null);
      return false;
    }
  }

  // Delete reminder
  Future<bool> deleteReminder(context, reminderId, userPosterId) async {
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
      return true;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite lors de la suppression du rappel', null);
      return false;
    }
  }

  ////////////////// STORY
  //////////////////
  //////////////////

  // Create a new story
  Future<bool> createStory(context, uid, Map<String, Object?> story) async {
    log('CREATING NEW STORY...');
    try {
      // Create story and write it to the database : Stories Table
      final refStory = FirebaseFirestore.instance.collection('stories').doc();
      await refStory.set(story);

      // Update StoryId Field
      var storyId = refStory.id;
      var refStoryCreated = FirebaseFirestore.instance.collection('stories').doc(storyId);
      await refStoryCreated.update({'storyId': storyId});
      log('Event id is: $storyId');

      // Update User_creator Stories Array
      log('Updating User "Stories field"...');
      var refUser = FirebaseFirestore.instance.collection('users').doc(uid);
      await refUser.update({
        'stories': FieldValue.arrayUnion([storyId])
      });

      // Update User_creator lastStoryUpdateDateTime field
      log('Updating User "Last Story UpdateDateTime field"...');
      await refUser.update({
        'lastStoryUpdateDateTime': DateTime.now().toIso8601String(),
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
  Future updateStoryViewersList(context, uid, storyId) async {
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
  Future<bool> deleteStory(context, storyId, userPosterId) async {
    log('DELETING STORY...');
    try {
      // Delete story : in Stories Table
      final refStory = FirebaseFirestore.instance.collection('stories').doc(storyId);
      await refStory.delete();

      // Delete story : in UserPoster Stories array
      var refUser = FirebaseFirestore.instance.collection('users').doc(userPosterId);
      await refUser.update({
        'stories': FieldValue.arrayRemove([storyId])
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

              // Check if the storyId already exists, then Add
              if (foreverStories.contains(storyId)) {
                await refForever.update({
                  'stories': FieldValue.arrayRemove([storyId])
                });
                log('Story removed to the Forever !');
              }

              log('Forever stories list updated !');
            }
          });
        }).toList();
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

  // Create forever
  Future createForever(context, uid, Map<String, Object?> forever) async {
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
  Future<bool> updateForever(context, foreverId, Map<String, Object?> foreverToUpdate) async
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
  Future AddOrDeleteStoryInsideForever(context, storyId, foreverId) async {
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
  Future<bool> deleteForever(context, foreverId, userPosterId) async {
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
  Stream<Discussion>? getDiscussionById(String discussionId) {
    if (discussionId == '') return null;
    return FirebaseFirestore.instance
        .collection('discussions')
        .doc(discussionId)
        .snapshots()
        .map((snapshot) => Discussion.fromJson(snapshot.data()!));
  }

  ////////////////// MESSAGE
  //////////////////
  //////////////////

  // Get [Future] any Message by Id
  Future<Message?> getMessageByIdAsFuture(messageId) async {
    final ref = FirebaseFirestore.instance.collection('messages').doc(messageId);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return Message.fromJson(snapshot.data()!);
    }
    return null;
  }

  // Get list of Existing Discussions
  Future<List<Discussion>> getListOfExistingDiscussions(
      {required String userSenderId, required String userReceiverId}) async {
    List<Discussion> listOfExistingDiscussions = [];
    final refDiscussions = FirebaseFirestore.instance.collection('discussions').where('participants', whereIn: [
      [userSenderId, userReceiverId, '${userSenderId}_$userReceiverId', '${userReceiverId}_$userSenderId']
    ]);
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
  Stream<List<Message>?> getMessagesByDiscussionId(String discussionId) {
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

  // Get Messages by discussionId
  Stream<List<Map<String, Object>>> getMessagesFromListOfDiscussion(List<Discussion> discussionList) {
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
  Future<List<Map<String, Object>>> getMessagesFromListOfDiscussionAsFuture(List<Discussion> discussionList) async {
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
  Future<List> createMessage({
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

  Future<bool> createPaymentMessage({
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
      bool result = false;

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

  Future updateUserSenderAndUserReceiverDiscussionsArray(
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

  Future deleteMessages(
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

      //
      // TODO:
      //
      // Set back LastValidMessage && LastInvalidMessage

      return;
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite de la suppression', null);
      return;
    }
  }

  //
  void updateMessagesToStatus2(List<String> messagesIds) async {
    try {
      List<Message> messagesList = [];

      // Get messages by messageById

      for (String messageId in messagesIds) {
        // print("Msg: $messageId");
        Message? message = await FirestoreMethods().getMessageByIdAsFuture(messageId);

        if (message != null) messagesList.add(message);
      }

      // Update message Status to 2
      for (Message message in messagesList) {
        if (message.status == 1 && message.receiverId == FirebaseAuth.instance.currentUser!.uid) {
          print('Message targetted: ${message.data}');
          // Update message status to 1
          final refMessage = FirebaseFirestore.instance.collection('messages').doc(message.messageId);
          await refMessage.update({
            'status': 2,
          });
        }
      }
    } catch (e) {
      print('Error in background: $e');
    }
  }

  void updateMessagesToStatus3(List<String> messagesIds) async {
    try {
      List<Message> messagesList = [];

      // Get messages by messageById

      for (String messageId in messagesIds) {
        // print("Msg: $messageId");
        Message? message = await FirestoreMethods().getMessageByIdAsFuture(messageId);

        if (message != null) messagesList.add(message);
      }

      // Update message Status to 3
      for (Message message in messagesList) {
        if (message.status == 2 ||
            message.status == 1 && message.receiverId == FirebaseAuth.instance.currentUser!.uid) {
          print('Message targetted: ${message.data}');
          // Update message status to 2
          final refMessage = FirebaseFirestore.instance.collection('messages').doc(message.messageId);
          await refMessage.update({
            'status': 3,
          });
        }
      }
    } catch (e) {
      print('Error in background: $e');
    }
  }

  Future updateIsTypingOrIsRecordingVoiceNoteList(
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
  Future createNotification(context, uid, contentId, type) async {
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
    //   // TODO:
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
  Stream<Payment> getPaymentByPaymentId(String paymentId) {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('paymentId', isEqualTo: paymentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Payment p = Payment.fromJson(doc.data());

              return p;
            }).first);
  }

  ////////////////// BUG REPORT, QUESTION, FEEDBACK
  //////////////////
  //////////////////

  // Send bug report
  Future sendBugReport(context, Map<String, Object?> reportToSend) async {
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
  Future sendQuestion(context, Map<String, Object?> questionToSend) async {
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
  Future sendFeedback(context, Map<String, Object?> feedbackToSend) async {
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
  Future<UserModel.User?> getUser(uid) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      UserModel.User user = UserModel.User.fromJson(snapshot.data()!);
      return user;
    }
    return null;
  }

  // Get User By Id
  Stream<UserModel.User> getUserById(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.User.fromJson(doc.data())).first);
  }

  // Get All User
  Stream<List<UserModel.User>> getAllUsers() {
    log('Fetching all users...');

    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.User.fromJson(doc.data())).toList());
  }

  // Get all events
  Stream<List<Event>> getAllEvents() {
    log('Fetching all events...');

    return FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList());
  }

  // Get event by id
  Stream<Event> getEventById(String eventId) {
    return FirebaseFirestore.instance
        .collection('events')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromJson(doc.data())).first);
  }

  // Get event by EventId : As Future
  Future<Event?> getEventByIdAsFuture(eventId) async {
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
  Stream<List<Reminder>> getEventRemindersById(String eventId, String userId) {
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('eventId', isEqualTo: eventId)
        .where('uid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Reminder.fromJson(doc.data())).toList());
  }

  // Get event by id
  Stream<Reminder> getReminderById(String reminderId) {
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('reminderId', isEqualTo: reminderId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Reminder.fromJson(doc.data())).first);
  }

// Get Reminder by Id : As Future
  Future<Reminder?> getReminderByIdAsFuture(reminderId) async {
    log('Fetching reminder with ReminderId...');

    var ref = FirebaseFirestore.instance.collection('reminders').doc(reminderId);
    var snapshot = await ref.get();
    if (snapshot.exists) {
      Reminder reminder = Reminder.fromJson(snapshot.data()!);
      return reminder;
    }
    return null;
  }

  // Get Story by id
  Stream<Story> getStoryById(String storyId) {
    return FirebaseFirestore.instance
        .collection('stories')
        .where('storyId', isEqualTo: storyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Story.fromJson(doc.data())).first);
  }

  // Get Story by Id : As Future
  Future<Story?> getStoryByIdAsFuture(String storyId) async {
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
  Stream<List<Payment>> getPaymentBySenderId(String userId) {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('userSenderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Payment.fromJson(doc.data())).toList());
  }

  // Get Payment by receiverId
  Stream<List<Payment>> getPaymentByReceiverId(String userId) {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('userReceiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Payment.fromJson(doc.data())).toList());
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

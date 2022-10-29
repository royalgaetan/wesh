import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wesh/models/forever.dart';
import 'package:wesh/models/reminder.dart';
import 'package:wesh/models/story.dart';
import 'package:wesh/utils/functions.dart';
import '../models/event.dart';
import '../models/user.dart' as UserModel;
import 'package:wesh/services/firestore.methods.dart';

class UserProvider with ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  var userUid = FirebaseAuth.instance.currentUser!.uid;

  String phoneCodeVerification = '';

  ////////////////// CURRENT USER
  //////////////////
  //////////////////

  // Get current user
  // get getCurrentUser => currentUser;

  Stream<UserModel.User?> getCurrentUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => UserModel.User.fromJson(snapshot.data()!));
  }

  // Get current user events
  Stream<List<Event>> getCurrentUserEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList());
  }

  // Get current user reminders
  Stream<List<Reminder>> getCurrentUserReminders() {
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Reminder.fromJson(doc.data())).toList());
  }

  // Get current user reminders
  Stream<List<Forever>> getCurrentUserForevers() {
    return FirebaseFirestore.instance
        .collection('forevers')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // Get Forevers
              return Forever.fromJson(doc.data());
            }).toList());
  }

  ////////////////// ANY USERS, EVENTS, STORIES, FOREVERS...
  //////////////////
  //////////////////

// Get any User by Id
  Stream<UserModel.User?> getUserById(uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => UserModel.User.fromJson(snapshot.data()!));
  }

// Get [Future] User by id
  Future<UserModel.User?> getFutureUserById(uid) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      UserModel.User user = UserModel.User.fromJson(snapshot.data()!);
      return user;
    }
    return null;
  }

// Get [Future] any User Birthday
  Future<Event?> getUserBirthday(uid) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      UserModel.User user = UserModel.User.fromJson(snapshot.data()!);
      return user.stories!.first;
    }
    return null;
  }

  // Get any Event by Id
  Future<Event?> getEventById(eventId) async {
    final ref = FirebaseFirestore.instance
        .collection('events')
        .where('eventId', isEqualTo: eventId);
    final snapshot = await ref.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        return Event.fromJson(doc.data());
      }).first;
    }
    return null;
  }

  // Get any User Stories
  Stream<List<Story>> getUserStories(uid) {
    return FirebaseFirestore.instance
        .collection('stories')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Story.fromJson(doc.data())).toList());
  }

  // Get any Forever Stories
  Future<List<Story>?> getFovererStories(Forever forever) async {
    List<Story>? foreverStories = [];
    for (String storyId in forever.stories) {
      final ref = FirebaseFirestore.instance
          .collection('stories')
          .where('storyId', isEqualTo: storyId);
      final snapshot = await ref.get();
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.map((doc) {
          foreverStories.add(
            Story.fromJson(doc.data()),
          );
        }).first;
      }
    }
    return foreverStories;
  }

  // Get Story by Id
  Future<Story?> getStoryById(storyId) async {
    final ref = FirebaseFirestore.instance
        .collection('stories')
        .where('storyId', isEqualTo: storyId);
    final snapshot = await ref.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        return Story.fromJson(doc.data());
      }).first;
    }
    return null;
  }

  // Get Users Forevers
  Stream<List<Forever>> getForevers(String uid) {
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
  Future<Widget?> getForeverCoverByFirstStoryId(storyId) async {
    final ref = FirebaseFirestore.instance
        .collection('stories')
        .where('storyId', isEqualTo: storyId);
    final snapshot = await ref.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        Story story = Story.fromJson(doc.data());
        return getStoryGridPreviewByType(story);
      }).first;
    }
    return null;
  }

  // Get Users in the List
  Stream<List<UserModel.User>> getUsersInTheGivenList(List usersId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: usersId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // Get Users
              return UserModel.User.fromJson(doc.data());
            }).toList());
  }

  // Get other any user info
  // Get any user name
  // Get any user birthday
  // Get any user ...
  // TODO:

}

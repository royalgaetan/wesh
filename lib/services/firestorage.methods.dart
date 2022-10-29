import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wesh/services/firestore.methods.dart';

import '../utils/functions.dart';

class FireStorageMethods {
  Future<String> uploadimageToProfilePic(context, String filepath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    if (filepath == '') {
      var ref = FirebaseStorage.instance
          .ref('profilepictures/default_profile_picture.jpg');
      //  Update Firestore
      String downloadUrl = await ref.getDownloadURL();
      await FirestoreMethods()
          .updateCurrentUserProfilePictureToDB(context, downloadUrl);
      Navigator.of(context).pop();
      return downloadUrl;

      //
    } else if (filepath.isNotEmpty) {
      File file = File(filepath);
      String finalName =
          'profilepic_${FirebaseAuth.instance.currentUser!.uid}.jpg';
      try {
        // Compress File
        // TODO: Compress file function here
        //
        //
        //

        // Upload to FireStorage
        var ref = FirebaseStorage.instance.ref('profilepictures/$finalName');
        await ref.putFile(file);
        debugPrint("ref is: $ref");

        //  Update Firestore
        String downloadUrl = await ref.getDownloadURL();
        await FirestoreMethods()
            .updateCurrentUserProfilePictureToDB(context, downloadUrl);
        Navigator.of(context).pop();

        //
        return downloadUrl;
      } catch (e) {
        debugPrint("Error : $e");

        showSnackbar(context, 'Une erreur s\'est produite', null);
        return '';
      }
    }
    return '';
  }

  Future<String> uploadimageToEventCover(context, String filepath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );
    String downloadUrl = '';
    if (filepath == '') {
      Navigator.of(context).pop();
      return downloadUrl;
    } else if (filepath.isNotEmpty) {
      File file = File(filepath);
      String finalName = 'eventcover_${const Uuid().v4()}.jpg';
      try {
        // Compress File
        // TODO: Compress file function here
        //
        //
        //

        // Upload to FireStorage
        var ref = FirebaseStorage.instance.ref('eventCovers/$finalName');
        await ref.putFile(file);
        debugPrint("ref is: $ref");
        Navigator.of(context).pop();

        downloadUrl = await ref.getDownloadURL();

        return downloadUrl;
      } catch (e) {
        showSnackbar(context, 'Une erreur s\'est produite : $e', null);
        downloadUrl = '';
        return downloadUrl;
      }
    }
    return downloadUrl;
  }

  Future<String> uploadStoryContent(
      context, dynamic filepath, String type) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    File file = File(filepath);
    String finalName = '';
    String downloadUrl = '';
    String extension = '';

    if (filepath == '') {
      Navigator.of(context).pop();
      return downloadUrl;
    }
    //
    else if (filepath.isNotEmpty) {
      if (type == 'video') {
        extension = 'mp4';
        finalName = 'story_video_${const Uuid().v4()}.$extension';
      }
      //
      else if (type == 'image') {
        extension = 'jpg';
        finalName = 'story_image_${const Uuid().v4()}.$extension';
      }
      //
      else if (type == 'vidThumbnail') {
        extension = 'png';
        finalName = 'story_videoThumbnail_${const Uuid().v4()}.$extension';
      }

      try {
        // Compress File
        // TODO: Compress file function here
        //
        //
        //

        // Upload to FireStorage
        var ref = FirebaseStorage.instance.ref('stories/$finalName');
        await ref.putFile(file);
        debugPrint("ref is: $ref");
        Navigator.of(context).pop();

        downloadUrl = await ref.getDownloadURL();

        return downloadUrl;
      } catch (e) {
        debugPrint('Erreur: $e');
        showSnackbar(context, 'Une erreur s\'est produite', null);
        downloadUrl = '';
        return downloadUrl;
      }
    }
    return downloadUrl;
  }
}

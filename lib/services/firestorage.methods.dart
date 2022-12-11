import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/services/internet_connection_checker.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';

class FireStorageMethods {
  Future<String> uploadimageToProfilePic(context, String filepath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    if (filepath == '') {
      var ref = FirebaseStorage.instance.ref('profilepictures/default_profile_picture.jpg');
      //  Update Firestore
      String downloadUrl = await ref.getDownloadURL();
      await FirestoreMethods().updateCurrentUserProfilePictureToDB(context, downloadUrl);
      Navigator.of(context).pop();
      return downloadUrl;

      //
    } else if (filepath.isNotEmpty) {
      File file = File(filepath);
      String finalName = 'profilepic_${FirebaseAuth.instance.currentUser!.uid}.jpg';
      try {
        // Compress File
        // TODO: Compress file function here
        //
        //
        //

        // Upload to FireStorage
        var ref = FirebaseStorage.instance.ref('profilepictures/$finalName');
        await ref.putFile(file);
        log("ref is: $ref");

        //  Update Firestore
        String downloadUrl = await ref.getDownloadURL();
        await FirestoreMethods().updateCurrentUserProfilePictureToDB(context, downloadUrl);
        Navigator.of(context).pop();

        //
        return downloadUrl;
      } catch (e) {
        log("Error : $e");

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
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
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
        var ref = FirebaseStorage.instance.ref('eventcovers/$finalName');
        await ref.putFile(file);
        log("ref is: $ref");
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

  ////////////////// MESSAGE
  //////////////////
  //////////////////

  Stream<num> uploadMessageFile({
    required BuildContext context,
    required String filepath,
    required String messageId,
    required String discussionId,
    required String type,
    required String thumbnailPath,
    required StreamController<bool> cancelStreamController,
  }) async*
  //
  {
    StreamController<num> progressStreamController = StreamController();
    StreamSubscription<bool> cancelHandlerSubscription;
    bool cancelValue = false;
    yield 0;

    cancelStreamController.stream.listen((value) async {
      cancelValue = value;
    });

    // // Compress file
    // File compressedFile = await FlutterNativeImage.compressImage(file.path, quality: 80, percentage: 50);

    // Get file info
    File file = File(filepath);
    String fileNameAndExtension = basename(filepath);
    print('File: $file');
    print('File & ext. : $fileNameAndExtension');

    // Get thumbnail info
    File thumbailFile = File(thumbnailPath);
    String thumbnailFileNameAndExtension = basename(thumbnailPath);
    print('Thumbnail: $thumbnailPath');
    print('Thumbnail & ext. : $thumbnailFileNameAndExtension');

    String downloadUrl = '';
    String thumbnailDownloadUrl = '';

    // Check Internet Connection
    var isConnected = await InternetConnection().isConnected(context);
    if (!isConnected) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
      log("Has connection : $isConnected");
      progressStreamController.add(-1);
      yield* progressStreamController.stream;
      return;
    }

    // Check file existence
    if (file.existsSync() == false) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Ce fichier n\'existe plus !', null);
      log('FILE is : $fileNameAndExtension');
      progressStreamController.add(-1);
      yield* progressStreamController.stream;
      return;
    }

    // Check thumbailFile existence : Only for Video or Image File
    if (type == 'image' || type == 'video') {
      if (thumbailFile.existsSync() == false) {
        // ignore: use_build_context_synchronously
        showSnackbar(context, 'Une erreur s\'est produite avec le fichier !', null);
        log('THUMBNAIL DOESN\'T EXIST !');
        progressStreamController.add(-1);
        yield* progressStreamController.stream;
        return;
      }
    }

    // Check file size : limit to 15MB
    if (file.lengthSync() > fileLimitSize) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Votre fichier ne doit pas dépasser 15MB', null);
      log('FILE SIZE ${file.lengthSync() / 1000000}');
      progressStreamController.add(-1);
      yield* progressStreamController.stream;
      return;
    }

    // // Upload file
    var ref = FirebaseStorage.instance.ref('messages/$fileNameAndExtension');
    Task putFileTask = ref.putFile(file);

    // Listen: Cancel Stream to cancel the uploading
    cancelHandlerSubscription = cancelStreamController.stream.listen((cancelValue) async {
      cancelValue = cancelValue;
      if (cancelValue == true) {
        log("Uploading Cancelled !");
        try {
          bool valuePutFileTask = await putFileTask.cancel();
          // bool valuePutThumbnailFileTask = await putThumbnailFileTask.cancel();
          print('Put File Task: $putFileTask');
          // print('Put Thumbnail File Task: $valuePutThumbnailFileTask');
          return;
        } catch (e) {
          print('Error while uploading file: $e');
        }
      }
    });

    // Continue uploading
    putFileTask.snapshotEvents.listen((event) async {
      print("Bytes: ${event.bytesTransferred}");
      // Increase progressValue : up to 70x
      progressStreamController.add(event.bytesTransferred.toDouble() / event.totalBytes.toDouble() * 70);

      if (file.lengthSync() == event.bytesTransferred) {
        downloadUrl = await ref.getDownloadURL();

        // Upload Thumbnail Only for Video or Image File
        if (type == 'image' || type == 'video') {
          // Upload thumbnail
          var refThumbnail = FirebaseStorage.instance.ref('thumbnails/$thumbnailFileNameAndExtension');
          Task putThumbnailFileTask = refThumbnail.putFile(thumbailFile);

          putThumbnailFileTask.snapshotEvents.listen((event) async {
            print('Thumbnail Bytes tranfered : ${event.bytesTransferred}');
            // Increase progressValue : up to 22x
            progressStreamController.add((event.bytesTransferred.toDouble() / event.totalBytes.toDouble() * 22) + 70);

            if (thumbailFile.lengthSync() == event.bytesTransferred) {
              thumbnailDownloadUrl = await refThumbnail.getDownloadURL();
              print('Thumbnail Download URL : $thumbnailDownloadUrl');
            }
          });
        }

        //

        // Increase progressValue : up to 95
        progressStreamController.add(95);

        // Update discussionLastMessageInfo
        var refDiscussionToUpdate = FirebaseFirestore.instance.collection('discussions').doc(discussionId);

        if (cancelValue == false) {
          await refDiscussionToUpdate.update({
            'lastValidMessagePosterId': FirebaseAuth.instance.currentUser!.uid,
            'lastValidMessageDateTime': DateTime.now(),
            'lastValidMessageId': messageId,
          });
        }

        // Increase progressValue : up to 98 - 99
        progressStreamController.add(98);
        progressStreamController.add(99);

        // Increase progressValue : up to 100
        progressStreamController.add(100);

        // Update message data
        // Update message thumbnail
        // Update message status to 1
        final refMessage = FirebaseFirestore.instance.collection('messages').doc(messageId);
        await refMessage.update({
          'status': cancelValue == true ? 0 : 1,
          'data': cancelValue == true ? '' : downloadUrl,
          'thumbnail': cancelValue == true ? '' : thumbnailDownloadUrl,
        });
        cancelValue = true;
      }
    });

    // END

    yield* progressStreamController.stream;
  }

  ////////////////// STORY
  //////////////////
  //////////////////

  Future<String> uploadStoryContent(context, dynamic filepath, String type) async
  //
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
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
        log("ref is: $ref");
        Navigator.of(context).pop();

        downloadUrl = await ref.getDownloadURL();

        return downloadUrl;
      } catch (e) {
        log('Erreur: $e');
        showSnackbar(context, 'Une erreur s\'est produite', null);
        downloadUrl = '';
        return downloadUrl;
      }
    }
    return downloadUrl;
  }
}

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wesh/services/firestore.methods.dart';

import '../utils/functions.dart';

class FireStorageMethods {
  Future uploadimageToProfilePic(context, String filepath) async {
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
        print("ref is: $ref");

        //  Update Firestore
        String downloadUrl = await ref.getDownloadURL();
        await FirestoreMethods()
            .updateCurrentUserProfilePictureToDB(context, downloadUrl);
        Navigator.of(context).pop();

        //
      } catch (e) {
        showSnackbar(context, 'Une erreur s\'est produite : $e', null);
      }
    }
  }
}

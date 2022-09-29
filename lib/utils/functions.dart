import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_number/phone_number.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../pages/auth.pages/otp.dart';
import '../services/sharedpreferences.service.dart';

// DATE PICKER
Future<DateTime?> pickDate(
    {required BuildContext context, initialDate, firstDate, lastDate}) async {
  var _initialDate = initialDate ?? DateTime.now();
  var _firstDate = firstDate ?? DateTime.now();
  var _lastDate = lastDate ?? DateTime.now().add(const Duration(days: 10000));

  final newDate = await showDatePicker(
      cancelText: 'ANNULER',
      helpText: 'Selectionner une date',
      fieldLabelText: 'Entrer une date',
      errorInvalidText: 'Date invalide, veuillez réessayer !',
      errorFormatText: 'Date invalide, veuillez réessayer !',
      context: context,
      initialDate: _initialDate,
      firstDate: _firstDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      lastDate: _lastDate);
  return newDate;
}

// TIME PICKER
//
//
//
//
//

// Launch URL (External Browser)
Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}

// Get Video Thumbnail
getVideoThumbnail(data) async {
  final uint8list = await VideoThumbnail.thumbnailData(
    video: data,
    imageFormat: ImageFormat.PNG,
    maxWidth:
        128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    quality: 25,
  );

  // print("Vid Thumbnail is: $uint8list");
  return uint8list;
}

// Get Duration Label
String getDurationLabel(Duration duration) {
  if (duration == const Duration(hours: 1)) {
    return '1h avant';
  } else if (duration == const Duration(days: 1)) {
    return '1 jour avant';
  } else if (duration == const Duration(days: 7)) {
    return '1 semaine avant';
  } else if (duration == const Duration(days: 30)) {
    return '1 mois avant';
  } else if (duration == null) {
    return 'Aucun rappel';
  }

  return 'Aucun rappel';
}

// Show Snackbar
showSnackbar(context, message, color) {
  var _color = color ?? Colors.black87;

  var snackBar = SnackBar(
    content: Text(message),
    backgroundColor: _color,
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
}) async {
  // Validate
  bool isValid = await PhoneNumberUtil()
      .validate(phoneContent, regionCode: regionCode)
      .onError(
        (error, stackTrace) =>
            showSnackbar(context, 'Votre numéro est incorrect !', null),
      );
  print('Is phone number valid: $isValid');

  if (isValid) {
    await UserSimplePreferences.setPhone('+${phoneCode}${phoneContent}');
    await UserSimplePreferences.setCountry(countryName);

    return true;
  } else {
    return false;
  }
}

// Returns true if email address is in use.
Future<bool> checkIfEmailInUse(context, String emailAddress) async {
  try {
    // Fetch sign-in methods for the email address
    final list =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

    // In case list is not empty
    if (list.isNotEmpty) {
      // Return true because there is an existing
      // user using the email address
      return true;
    } else {
      // Return false because email adress is not in use
      return false;
    }
  } catch (error) {
    // Handle error
    // ...
    showSnackbar(context, 'Une erreur s\'est produite : $error', null);
    return true;
  }
}

// Returns true if phone number is in use.
Future<bool> checkIfPhoneNumberInUse(context, String phoneNumber) async {
  try {
    var finalValue;
    // Fetch all phone number in DB
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length > 0) {
      //exists
      finalValue = true;
    } else {
      //not exists
      finalValue = false;
    }

    if (finalValue) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    // Handle error
    // ...
    showSnackbar(context, 'Une erreur s\'est produite : $error', null);
    return true;
  }
}

// Returns true if username is in use.
Future<bool> checkIfUsernameInUse(context, String username) async {
  try {
    var finalValue;
    // Fetch all username in DB
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length > 0) {
      //exists
      finalValue = true;
    } else {
      //not exists
      finalValue = false;
    }

    if (finalValue) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    // Handle error
    // ...
    showSnackbar(context, 'Une erreur s\'est produite : $error', null);
    return true;
  }
}

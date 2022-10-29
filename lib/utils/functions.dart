import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:phone_number/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wesh/models/eventtype.dart';
import '../models/event.dart';
import '../models/story.dart';
import '../providers/user.provider.dart';
import '../services/sharedpreferences.service.dart';
import 'constants.dart';
import '../models/user.dart' as UserModel;

// Get User by Id /current user or anyone else
Stream<UserModel.User?> getUserById(context, String userId) {
  // await Future.delayed(Duration(seconds: 3));

  if (userId == FirebaseAuth.instance.currentUser!.uid || userId.isEmpty) {
    return Provider.of<UserProvider>(context, listen: true).getCurrentUser();
  }
  return Provider.of<UserProvider>(context, listen: true).getUserById(userId);
}

// Show DecisionModal
Future<bool> showModalDecision(
    {context, header, content, firstButton, secondButton}) async {
  bool? result = await showDialog(
    context: context,
    builder: ((context) {
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
              Text(
                header,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
              const SizedBox(height: 20),
              Text(
                content,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.black),
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
    }),
  );

  if (result == true) {
    return true;
  }
  return false;
}

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

// COMPARE TWO DATES
isEndTimeSuperiorThanStartTime(startTime, endTime) {
  bool result = false;
  int startTimeInt = (startTime.hour * 60 + startTime.minute) * 60;
  int EndTimeInt = (endTime.hour * 60 + endTime.minute) * 60;
  int dif = EndTimeInt - startTimeInt;

  if (EndTimeInt > startTimeInt) {
    result = true;
  } else {
    result = false;
  }
  return result;
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
    maxWidth:
        128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    quality: 25,
  );

  // debugPrint("Vid Thumbnail is: $uint8list");
  return result;
}

// Get StoryItem by Type
StoryItem getStoryItemByType(
    Story storySelected, StoryController storyController) {
  // Case : Story Text
  if (storySelected.storyType == 'text') {
    return StoryItem.text(
      title: storySelected.content,
      textStyle: TextStyle(
          fontFamily: storiesAvailableFontsList[storySelected.fontType],
          fontSize: 50,
          color: Colors.white),
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
Widget getStoryGridPreviewByType(Story storySelected) {
  return Stack(
    children: [
      const Center(
        child: CupertinoActivityIndicator(),
      ),
      (() {
        // Case : Story Text
        if (storySelected.storyType == 'text') {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: storiesAvailableColorsList[storySelected.bgColor],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Text(
                  storySelected.content,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily:
                          storiesAvailableFontsList[storySelected.fontType],
                      color: Colors.white),
                ),
              ),
            ),
          );
        }

        // Case : Story Image
        else if (storySelected.storyType == 'image') {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(storySelected.content),
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        // Case : Story Video
        else {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(storySelected.videoThumbnail),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      }())
    ],
  );
}

// Get story GridPreview by Type
Widget getEventGridPreview(Event eventSelected) {
  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Trailing
          Hero(
            tag: eventSelected.eventId,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: eventSelected.trailing.isNotEmpty
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(eventSelected.trailing))
                  : CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                          'assets/images/eventtype.icons/${eventSelected.type}.png'),
                    ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),

          // Event content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventSelected.title,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 7,
              ),
              // Event Info
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.calendar,
                      size: 15, color: Colors.black54),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    DateFormat('EEE, d MMM yyyy', 'fr_Fr')
                        .format(eventSelected.startDateTime),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54),
                  ),
                ],
              )
            ],
          ),
        ],
      ),

      // Divider
      const SizedBox(height: 10),

      Container(
        width: double.infinity,
        child: const Divider(
          height: 1,
          color: Colors.grey,
        ),
      ),
    ],
  );
}

// Get Duration Label
String getDurationLabel(DateTime eventStartedDate, DateTime reminderDate) {
  Duration duration = eventStartedDate.difference(reminderDate);

  if (duration == Duration()) {
    return 'dès qu\'il commence';
  }
  if (duration == const Duration(hours: 1)) {
    return '1h avant';
  } else if (duration == const Duration(days: 1)) {
    return '1 jour avant';
  } else if (duration == const Duration(days: 7)) {
    return '1 semaine avant';
  } else if (duration == const Duration(days: 30)) {
    return '1 mois avant';
  }

  return 'Aucun rappel';
}

// Get Event Icon from type
String getEventIconPath(key) {
  EventType eventresult =
      eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.iconPath;
}

// Get Event Title from type
String getEventTitle(key) {
  EventType eventresult =
      eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.name;
}

// Get Event Recurrence from type
bool getEventRecurrence(key) {
  EventType eventresult =
      eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.recurrence;
  ;
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
  debugPrint('Is phone number valid: $isValid');

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

// Returns true if username is in use.
Future<bool> checkIfEmailInUseInFirestore(context, String emailAddress) async {
  try {
    bool finalValue;
    // Fetch all email in DB
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: emailAddress)
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

// Returns true if phone number is in use.
Future<bool> checkIfPhoneNumberInUse(context, String phoneNumber) async {
  try {
    bool finalValue;
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
    bool finalValue;
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

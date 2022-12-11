import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mime/mime.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:external_path/external_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wesh/models/eventtype.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import '../models/event.dart';
import '../models/message.dart';
import '../models/story.dart';
import '../pages/in.pages/storyviewer_single_story.dart';
import '../providers/user.provider.dart';
import '../services/firestorage.methods.dart';
import '../services/firestore.methods.dart';
import '../services/sharedpreferences.service.dart';
import 'constants.dart';
import '../models/user.dart' as UserModel;
import 'package:external_path/external_path.dart';

// VIBRATE
Future triggerVibration({int? duration}) async {
  if (await Vibration.hasVibrator() == true) {
    Vibration.vibrate(duration: duration ?? 100);
  }
}

// Debouncer
class Debouncer {
  final int milliseconds;

  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

// Check whether story has expired or not
bool hasStoryExpired(DateTime endAt) {
  if (endAt.isBefore(DateTime.now())) {
    return true;
  }
  return false;
}

// Get Timeago : Long form
String getTimeAgoLongForm(DateTime dateTime) {
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  return timeago.format(dateTime, locale: 'fr');
}

// Get Timeago : Short form
String getTimeAgoShortForm(DateTime dateTime) {
  timeago.setLocaleMessages('fr', FrMessagesShortsform());
  return timeago.format(dateTime, locale: 'fr');
}

//
bool isAudio(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType?.startsWith('audio/') ?? false;
}

// Get Last Message of Discussion
Message? getLastMessageOfDiscussion(List<Message> discussionMessages) {
  Message? messageToDisplay;
  List<Message> messagesList = [];

  // Sort messages : by the latest
  discussionMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Remove: DeleteForMe messages
  for (Message message in discussionMessages) {
    if (!message.deleteFor.contains(FirebaseAuth.instance.currentUser!.uid)) {
      messagesList.add(message);
    }
  }

  for (int i = 0; i < messagesList.length; i++) {
    if (messagesList[i].status != 0) {
      messageToDisplay = messagesList[i];
      return messageToDisplay;
    } else if (messagesList[i].status == 0 && messagesList[i].senderId == FirebaseAuth.instance.currentUser!.uid) {
      messageToDisplay = messagesList[i];
      return messageToDisplay;
    }
  }
}

// Get Directories
Future<List> getDirectories() async {
  List dirList = await ExternalPath.getExternalStorageDirectories();
  Directory appDirectory = await getApplicationDocumentsDirectory();
  // 0: [/storage/emulated/0]
  // 1: [/storage/15FD-3004]
  // 2: [/data/user/0/packageName/app_flutter]

  return [dirList[0], '', appDirectory.path];
}

// Get Message Type Icon
Widget getMsgTypeIcon(int? messageStatus, String lastMessageType) {
  if (messageStatus != null && messageStatus == 0) {
    return const Padding(
      padding: EdgeInsets.only(right: 6),
      child: Icon(Icons.access_time_rounded, color: Colors.grey, size: 18),
    );
  } else {
    // if MessageType.text
    // if (lastMessageType == MessageType.text) {
    //   return Padding(
    //     padding: const EdgeInsets.only(right: 5),
    //     child: CircleAvatar(
    //       radius: 11,
    //       backgroundColor: Colors.lightBlue.shade200,
    //       child: Icon(FontAwesomeIcons.comment, color: Colors.white, size: 13),
    //     ),
    //   );
    // }

    // if MessageType.image
    if (lastMessageType == 'image') {
      return const Padding(
        padding: EdgeInsets.only(right: 6),
        child: Icon(FontAwesomeIcons.image, color: Colors.grey, size: 18),
      );
    }

    // if MessageType.video
    else if (lastMessageType == 'video') {
      return const Padding(
        padding: EdgeInsets.only(right: 6),
        child: Icon(FontAwesomeIcons.play, color: Colors.red, size: 18),
      );
    }

    // if MessageType.music
    else if (lastMessageType == 'music') {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Icon(FontAwesomeIcons.itunesNote, color: Colors.purple.shade300, size: 18),
      );
    }

    // if MessageType.voicenote
    else if (lastMessageType == 'voicenote') {
      return const Padding(
        padding: EdgeInsets.only(right: 6),
        child: Icon(FontAwesomeIcons.microphone, color: Colors.black87, size: 18),
      );
    }

    // if MessageType.gift
    else if (lastMessageType == 'gift') {
      return const Padding(
        padding: EdgeInsets.only(right: 7),
        child: CircleAvatar(
          radius: 11,
          backgroundColor: Colors.orangeAccent,
          child: Icon(FontAwesomeIcons.gift, color: Colors.white, size: 13),
        ),
      );
    }

    // if MessageType.payment
    else if (lastMessageType == 'payment') {
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Icon(FontAwesomeIcons.dollarSign, color: Colors.green.shade300, size: 13),
      );
    }

    // Default
    return Container();
  }
}

// Get Message Status
Widget getMessageStatusIcon(int status) {
  if (status == 0) {
    return Icon(
      FontAwesomeIcons.clock,
      color: Colors.black54,
      size: 12.sp,
    );
  } else if (status == 1) {
    return Icon(
      FontAwesomeIcons.check,
      color: Colors.black54,
      size: 12.sp,
    );
  } else if (status == 2) {
    return Icon(
      FontAwesomeIcons.checkDouble,
      color: Colors.black54,
      size: 12.sp,
    );
  } else if (status == 3) {
    return Icon(
      FontAwesomeIcons.checkDouble,
      color: kSecondColor,
      size: 12.sp,
    );
  }

  return Icon(
    FontAwesomeIcons.clock,
    color: Colors.black54,
    size: 12.sp,
  );
}

// Get PaymentMethod Device
String getPaymentMethodDevise(String paymentMethod) {
  // Switch
  switch (paymentMethod) {
    case mtnMobileMoneyLabel:
      return 'XAF';

    case airtelMoneyLabel:
      return 'XAF';

    default:
      return '';
  }
}

// Get PaymentMethod Device
String getPaymentMethodLogo(String paymentMethod) {
  // Switch
  switch (paymentMethod) {
    case mtnMobileMoneyLabel:
      return mtnMobileMoneyLogo;

    case airtelMoneyLabel:
      return airtelMoneyLogo;

    default:
      return '';
  }
}

// Get Message Notification Body
String getMessageNotificationBody(Message message) {
  // Switch
  switch (message.type) {
    case "text":
      return message.data;
    case "image":
      return '📷 Image ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "video":
      return '🎬 Video ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "voicenote":
      return '🎤 Note vocale ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "music":
      return '🎵 Audio ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "gift":
      return '🎁 Cadeau ${message.caption.isNotEmpty ? '• ${message.caption}' : ''}';

    case "payment":
      return '💳 Argent ${message.data.isNotEmpty ? '• ${message.data}' : ''}';

    default:
      return '';
  }
}

// Get Message Notification largeIconPath
Future<String> getMessageNotificationLargeIconPath(
    {required String url, required String filename, required String type}) async {
  List directories = await getDirectories();
  // Check file existence
  File file =
      File('${directories[0]}/$appName/${getSpecificDirByType(type)}/${transformExtensionToThumbnailExt(filename)}');
  if (file.existsSync()) {
    return file.path;
  } else {
    return await downloadFile(url: url, fileName: filename, type: type);
  }
}

// Get Default Caption by messageType
String getDefaultMessageCaptionByType(messageType) {
  // Switch
  switch (messageType) {
    case "image":
      return 'Image';

    case "video":
      return 'Video';

    case "voicenote":
      return 'Note vocale';

    case "music":
      return 'Audio';

    case "gift":
      return 'Cadeau';

    case "payment":
      return 'Argent';

    default:
      return '';
  }
}

// Get Specific Directories by type
String getSpecificDirByType(messageType) {
  // Switch
  switch (messageType) {
    case "image":
      return '$appName Images';

    case "video":
      return '$appName Videos';

    case "voicenote":
      return '$appName Notes Vocales';

    case "music":
      return '$appName Audio';

    case "story":
      return '$appName Stories';

    case "thumbnail":
      return '$appName thumbnails';
    default:
      return '';
  }
}

Future deleteMessageAssociatedFiles(Message message) async {
  List directories = await getDirectories();

  File correspondingFile = File('${directories[0]}/$appName/${getSpecificDirByType(message.type)}/${message.filename}');
  if (correspondingFile.existsSync()) {
    await correspondingFile.delete();
    log('File deleted at ${correspondingFile.path}');
  }
}

// Get User by Id /current user or anyone else
Stream<UserModel.User?> getUserById(context, String userId) {
  // await Future.delayed(Duration(seconds: 3));

  if (userId == FirebaseAuth.instance.currentUser!.uid || userId.isEmpty) {
    return Provider.of<UserProvider>(context, listen: true).getCurrentUser();
  }
  return Provider.of<UserProvider>(context, listen: true).getUserById(userId);
}

// Show DecisionModal
Future<List> showModalDecision({
  context,
  header,
  content,
  firstButton,
  secondButton,
  barrierDismissible,
  String? checkBoxCaption,
  bool? checkBoxValue,
}) async
//
{
  bool? result = await showDialog(
    barrierDismissible: barrierDismissible ?? true,
    context: context,
    builder: ((context) {
      return StatefulBuilder(builder: (context, setState) {
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
                // HEADER
                Text(
                  header,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
                ),
                const SizedBox(height: 20),

                // CONTENT
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp),
                ),
                const SizedBox(height: 20),

                // CHECK BOX : if possible
                checkBoxCaption != null
                    ? CheckboxListTile(
                        value: checkBoxValue,
                        onChanged: (bool? value) {
                          setState(() {
                            checkBoxValue = !checkBoxValue!;
                          });
                        },
                        title: Text(
                          checkBoxCaption,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                        ),
                      )
                    : Container(),

                checkBoxCaption != null ? const SizedBox(height: 7) : Container(),

                // ACTION BUTTONS
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
                        style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
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
      });
    }),
  );

  if (result == true) {
    return [true, checkBoxValue ?? false];
  }

  return [false, checkBoxValue ?? false];
}

// DATE PICKER
Future<DateTime?> pickDate(
    {required BuildContext context, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
  final newDate = await showDatePicker(
    cancelText: 'ANNULER',
    helpText: 'Selectionner une date',
    fieldLabelText: 'Entrer une date',
    errorInvalidText: 'Date invalide, veuillez réessayer !',
    errorFormatText: 'Date invalide, veuillez réessayer !',
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime.now(),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    lastDate: lastDate ?? DateTime.now().add(const Duration(days: 10000)),
  );
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
bool isEndTimeSuperiorThanStartTime(TimeOfDay startTime, TimeOfDay endTime) {
  if (endTime.hour > startTime.hour) {
    return true;
  } else if (endTime.hour == startTime.hour) {
    if (endTime.minute > startTime.minute) {
      return true;
    } else {
      return false;
    }
  }
  return false;
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

// GET THUMBNAIL EXTENSION : from a filename

String transformExtensionToThumbnailExt(String filename) {
  String withoutExt = filename.split('.').first;
  return '$withoutExt.png';
}

double getMessagePreviewCardHeight(messageType) {
  // Switch
  switch (messageType) {
    case "image":
      return 0.45.sh;
    case "video":
      return 0.3.sh;
    case "voicenote":
      return 0.08.sh;
    case "music":
      return 0.08.sh;
    default:
      return 0;
  }
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.create(recursive: true);
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

// Send Message
Future sendMessage({
  required BuildContext context,
  required String userReceiverId,
  required String messageType,
  required String discussionId,
  required String eventId,
  required String storyId,
  required String messageTextValue,
  required String messageCaptionText,
  required String voiceNotePath,
  required String imagePath,
  required String videoPath,
  required String musicPath,
  required bool isPaymentMessage,
  required int amount,
  required String paymentMethod,
  required String transactionId,
  required String receiverPhoneNumber,
  required String messageToReplyId,
  required String messageToReplyType,
  required String messageToReplyData,
  required String messageToReplyFilename,
  required String messageToReplyThumbnail,
  required String messageToReplyCaption,
  required String messageToReplySenderId,
}) async
//
{
  List directories = await getDirectories();
  bool result = false;
  String data = '';
  int status = 0;
  String thumbnail = '';
  String filename = '';
  // String discussionId = 'AcuUnKLwEIxG7xdINKMJ';
  String userSenderId = FirebaseAuth.instance.currentUser!.uid;
  // String userReceiverId = 'NxghAin2gKaAHYCatY2c2Vty17n1';

  File voicenoteMoved = File('');
  File imageMoved = File('');
  File thumbnailFileMoved = File('');
  File videoMoved = File('');
  File musicMoved = File('');

  // Process with Text, Payment
  if (messageType == 'text' || messageType == 'payment') {
    data = messageTextValue;
    status = 1;
  }

  // Process with Message File: voicenote, image, video, music

  // Check WRITE_EXTERNAL_STORAGE permission
  if (await Permission.storage.request().isGranted) {
    //
    //
    if (messageType == 'voicenote') {
      // Voicenote filename
      final voiceNoteFilename = '${appName}_voicenote_msg_${const Uuid().v4()}.aac';
      filename = voiceNoteFilename;

      voicenoteMoved = await copyFile(
          File(voiceNotePath), '${directories[0]}/$appName/${getSpecificDirByType(messageType)}/$voiceNoteFilename');
      log('Voicenote file : $voicenoteMoved');
    }
    //
    else if (messageType == 'music') {
      // Music filename
      final musicFilename = '${appName}_music_msg_${const Uuid().v4()}.mp3';
      filename = musicFilename;

      musicMoved = await copyFile(
          File(musicPath), '${directories[0]}/$appName/${getSpecificDirByType(messageType)}/$musicFilename');
      log('Music file : $musicMoved');
    }
    //
    else if (messageType == 'image') {
      // Image filename
      final imageFilename = '${appName}_image_msg_${const Uuid().v4()}.png';
      filename = imageFilename;

      imageMoved = await copyFile(
          File(imagePath), '${directories[0]}/$appName/${getSpecificDirByType(messageType)}/$imageFilename');
      log('Image file : $imageMoved');

      // Create image thumbnail
      ImageProperties properties = await FlutterNativeImage.getImageProperties(imageMoved.path);
      File compressedImageFile = await FlutterNativeImage.compressImage(imageMoved.path,
          quality: 80, targetWidth: 100, targetHeight: (properties.height! * 100 / properties.width!).round());

      // Move thumbnail
      thumbnailFileMoved = await copyFile(compressedImageFile,
          '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(imageFilename)}');
      log('Thumbnail file moved : $thumbnailFileMoved');
    }
    //
    else if (messageType == 'video') {
      // Video filename
      final videoFilename = '${appName}_video_msg_${const Uuid().v4()}.mp4';
      filename = videoFilename;

      videoMoved = await copyFile(
          File(videoPath), '${directories[0]}/$appName/${getSpecificDirByType(messageType)}/$videoFilename');
      log('Video file : $videoMoved');

      // Create Video thumbnail
      String vidhumbnailPath = await getVideoThumbnail(videoMoved.path) ?? '';

      // Move thumbnail
      thumbnailFileMoved = await copyFile(File(vidhumbnailPath),
          '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(videoFilename)}');
      log('Thumbnail file moved : $thumbnailFileMoved');
    }

    if (messageType != 'text' && messageType != 'voicenote' && messageType != 'music' && messageType != 'payment') {
      // init info
      data = '';
      status = 0;
      thumbnail = '';
      //
    }
  } else {
    log('Permission isn\'t  granted !');

    // ignore: use_build_context_synchronously
    Navigator.pop(
      context,
    );
    // ignore: use_build_context_synchronously
    showSnackbar(context, 'Nous avons besoin d\'une permission pour continuer !', null);
    return;
  }

  //
  // MODELING A NEW MESSAGE
  //

  Map<String, Object> newMessage = Message(
    messageId: '',
    type: messageType,
    createdAt: DateTime.now(),
    discussionId: discussionId,
    data: data,
    thumbnail: thumbnail,
    filename: filename,
    caption: messageCaptionText,
    eventId: eventId,
    storyId: storyId,
    receiverId: userReceiverId,
    senderId: userSenderId,
    status: status,
    deleteFor: [],
    paymentId: '',
    messageToReplyId: messageToReplyId,
    messageToReplyType: messageToReplyType,
    messageToReplyData: messageToReplyData,
    messageToReplyFilename: messageToReplyFilename,
    messageToReplyThumbnail: messageToReplyThumbnail,
    messageToReplyCaption: messageToReplyCaption,
    messageToReplySenderId: messageToReplySenderId,
  ).toJson();

  log('Message is: $newMessage');

  //
  // CREATE MESSAGE IN FIRESTORE
  //
  // ignore: use_build_context_synchronously
  List messageResult = await FirestoreMethods().createMessage(
    context: context,
    userSenderId: userSenderId,
    userReceiverId: userReceiverId,
    message: newMessage,
    isPaymentMessage: isPaymentMessage,
    amount: amount,
    receiverPhoneNumber: receiverPhoneNumber,
    paymentMethod: paymentMethod,
    transactionId: transactionId,
  );
  result = messageResult[0];

  if (result) {
    log('Message created !');
    return true;
  }
  // else {
  //   // ignore: use_build_context_synchronously
  //   showSnackbar(context, 'Une erreur s\'est produite !', null);
  //   log('Error while creating a message !');
  //   return false;
  // }
}

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
    maxWidth: 128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    quality: 25,
  );

  // log("Vid Thumbnail is: $uint8list");
  return result;
}

// Download File
Future<String> downloadFile({required String url, required String fileName, required String type}) async {
  List directories = await getDirectories();
  String filePath =
      '${directories[0]}/$appName/${getSpecificDirByType(type)}/${transformExtensionToThumbnailExt(fileName)}';
  final response = await http.get(Uri.parse(url));
  final file = File(filePath);

  await file.writeAsBytes(response.bodyBytes);

  return file.path;
}

// Copy file
Future<File> copyFile(File sourceFile, String newPath) async {
  try {
    return await sourceFile.copy(newPath);
  } on FileSystemException catch (e) {
    throw Exception('An error occured while copying file');
  }
}

// Move file
Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    // prefer using rename as it is probably faster
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (e) {
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}

// Get MessageToReply GridPreview by Type
Widget getMessageToReplyGridPreview({
  required String messageToReplyId,
  required String messageToReplyType,
  required String messageToReplyData,
  required String messageToReplyFilename,
  required String messageToReplyThumbnail,
  required String messageToReplyCaption,
  required String messageToReplySenderId,
  bool? hasDivider,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trailing
          messageToReplyType == 'image' || messageToReplyType == 'video'
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(1, 1, 0, 1),
                  child: FutureBuilder(
                    future: getDirectories(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      // Display DATA
                      if (snapshot.hasData) {
                        var directories = snapshot.data;
                        File thumbnailFile = File(
                            '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(messageToReplyFilename)}');

                        return FittedBox(
                          child: Container(
                            height: 45,
                            width: 45,
                            margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black87.withOpacity(0.3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Thumbnail
                                  ProgressiveImage(
                                    height: 45,
                                    width: 45,
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage(darkBackground),
                                    //
                                    thumbnail: thumbnailFile.existsSync()
                                        ? FileImage(thumbnailFile)
                                        : NetworkImage(messageToReplyThumbnail) as ImageProvider,
                                    //
                                    image: thumbnailFile.existsSync()
                                        ? FileImage(thumbnailFile)
                                        : NetworkImage(messageToReplyThumbnail) as ImageProvider,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Display Loader
                      return Container(
                        height: 45,
                        width: 45,
                        margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black87.withOpacity(0.3),
                          image: const DecorationImage(
                            image: AssetImage(darkBackground),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(),

          // Message content
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MESSAGE SENDER USERNAME
              Padding(
                padding: messageToReplyType == 'video' || messageToReplyType == 'image'
                    ? const EdgeInsets.only(bottom: 10, top: 10)
                    : const EdgeInsets.only(left: 15, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildUserNameToDisplay(
                      userId: messageToReplySenderId,
                      isMessagePreviewCard: true,
                      hasShimmerLoader: hasDivider,
                    ),
                  ],
                ),
              ),

              // MESSAGE BODY
              () {
                // DISPLAY TEXT MESSAGE
                if (messageToReplyType == 'text') {
                  return Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                        child: Text(
                          messageToReplyData,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12.sp,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                // DISPLAY PAYMENT
                else if (messageToReplyType == 'payment') {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                    child: Row(
                      children: [
                        getMsgTypeIcon(null, messageToReplyType),
                        Expanded(
                          child: Text(
                            messageToReplyData.isNotEmpty
                                ? messageToReplyData
                                : getDefaultMessageCaptionByType(messageToReplyType),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12.sp,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                // DISPLAY MUSIC OR VOICENOTE
                else if (messageToReplyType == 'music' || messageToReplyType == 'voicenote') {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 10, 10),
                    child: Row(
                      children: [
                        getMsgTypeIcon(null, messageToReplyType),
                        Expanded(
                          child: Text(
                            messageToReplyCaption.isNotEmpty
                                ? messageToReplyCaption
                                : getDefaultMessageCaptionByType(messageToReplyType),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12.sp,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }

                // DISPLAY VIDEO OR IMAGE
                if (messageToReplyType == 'video' || messageToReplyType == 'image') {
                  return Row(
                    children: [
                      getMsgTypeIcon(null, messageToReplyType),
                      Expanded(
                        child: Text(
                          messageToReplyCaption.isNotEmpty
                              ? messageToReplyCaption
                              : getDefaultMessageCaptionByType(messageToReplyType),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12.sp,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      )
                    ],
                  );
                }
                return Container();
              }(),
            ],
          )),
        ],
      ),

      // Divider
      hasDivider != null && hasDivider == true
          ? Container(
              margin: const EdgeInsets.only(top: 10),
              width: double.infinity,
              child: const Divider(
                height: 1,
                color: Colors.grey,
              ),
            )
          : Container(),
    ],
  );
}

// Get StoryItem by Type
StoryItem getStoryItemByType(Story storySelected, StoryController storyController) {
  // Case : Story Text
  if (storySelected.storyType == 'text') {
    return StoryItem.text(
      title: storySelected.content,
      textStyle:
          TextStyle(fontFamily: storiesAvailableFontsList[storySelected.fontType], fontSize: 50, color: Colors.white),
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
Widget getStoryGridPreviewThumbnail({required Story storySelected, double? height, double? width}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      const Center(
        child: CupertinoActivityIndicator(),
      ),
      (() {
        // Case : Story Text
        if (storySelected.storyType == 'text') {
          return Container(
            height: height ?? 45,
            width: width ?? 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: storiesAvailableColorsList[storySelected.bgColor],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Text(
                  storySelected.content,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: storiesAvailableFontsList[storySelected.fontType], color: Colors.white),
                ),
              ),
            ),
          );
        }

        // Case : Story Video
        else {
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ProgressiveImage(
              height: height ?? 45,
              width: width ?? 45,
              fit: BoxFit.cover,
              placeholder: const AssetImage(darkBackground),
              //
              thumbnail: NetworkImage(
                  storySelected.storyType == 'image' ? storySelected.content : storySelected.videoThumbnail),
              //
              image: NetworkImage(
                  storySelected.storyType == 'image' ? storySelected.content : storySelected.videoThumbnail),
            ),
          );
        }
      }())
    ],
  );
}

// Get Story GridPreview
Widget getStoryGridPreview({
  required String storyId,
  bool? hasDivider,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: StreamBuilder<Story>(
      stream: FirestoreMethods().getStoryById(storyId),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.hasData && snapshot.data != null) {
          Story storyGet = snapshot.data!;

          return InkWell(
            onTap: () {
              // View Story
              if (!hasStoryExpired(storyGet.endAt)) {
                context.pushTransparentRoute(SingleStoryPageViewer(
                  storyTodiplay: storyGet,
                ));
              }
            },
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Trailing
                    getStoryGridPreviewThumbnail(storySelected: storyGet),
                    const SizedBox(
                      width: 10,
                    ),

                    // Event content
                    Expanded(
                      child: Wrap(
                        children: [
                          hasStoryExpired(storyGet.endAt)
                              ? FittedBox(
                                  child: Text(
                                    'Cette story a expiré',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.circleNotch,
                                          size: 0.06.sw,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        buildUserNameToDisplay(
                                          userId: storyGet.uid,
                                          isMessagePreviewCard: true,
                                          hasShimmerLoader: hasDivider,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      storyGet.storyType == 'text' ? storyGet.content : storyGet.caption,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Divider
                hasDivider != null && hasDivider == true
                    ? Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: double.infinity,
                        child: const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
              ],
            ),
          );
        }

        // Diplay Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade400,
                child: const CircleAvatar(
                  radius: 23,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                children: [
                  const Text('...'),
                  const SizedBox(height: 5),
                  hasDivider != null && hasDivider == true
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              width: 50,
                              height: 15,
                              color: Colors.grey.shade400),
                        )
                      : const Text('...'),
                ],
              ),
            ],
          );
        }

        return Container();
      },
    ),
  );
}

// Get Event GridPreview by Type
Widget getEventGridPreview({required String eventId, bool? hasDivider}) {
  return StreamBuilder<Event>(
    stream: FirestoreMethods().getEventById(eventId),
    builder: (context, snapshot) {
      // Handle error
      if (snapshot.hasError) {
        return Container();
      }

      if (snapshot.hasData && snapshot.data != null) {
        Event eventGet = snapshot.data!;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Trailing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: ProgressiveImage(
                      height: 0.1.sw,
                      width: 0.1.sw,
                      fit: BoxFit.cover,
                      placeholder: const AssetImage(darkBackground),
                      //
                      thumbnail: AssetImage('assets/images/eventtype.icons/${eventGet.type}.png'),
                      //
                      image: eventGet.trailing.isNotEmpty
                          ? NetworkImage(eventGet.trailing)
                          : AssetImage('assets/images/eventtype.icons/${eventGet.type}.png') as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),

                // Event content
                Expanded(
                  child: Wrap(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              buildUserNameToDisplay(
                                userId: eventGet.uid,
                                isMessagePreviewCard: true,
                                hasShimmerLoader: hasDivider,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            eventGet.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Divider
            hasDivider != null && hasDivider == true
                ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    child: const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  )
                : Container(),
          ],
        );
      }

      // Diplay Loader
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade400,
                child: CircleAvatar(
                  radius: 0.04.sw,
                ),
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            Column(
              children: [
                const Text('...'),
                const SizedBox(height: 2),
                hasDivider != null && hasDivider == true
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade400,
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            width: 50,
                            height: 12,
                            color: Colors.grey.shade400),
                      )
                    : const Text('...'),
              ],
            ),
          ],
        );
      }

      return Container();
    },
  );
}

// Get Duration Label
String getDurationLabel(DateTime eventStartedDate, DateTime reminderDate) {
  Duration duration = eventStartedDate.difference(reminderDate);

  if (duration == const Duration()) {
    return 'dès qu\'il commence';
  } else if (duration == const Duration(minutes: 10)) {
    return '10min avant';
  } else if (duration == const Duration(hours: 1)) {
    return '1h avant';
  } else if (duration == const Duration(days: 1)) {
    return '1 jour avant';
  } else if (duration == const Duration(days: 3)) {
    return '3 jours avant';
  } else if (duration == const Duration(days: 7)) {
    return '1 semaine avant';
  } else if (duration == const Duration(days: 30)) {
    return '1 mois avant';
  }

  return 'Aucun rappel';
}

// Get Event Icon from type
String getEventIconPath(key) {
  EventType eventresult = eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.iconPath;
}

// Get Event Title from type
String getEventTitle(key) {
  EventType eventresult = eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.name;
}

// Get Event Recurrence from type
bool getEventRecurrence(key) {
  EventType eventresult = eventAvailableTypeList.singleWhere((element) => element.key == key);

  return eventresult.recurrence;
  ;
}

// Show Snackbar
showSnackbar(context, message, color) {
  var _color = color ?? Colors.black87;

  var snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: 13.sp),
    ),
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
}) async
//
{
// Validate
  bool isValid = await PhoneNumberUtil().validate(phoneContent, regionCode: regionCode).onError(
        (error, stackTrace) => showSnackbar(context, 'Votre numéro est incorrect !', null),
      );
  log('Is phone number valid: $isValid');

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
    final list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

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
    return false;
  }
}

// Returns true if username is in use.
Future<bool> checkIfEmailInUseInFirestore(context, String emailAddress) async {
  try {
    bool finalValue;
    // Fetch all email in DB
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: emailAddress).get();

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
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: phoneNumber).get();

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
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username.toLowerCase()).get();

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

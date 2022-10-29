import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wesh/models/message.dart';
import 'package:wesh/pages/in.pages/previewmessagefile.dart';
import 'package:wesh/pages/in.pages/sendpayment.dart';
import 'package:wesh/pages/in.pages/suggestions.dart';
import 'package:wesh/utils/constants.dart';

import '../models/event.dart';
import 'buildWidgets.dart';

class MessageFilePicker extends StatefulWidget {
  final String uid;
  final Event? eventAttached;
  const MessageFilePicker({Key? key, required this.uid, this.eventAttached})
      : super(key: key);

  @override
  State<MessageFilePicker> createState() => _DeleteDecisionState();
}

class _DeleteDecisionState extends State<MessageFilePicker> {
  late dynamic filePicked = null;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 13, bottom: 20),
          child: Text(
            'Envoyer...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 19,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Camera Picker
            buttonPicker(
              icon: const Icon(FontAwesomeIcons.camera,
                  color: Colors.white, size: 22),
              label: 'Camera',
              widgetColor: kSecondColor,
              function: () async {
                // Take Picture From Camera
                filePicked =
                    await _picker.pickImage(source: ImageSource.camera);

                debugPrint('File picked iz: $filePicked');
                if (filePicked != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewMessageFile(
                            uid: widget.uid,
                            eventAttached: widget.eventAttached,
                            filetype: 'image',
                            file: filePicked),
                      ));
                } else {
                  Navigator.pop(context);
                }
              },
            ),

            // Image Picker
            buttonPicker(
              icon: const Icon(FontAwesomeIcons.image,
                  color: Colors.white, size: 21),
              label: 'Image',
              widgetColor: Colors.grey,
              function: () async {
                // Take Picture From Gallery
                filePicked =
                    await _picker.pickImage(source: ImageSource.gallery);

                debugPrint('File picked iz: $filePicked');
                if (filePicked != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewMessageFile(
                            uid: widget.uid,
                            eventAttached: widget.eventAttached,
                            filetype: 'image',
                            file: filePicked),
                      ));
                } else {
                  Navigator.pop(context);
                }
              },
            ),

            // Video Picker
            buttonPicker(
              icon: Icon(FontAwesomeIcons.play, color: Colors.white, size: 22),
              label: 'Video',
              widgetColor: Colors.red,
              function: () async {
                // Take Video From Gallery
                filePicked =
                    await _picker.pickVideo(source: ImageSource.gallery);

                if (filePicked != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewMessageFile(
                            uid: widget.uid,
                            eventAttached: widget.eventAttached,
                            filetype: 'video',
                            file: filePicked),
                      ));
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mucic Picker
            buttonPicker(
              icon: Icon(FontAwesomeIcons.itunesNote,
                  color: Colors.white, size: 22),
              label: 'Son',
              widgetColor: Colors.purple.shade300,
              function: () async {
                // Take Mucic From Galery && Send Music Message
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.audio);

                if (result != null) {
                  // Move to App Directory
                  PlatformFile file = result.files.first;
                  var filename = 'msgMusic_${Uuid().v4()}';

                  final Directory directory =
                      await getApplicationDocumentsDirectory();
                  var path = '${directory.path}/${filename}.${file.extension}';

                  try {
                    File finalFilePath =
                        File(file.path as String).copySync(path);
                    if (finalFilePath != null)
                      debugPrint(
                          'Message File was saved correctly at $finalFilePath');

                    // Save msg to Sql DB
                    // final newMessage = Message(
                    //   messageId: 'message_${const Uuid().v4()}',
                    //   eventId: widget.eventAttached ?? '',
                    //   senderId: '3',
                    //   receiverId: '4',
                    //   createdAt: DateTime.now(),
                    //   status: 'pending',
                    //   type: 'music',
                    //   data: '$finalFilePath',
                    //   caption: '',
                    // );

                    // await SqlDatabase.instance.createMessage(newMessage);
                  } catch (e) {
                    Exception('Erreur when saving file: $e');
                  }
                } else {
                  // User canceled the picker
                  filePicked = null;
                }

                Navigator.pop(context, filePicked);
              },
            ),

            // Payment Picker
            buttonPicker(
              icon: Icon(FontAwesomeIcons.dollarSign,
                  color: Colors.white, size: 22),
              label: 'Argent',
              widgetColor: Colors.green.shade300,
              function: () {
                // POP THE CURRENT MODAL
                Navigator.pop(
                  context,
                );

                // PUSH TO SEND PAYMENT PAGE
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendPayment(
                        uid: widget.uid,
                        eventAttached: widget.eventAttached,
                        filetype: 'payment',
                      ),
                    ));
              },
            ),

            // Gift Picker
            buttonPicker(
              icon: Icon(FontAwesomeIcons.gift, color: Colors.white, size: 22),
              label: 'Cadeau',
              widgetColor: Colors.orangeAccent,
              function: () {
                // POP THE CURRENT MODAL
                Navigator.pop(
                  context,
                );

                // PUSH TO SUGGESTIONS PAGE
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Suggestions(
                        suggestionType: 'gift',
                        uid: widget.uid,
                        eventAttached: widget.eventAttached,
                      ),
                    ));
              },
            ),
          ],
        )
      ],
    );
  }
}

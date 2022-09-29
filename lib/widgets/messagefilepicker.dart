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

class MessageFilePicker extends StatefulWidget {
  final String uid;
  final String? eventIdAttached;
  const MessageFilePicker({Key? key, required this.uid, this.eventIdAttached})
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
          padding: EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            'Envoyer...',
            textAlign: TextAlign.center,
            style: const TextStyle(
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
              icon:
                  Icon(Icons.camera_alt_rounded, color: Colors.white, size: 27),
              label: 'Camera',
              widgetColor: kSecondColor,
              function: () async {
                // Take Picture From Camera
                filePicked =
                    await _picker.pickImage(source: ImageSource.camera);

                print('File picked iz: $filePicked');
                if (filePicked != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewMessageFile(
                            uid: widget.uid,
                            eventIdAttached: widget.eventIdAttached,
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
              icon: Icon(FontAwesomeIcons.image, color: Colors.white, size: 20),
              label: 'Image',
              widgetColor: Colors.grey,
              function: () async {
                // Take Picture From Gallery
                filePicked =
                    await _picker.pickImage(source: ImageSource.gallery);

                print('File picked iz: $filePicked');
                if (filePicked != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewMessageFile(
                            uid: widget.uid,
                            eventIdAttached: widget.eventIdAttached,
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
              icon: Icon(FontAwesomeIcons.play, color: Colors.white, size: 20),
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
                            eventIdAttached: widget.eventIdAttached,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mucic Picker
            buttonPicker(
              icon: Icon(FontAwesomeIcons.itunesNote,
                  color: Colors.white, size: 20),
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
                      print(
                          'Message File was saved correctly at $finalFilePath');

                    // Save msg to Sql DB
                    final newMessage = Message(
                      messageId: 'message_${const Uuid().v4()}',
                      eventId: widget.eventIdAttached ?? '',
                      senderId: '3',
                      receiverId: '4',
                      createdAt: DateTime.now(),
                      status: 'pending',
                      type: 'music',
                      data: '$finalFilePath',
                      caption: '',
                    );

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
                  color: Colors.white, size: 20),
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
                        eventIdAttached: widget.eventIdAttached,
                        filetype: 'payment',
                      ),
                    ));
              },
            ),

            // Gift Picker
            buttonPicker(
              icon: Icon(FontAwesomeIcons.gift, color: Colors.white, size: 20),
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
                        eventIdAttached: widget.eventIdAttached,
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

class buttonPicker extends StatelessWidget {
  final Widget icon;
  final Color widgetColor;
  final String label;
  final VoidCallback function;

  const buttonPicker({
    Key? key,
    required this.icon,
    required this.widgetColor,
    required this.label,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: InkWell(
          onTap: () async {
            // Return selected file
            function();
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: widgetColor,
                child: icon,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 15,
                ),
              )
            ],
          )),
    );
  }
}

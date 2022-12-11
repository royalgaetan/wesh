import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:uuid/uuid.dart';
import 'package:wesh/pages/in.pages/previewmessagefile.dart';
import 'package:wesh/pages/in.pages/sendpayment.dart';
import 'package:wesh/pages/in.pages/suggestions.dart';
import 'package:wesh/utils/constants.dart';
import '../models/event.dart';
import '../models/message.dart';
import '../models/story.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class MessageFilePicker extends StatefulWidget {
  final String userReceiverId;
  final String? discussionId;
  final Message? messageToReply;
  final Event? eventAttached;
  final Story? storyAttached;

  MessageFilePicker(
      {Key? key,
      this.discussionId,
      required this.userReceiverId,
      this.eventAttached,
      this.storyAttached,
      this.messageToReply})
      : super(key: key);

  @override
  State<MessageFilePicker> createState() => _DeleteDecisionState();
}

class _DeleteDecisionState extends State<MessageFilePicker> {
  File filePicked = File('');
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 13, bottom: 20),
          child: Text(
            'Envoyer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 15.sp,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Camera Picker
            buttonPicker(
              icon: const Icon(FontAwesomeIcons.camera, color: Colors.white, size: 22),
              label: 'Camera',
              widgetColor: kSecondColor,
              function: () async {
                // Take Picture From Camera
                var getFilePicked = await _picker.pickImage(source: ImageSource.camera);

                debugPrint('File picked is : $filePicked');
                if (getFilePicked != null) {
                  filePicked = File(getFilePicked.path);
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => PreviewMessageFile(
                            discussionId: widget.discussionId ?? '',
                            userReceiverId: widget.userReceiverId,
                            messageToReply: widget.messageToReply,
                            eventAttached: widget.eventAttached,
                            storyAttached: widget.storyAttached,
                            filetype: 'image',
                            file: filePicked),
                      ));
                } else {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, null);
                }
              },
            ),

            // Image Picker
            buttonPicker(
              icon: const Icon(FontAwesomeIcons.image, color: Colors.white, size: 21),
              label: 'Image',
              widgetColor: Colors.grey,
              function: () async {
                //
                // Take Picture From Gallery
                var getFilePicked = await _picker.pickImage(source: ImageSource.gallery);

                debugPrint('File picked is : $filePicked');
                if (getFilePicked != null) {
                  filePicked = File(getFilePicked.path);
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => PreviewMessageFile(
                            discussionId: widget.discussionId ?? '',
                            userReceiverId: widget.userReceiverId,
                            messageToReply: widget.messageToReply,
                            eventAttached: widget.eventAttached,
                            storyAttached: widget.storyAttached,
                            filetype: 'image',
                            file: filePicked),
                      ));
                } else {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, null);
                }
              },
            ),

            // Video Picker
            buttonPicker(
              icon: const Icon(FontAwesomeIcons.play, color: Colors.white, size: 22),
              label: 'Video',
              widgetColor: Colors.red,
              function: () async {
                // Take Video From Gallery
                var getFilePicked = await _picker.pickVideo(source: ImageSource.gallery);

                if (getFilePicked != null) {
                  filePicked = File(getFilePicked.path);
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => PreviewMessageFile(
                            discussionId: widget.discussionId ?? '',
                            userReceiverId: widget.userReceiverId,
                            messageToReply: widget.messageToReply,
                            eventAttached: widget.eventAttached,
                            storyAttached: widget.storyAttached,
                            filetype: 'video',
                            file: filePicked),
                      ));
                } else {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, null);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mucic Picker
            buttonPicker(
              icon: const Icon(FontAwesomeIcons.itunesNote, color: Colors.white, size: 22),
              label: 'Son',
              widgetColor: Colors.purple.shade300,
              function: () async {
                // Take Mucic From Galery && Send Music Message
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

                if (result != null) {
                  // Move to App Directory
                  PlatformFile musicfilePicked = result.files.first;
                  File musicfilePickedFILE = File(musicfilePicked.path!);

                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      SwipeablePageRoute(
                        builder: (context) => PreviewMessageFile(
                            discussionId: widget.discussionId ?? '',
                            userReceiverId: widget.userReceiverId,
                            messageToReply: widget.messageToReply,
                            eventAttached: widget.eventAttached,
                            storyAttached: widget.storyAttached,
                            filetype: 'music',
                            file: musicfilePickedFILE),
                      ));
                } else {
                  // User canceled the picker
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, null);
                }
              },
            ),

            // Payment Picker
            buttonPicker(
              icon: const Icon(FontAwesomeIcons.dollarSign, color: Colors.white, size: 22),
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
                    SwipeablePageRoute(
                      builder: (context) => SendPayment(
                        discussionId: widget.discussionId ?? '',
                        userReceiverId: widget.userReceiverId,
                        messageToReply: widget.messageToReply,
                        eventAttached: widget.eventAttached,
                        storyAttached: widget.storyAttached,
                        filetype: 'payment',
                      ),
                    ));
              },
            ),

            // Gift Picker
            buttonPicker(
              icon: const Icon(FontAwesomeIcons.gift, color: Colors.white, size: 22),
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
                    SwipeablePageRoute(
                      builder: (context) => Suggestions(
                        suggestionType: 'gift',
                        userReceiverId: widget.userReceiverId,
                        messageToReply: widget.messageToReply,
                        eventAttached: widget.eventAttached,
                        storyAttached: widget.storyAttached,
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

// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/previewmessagefile.dart';
import 'package:wesh/pages/in.pages/sendpayment.dart';
import 'package:wesh/pages/in.pages/suggestions.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import '../models/event.dart';
import '../models/message.dart';
import '../models/story.dart';
import 'buildWidgets.dart';

class MessageFilePicker extends StatefulWidget {
  final String userReceiverId;
  final String? discussionId;
  final Message? messageToReply;
  final Event? eventAttached;
  final Story? storyAttached;

  const MessageFilePicker(
      {super.key,
      this.discussionId,
      required this.userReceiverId,
      this.eventAttached,
      this.storyAttached,
      this.messageToReply});

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
          padding: const EdgeInsets.only(top: 13, bottom: 15),
          child: Text(
            'Send...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 17.sp,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Camera Picker
            ButtonPicker(
              icon: const Icon(FontAwesomeIcons.camera, color: Colors.white, size: 22),
              label: 'Camera',
              widgetColor: kSecondColor,
              function: () async {
                // Full Loader
                showFullPageLoader(context: context);

                // Take Picture From Camera
                var getFilePicked = await _picker.pickImage(source: ImageSource.camera);

                // Remove FullLoader
                Navigator.pop(context);

                debugPrint('File picked is : $filePicked');
                if (getFilePicked != null) {
                  filePicked = File(getFilePicked.path);
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
                  if (!mounted) return;
                  Navigator.pop(context, null);
                }
              },
            ),

            // Image Picker
            ButtonPicker(
              icon: const Icon(FontAwesomeIcons.image, color: Colors.white, size: 21),
              label: 'Image',
              widgetColor: Colors.blueGrey.shade500,
              function: () async {
                // Full Loader
                showFullPageLoader(context: context);

                // Take Picture From Gallery
                var getFilePicked = await _picker.pickImage(source: ImageSource.gallery);

                // Remove FullLoader
                Navigator.pop(context);

                debugPrint('File picked is : $filePicked');
                if (getFilePicked != null) {
                  filePicked = File(getFilePicked.path);

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
                  if (!mounted) return;
                  Navigator.pop(context, null);
                }
              },
            ),

            // Video Picker
            ButtonPicker(
              icon: const Icon(FontAwesomeIcons.play, color: Colors.white, size: 22),
              label: 'Video',
              widgetColor: Colors.red.shade500,
              function: () async {
                // Full Loader
                showFullPageLoader(context: context);

                // Take Video From Gallery
                var getFilePicked = await _picker.pickVideo(source: ImageSource.gallery);

                // Remove FullLoader
                Navigator.pop(context);

                if (getFilePicked != null) {
                  filePicked = File(getFilePicked.path);
                  if (!mounted) return;
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
                  if (!mounted) return;
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
            ButtonPicker(
              icon: const Icon(FontAwesomeIcons.itunesNote, color: Colors.white, size: 22),
              label: 'Song',
              widgetColor: Colors.deepPurple.shade400,
              function: () async {
                // Full Loader
                showFullPageLoader(context: context);
                // Take Mucic From Galery && Send Music Message
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

                // Remove FullLoader
                Navigator.pop(context);

                if (result != null) {
                  // Move to App Directory
                  PlatformFile musicfilePicked = result.files.first;
                  File musicfilePickedFILE = File(musicfilePicked.path!);

                  if (!mounted) return;
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
                  if (!mounted) return;
                  Navigator.pop(context, null);
                }
              },
            ),

            // Payment Picker
            ButtonPicker(
              icon: const Icon(FontAwesomeIcons.dollarSign, color: Colors.white, size: 22),
              label: 'Money',
              widgetColor: Colors.green.shade500,
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
            ButtonPicker(
              icon: const Icon(FontAwesomeIcons.gift, color: Colors.white, size: 22),
              label: 'Gift',
              widgetColor: Colors.orange.shade500,
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

// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import '../models/story.dart';
import '../pages/settings.pages/bug_report_page.dart';
import '../services/dynamiclink.service.dart';
import '../services/firestore.methods.dart';
import '../services/internet_connection_checker.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class StoryMoreOptionsModal extends StatefulWidget {
  final Story story;
  final bool isSuppressionBtnAllowed;
  final ScreenshotController storySreenshotController;

  const StoryMoreOptionsModal(
      {super.key, required this.story, required this.storySreenshotController, required this.isSuppressionBtnAllowed});

  @override
  State<StoryMoreOptionsModal> createState() => _StoryAllViewerModalState();
}

class _StoryAllViewerModalState extends State<StoryMoreOptionsModal> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'More',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 17.sp,
              ),
            ),
          ],
        ),
        // BODY
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Take a Story Screenshot: if StoryType == 'text' or 'image'
            widget.story.storyType == 'text' || widget.story.storyType == 'image'
                ? Expanded(
                    child: ButtonPicker(
                      icon: Icon(CupertinoIcons.viewfinder, color: Colors.white, size: 21.sp),
                      label: 'Capture',
                      widgetColor: Colors.green.shade500,
                      function: () async {
                        // Take Story screenshot

                        // Check WRITE_EXTERNAL_STORAGE permission
                        if (await Permission.storage.request().isGranted) {
                          //
                          showFullPageLoader(context: context, color: Colors.white);
                          //
                          List directories = await getDirectories();

                          final filename = '${appName}_story_${getUniqueId()}.jpg';
                          widget.storySreenshotController
                              .captureAndSave('${directories[0]}/$appName/${getSpecificDirByType('story')}',
                                  fileName: filename)
                              .then((value) {
                            // Dismiss loader
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            log('Screenshot: $value');
                            if (value!.contains('${appName}_story_')) {
                              if (!mounted) return;
                              Navigator.pop(
                                context,
                              );
                              showSnackbar(context, 'The story has been successfully saved!', kSuccessColor);
                            } else {
                              if (!mounted) return;
                              Navigator.pop(
                                context,
                              );
                              showSnackbar(context, 'An error occured! !', null);
                            }
                          });
                        } else {
                          //
                          log('Permission isn\'t granted !');

                          if (!mounted) return;
                          Navigator.pop(
                            context,
                          );
                          showSnackbar(context, 'We need permission to save screenshots!', null);
                        }
                      },
                    ),
                  )
                : Container(),

            // Bug report
            Expanded(
              child: ButtonPicker(
                icon: Icon(Icons.bug_report_outlined, color: Colors.white, size: 21.sp),
                label: 'Report',
                widgetColor: kSecondColor,
                function: () async {
                  // Redirect Bug Report Page
                  Navigator.push(context, SwipeablePageRoute(builder: (context) => const BugReportPage()));
                },
              ),
            ),

            // Share : Show Share Modal
            Expanded(
              child: ButtonPicker(
                icon: Icon(Icons.share_rounded, color: Colors.white, size: 21.sp),
                label: 'Share',
                widgetColor: Colors.blueGrey.shade500,
                function: () async {
                  // Share story
                  bool result = false;
                  // Case 1: text || image
                  if (widget.story.storyType == 'text' || widget.story.storyType == 'image') {
                    await widget.storySreenshotController
                        .capture(delay: const Duration(milliseconds: 10))
                        .then((Uint8List? image) async {
                      if (image != null) {
                        try {
                          // Create Wesh Story file [ApplicationDocumentsDirectory]
                          final directory = await getApplicationDocumentsDirectory();

                          var filename = '${appName}_story_${getUniqueId()}.jpg';
                          File('${directory.path}/${getSpecificDirByType('story')}/$filename')
                              .createSync(recursive: true);

                          final imagePath = await File('${directory.path}/${getSpecificDirByType('story')}/$filename')
                              .writeAsBytes(image);
                          log('Story to share: ${imagePath.path}');

                          /// Share Plugin
                          await Share.shareXFiles([XFile(imagePath.path)]);
                          log('Share succeeded');
                          setState(() {
                            result = true;
                          });
                        } catch (e) {
                          log('Erreur : $e');
                          setState(() {
                            result = false;
                          });
                        }
                      } else {
                        log('An error occured !');
                        setState(() {
                          result = false;
                        });
                      }
                    });
                  }
                  // Case 2: video
                  else if (widget.story.storyType == 'video') {
                    // Check internet connection

                    //
                    showFullPageLoader(context: context, color: Colors.white);
                    //

                    var isConnected = await InternetConnection.isConnected(context);
                    if (!mounted) return;
                    Navigator.pop(
                      context,
                    );
                    if (isConnected) {
                      log("Has connection : $isConnected");
                      // CONTINUE
                      /// Get PsterUser name
                      var userPosterName = await FirestoreMethods.getUserByIdAsFuture(widget.story.uid);

                      String shortenURL = '';

                      /// Shorten video link
                      shortenURL = await DynamicLinksService.createDynamicLink(widget.story.content);

                      /// Share Plugin
                      if (userPosterName != null) {
                        try {
                          await Share.share('$appName Story de ${userPosterName.name}: 🔗 $shortenURL');
                          log('Share succeeded');
                          log('Video text msg is: $appName Story de ${userPosterName.name}: 🔗$shortenURL');
                          result = true;
                        } catch (e) {
                          log('Erreur : $e');
                          result = false;
                        }
                      } else {
                        result = false;
                      }

                      // Check result
                      if (result) {
                        if (!mounted) return;
                        Navigator.pop(
                          context,
                        );
                      } else {
                        if (!mounted) return;
                        Navigator.pop(
                          context,
                        );
                        if (!mounted) return;
                        showSnackbar(context, 'An error occured! !', null);
                      }
                    } else {
                      log("Has connection : $isConnected");
                      if (!mounted) return;
                      showSnackbar(context, 'Please check your internet connection', null);
                    }
                  }
                },
              ),
            ),
          ],
        )
      ]),
    );
  }
}

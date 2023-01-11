import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
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
              'Plus d\'options',
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
        const SizedBox(
          height: 25,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bug report

            widget.isSuppressionBtnAllowed && widget.story.uid == FirebaseAuth.instance.currentUser!.uid
                ? Expanded(
                    child: buttonPicker(
                      icon: Icon(Icons.bug_report_outlined, color: Colors.white, size: 21.sp),
                      label: 'Un problème ?',
                      widgetColor: Colors.red,
                      function: () async {
                        // Redirect Bug Report Page
                        Navigator.push(context, SwipeablePageRoute(builder: (context) => const BugReportPage()));
                      },
                    ),
                  )
                : Container(),

            // Take a Story Screenshot: if StoryType == 'text' or 'image'
            widget.story.storyType == 'text' || widget.story.storyType == 'image'
                ? Expanded(
                    child: buttonPicker(
                      icon: Icon(CupertinoIcons.viewfinder, color: Colors.white, size: 21.sp),
                      label: 'Capturer',
                      widgetColor: Colors.grey.shade500,
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
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                            log('Screenshot: $value');
                            if (value!.contains('${appName}_story_')) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(
                                context,
                              );
                              showSnackbar(context, 'La story a bien été enregistrée !', kSuccessColor);
                            } else {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(
                                context,
                              );
                              showSnackbar(context, 'Une erreur s\'est produite !', null);
                            }
                          });
                        } else {
                          //
                          log('Permission isn\'t  granted !');

                          // ignore: use_build_context_synchronously
                          Navigator.pop(
                            context,
                          );
                          showSnackbar(context,
                              'Nous avons besoin d\'une permission pour enregistrer des captures d\'écran !', null);
                        }
                      },
                    ),
                  )
                : Container(),

            // Share : Show Share Modal
            Expanded(
              child: buttonPicker(
                icon: Icon(Icons.share_rounded, color: Colors.white, size: 21.sp),
                label: 'Partager',
                widgetColor: Colors.lightBlue.shade500,
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
                          await Share.shareFiles([imagePath.path]).onError((error, stackTrace) {
                            log('Erreur : $error');
                            setState(() {
                              result = false;
                            });
                          }).then((value) {
                            log('Share succeeded');
                            setState(() {
                              result = true;
                            });
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
                    // ignore: use_build_context_synchronously
                    Navigator.pop(
                      context,
                    );
                    if (isConnected) {
                      log("Has connection : $isConnected");
                      // CONTINUE
                      /// Get PsterUser name
                      var userPosterName = await FirestoreMethods.getUserByIdAsFuture(widget.story.uid);

                      String _shortenURL = '';

                      /// Shorten video link
                      _shortenURL = await DynamicLinksService.createDynamicLink(widget.story.content);

                      /// Share Plugin
                      if (userPosterName != null) {
                        await Share.share('$appName Story de ${userPosterName.name}: 🔗 $_shortenURL')
                            .onError((error, stackTrace) {
                          log('Erreur : $error');
                          result = false;
                        }).then((value) {
                          log('Share succeeded');
                          log('Video text msg is: $appName Story de ${userPosterName.name}: 🔗$_shortenURL');
                          result = true;
                        });
                      } else {
                        result = false;
                      }

                      // Check result
                      if (result) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(
                          context,
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(
                          context,
                        );
                        // ignore: use_build_context_synchronously
                        showSnackbar(context, 'Une erreur s\'est produite !', null);
                      }
                    } else {
                      log("Has connection : $isConnected");
                      // ignore: use_build_context_synchronously
                      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
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

import 'dart:io';
import 'dart:typed_data';
import 'package:external_path/external_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/story.dart';
import '../providers/user.provider.dart';
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
      {super.key,
      required this.story,
      required this.storySreenshotController,
      required this.isSuppressionBtnAllowed});

  @override
  State<StoryMoreOptionsModal> createState() => _StoryAllViewerModalState();
}

class _StoryAllViewerModalState extends State<StoryMoreOptionsModal> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // HEADER
          const Text(
            'Plus d\'options',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 19,
            ),
          ),
          // BODY
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              // Delete story

              widget.isSuppressionBtnAllowed &&
                      widget.story.uid == FirebaseAuth.instance.currentUser!.uid
                  ? Expanded(
                      child: buttonPicker(
                        icon: const Icon(FontAwesomeIcons.trash,
                            color: Colors.white, size: 21),
                        label: 'Supprimer',
                        widgetColor: Colors.red,
                        function: () async {
                          // Delete Story

                          // Show Delete Decision Modal
                          bool? deleteDecision = await showModalDecision(
                            context: context,
                            header: 'Supprimer',
                            content:
                                'Voulez-vous supprimer définitivement cette story ?',
                            firstButton: 'Annuler',
                            secondButton: 'Supprimer',
                          );

                          if (deleteDecision == true) {
                            // Delete event...
                            // ignore: use_build_context_synchronously
                            bool result = await FirestoreMethods().deleteStory(
                                context,
                                widget.story.storyId,
                                FirebaseAuth.instance.currentUser!.uid);
                            if (result) {
                              debugPrint('Story deleted !');

                              // ignore: use_build_context_synchronously
                              Navigator.pop(
                                context,
                              );
                              // ignore: use_build_context_synchronously
                              showSnackbar(
                                  context,
                                  'Votre story à bien été supprimée !',
                                  kSecondColor);
                            }
                          }
                        },
                      ),
                    )
                  : Container(),

              // Take a Story Screenshot: if StoryType == 'text' or 'image'
              widget.story.storyType == 'text' ||
                      widget.story.storyType == 'image'
                  ? Expanded(
                      child: buttonPicker(
                        icon: const Icon(FontAwesomeIcons.expand,
                            color: Colors.white, size: 21),
                        label: 'Capturer',
                        widgetColor: Colors.grey.shade500,
                        function: () async {
                          // Take Story screenshot

                          // Check WRITE_EXTERNAL_STORAGE permission
                          if (await Permission.storage.request().isGranted &&
                              await Permission.accessMediaLocation
                                  .request()
                                  .isGranted &&
                              await Permission.manageExternalStorage
                                  .request()
                                  .isGranted) {
                            // Create Wesh folder
                            var directory = await ExternalPath
                                .getExternalStorageDirectories();
                            Directory('${directory[0]}/$appName/Stories')
                                .createSync(recursive: true);

                            final filename =
                                '${appName}_story_${const Uuid().v4()}.jpg';
                            widget.storySreenshotController
                                .captureAndSave(
                                    '${directory[0]}/$appName/Stories',
                                    fileName: filename)
                                .then((value) {
                              debugPrint('Screenshot: $value');
                              if (value!.contains('${appName}_story_')) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(
                                  context,
                                );
                                showSnackbar(
                                    context,
                                    'La story a bien été enregistrée !',
                                    kSuccessColor);
                              } else {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(
                                  context,
                                );
                                showSnackbar(context,
                                    'Une erreur s\'est produite !', null);
                              }
                            });
                          } else {
                            //
                            debugPrint('Permission isn\'t  granted !');

                            // ignore: use_build_context_synchronously
                            Navigator.pop(
                              context,
                            );
                            showSnackbar(
                                context,
                                'Nous avons besoin d\'une permission pour enregistrer des captures d\'écran !',
                                null);
                          }
                        },
                      ),
                    )
                  : Container(),

              // Share : Show Share Modal
              Expanded(
                child: buttonPicker(
                  icon: const Icon(FontAwesomeIcons.share,
                      color: Colors.white, size: 21),
                  label: 'Partager',
                  widgetColor: Colors.lightBlue.shade500,
                  function: () async {
                    // Share story
                    bool result = false;

                    // Case 1: text || image
                    if (widget.story.storyType == 'text' ||
                        widget.story.storyType == 'image') {
                      await widget.storySreenshotController
                          .capture(delay: const Duration(milliseconds: 10))
                          .then((Uint8List? image) async {
                        if (image != null) {
                          try {
                            // Create Wesh Story file [ApplicationDocumentsDirectory]
                            final directory =
                                await getApplicationDocumentsDirectory();

                            var filename =
                                '${appName}_story_${const Uuid().v4()}.jpg';
                            File('${directory.path}/Stories/$filename')
                                .createSync(recursive: true);

                            final imagePath = await File(
                                    '${directory.path}/Stories/$filename')
                                .writeAsBytes(image);
                            debugPrint('Story to share: ${imagePath.path}');

                            /// Share Plugin
                            await Share.shareFiles([imagePath.path])
                                .onError((error, stackTrace) {
                              debugPrint('Erreur : $error');
                              setState(() {
                                result = false;
                              });
                            }).then((value) {
                              debugPrint('Share succeeded');
                              setState(() {
                                result = true;
                              });
                            });
                          } catch (e) {
                            debugPrint('Erreur : $e');
                            setState(() {
                              result = false;
                            });
                          }
                        } else {
                          debugPrint('An error occured !');
                          setState(() {
                            result = false;
                          });
                        }
                      });
                    }
                    // Case 2: video
                    else if (widget.story.storyType == 'video') {
                      // Check internet connection

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CupertinoActivityIndicator(
                              radius: 16, color: Colors.white),
                        ),
                      );
                      var isConnected =
                          await InternetConnection().isConnected(context);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(
                        context,
                      );
                      if (isConnected) {
                        debugPrint("Has connection : $isConnected");
                        // CONTINUE
                        /// Get PsterUser name
                        var userPosterName = await Provider.of<UserProvider>(
                                context,
                                listen: false)
                            .getFutureUserById(widget.story.uid);

                        String _shortenURL = '';

                        /// Shorten video link
                        _shortenURL =
                            await DynamicLinksService.createDynamicLink(
                                widget.story.content);

                        /// Share Plugin
                        if (userPosterName != null) {
                          await Share.share(
                                  '$appName Story de ${userPosterName.name}: 🔗 $_shortenURL')
                              .onError((error, stackTrace) {
                            debugPrint('Erreur : $error');
                            result = false;
                          }).then((value) {
                            debugPrint('Share succeeded');
                            debugPrint(
                                'Video text msg is: $appName Story de ${userPosterName.name}: 🔗$_shortenURL');
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
                          showSnackbar(
                              context, 'Une erreur s\'est produite !', null);
                        }
                      } else {
                        debugPrint("Has connection : $isConnected");
                        // ignore: use_build_context_synchronously
                        showSnackbar(context,
                            'Veuillez vérifier votre connexion internet', null);
                      }
                    }
                  },
                ),
              ),
            ],
          )
        ]));
  }
}

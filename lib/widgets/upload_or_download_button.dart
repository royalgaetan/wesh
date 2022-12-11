import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:external_path/external_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wesh/services/firestorage.methods.dart';
import '../pages/in.pages/fileviewer.dart';
import '../services/internet_connection_checker.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';

import 'dart:isolate';
import 'dart:ui';

late ReceivePort _port;

class UploadOrDowloadButton extends StatefulWidget {
  final String uidPoster;
  final String messageType;
  final String messageId;
  final String discussionId;
  final String fileName;
  final String thumbnailDownloadLink;
  final String fileDonwloadLink;
  final int status;
  final Function? rebuildWidget;

  const UploadOrDowloadButton({
    required Key key,
    required this.uidPoster,
    required this.messageType,
    required this.fileName,
    required this.messageId,
    required this.discussionId,
    required this.status,
    required this.thumbnailDownloadLink,
    required this.fileDonwloadLink,
    this.rebuildWidget,
  }) : super(key: key);

  @override
  State<UploadOrDowloadButton> createState() => _UploadOrDowloadButtonState();
}

class _UploadOrDowloadButtonState extends State<UploadOrDowloadButton> {
  List directories = [];
  bool fileExistence = false;
  //

  bool isUploadingOrDownloading = false;
  StreamController<num> progressStreamController = StreamController();
  Stream<num>? progressStream;
  num progressValue = 0;

  StreamController dowloadProgressStreamController = StreamController.broadcast();
  Stream? dowloadProgressStream;
  Map<String, dynamic> downloadProgressValues = {'': ''};
  String currentDownloadTaskID = '';
  String? taskId = '';

  StreamController<bool> cancelUploadingOrDownloadingController = StreamController.broadcast();

  rebuildWidget() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //
    getFileExistence();
    //
    cancelUploadingOrDownloadingController.add(false);
    //
    // if (widget.uidPoster == FirebaseAuth.instance.currentUser!.uid && widget.status == 0) {
    //   uploadOrDownloadMessageFile();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port_$taskId');
  }

  Future getFileExistence() async {
    directories = await getDirectories();
    File file = File('${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');
    File thumbnailFile = File(
        '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(widget.fileName)}');

    // Image && Video
    if (widget.messageType == 'image' || widget.messageType == 'video') {
      if (file.existsSync() && thumbnailFile.existsSync()) {
        setState(() {
          fileExistence = true;
        });
      } else {
        setState(() {
          fileExistence = false;
        });
      }
    }

    // Text, Payment, Voicenote, Music
    else {
      if (file.existsSync()) {
        setState(() {
          fileExistence = true;
        });
      } else {
        setState(() {
          fileExistence = false;
        });
      }
    }
  }

  cancelCurrentUploadorDownload() {
    cancelUploadingOrDownloadingController.add(true);
    setState(() {
      isUploadingOrDownloading = false;
    });
  }

  Future uploadOrDownloadMessageFile() async {
    isUploadingOrDownloading = true;
    directories = await getDirectories();

    // Upload Content
    if (widget.uidPoster == FirebaseAuth.instance.currentUser!.uid && widget.status == 0) {
      // Upload content

      progressStream = await FireStorageMethods().uploadMessageFile(
          context: context,
          type: widget.messageType,
          discussionId: widget.discussionId,
          filepath: '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}',
          thumbnailPath:
              '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(widget.fileName)}',
          messageId: widget.messageId,
          cancelStreamController: cancelUploadingOrDownloadingController);
      progressStream!.listen((event) {
        print('Progress value: $progressValue');
        setState(() {
          progressValue = event;
        });
        if (event == -1) {
          setState(() {
            isUploadingOrDownloading = false;
          });
        }
        if (event == 100) {
          setState(() {
            progressValue = 0;
            isUploadingOrDownloading = false;
            fileExistence = true;

            print('Data progress SUCC: $progressValue');
          });
        }
      });

      progressStreamController.add(progressValue);
    }
    // Download Content
    else {
      // Check Internet Connection
      var isConnected = await InternetConnection().isConnected(context);
      if (!isConnected) {
        // ignore: use_build_context_synchronously
        showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
        debugPrint("Has connection : $isConnected");

        return;
      }

      // Download Thumbnail
      await Future.wait(
        [
          FlutterDownloader.enqueue(
            url: widget.thumbnailDownloadLink,
            fileName: transformExtensionToThumbnailExt(widget.fileName),
            headers: {}, // optional: header send with url (auth token etc)
            savedDir: '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/',
            showNotification: false, // show download progress in status bar (for Android)
            openFileFromNotification: false, // click on notification to open downloaded file (for Android)
          ),
        ],
      );

      // Download File
      taskId = await FlutterDownloader.enqueue(
        url: widget.fileDonwloadLink,
        fileName: widget.fileName,
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/',
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );

      // Listen: Cancel Stream to cancel the downloading
      cancelUploadingOrDownloadingController.stream.listen((cancelValue) async {
        cancelValue = cancelValue;
        if (cancelValue == true) {
          FlutterDownloader.cancel(taskId: taskId!);
          FlutterDownloader.remove(taskId: taskId!, shouldDeleteContent: true);
          rebuildWidget();
          return;
        }
      });

      dowloadProgressStreamController.stream.asBroadcastStream().listen((event) {
        print('download values: $event');
        print('download values ID: ${event[0]}');
        if (event.isNotEmpty && taskId == event[0]) {
          setState(() {
            isUploadingOrDownloading = true;
            progressValue = event[2];
            print('Data progress: $progressValue');
          });

          // Download end with error or success
          if (progressValue == -1 || progressValue == 100) {
            setState(() {
              isUploadingOrDownloading = false;
              rebuildWidget();
            });
          }

          // Download end with error or success
          if (event[1] == DownloadTaskStatus.canceled || event[1] == DownloadTaskStatus.failed) {
            setState(() {
              progressValue = -1;
              isUploadingOrDownloading = false;
              print('Data progress ERR: $progressValue');
              rebuildWidget();
            });
          }

          // Download end with error or success
          if (event[1] == DownloadTaskStatus.complete) {
            setState(() {
              progressValue = 0;
              isUploadingOrDownloading = false;
              fileExistence = true;
              print('Data progress SUCC: $progressValue');
              rebuildWidget();
            });
          }
        }
      });

      ReceivePort _port = ReceivePort();

      IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port_$taskId');
      _port.asBroadcastStream().listen((data) {
        setState(() {
          dowloadProgressStreamController.add(data);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        // WHEN STILL EXIST IN USER MEMORY
        SizedBox(
      width: double.infinity,
      height: isUploadingOrDownloading ? getMessagePreviewCardHeight(widget.messageType) : null,
      child: Stack(
        alignment:
            widget.messageType != 'image' && widget.messageType != 'video' ? Alignment.centerLeft : Alignment.center,
        children: [
          // CENTER BTN
          () {
            // PLAY MODE
            if (isUploadingOrDownloading == false && fileExistence == true && widget.status != 0) {
              switch (widget.messageType) {
                case "image":
                  return Container();
                case "video":
                  return // Play Button
                      CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () async {
                      // Display Picture
                      File videoFile = File(
                          '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');
                      if (await videoFile.exists()) {
                        context.pushTransparentRoute(
                          FileViewer(
                              fileType: 'video',
                              fileName: widget.fileName,
                              data: widget.fileDonwloadLink,
                              thumbnail: widget.thumbnailDownloadLink),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 0.09.sw,
                      backgroundColor: Colors.black87.withOpacity(0.5),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 0.09.sw,
                      ),
                    ),
                  );

                case "music":
                  return Container();
                case "voicenote":
                  return Container();

                default:
                  return Container();
              }
            }

            // UPLOAD MODE
            if (widget.uidPoster == FirebaseAuth.instance.currentUser!.uid &&
                fileExistence == true &&
                widget.status == 0 &&
                progressValue != -1 &&
                isUploadingOrDownloading == false) {
              return CupertinoButton(
                onPressed: () async {
                  await uploadOrDownloadMessageFile();
                  widget.rebuildWidget!();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: widget.messageType != 'image' && widget.messageType != 'video' ? 0.07.sw : 0.09.sw,
                  backgroundColor: Colors.black87.withOpacity(0.5),
                  child: Icon(
                    Icons.file_upload_rounded,
                    color: Colors.white,
                    size: widget.messageType != 'image' && widget.messageType != 'video' ? 0.07.sw : 0.09.sw,
                  ),
                ),
              );
            }

            // DOWNLOAD MODE
            else if (widget.uidPoster != FirebaseAuth.instance.currentUser!.uid &&
                fileExistence == false &&
                widget.status != 0 &&
                progressValue != -1 &&
                widget.messageType != 'image' &&
                isUploadingOrDownloading == false) {
              return CupertinoButton(
                onPressed: () async {
                  await uploadOrDownloadMessageFile();
                  widget.rebuildWidget!();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: widget.messageType != 'image' &&
                          widget.messageType != 'video' &&
                          widget.messageType != 'music' &&
                          widget.messageType != 'voicenote'
                      ? 0.08.sw
                      : 0.09.sw,
                  backgroundColor: Colors.black87.withOpacity(0.5),
                  child: Icon(
                    Icons.download,
                    color: Colors.white,
                    size: widget.messageType != 'image' &&
                            widget.messageType != 'video' &&
                            widget.messageType != 'music' &&
                            widget.messageType != 'voicenote'
                        ? 0.08.sw
                        : 0.09.sw,
                  ),
                ),
              );
            }

            // RETRY MODE
            else if (progressValue == -1 && isUploadingOrDownloading == false) {
              return CupertinoButton(
                onPressed: () async {
                  await uploadOrDownloadMessageFile();
                  widget.rebuildWidget!();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: widget.messageType != 'image' && widget.messageType != 'video' ? 0.08.sw : 0.09.sw,
                  backgroundColor: Colors.black87.withOpacity(0.5),
                  child: Icon(
                    Icons.restart_alt_outlined,
                    color: Colors.white,
                    size: widget.messageType != 'image' && widget.messageType != 'video' ? 0.08.sw : 0.09.sw,
                  ),
                ),
              );
            }

            // IS DOWNLOADING OR UPLOADING
            else if (progressValue != -1 && isUploadingOrDownloading == true) {
              return CircleAvatar(
                radius: widget.messageType != 'image' && widget.messageType != 'video' ? 0.08.sw : 0.09.sw,
                backgroundColor: Colors.black87.withOpacity(0.5),
                child: LiquidCircularProgressIndicator(
                  value: progressValue.toDouble() / 100,
                  valueColor: AlwaysStoppedAnimation(kSecondColor.withOpacity(0.7)),
                  backgroundColor: Colors.black87.withOpacity(0.5),
                  direction: Axis.vertical,
                  center: Center(
                    child: Text(
                      '${progressValue.toStringAsFixed(0)} %',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }

            return Container();
          }(),

          // CANCEL BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: isUploadingOrDownloading,
                child: FittedBox(
                  child: CupertinoButton(
                    color: Colors.black87.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(horizontal: 0.02.sw, vertical: 0.01.sw),
                    borderRadius:
                        BorderRadius.circular(widget.messageType != 'image' && widget.messageType != 'video' ? 50 : 10),
                    child: Row(
                      children: [
                        Icon(Icons.close, size: 0.05.sw),
                        Visibility(
                          visible: widget.messageType != 'image' && widget.messageType != 'video' ? false : true,
                          child: Column(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Annuler',
                                style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      // Cancel uploading or downloading
                      cancelCurrentUploadorDownload();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:wesh/services/firestorage.methods.dart';
import '../pages/in.pages/fileviewer.dart';
import '../services/internet_connection_checker.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'dart:isolate';
import 'dart:ui';

late ReceivePort port;

class UploadOrDowloadButton extends StatefulWidget {
  final String uidPoster;
  final String messageType;
  final String messageId;
  final String discussionId;
  final String fileName;
  final String thumbnailDownloadLink;
  final String fileDonwloadLink;
  final int status;
  final Function(bool hasSucceed)? rebuildWidget;

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

    // For: Image Or Video
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

    // Else for: Text, Payment, Voicenote, Music
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
    setState(() {
      isUploadingOrDownloading = true;
      progressValue = 0;
    });
    directories = await getDirectories();

    // Upload Content
    if (widget.uidPoster == FirebaseAuth.instance.currentUser!.uid && widget.status == 0) {
      progressStream = FireStorageMethods.uploadMessageFile(
          context: context,
          type: widget.messageType,
          discussionId: widget.discussionId,
          filepath: '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}',
          thumbnailPath:
              '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(widget.fileName)}',
          messageId: widget.messageId,
          cancelStreamController: cancelUploadingOrDownloadingController);
      progressStream!.listen((event) {
        debugPrint('Progress value: $progressValue');
        setState(() {
          progressValue = event;
        });
        if (event == -1) {
          setState(() {
            progressValue = -1;
            isUploadingOrDownloading = false;
            debugPrint('Data progress [ERROR]: $progressValue');
          });
        }
        if (event == 100) {
          setState(() {
            progressValue = 0;
            isUploadingOrDownloading = false;
            fileExistence = true;
            debugPrint('Data progress [SUCCESS]: $progressValue');
          });

          widget.rebuildWidget!(fileExistence);
        }
      });

      progressStreamController.add(progressValue);
    }
    // Download Content
    else {
      // Check Internet Connection
      var isConnected = await InternetConnection.isConnected(context);
      if (!isConnected) {
        if (!mounted) return;
        showSnackbar(context, 'Please check your internet connection', null);
        debugPrint("Has connection : $isConnected");

        return;
      }

      // Download Thumbnail
      await FlutterDownloader.enqueue(
        url: widget.thumbnailDownloadLink,
        fileName: transformExtensionToThumbnailExt(widget.fileName),
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/',
        showNotification: false, // NO show download progress in status bar (for Android)
        openFileFromNotification: false, // NO click on notification to open downloaded file (for Android)
      );

      // Download File
      taskId = await FlutterDownloader.enqueue(
        url: widget.fileDonwloadLink,
        fileName: widget.fileName,
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/',
        showNotification: false, // NO show download progress in status bar (for Android)
        openFileFromNotification: false, // NO click on notification to open downloaded file (for Android)
      );

      // Listen: Cancel Stream to cancel the downloading
      cancelUploadingOrDownloadingController.stream.listen((cancelValue) async {
        cancelValue = cancelValue;
        if (cancelValue == true) {
          FlutterDownloader.cancel(taskId: taskId!);
          FlutterDownloader.remove(taskId: taskId!, shouldDeleteContent: true);
          setState(() {
            isUploadingOrDownloading = false;
          });
          return;
        }
      });

      // Listen: Download progression
      dowloadProgressStreamController.stream.asBroadcastStream().listen((event) {
        debugPrint('download values: $event');
        debugPrint('download values ID: ${event[0]}');
        if (event.isNotEmpty && taskId == event[0]) {
          setState(() {
            isUploadingOrDownloading = true;
            progressValue = event[2];
            debugPrint('Data progress: $progressValue');
          });

          // Download ended with error or failure
          if (event[1] == DownloadTaskStatus.canceled || event[1] == DownloadTaskStatus.failed || progressValue == -1) {
            setState(() {
              progressValue = -1;
              isUploadingOrDownloading = false;
              debugPrint('Data progress [ERROR]: $progressValue');
            });
            return;
          }

          // Download ended with success
          if (event[1] == DownloadTaskStatus.complete || progressValue == 100) {
            setState(() {
              isUploadingOrDownloading = false;
              fileExistence = true;
              progressValue = 0;
              debugPrint('Data progress [SUCCESS]: $progressValue');
            });
            dowloadProgressStreamController.close();
            widget.rebuildWidget!(fileExistence);
            return;
          }
        }
      });

      ReceivePort port = ReceivePort();

      IsolateNameServer.registerPortWithName(port.sendPort, 'downloader_send_port_$taskId');
      port.asBroadcastStream().listen((data) {
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
      height: isUploadingOrDownloading ? getMessagePreviewCardHeight(messageType: widget.messageType) : null,
      child: Stack(
        alignment:
            widget.messageType != 'image' && widget.messageType != 'video' ? Alignment.centerLeft : Alignment.center,
        children: [
          // CENTER BTN
          () {
            // PLAY MODE: only for video type
            if (isUploadingOrDownloading == false && fileExistence == true && widget.status != 0) {
              switch (widget.messageType) {
                case "image":
                  return Container();
                case "video":
                  // Play Button
                  return CupertinoButton(
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
                      radius: 27,
                      backgroundColor: Colors.black87.withOpacity(0.7),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
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
                onPressed: () {
                  uploadOrDownloadMessageFile();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: widget.messageType != 'image' && widget.messageType != 'video' ? 20 : 27,
                  backgroundColor: widget.messageType != 'image' && widget.messageType != 'video'
                      ? Colors.transparent
                      : Colors.black87.withOpacity(0.7),
                  child: Icon(
                    Icons.file_upload_outlined,
                    size: 30,
                    color: widget.messageType != 'image' && widget.messageType != 'video'
                        ? Colors.grey.shade700
                        : Colors.white,
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
                onPressed: () {
                  uploadOrDownloadMessageFile();
                },
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: widget.messageType != 'image' && widget.messageType != 'video' ? 20 : 27,
                  backgroundColor: widget.messageType != 'image' && widget.messageType != 'video'
                      ? Colors.transparent
                      : Colors.black87.withOpacity(0.7),
                  child: Icon(
                    Icons.file_download_outlined,
                    size: 27,
                    color: widget.messageType != 'image' && widget.messageType != 'video'
                        ? Colors.grey.shade700
                        : Colors.white,
                  ),
                ),
              );
            }

            // RETRY MODE
            else if (progressValue == -1 && isUploadingOrDownloading == false) {
              return CupertinoButton(
                onPressed: () {
                  uploadOrDownloadMessageFile();
                },
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  radius: widget.messageType != 'image' && widget.messageType != 'video' ? 20 : 27,
                  backgroundColor: widget.messageType != 'image' && widget.messageType != 'video'
                      ? Colors.transparent
                      : Colors.black87.withOpacity(0.7),
                  child: Icon(
                    widget.uidPoster == FirebaseAuth.instance.currentUser!.uid
                        ? Icons.file_upload_outlined
                        : Icons.file_download_outlined,
                    size: 27,
                    color: widget.messageType != 'image' && widget.messageType != 'video'
                        ? Colors.grey.shade700
                        : Colors.white,
                  ),
                ),
              );
            }

            // IS DOWNLOADING OR UPLOADING
            else if (progressValue != -1 && isUploadingOrDownloading == true) {
              return widget.messageType != 'image' && widget.messageType != 'video'
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        // Loader
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.transparent,
                          child: RepaintBoundary(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: CircularProgressIndicator(
                                // value: progressValue.toDouble() / 100,
                                strokeWidth: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),

                        // Cancel Button
                        GestureDetector(
                          onTap: () {
                            // Cancel uploading or downloading
                            cancelCurrentUploadorDownload();
                          },
                          child: const Icon(Icons.close, size: 15, color: Colors.black87),
                        ),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Download/Upload Progress Indicator
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.black87.withOpacity(0.7),
                          child: LiquidCircularProgressIndicator(
                            value: progressValue.toDouble() / 100,
                            valueColor: AlwaysStoppedAnimation(kSecondColor.withOpacity(0.7)),
                            backgroundColor: Colors.black87.withOpacity(0.7),
                            direction: Axis.vertical,
                            center: Center(
                              child: Text(
                                '${progressValue.toStringAsFixed(0)} %',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.sp),
                              ),
                            ),
                          ),
                        ),

                        // Cancel Button
                        Transform.translate(
                          offset: const Offset(50, 0),
                          child: GestureDetector(
                            onTap: () {
                              // Cancel uploading or downloading
                              cancelCurrentUploadorDownload();
                            },
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.black87.withOpacity(0.7),
                              child: const Icon(Icons.close, size: 15, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
            }

            return Container();
          }(),
        ],
      ),
    );
  }
}

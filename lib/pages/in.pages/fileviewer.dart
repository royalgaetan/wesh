import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:wesh/widgets/videowidget.dart';

class FileViewer extends StatefulWidget {
  final String fileType;
  final dynamic data;

  FileViewer({Key? key, required this.fileType, required this.data})
      : super(key: key);

  @override
  State<FileViewer> createState() => _FileviewerState();
}

class _FileviewerState extends State<FileViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // BODY: VIEWER
            Center(
                child: Column(
              children: [
                // IMAGE
                widget.fileType == 'image'
                    ? Expanded(
                        child: PhotoView(
                          imageProvider: FileImage(File(widget.data)),
                        ),
                      )
                    : Container(),

                // VIDEO
                widget.fileType == 'video'
                    ? Expanded(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VideoPlayerWidget(data: widget.data),
                        ],
                      ))
                    : Container(),

                // AUDIO

                // OTHERS
                // ...
              ],
            )),

            // CUSTOM APP BAR: VIEWER

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SafeArea(
                    child: IconButton(
                      splashRadius: 25,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
}

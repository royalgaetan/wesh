import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/widgets/videowidget.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/buildWidgets.dart';

class FileViewer extends StatefulWidget {
  final String fileType;
  final dynamic data;
  final String fileName;
  final String thumbnail;

  const FileViewer({
    super.key,
    required this.fileType,
    required this.data,
    required this.fileName,
    required this.thumbnail,
  });

  @override
  State<FileViewer> createState() => _FileviewerState();
}

class _FileviewerState extends State<FileViewer> {
  @override
  void initState() {
    super.initState();
    setSuitableStatusBarColor(Colors.black87);
  }

  @override
  void dispose() {
    super.dispose();
    setSuitableStatusBarColor(Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      minRadius: 0,
      onDismissed: () {
        // Pop the page
        setSuitableStatusBarColor(Colors.white);
        Navigator.of(context).pop();
      },
      direction: DismissiblePageDismissDirection.down,
      child: Scaffold(
        appBar: MorphingAppBar(
          scrolledUnderElevation: 0.0,
          heroTag: 'fileViewerPageAppBar',
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.black87,
        body: Stack(
          alignment: Alignment.topRight,
          children: [
            // BODY: VIEWER
            Center(
                child: Column(
              children: [
                // PROFILE PICTURE
                widget.fileType == 'profilePicture'
                    ? Expanded(
                        child: PhotoView(
                          imageProvider: NetworkImage(widget.data),
                        ),
                      )
                    : Container(),

                // IMAGE
                widget.fileType == 'image'
                    ? Expanded(
                        child: FutureBuilder(
                          future: getDirectories(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            // Handle error
                            if (snapshot.hasError) {
                              debugPrint('error: ${snapshot.error}');
                              return const Center(
                                child: BuildErrorWidget(),
                              );
                            }

                            // Display DATA
                            if (snapshot.hasData) {
                              var directories = snapshot.data;
                              File imageFile = File(
                                  '${directories[0]}/$appName/${getSpecificDirByType(widget.fileType)}/${widget.fileName}');

                              // IF file exist, then Display it:
                              if (imageFile.existsSync()) {
                                return Hero(
                                  tag: 'fileviewer_${widget.data}',
                                  child: PhotoView(
                                    imageProvider: NetworkToFileImage(url: widget.data, file: imageFile),
                                  ),
                                );
                              }
                              // NO FILE FOUND
                              else {
                                return Center(
                                  child: FittedBox(
                                    child: Container(
                                      padding: const EdgeInsets.all(13),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black87.withOpacity(0.3),
                                      ),
                                      child: const Text('This file has been moved or no longer exists!',
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                );
                              }
                            }

                            // Display Loader
                            return Center(
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black87.withOpacity(0.5),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(),

                // VIDEO
                widget.fileType == 'video'
                    ? Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FutureBuilder(
                              future: getDirectories(),
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                // Handle error
                                if (snapshot.hasError) {
                                  debugPrint('error: ${snapshot.error}');
                                  return const Center(
                                    child: BuildErrorWidget(),
                                  );
                                }

                                // Display DATA
                                if (snapshot.hasData) {
                                  var directories = snapshot.data;
                                  File videoFile = File(
                                      '${directories[0]}/$appName/${getSpecificDirByType(widget.fileType)}/${widget.fileName}');

                                  // IF file exist, then Display it:
                                  if (videoFile.existsSync()) {
                                    return VideoPlayerWidget(data: videoFile.path);
                                  }
                                  // NO FILE FOUND
                                  else {
                                    return Center(
                                      child: FittedBox(
                                        child: Container(
                                          padding: const EdgeInsets.all(13),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.black87.withOpacity(0.3),
                                          ),
                                          child: const Text('This file has been moved or no longer exists!',
                                              style: TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                    );
                                  }
                                }

                                // Display Loader
                                return Center(
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.black87.withOpacity(0.5),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, top: 5),
                      child: IconButton(
                        splashRadius: 0.06.sw,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 25.sp,
                        ),
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

import 'dart:io';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/models/message.dart';
import 'package:wesh/widgets/audio_wave_widget.dart';
import 'package:wesh/widgets/upload_or_download_button.dart';
import 'package:widget_size/widget_size.dart';
import '../pages/in.pages/fileviewer.dart';
import '../services/firestore.methods.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';
import 'eventview.dart';
import 'modal.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  final int currentMessageIndex;
  final Message nextMessage;
  final bool hasTheSameDateWithNextMessage;
  final int listMsgLength;
  final bool isMessageSelected;
  final Function() onScrollTo;
  final Function() onSwipe;

  const MessageCard({
    super.key,
    required this.message,
    required this.currentMessageIndex,
    required this.isMessageSelected,
    required this.onScrollTo,
    required this.nextMessage,
    required this.hasTheSameDateWithNextMessage,
    required this.listMsgLength,
    required this.onSwipe,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isLoading = false;
  Size messageCardHeight = const Size(0, 0);

  @override
  void initState() {
    super.initState();
    //
    FirestoreMethods.updateMessagesAsSeen(widget.message);
  }

  @override
  void dispose() {
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // GROUP DATETIME
            Visibility(
              visible: widget.currentMessageIndex == widget.listMsgLength - 1
                  ? true
                  : widget.hasTheSameDateWithNextMessage == true
                      ? false
                      : true,
              child: Container(
                constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width, maxWidth: MediaQuery.of(context).size.width),
                child: BuildGroupSeparatorWidget(
                  groupByValue: DateUtils.dateOnly(widget.message.createdAt),
                  simpleMode: false,
                ),
              ),
            ),

            SwipeTo(
              offsetDx: 0.2,
              onRightSwipe: (_) {
                widget.onSwipe();
              },
              child: Container(
                constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width, maxWidth: MediaQuery.of(context).size.width),
                child: Stack(
                  alignment: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                      ? AlignmentDirectional.topEnd
                      : AlignmentDirectional.topStart,
                  children: [
                    WidgetSize(
                      onChange: (Size size) {
                        // your Widget size available here
                        setState(() {
                          messageCardHeight = size;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid ? 80 : 5,
                              right: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid ? 5 : 80,
                              top: 3,
                              bottom: 4,
                            ),
                            constraints: BoxConstraints(minWidth: 0.1.sw, maxWidth: 0.7.sw),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                  ? kSecondColor.withOpacity(0.1)
                                  : const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                    ? const Radius.circular(20)
                                    : const Radius.circular(0),
                                bottomRight: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                    ? const Radius.circular(0)
                                    : const Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // MESSAGE TO REPLY || EVENT ATTACHED || STORY ATTACHED
                                Visibility(
                                  visible: widget.message.messageToReplyId == '' &&
                                          widget.message.messageToReplyData == '' &&
                                          widget.message.eventId == '' &&
                                          widget.message.storyId == ''
                                      ? false
                                      : true,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 0.1.sw, maxWidth: 0.7.sw),
                                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                          ? kSecondColor.withOpacity(0.2).withOpacity(0.1)
                                          : const Color.fromARGB(255, 228, 227, 227),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: () {
                                      // Display Message to reply
                                      if (widget.message.messageToReplyId != '' &&
                                          widget.message.messageToReplyData != '') {
                                        return GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: widget.onScrollTo,
                                          child: Wrap(
                                            children: [
                                              getMessageToReplyGridPreview(
                                                messageToReplyId: widget.message.messageToReplyId,
                                                messageToReplySenderId: widget.message.messageToReplySenderId,
                                                messageToReplyType: widget.message.messageToReplyType,
                                                messageToReplyCaption: widget.message.messageToReplyCaption,
                                                messageToReplyFilename: widget.message.messageToReplyFilename,
                                                messageToReplyData: widget.message.messageToReplyData,
                                                messageToReplyThumbnail: widget.message.messageToReplyThumbnail,
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      // Display Event Attached
                                      else if (widget.message.eventId != '') {
                                        return InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () {
                                            // Show EventViewer Modal
                                            showModalBottomSheet(
                                              enableDrag: true,
                                              isScrollControlled: true,
                                              context: context,
                                              backgroundColor: Colors.transparent,
                                              builder: ((context) => Modal(
                                                    minHeightSize: MediaQuery.of(context).size.height / 1.4,
                                                    maxHeightSize: MediaQuery.of(context).size.height,
                                                    child: EventView(eventId: widget.message.eventId),
                                                  )),
                                            );
                                          },
                                          child: getEventGridPreview(
                                            eventId: widget.message.eventId,
                                            hasDivider: false,
                                            baseColor: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                                ? kSecondColor.withOpacity(0.1).withOpacity(0.3)
                                                : Colors.grey.shade100,
                                            highlightColor:
                                                widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                                    ? kSecondColor.withOpacity(0.1).withOpacity(0.5)
                                                    : Colors.grey.shade200.withOpacity(.2),
                                          ),
                                        );
                                      }

                                      // Display Story Attached
                                      else if (widget.message.storyId != '') {
                                        return getStoryGridPreview(
                                          storyId: widget.message.storyId,
                                          hasDivider: false,
                                          baseColor: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                              ? kSecondColor.withOpacity(0.1).withOpacity(0.3)
                                              : Colors.grey.shade100,
                                          highlightColor:
                                              widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                                  ? kSecondColor.withOpacity(0.1).withOpacity(0.5)
                                                  : Colors.grey.shade200.withOpacity(.2),
                                        );
                                      }

                                      return Container();
                                    }(),
                                  ),
                                ),

                                // If Msg is an Image, Video, Music, Voicenote, Gift, Payment
                                BuildMessageDataSection(
                                  uidPoster: widget.message.senderId,
                                  data: widget.message.data,
                                  fileName: widget.message.filename,
                                  discussionId: widget.message.discussionId,
                                  messageId: widget.message.messageId,
                                  messageType: widget.message.type,
                                  status: widget.message.status,
                                  thumbnail: widget.message.thumbnail,
                                  paymentId: widget.message.paymentId,
                                ),

                                // Caption area
                                Wrap(
                                  children: [
                                    Visibility(
                                      visible: widget.message.caption.isEmpty ? false : true,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          widget.message.caption,
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13.sp,
                                              height: 1.4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Message Info: timestamps
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm', 'en').format(widget.message.createdAt),
                                        style: TextStyle(
                                            color: Colors.black54, fontSize: 10.sp, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 5),

                                      // Status: seen, read, sent, pending
                                      widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                          ? getMessageStatusIcon(widget.message)
                                          : Container()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Message Selection Mask
                    Visibility(
                      visible: widget.isMessageSelected ? true : false,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 0, maxWidth: MediaQuery.of(context).size.width),
                        width: MediaQuery.of(context).size.width,
                        height: messageCardHeight.height - 5,
                        color: Colors.green.shade400.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// If Msg is an Image, Video, Music, Voicenote, Gift, Payment
class BuildMessageDataSection extends StatefulWidget {
  final String uidPoster;
  final String messageId;
  final String messageType;
  final String fileName;
  final String discussionId;
  final String paymentId;
  final dynamic data;
  final dynamic thumbnail;
  final int status;

  const BuildMessageDataSection({
    super.key,
    required this.uidPoster,
    required this.discussionId,
    required this.messageId,
    required this.messageType,
    required this.fileName,
    required this.data,
    required this.thumbnail,
    required this.status,
    required this.paymentId,
  });

  @override
  State<BuildMessageDataSection> createState() => BuildMessageDataSectionState();
}

class BuildMessageDataSectionState extends State<BuildMessageDataSection> {
  bool isMusicOrVoicenoteFileExisting = false;

  rebuildWidget(bool hasSucceed) {
    if (hasSucceed) {
      setState(() {
        isMusicOrVoicenoteFileExisting = false;
        isMusicOrVoicenoteFileExisting = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return () {
      // MessageType == Text
      if (widget.messageType == 'text') {
        return Wrap(
          children: [
            Text(
              widget.data,
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13.sp, height: 1.4),
            ),
          ],
        );
      }

      // MessageType == Payment
      if (widget.messageType == 'payment' && widget.paymentId.isNotEmpty) {
        return Column(
          children: [
            BuildPaymentRow(
              paymentId: widget.paymentId,
            ),
            //

            widget.data != ''
                ? Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      widget.data,
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 12.sp),
                    ),
                  )
                : Container(),
          ],
        );
      }

      // MessageType == Image
      else if (widget.messageType == 'image') {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(top: 5, bottom: 7),
                width: double.infinity,
                child: () {
                  // Image Sent
                  if (widget.uidPoster == FirebaseAuth.instance.currentUser!.uid) {
                    return FutureBuilder(
                      future: getDirectories(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          debugPrint('error: ${snapshot.error}');
                          return const Center(
                            child: BuildErrorWidget(onWhiteBackground: true),
                          );
                        }

                        // Display DATA
                        if (snapshot.hasData) {
                          List directories = snapshot.data;
                          File imageFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');
                          File thumbnailFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(widget.fileName)}');

                          // IF file exist, then Display it:
                          if (imageFile.existsSync() && thumbnailFile.existsSync()) {
                            return GestureDetector(
                              onTap: () {
                                // Display Picture
                                if (imageFile.existsSync()) {
                                  context.pushTransparentRoute(
                                    FileViewer(
                                        fileType: 'image',
                                        fileName: widget.fileName,
                                        data: widget.data,
                                        thumbnail: widget.thumbnail),
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Hero(
                                  tag: 'fileviewer_${widget.messageId}',
                                  child: FutureBuilder<ImageProperties>(
                                    future: FlutterNativeImage.getImageProperties(imageFile.path),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                        return LayoutBuilder(builder: (context, constraints) {
                                          // Define Max Width & Image Dimensions
                                          double maxWidth = constraints.maxWidth;
                                          double imageWidth = (snapshot.data!.width ?? maxWidth).toDouble();
                                          double imageHeight = (snapshot.data!.height ?? 0.45.sh).toDouble();

                                          // If the image width is greater than the max width, scale it down
                                          if (imageWidth > maxWidth) {
                                            final scaleFactor = maxWidth / imageWidth;
                                            imageWidth *= scaleFactor;
                                            imageHeight *= scaleFactor;
                                          }

                                          return ProgressiveImage(
                                            height: imageHeight,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: const AssetImage(darkBackground),
                                            thumbnail: FileImage(thumbnailFile),
                                            image: FileImage(imageFile),
                                          );
                                        });
                                      } else {
                                        return const BuildFileLoader();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          }
                          // NO FILE FOUND
                          else {
                            return const BuildNoFileFoundWidget();
                          }
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const RepaintBoundary(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Image Received
                  else {
                    return FutureBuilder(
                      future: getDirectories(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          debugPrint('error: ${snapshot.error}');
                          return const Center(
                            child: BuildErrorWidget(onWhiteBackground: true),
                          );
                        }

                        // Display DATA
                        if (snapshot.hasData) {
                          var directories = snapshot.data;
                          File imageFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');
                          File thumbnailFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(widget.fileName)}');

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                              onTap: () {
                                // Display Picture
                                if (imageFile.existsSync()) {
                                  context.pushTransparentRoute(
                                    FileViewer(
                                        fileType: 'image',
                                        fileName: widget.fileName,
                                        data: widget.data,
                                        thumbnail: widget.thumbnail),
                                  );
                                }
                              },
                              child: Hero(
                                tag: 'fileviewer_${widget.messageId}',
                                child: FutureBuilder<ImageProperties>(
                                  future: FlutterNativeImage.getImageProperties(imageFile.path),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                      return LayoutBuilder(builder: (context, constraints) {
                                        // Define Max Width & Image Dimensions
                                        double maxWidth = constraints.maxWidth;
                                        double imageWidth = (snapshot.data!.width ?? maxWidth).toDouble();
                                        double imageHeight = (snapshot.data!.height ?? 0.45.sh).toDouble();

                                        // If the image width is greater than the max width, scale it down
                                        if (imageWidth > maxWidth) {
                                          final scaleFactor = maxWidth / imageWidth;
                                          imageWidth *= scaleFactor;
                                          imageHeight *= scaleFactor;
                                        }

                                        return ProgressiveImage(
                                          height: imageHeight,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: const AssetImage(darkBackground),
                                          thumbnail: NetworkToFileImage(url: widget.thumbnail, file: thumbnailFile),
                                          image: NetworkToFileImage(url: widget.data, file: imageFile),
                                        );
                                      });
                                    } else {
                                      return const BuildFileLoader();
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const RepaintBoundary(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }()),

            // Download/Upload Image Button
            UploadOrDowloadButton(
              key: const Key('A'),
              fileName: widget.fileName,
              discussionId: widget.discussionId,
              fileDonwloadLink: widget.data,
              thumbnailDownloadLink: widget.thumbnail,
              messageId: widget.messageId,
              messageType: widget.messageType,
              uidPoster: widget.uidPoster,
              status: widget.status,
            )
          ],
        );
      }

      // MessageType == Video
      else if (widget.messageType == 'video') {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                width: double.infinity,
                child: () {
                  // Video Sent
                  if (widget.uidPoster == FirebaseAuth.instance.currentUser!.uid) {
                    return FutureBuilder(
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
                              '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');
                          File thumbnailFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(widget.fileName)}');

                          // IF file exist, then Display it:
                          if (videoFile.existsSync()) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Thumbnail
                                  ProgressiveImage(
                                    height: getMessagePreviewCardHeight(
                                        messageType: widget.messageType, filepath: thumbnailFile.path),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage(darkBackground),
                                    //
                                    thumbnail: FileImage(thumbnailFile),
                                    //
                                    image: FileImage(thumbnailFile),
                                  ),
                                ],
                              ),
                            );
                          }
                          // NO FILE FOUND
                          else {
                            return const BuildNoFileFoundWidget();
                          }
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const RepaintBoundary(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Video Received
                  else {
                    return FutureBuilder(
                      future: getDirectories(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          debugPrint('error: ${snapshot.error}');
                          return const Center(
                            child: BuildErrorWidget(onWhiteBackground: true),
                          );
                        }

                        // Display DATA
                        if (snapshot.hasData) {
                          var directories = snapshot.data;
                          File thumbnailFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(widget.fileName)}');

                          //
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ProgressiveImage(
                              height: getMessagePreviewCardHeight(
                                  messageType: widget.messageType, filepath: thumbnailFile.path),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: const AssetImage(darkBackground),
                              //
                              thumbnail: NetworkToFileImage(url: widget.thumbnail, file: thumbnailFile),
                              //
                              image: NetworkToFileImage(url: widget.thumbnail, file: thumbnailFile),
                            ),
                          );
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const RepaintBoundary(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }()),

            // Download/Upload Video Button
            UploadOrDowloadButton(
              key: Key(widget.fileName),
              fileName: widget.fileName,
              fileDonwloadLink: widget.data,
              thumbnailDownloadLink: widget.thumbnail,
              messageId: widget.messageId,
              discussionId: widget.discussionId,
              messageType: widget.messageType,
              uidPoster: widget.uidPoster,
              status: widget.status,
            )
          ],
        );
      }

      // MessageType == Music OR MessageType == Voicenote
      else if (widget.messageType == 'music' || widget.messageType == 'voicenote') {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                width: double.infinity,
                child: () {
                  // Music or Voicenote Sent
                  if (widget.uidPoster == FirebaseAuth.instance.currentUser!.uid) {
                    return FutureBuilder(
                      future: getDirectories(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          debugPrint('error: ${snapshot.error}');
                          return const Center(
                            child: BuildErrorWidget(onWhiteBackground: true),
                          );
                        }

                        // Display DATA
                        if (snapshot.hasData) {
                          var directories = snapshot.data;
                          File musicFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');

                          isMusicOrVoicenoteFileExisting = musicFile.existsSync();

                          // IF file exist, then Display it:
                          if (isMusicOrVoicenoteFileExisting && widget.status >= 1) {
                            return AudioWaveWidget(path: musicFile.path, isDark: true);
                          }

                          // NO FILE FOUND
                          else if (!isMusicOrVoicenoteFileExisting) {
                            return const BuildNoFileFoundWidget();
                          } else if (widget.status == 0) {
                            return Row(
                              children: [
                                const SizedBox(width: 40),
                                Expanded(
                                  child: Container(
                                    height: 20,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: const DecorationImage(image: AssetImage(soundWaves), fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 0.095.sw),
                              ],
                            );
                          }
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const RepaintBoundary(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Music or Voicenote Received
                  else {
                    return FutureBuilder(
                      future: getDirectories(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          debugPrint('error: ${snapshot.error}');
                          return const Center(
                            child: BuildErrorWidget(onWhiteBackground: true),
                          );
                        }

                        // Display DATA
                        if (snapshot.hasData) {
                          var directories = snapshot.data;
                          File musicFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');

                          isMusicOrVoicenoteFileExisting = musicFile.existsSync();

                          // IF file exist, then Display it:
                          if (isMusicOrVoicenoteFileExisting) {
                            return AudioWaveWidget(path: musicFile.path, isDark: true);
                          }

                          // NO FILE FOUND : DISPLAY NOTHING
                          else {
                            return Row(
                              children: [
                                const SizedBox(width: 40),
                                Expanded(
                                  child: Container(
                                    height: 20,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: const DecorationImage(image: AssetImage(soundWaves), fit: BoxFit.cover),
                                    ),
                                    // child: const Text('This file has been moved or no longer exists!',
                                    //     style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                SizedBox(width: 0.095.sw),
                              ],
                            );
                          }
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const RepaintBoundary(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }()),

            // Download/Upload Music or Voicenote Button
            UploadOrDowloadButton(
              key: Key(widget.fileName),
              fileName: widget.fileName,
              fileDonwloadLink: widget.data,
              thumbnailDownloadLink: widget.thumbnail,
              messageId: widget.messageId,
              discussionId: widget.discussionId,
              messageType: widget.messageType,
              uidPoster: widget.uidPoster,
              status: widget.status,
              rebuildWidget: rebuildWidget,
            )
          ],
        );
      }

      return Container();
    }();
  }
}

class BuildNoFileFoundWidget extends StatelessWidget {
  const BuildNoFileFoundWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black87.withOpacity(0.3),
          ),
          child: const Text('This file has been moved or no longer exists!', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class BuildFileLoader extends StatelessWidget {
  const BuildFileLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.black87.withOpacity(0.5),
        child: const SizedBox(
          width: 15,
          height: 15,
          child: RepaintBoundary(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.4),
          ),
        ),
      ),
    );
  }
}

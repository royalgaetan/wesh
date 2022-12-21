import 'dart:io';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/models/message.dart';
import 'package:wesh/widgets/audiowidget.dart';
import 'package:wesh/widgets/upload_or_download_button.dart';
import 'package:widget_size/widget_size.dart';
import '../pages/in.pages/fileviewer.dart';
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
    Key? key,
    required this.message,
    required this.currentMessageIndex,
    required this.isMessageSelected,
    required this.onScrollTo,
    required this.nextMessage,
    required this.hasTheSameDateWithNextMessage,
    required this.listMsgLength,
    required this.onSwipe,
  }) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isLoading = false;
  Size messageCardHeight = const Size(0, 0);

  @override
  void initState() {
    super.initState();
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
                child: buildGroupSeparatorWidget(
                  groupByValue: DateUtils.dateOnly(widget.message.createdAt),
                  simpleMode: false,
                ),
              ),
            ),

            SwipeTo(
              offsetDx: 0.2,
              onRightSwipe: widget.onSwipe,
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
                                    padding: const EdgeInsets.only(right: 5, bottom: 5),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                          ? kSecondColor.withOpacity(0.2).withOpacity(0.1)
                                          : const Color.fromARGB(255, 228, 227, 227),
                                      borderRadius: BorderRadius.circular(20),
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
                                          child:
                                              getEventGridPreview(eventId: widget.message.eventId, hasDivider: false),
                                        );
                                      }

                                      // Display Story Attached
                                      else if (widget.message.storyId != '') {
                                        return getStoryGridPreview(storyId: widget.message.storyId, hasDivider: false);
                                      }

                                      return Container();
                                    }(),
                                  ),
                                ),

                                // If Msg is an Image, Video, Music, Voicenote, Gift, Payment
                                buildMessageDataSection(
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
                                const SizedBox(
                                  height: 5,
                                ),

                                // Caption area
                                Wrap(
                                  children: [
                                    Visibility(
                                      visible: widget.message.caption.isEmpty ? false : true,
                                      child: Text(
                                        widget.message.caption,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Message Info
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm', 'fr').format(widget.message.createdAt),
                                        style: TextStyle(
                                            color: Colors.black54, fontSize: 11.sp, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),

                                      // Status: doubleticks, seen, sent, pending
                                      widget.message.senderId == FirebaseAuth.instance.currentUser!.uid
                                          ? getMessageStatusIcon(widget.message.status)
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
class buildMessageDataSection extends StatefulWidget {
  final String uidPoster;
  final String messageId;
  final String messageType;
  final String fileName;
  final String discussionId;
  final String paymentId;
  final dynamic data;
  final dynamic thumbnail;
  final int status;

  const buildMessageDataSection({
    Key? key,
    required this.uidPoster,
    required this.discussionId,
    required this.messageId,
    required this.messageType,
    required this.fileName,
    required this.data,
    required this.thumbnail,
    required this.status,
    required this.paymentId,
  }) : super(key: key);

  @override
  State<buildMessageDataSection> createState() => _buildMessageDataSectionState();
}

class _buildMessageDataSectionState extends State<buildMessageDataSection> {
  rebuildWidget() {
    setState(() {});
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
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        );
      }

      // MessageType == Payment
      if (widget.messageType == 'payment' && widget.paymentId.isNotEmpty) {
        return Column(
          children: [
            buildPaymentRow(
              paymentId: widget.paymentId,
            ),
            //

            widget.data != ''
                ? Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      widget.data,
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
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
                margin: const EdgeInsets.only(top: 5, bottom: 10),
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
                            child: buildErrorWidget(),
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
                                  tag: 'fileviewer_${widget.data}',
                                  child: ProgressiveImage(
                                    height: getMessagePreviewCardHeight(widget.messageType),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage(darkBackground),
                                    //
                                    thumbnail: FileImage(thumbnailFile),
                                    //
                                    image: FileImage(imageFile),
                                  ),
                                ),
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
                                  child: const Text('Ce fichier a été déplacé ou n\'existe plus !',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            );
                          }
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
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
                            child: buildErrorWidget(),
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
                                tag: 'fileviewer_${widget.data}',
                                child: ProgressiveImage(
                                  height: getMessagePreviewCardHeight(widget.messageType),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(darkBackground),
                                  //
                                  thumbnail: NetworkToFileImage(url: widget.thumbnail, file: thumbnailFile),
                                  //
                                  image: NetworkToFileImage(url: widget.data, file: imageFile),
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
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  }
                }()),

            // Download Image Button
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
                            child: buildErrorWidget(),
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
                                    height: getMessagePreviewCardHeight(widget.messageType),
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
                            return Center(
                              child: FittedBox(
                                child: Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black87.withOpacity(0.3),
                                  ),
                                  child: const Text('Ce fichier a été déplacé ou n\'existe plus !',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            );
                          }
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
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
                            child: buildErrorWidget(),
                          );
                        }

                        // Display DATA
                        if (snapshot.hasData) {
                          var directories = snapshot.data;
                          File videoFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');
                          File thumbnailFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType('thumbnail')}/${transformExtensionToThumbnailExt(widget.fileName)}');

                          //
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ProgressiveImage(
                              height: getMessagePreviewCardHeight(widget.messageType),
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
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  }
                }()),

            // Download Video Button
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
                  // Music Sent
                  if (widget.uidPoster == FirebaseAuth.instance.currentUser!.uid) {
                    return FutureBuilder(
                      future: getDirectories(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          debugPrint('error: ${snapshot.error}');
                          return const Center(
                            child: buildErrorWidget(),
                          );
                        }

                        // Display DATA
                        if (snapshot.hasData) {
                          var directories = snapshot.data;
                          File musicFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');

                          // IF file exist, then Display it:
                          if (musicFile.existsSync()) {
                            if (widget.status == 1) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AudioWidget(data: musicFile.path, displaySpeedUpBtn: false),
                              );
                            } else if (widget.status == 0) {
                              return Row(
                                children: [
                                  SizedBox(width: 0.15.sw),
                                  Expanded(
                                    child: Container(
                                      height: getMessagePreviewCardHeight(widget.messageType),
                                      width: 0.044.sw,
                                      padding: const EdgeInsets.all(13),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: const DecorationImage(image: AssetImage(soundWaves), fit: BoxFit.cover),
                                      ),
                                      // child: const Text('Ce fichier a été déplacé ou n\'existe plus !',
                                      //     style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(width: 0.095.sw),
                                ],
                              );
                            }
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
                                  child: const Text('Ce fichier a été déplacé ou n\'existe plus !',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            );
                          }
                        }

                        // Display Loader
                        return Center(
                          child: CircleAvatar(
                            radius: 0.09.sw,
                            backgroundColor: Colors.black87.withOpacity(0.5),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Music Received
                  else {
                    return FutureBuilder(
                      future: getDirectories(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          debugPrint('error: ${snapshot.error}');
                          return const Center(
                            child: buildErrorWidget(),
                          );
                        }

                        // Display DATA
                        if (snapshot.hasData) {
                          var directories = snapshot.data;
                          File musicFile = File(
                              '${directories[0]}/$appName/${getSpecificDirByType(widget.messageType)}/${widget.fileName}');

                          // IF file exist, then Display it:

                          if (musicFile.existsSync() == true) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AudioWidget(data: musicFile.path, displaySpeedUpBtn: false),
                            );
                          }

                          // NO FILE FOUND : DISPLAY NOTHING
                          else {
                            return Row(
                              children: [
                                SizedBox(width: 0.15.sw),
                                Expanded(
                                  child: Container(
                                    height: getMessagePreviewCardHeight(widget.messageType),
                                    width: 0.044.sw,
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: const DecorationImage(image: AssetImage(soundWaves), fit: BoxFit.cover),
                                    ),
                                    // child: const Text('Ce fichier a été déplacé ou n\'existe plus !',
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
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  }
                }()),

            // Download Video Button
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

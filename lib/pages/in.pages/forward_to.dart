// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/in.pages/inbox.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/usercard.dart';
import '../../models/discussion.dart';
import '../../models/story.dart';
import '../../services/firestorage.methods.dart';
import '../../services/firestore.methods.dart';
import '../../models/user.dart' as usermodel;
import '../../models/message.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';

class ForwardToPage extends StatefulWidget {
  final String typeToForward;
  final List<Message>? messagesToForward;
  final List<Map<String, Object>>? mediaSharedToForward;
  final String previousPageName;

  const ForwardToPage({
    super.key,
    required this.previousPageName,
    required this.typeToForward,
    this.messagesToForward,
    this.mediaSharedToForward,
  });

  @override
  State<ForwardToPage> createState() => _ForwardToPageState();
}

class _ForwardToPageState extends State<ForwardToPage> {
  //
  final TextEditingController _searchtextcontroller = TextEditingController();
  //
  String _searchQuery = '';
  //

  @override
  void initState() {
    super.initState();
    //
  }

  @override
  void dispose() {
    // Reset Receiver_intent
    ReceiveSharingIntent.instance.reset();
    super.dispose();
  }

//
  Future<List<Map<String, String>>> getDataToForward() async {
    List directories = await getDirectories();
    List<Map<String, String>> dataToForward = [];

    // Forward [Messages] to [My] Story
    if (widget.typeToForward == 'messages' && widget.messagesToForward != null) {
      for (Message message in widget.messagesToForward ?? []) {
        // Text message
        if (message.type == 'text') {
          Map<String, String> dataMap = {
            'data': message.data.substring(0, message.data.length > 500 ? 500 : message.data.length),
            'type': message.type
          };
          dataToForward.add(dataMap);
        }
        // Non-Text message
        else if (message.type != 'text') {
          File messageFile =
              File('${directories[0]}/$appName/${getSpecificDirByType(message.type)}/${message.filename}');
          dev.log('FILE SIZE ${messageFile.lengthSync() / 1000000}');

          // Check file size : limit to 15MB fileLimitSize15MB
          if (messageFile.lengthSync() < fileLimitSize15MB) {
            Map<String, String> dataMap = {'data': messageFile.path, 'type': message.type};
            dataToForward.add(dataMap);
          }
        }
      }
    }
    // [VIA] SHARED CONTENT
    else if (widget.typeToForward == 'contentShared') {
      for (Map<String, Object> mediaShared in widget.mediaSharedToForward ?? []) {
        // FOR TEXT/URL: if it's text or url
        if (mediaShared['type'] == SharedMediaType.text || mediaShared['type'] == SharedMediaType.url) {
          Map<String, String> dataMap = {
            'data': (mediaShared['data'] as String).substring(
                0, (mediaShared['data'] as String).length > 500 ? 500 : (mediaShared['data'] as String).length),
            'type': 'text'
          };
          dataToForward.add(dataMap);
        }

        // FOR MEDIA: if it's media (video, image, etc.)
        // Check file size 1st
        File contentFile = File(mediaShared['data'] as String);
        dev.log('FILE SIZE ${contentFile.lengthSync() / 1000000}');
        if (contentFile.lengthSync() < fileLimitSize15MB) {
          // Image
          if (mediaShared['type'] == SharedMediaType.image) {
            Map<String, String> dataMap = {'data': (mediaShared['data'] as String), 'type': 'image'};
            dataToForward.add(dataMap);
          }
          // Video
          if (mediaShared['type'] == SharedMediaType.video) {
            Map<String, String> dataMap = {'data': (mediaShared['data'] as String), 'type': 'video'};
            dataToForward.add(dataMap);
          }
          // Music
          if (mediaShared['type'] == SharedMediaType.file && isAudio(mediaShared['data'] as String)) {
            Map<String, String> dataMap = {'data': (mediaShared['data'] as String), 'type': 'music'};
            dataToForward.add(dataMap);
          }
        }
      }
    }
    // RETURN DATA...
    return dataToForward;
  }

  //
  //
  //

  // Forward As Story : [My] Story
  forwardToMyStory(List<Map<String, String>> dataToForward) async {
    // Loader
    showFullPageLoader(context: context);

    //
    List<bool> resultsList = [];

    //
    dev.log('Data to forward : $dataToForward');
    if (dataToForward.isNotEmpty) {
      for (Map<String, String> data in dataToForward) {
        //

        // Forbidden to forward Music or Audio file to Stories
        if (data['type'] == 'music' || data['type'] == 'voicenote') {
          debugPrint('[OPERATION FORBIDDEN] Can\'t forward ${data['type']} --> my Story...');
          resultsList.add(false);
        }

        // Forward Text
        if (data['type'] == 'text') {
          debugPrint('Forwarding text --> my Story...');
          // Modeling a new Text Story
          Map<String, dynamic> newTextStory = Story(
              storyId: '',
              content: (data['data'] as String),
              uid: FirebaseAuth.instance.currentUser!.uid,
              bgColor: Random().nextInt(storiesAvailableColorsList.length),
              fontType: Random().nextInt(storiesAvailableFontsList.length),
              storyType: (data['type'] as String),
              caption: '',
              videoThumbnail: '',
              eventId: '',
              createdAt: DateTime.now(),
              endAt: DateTime.now().add(const Duration(hours: 24)),
              viewers: []).toJson();

          debugPrint('Story created : $newTextStory');

          //  Update Firestore Stories Table
          bool result =
              await FirestoreMethods.createStory(context, FirebaseAuth.instance.currentUser!.uid, newTextStory);
          resultsList.add(result);
        }

        // Forward Image
        if (data['type'] == 'image') {
          debugPrint('Forwarding image --> my Story...');

          // Upload StoryImage to Firestorage and getDownloadURL

          //
          // Compress File : Only for Image Message
          // Compress File : size > 2MB
          File imageFile = File(data['data'] as String);
          if (imageFile.lengthSync() > fileLimitSize2MB) {
            // Resize file
            imageFile = await resizeImageFile(filePath: imageFile.path);
          }

          List resultFromStoryImageFile = await FireStorageMethods.uploadStoryContent(context, imageFile.path, 'image');
          bool isAllowToContinue = resultFromStoryImageFile[0];
          String downloadUrl = resultFromStoryImageFile[1];

          if (isAllowToContinue && downloadUrl.isNotEmpty) {
            // Modeling a new Image Story
            Map<String, dynamic> newImageStory = Story(
                storyId: '',
                content: downloadUrl,
                uid: FirebaseAuth.instance.currentUser!.uid,
                bgColor: 0,
                fontType: 0,
                storyType: (data['type'] as String),
                caption: '',
                videoThumbnail: '',
                eventId: '',
                createdAt: DateTime.now(),
                endAt: DateTime.now().add(const Duration(hours: 24)),
                viewers: []).toJson();

            debugPrint('Story modelled : $newImageStory');

            //  Update Firestore Stories Table
            bool result =
                await FirestoreMethods.createStory(context, FirebaseAuth.instance.currentUser!.uid, newImageStory);
            resultsList.add(result);
          } else {
            resultsList.add(false);
          }
        }

        // Forward Video
        if (data['type'] == 'video') {
          debugPrint('Forwarding video --> my Story...');

          //
          // STORY VIDEO FILE
          //

          // Upload StoryVideo to Firestorage and getDownloadURL

          List resultFromStoryVidFile = await FireStorageMethods.uploadStoryContent(context, data['data'], 'video');
          bool isAllowToContinue = resultFromStoryVidFile[0];
          String downloadUrl = resultFromStoryVidFile[1];

          //
          // STORY VIDEO THUMBNAIL
          //

          // Upload StoryVideo Thumbnail to Firestorage and get Thumbnail downloadUrl
          String vidhumbnailInString = await getVideoThumbnail(data['data']) ?? '';

          List resultFromStoryVidThumbnailFile =
              await FireStorageMethods.uploadStoryContent(context, vidhumbnailInString, 'vidThumbnail');
          isAllowToContinue = resultFromStoryVidThumbnailFile[0];
          String thumbnailVideoDownloadUrl = resultFromStoryVidThumbnailFile[1];

          if (isAllowToContinue && downloadUrl.isNotEmpty && thumbnailVideoDownloadUrl.isNotEmpty) {
            // Modeling a new Video Story
            Map<String, dynamic> newVideoStory = Story(
                storyId: '',
                content: downloadUrl,
                uid: FirebaseAuth.instance.currentUser!.uid,
                bgColor: 0,
                fontType: 0,
                storyType: (data['type'] as String),
                videoThumbnail: thumbnailVideoDownloadUrl,
                caption: '',
                eventId: '',
                createdAt: DateTime.now(),
                endAt: DateTime.now().add(const Duration(hours: 24)),
                viewers: []).toJson();

            debugPrint('Story created : $newVideoStory');

            //  Update Firestore Stories Table
            bool result =
                await FirestoreMethods.createStory(context, FirebaseAuth.instance.currentUser!.uid, newVideoStory);

            resultsList.add(result);
          } else {
            resultsList.add(false);
          }
        }
      }
    }

    // Reset Receiver_intent
    ReceiveSharingIntent.instance.reset();

    // Pop the Loader Modal
    if (!mounted) return;
    Navigator.of(context).pop();
    if (resultsList.isEmpty || resultsList.contains(false)) {
      showSnackbar(
        context,
        resultsList.length <= 1
            ? 'Unable to share this story!'
            : 'Some stories were shared successfully, but others failed!',
        resultsList.length == 1 ? kSecondColor : null,
      );
    } else {
      if (!mounted) return;
      showSnackbar(
        context,
        resultsList.length == 1 ? 'Your story was shared successfully!' : 'Your stories were shared successfully!',
        kSuccessColor,
      );
    }

    // PROCESS FINISHED
    dev.log('Story posting process finished !');

    // Reset Receiver_intent
    ReceiveSharingIntent.instance.reset();

    // Pop the screen
    if (widget.previousPageName == 'inbox') {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacement(
        context,
        SwipeablePageRoute(
          builder: (context) {
            return StartPage(
              context: context,
              initTabIndex: 3,
            );
          },
        ),
      );
    }
  }

  // Forward As Message : to [Another] User
  forwardAsMessage(String anotherUserId, List<Map<String, String>> dataToForward) async {
    // Loader
    showFullPageLoader(context: context);
    //
    List<bool> resultsList = [];

    //
    dev.log('Data to forward : $dataToForward');
    if (dataToForward.isNotEmpty) {
      // FORWARD ALL MESSAGES
      for (Map<String, String> data in dataToForward) {
        String type = (data['type'] as String);
        String dataPath = (data['data'] as String);

        await sendMessage(
          context: context,
          userReceiverId: anotherUserId,
          messageType: type,
          discussionId: '',
          eventId: '',
          storyId: '',
          isPaymentMessage: false,
          amount: 0,
          receiverPhoneNumber: '',
          paymentMethod: '',
          transactionId: '',
          messageTextValue: type == 'text' ? dataPath : '',
          messageCaptionText: '',
          voiceNotePath: type == 'voicenote' ? dataPath : '',
          imagePath: type == 'image' ? dataPath : '',
          videoPath: type == 'video' ? dataPath : '',
          musicPath: type == 'music' ? dataPath : '',
          messageToReplyId: '',
          messageToReplyType: '',
          messageToReplyData: '',
          messageToReplyFilename: '',
          messageToReplyThumbnail: '',
          messageToReplyCaption: '',
          messageToReplySenderId: '',
        );
        resultsList.add(true);
      }
    }

    // Get Discussion of [anotherUserId] and [Me]
    List<Discussion> listOfExistingDiscussions = await FirestoreMethods.getListOfExistingDiscussions(
        userSenderId: FirebaseAuth.instance.currentUser!.uid, userReceiverId: anotherUserId);
    debugPrint('listOfExistingDiscussions: $listOfExistingDiscussions');
    dev.log('listOfExistingDiscussions: $listOfExistingDiscussions');

    if (resultsList.isEmpty || resultsList.contains(false)) {
      showSnackbar(
        context,
        resultsList.length <= 1
            ? 'Unable to forward this message!'
            : 'Some messages were forwarded successfully, but others failed!',
        resultsList.length == 1 ? kSecondColor : null,
      );
    } else {
      showSnackbar(
        context,
        resultsList.length == 1
            ? 'Your message was forwarded successfully!'
            : 'Your messages were forwarded successfully!',
        kSuccessColor,
      );
    }

    // Pop the Loader Modal

    Navigator.of(context).pop();

    // Reset Receiver_intent
    ReceiveSharingIntent.instance.reset();

    // Redirect to [anotherUserId] Inbox
    if (widget.previousPageName == 'inbox') {
      // Pop the ForwardToPage...

      Navigator.of(context).pop();

      // Replace Actual InboxPage by the NEW InboxPage...
      if (listOfExistingDiscussions.isNotEmpty) {
        Navigator.pushReplacement(context, SwipeablePageRoute(
          builder: (context) {
            return InboxPage(
              discussion: listOfExistingDiscussions.first,
              userReceiverId: anotherUserId,
            );
          },
        ));
      }
    } else {
      // Replace Actual ForwardPage by the DiscussionPage [In order to create a page stack]...

      Navigator.pushReplacement(
        context,
        SwipeablePageRoute(
          builder: (context) {
            return StartPage(context: context, initTabIndex: 1);
          },
        ),
      );

      // Go to the NEW InboxPage...
      if (listOfExistingDiscussions.isNotEmpty) {
        Navigator.push(context, SwipeablePageRoute(
          builder: (context) {
            return InboxPage(
              discussion: listOfExistingDiscussions.first,
              userReceiverId: anotherUserId,
            );
          },
        ));
      }
    }
  }

  onBackButtonPressed() {
    // Reset Receiver_intent
    ReceiveSharingIntent.instance.reset();

    // Pop the screen
    if (widget.previousPageName == 'inbox') {
      Navigator.of(context).pop();
    } else {
      Navigator.pushAndRemoveUntil(context, SwipeablePageRoute(
        builder: (context) {
          return StartPage(
            context: context,
          );
        },
      ), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 0.08.sh),
          child: MorphingAppBar(
            toolbarHeight: 46,
            scrolledUnderElevation: 0.0,
            heroTag: 'forwardToPageAppBar',
            backgroundColor: Colors.white,
            titleSpacing: 0,
            elevation: 0,
            leading: IconButton(
              splashRadius: 0.06.sw,
              onPressed: () {
                onBackButtonPressed();
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black,
              ),
            ),
            title: Container(
              margin: const EdgeInsets.only(right: 10, top: 0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: CupertinoSearchTextField(
                controller: _searchtextcontroller,
                onChanged: ((value) {
                  // GET SEARCH RESULT
                  setState(() {
                    _searchQuery = removeDiacritics(value.trim());
                  });
                }),
                onSubmitted: ((value) {
                  // GET SEARCH RESULT
                }),
                padding: EdgeInsets.symmetric(horizontal: 0.03.sw, vertical: 0.03.sw),
                prefixIcon: Container(),
                style: TextStyle(color: Colors.black87, fontSize: 15.sp),
                placeholderStyle: TextStyle(color: Colors.black54, fontSize: 15.sp),
                placeholder: "Search for a person...",
                backgroundColor: const Color(0xFFF0F0F0),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _searchQuery.isNotEmpty
                    ?
                    // SEARCH LISTVIEW
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // HEADER
                          Padding(
                            padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Results',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          // SEARCH RESULTS
                          StreamBuilder<List<usermodel.User>>(
                              stream: FirestoreMethods.getAllUsersWithoutMe(),
                              builder: (context, snapshot) {
                                // Handle Errors
                                if (snapshot.hasError) {
                                  return Container(
                                    padding: const EdgeInsets.all(50),
                                    height: 300,
                                    child: const Center(
                                      child: BuildErrorWidget(onWhiteBackground: true),
                                    ),
                                  );
                                }

                                // Handle Data and perform search
                                if (snapshot.hasData) {
                                  List<usermodel.User> result = snapshot.data!
                                      .where((user) =>
                                          removeDiacritics(user.name)
                                              .toLowerCase()
                                              .contains(_searchQuery.toLowerCase()) ||
                                          removeDiacritics(user.username)
                                              .toLowerCase()
                                              .contains(_searchQuery.toLowerCase()))
                                      .toList();

                                  // DATA FOUND
                                  if (result.isNotEmpty) {
                                    return Column(
                                      children: result.map((user) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: UserCard(
                                            status: 'forward',
                                            user: user,
                                            onTap: () async {
                                              // Forward to this User
                                              debugPrint('FORWARDED !');
                                              List<Map<String, String>> dataToForward = await getDataToForward();
                                              forwardAsMessage(user.id, dataToForward);
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }

                                  // NO DATA FOUND
                                  else {
                                    return Container(
                                      padding: const EdgeInsets.all(50),
                                      height: 300,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Lottie.asset(
                                            height: 100,
                                            empty,
                                            width: double.infinity,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text(
                                            'No accounts found!',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }

                                // Display Loading while waiting
                                return Container(
                                  padding: const EdgeInsets.all(50),
                                  height: 100,
                                  child: const CupertinoActivityIndicator(),
                                );
                              }),
                        ],
                      )
                    :

                    // NORMAL LISTVIEW
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // HEADER
                          Padding(
                            padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Share to my story',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          // FORWARD TO [MY] Story
                          StreamBuilder(
                            stream: FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid),
                            builder: ((context, snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: UserCard(
                                    user: (snapshot.data! as usermodel.User),
                                    status: 'forward',
                                    onTap: () async {
                                      // CONTINUE...
                                      List<Map<String, String>> dataToForward = await getDataToForward();
                                      debugPrint('dataToForward: $dataToForward');
                                      forwardToMyStory(dataToForward);
                                    },
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                //probably an error occured
                                debugPrint('Erreur: ${snapshot.error}');
                                return const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text('An error occured!'),
                                );
                              }

                              return Container();
                            }),
                          ),

                          FutureBuilder<List<usermodel.User>>(
                              future: FirestoreMethods.getAllUsersFromMyDiscussions(),
                              builder: (context, snapshot) {
                                // Handle Errors
                                if (snapshot.hasError) {
                                  debugPrint(
                                      'An error occured while fetching recents users: in Forward Page: ${snapshot.error}');
                                  return Container();
                                }

                                // Handle Data and perform search
                                if (snapshot.hasData) {
                                  List<usermodel.User> result = snapshot.data!;

                                  // DATA FOUND
                                  if (result.isNotEmpty) {
                                    return Column(
                                      children: [
                                        // HEADER
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Recent',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Users from [My] Discussions
                                        Column(
                                          children: result.map((user) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 5),
                                              child: UserCard(
                                                status: 'forward',
                                                user: user,
                                                onTap: () async {
                                                  // Forward to this User
                                                  debugPrint('Forwarded !');
                                                  List<Map<String, String>> dataToForward = await getDataToForward();
                                                  forwardAsMessage(user.id, dataToForward);
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    );
                                  }
                                }

                                // Loader
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // Display Loading while waiting
                                  return Container(
                                    padding: const EdgeInsets.all(50),
                                    height: 100,
                                    child: const CupertinoActivityIndicator(),
                                  );
                                }

                                return Container();
                              }),
                        ],
                      ),
              ],
            ),
          ),
        ));
  }
}

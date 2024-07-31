// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textformfield.dart';
import '../../models/feedback.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../models/user.dart' as usermodel;

class FeedBackModal extends StatefulWidget {
  const FeedBackModal({super.key});

  @override
  State<FeedBackModal> createState() => _FeedBackModalState();
}

class _FeedBackModalState extends State<FeedBackModal> {
  ValueNotifier<usermodel.User?> currentUser = ValueNotifier<usermodel.User?>(null);
  TextEditingController textController = TextEditingController();
  PageController pageController = PageController();
  bool isLoading = false;

  String reactionTitle = '';
  String reactionEmoji = '';

  @override
  void dispose() {
    //
    super.dispose();
    textController.dispose();
  }

  Future<bool> sendFeedBack() async {
    bool result = false;

    showFullPageLoader(context: context);

    // Modeling a new feedback model
    Map<String, dynamic> feedbackToSend = FeedBack(
      feedbackId: '',
      uid: currentUser.value!.id,
      name: currentUser.value!.name,
      content: textController.text,
      reactionTitle: reactionTitle,
      reactionEmoji: reactionEmoji,
      createdAt: DateTime.now(),
    ).toJson();

    result = await FirestoreMethods.sendFeedback(context, feedbackToSend);
    debugPrint('Feedback sent : $feedbackToSend');

    Navigator.pop(
      context,
    );
    // Pop the Screen once profile updated
    return result;
  }

  onWillPopHandler(context) async {
    //
    textController.text = '';
    if (reactionTitle.isNotEmpty && reactionEmoji.isNotEmpty) {
      bool result = await sendFeedBack();
      if (result && reactionTitle.isNotEmpty && reactionEmoji.isNotEmpty) {
        showSnackbar(context, 'Your feedback has been sent :)', kSuccessColor);
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        onWillPopHandler(context);
      },
      child: StreamBuilder<usermodel.User?>(
          stream: FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              // Update current user
              currentUser.value = snapshot.data;

              return Container(
                padding: const EdgeInsets.only(right: 7, left: 7, top: 10),
                alignment: Alignment.center,
                height: 150,
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    // Page 1: Add reaction
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'How do you find $appName?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
                        ),
                        const SizedBox(height: 25),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: feedbackAvailableTypeList.map((feedbackReaction) {
                              return InkWell(
                                onTap: () {
                                  // Go to Step 2: Add feedback
                                  setState(() {
                                    reactionTitle = feedbackReaction.title;
                                    reactionEmoji = feedbackReaction.emoji;
                                  });
                                  pageController.nextPage(
                                      duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/emoji.reactions/${feedbackReaction.index}.png'),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        child: Text(
                                          feedbackReaction.title,
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),

                    // Page 2: Add feedback content
                    Column(
                      children: [
                        // Field
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: BuildTextFormField(
                            controller: textController,
                            hintText: 'What feature would you like to see in $appName?',
                            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.black54),
                            fontSize: 14.sp,
                            maxLines: 3,
                            minLines: 3,
                            maxLength: 500,
                            inputBorder: InputBorder.none,
                            validateFn: (text) {
                              return null;
                            },
                            onChanged: (text) async {
                              return;
                            },
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Buttons
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Button(
                                text: 'Send',
                                height: 0.11.sw,
                                width: 0.30.sw,
                                fontsize: 12.sp,
                                fontColor: Colors.white,
                                color: kSecondColor,
                                onTap: () async {
                                  // Send feedback
                                  //  Show Loader Modal
                                  showFullPageLoader(context: context, color: Colors.white);
                                  //
                                  var isConnected = await InternetConnection.isConnected(context);
                                  //  Dismiss Loader Modal
                                  if (!mounted) return;
                                  Navigator.pop(context);

                                  if (isConnected) {
                                    debugPrint("Has connection : $isConnected");
                                    // CONTINUE
                                    if (textController.text.isNotEmpty) {
                                      bool result = await sendFeedBack();

                                      Navigator.pop(context);
                                      if (result) {
                                        showSnackbar(
                                            context, 'Your feedback has been sent successfully!', kSuccessColor);
                                      }
                                    } else {
                                      showSnackbar(context, 'Please enter something before continuing', null);
                                    }
                                  } else {
                                    debugPrint("Has connection : $isConnected");
                                    showSnackbar(context, 'Please check your internet connection', null);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              // Handle error
              debugPrint('error: ${snapshot.error}');
              return const Center(
                child: Text('An error occured!', style: TextStyle(color: Colors.white)),
              );
            }

            // Display CircularProgressIndicator
            return const Center(
              child: RepaintBoundary(child: CupertinoActivityIndicator(color: Colors.white60, radius: 15)),
            );
          }),
    );
  }
}

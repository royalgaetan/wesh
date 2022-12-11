import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/feedback.dart';
import '../../providers/user.provider.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/textformfield.dart';
import '../../models/user.dart' as UserModel;

class FeedBackModal extends StatefulWidget {
  const FeedBackModal({super.key});

  @override
  State<FeedBackModal> createState() => _FeedBackModalState();
}

class _FeedBackModalState extends State<FeedBackModal> {
  ValueNotifier<UserModel.User?> currentUser = ValueNotifier<UserModel.User?>(null);
  TextEditingController textController = TextEditingController();
  PageController pageController = PageController();
  bool isLoading = false;

  String reactionTitle = '';
  String reactionEmoji = '';

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textController.dispose();
  }

  Future<bool> sendFeedBack() async {
    bool result = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Modeling a question model
    Map<String, Object?> feedbackToSend = FeedBack(
      feedbackId: '',
      uid: currentUser.value!.id,
      name: currentUser.value!.name,
      content: textController.text,
      reactionTitle: reactionTitle,
      reactionEmoji: reactionEmoji,
      createdAt: DateTime.now(),
    ).toJson();

    // ignore: use_build_context_synchronously
    result = await FirestoreMethods().sendFeedback(context, feedbackToSend);
    debugPrint('Feedback sent : $feedbackToSend');
    // ignore: use_build_context_synchronously
    Navigator.pop(
      context,
    );
    // Pop the Screen once profile updated
    return result;
  }

  Future<bool> onWillPopHandler(context) async {
    //
    textController.text = '';
    if (reactionTitle.isNotEmpty && reactionEmoji.isNotEmpty) {
      bool result = await sendFeedBack();
      if (result && reactionTitle.isNotEmpty && reactionEmoji.isNotEmpty) {
        // ignore: use_build_context_synchronously
        showSnackbar(context, 'Votre feedback à bien été envoyé !', kSuccessColor);
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await onWillPopHandler(context);
      },
      child: StreamBuilder<UserModel.User?>(
          stream: Provider.of<UserProvider>(context).getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              // Update current user
              currentUser.value = snapshot.data;

              return Stack(
                alignment: Alignment.topRight,
                children: [
                  // Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    height: 240,
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: pageController,
                      children: [
                        // Page 1: Add reaction
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              'Comment trouvez-vous $appName ?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
                            ),
                            const SizedBox(height: 20),
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
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: kGreyColor,
                                            backgroundImage: AssetImage(
                                                'assets/images/emoji.reactions/${feedbackReaction.index}.png'),
                                          ),
                                          const SizedBox(height: 5),
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
                              child: buildTextFormField(
                                controller: textController,
                                hintText: 'Quelle fonctionnalité souhaitez-vous voir dans $appName ?',
                                icon: const Icon(Icons.auto_awesome_rounded),
                                fontSize: 14.sp,
                                maxLines: 4,
                                maxLength: 500,
                                inputBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kSecondColor)),
                                validateFn: (text) {
                                  return null;
                                },
                                onChanged: (text) async {
                                  return;
                                },
                              ),
                            ),

                            // Buttons

                            FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 5),
                                child: Row(
                                  children: [
                                    //
                                    CupertinoButton.filled(
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 3),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Row(
                                        children: const [
                                          Text(
                                            'Envoyer',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      onPressed: () async {
                                        // Send feedback

                                        //  Show Loader Modal
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) => const Center(
                                            child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
                                          ),
                                        );
                                        var isConnected = await InternetConnection().isConnected(context);
                                        //  Dismiss Loader Modal
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);

                                        if (isConnected) {
                                          debugPrint("Has connection : $isConnected");
                                          // CONTINUE
                                          if (textController.text.isNotEmpty) {
                                            bool result = await sendFeedBack();
                                            // ignore: use_build_context_synchronously
                                            Navigator.pop(context);
                                            if (result) {
                                              // ignore: use_build_context_synchronously
                                              showSnackbar(
                                                  context, 'Votre feedback à bien été envoyé !', kSuccessColor);
                                            }
                                          } else {
                                            // ignore: use_build_context_synchronously
                                            showSnackbar(
                                                context, 'Veuillez entrer quelque chose avant de continuer', null);
                                          }
                                        } else {
                                          debugPrint("Has connection : $isConnected");
                                          // ignore: use_build_context_synchronously
                                          showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  IconButton(
                    splashRadius: 18,
                    onPressed: () {
                      // Pop the modal
                      // ignore: use_build_context_synchronously
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey.shade500,
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  )
                ],
              );
            }

            if (snapshot.hasError) {
              // Handle error
              debugPrint('error: ${snapshot.error}');
              return const Center(
                child: Text('Une erreur s\'est produite', style: TextStyle(color: Colors.white)),
              );
            }

            // Display CircularProgressIndicator
            return const Center(
              child: CupertinoActivityIndicator(color: Colors.white60, radius: 15),
            );
          }),
    );
  }
}

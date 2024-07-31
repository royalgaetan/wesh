// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/widgets/textformfield.dart';
import '../../models/question.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../models/user.dart' as usermodel;

class AskUsQuestionPage extends StatefulWidget {
  const AskUsQuestionPage({super.key});

  @override
  State<AskUsQuestionPage> createState() => _AskUsQuestionPageState();
}

class _AskUsQuestionPageState extends State<AskUsQuestionPage> {
  TextEditingController textController = TextEditingController();
  bool isLoading = false;
  int questionLimit = 500;
  ValueNotifier<usermodel.User?> currentUser = ValueNotifier<usermodel.User?>(null);

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  void dispose() {
    //
    super.dispose();
    textController.dispose();
  }

  sendQuestion() async {
    bool result = false;

    showFullPageLoader(context: context);

    // Modeling a question model
    Map<String, dynamic> questionToSend = Question(
      questionId: '',
      uid: currentUser.value!.id,
      name: currentUser.value!.name,
      content: textController.text,
      createdAt: DateTime.now(),
    ).toJson();

    if (!mounted) return;
    result = await FirestoreMethods.sendQuestion(context, questionToSend);

    if (!mounted) return;
    Navigator.pop(
      context,
    );
    // Pop the Screen once profile updated
    if (result) {
      if (!mounted) return;
      Navigator.pop(context);

      if (!mounted) return;
      showSnackbar(context, 'Your question has been sent successfully!', kSuccessColor);
    }
  }

  handleCTAButton() async {
    // VIBRATE
    triggerVibration();

    // Send a bug report
    var isConnected = await InternetConnection.isConnected(context);

    if (isConnected) {
      debugPrint("Has connection : $isConnected");
      // Verify if Question is set
      if (textController.text.isNotEmpty) {
        // Verify Question length
        if (textController.text.length <= questionLimit) {
          sendQuestion();
        } else {
          showSnackbar(context, 'Your question exceeds the $questionLimit character limit. Please shorten it.', null);
        }
      } else {
        showSnackbar(context, 'Please enter your question', null);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'askUsQuestionPageAppBar',
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 0.06.sw,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Ask Us a Question',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          // CTA Button Create or Edit Forever
          GestureDetector(
            onTap: () {
              handleCTAButton();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 15, 10),
              child: Text(
                'Send',
                style: TextStyle(fontSize: 16.sp, color: kSecondColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 5, left: 10, right: 10),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            isLoading
                ? Container(
                    padding: const EdgeInsets.all(50),
                    height: 300,
                    child: const Center(child: CupertinoActivityIndicator()),
                  )
                : StreamBuilder<usermodel.User?>(
                    stream: FirestoreMethods.getUserById(FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        // Update current user
                        currentUser.value = snapshot.data;

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6, bottom: 5, top: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      alignment: Alignment.center,
                                      child:
                                          Icon(FontAwesomeIcons.circleInfo, size: 18.sp, color: Colors.grey.shade400),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                        child: Wrap(
                                          children: [
                                            Text(
                                              'We will reply to you in your $appName inbox from our official account',
                                              style: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Bug report add content field
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: BuildTextFormField(
                                  controller: textController,
                                  hintText: 'How can we help? (max $questionLimit chars)...',
                                  icon: Icon(Icons.contact_support_rounded, color: Colors.grey.shade600),
                                  minLines: 3,
                                  maxLines: 20,
                                  maxLength: questionLimit,
                                  fontSize: 13.sp,
                                  inputBorder: InputBorder.none,
                                  validateFn: (text) {
                                    return null;
                                  },
                                  onChanged: (text) async {
                                    return;
                                  },
                                ),
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
          ],
        ),
      ),
    );
  }
}

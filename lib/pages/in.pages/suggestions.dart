import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/utils/constants.dart';
import '../../models/event.dart';
import '../../models/feedback.dart';
import '../../models/message.dart';
import '../../models/story.dart';
import '../../models/user.dart' as usermodel;
import '../../services/firestore.methods.dart';

class Suggestions extends StatefulWidget {
  final String suggestionType;
  final String userReceiverId;
  final Message? messageToReply;
  final Event? eventAttached;
  final Story? storyAttached;

  const Suggestions({
    super.key,
    required this.suggestionType,
    this.eventAttached,
    required this.userReceiverId,
    this.storyAttached,
    this.messageToReply,
  });

  @override
  State<Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  bool hasSentAnswer = false;

  Future sendAnswer(bool answer) async {
    setState(() {
      hasSentAnswer = true;
    });

    usermodel.User? currentUser = await FirestoreMethods.getUser(FirebaseAuth.instance.currentUser!.uid);

    // Send Answer About "Send Gift Feature"

    // Modeling a new feedback model
    Map<String, dynamic> feedbackToSend = FeedBack(
      feedbackId: '',
      uid: FirebaseAuth.instance.currentUser!.uid,
      name: currentUser?.name ?? '',
      content: answer
          ? 'Oui, j\'aimerai pouvoir envoyer des cadeaux à travers $appName'
          : 'Non, envoyer des cadeaux à travers $appName n\'est pas une bonne idée',
      reactionTitle: answer ? 'Excellent' : 'Pas cool',
      reactionEmoji: answer ? '🥰' : '😒',
      createdAt: DateTime.now(),
    ).toJson();

    if (!mounted) return;
    await FirestoreMethods.sendFeedback(context, feedbackToSend);
    log('Feedback [About "Send Gift Feature"] sent : $feedbackToSend');
  }

  int tabSelected = 0;
  TextEditingController receiverPhoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'suggestionsPageAppBar',
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
          'Envoyer un cadeau',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedCrossFade(
          crossFadeState: hasSentAnswer == false ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(
            milliseconds: 700,
          ),
          firstChild:
              // Ask question
              Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gift Icon
              const SizedBox(
                height: 100,
                width: double.infinity,
                child: Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orangeAccent,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        FontAwesomeIcons.gift,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Text 1
              Text('C\'est ici que vous pouvez envoyer des cadeaux aux personnes',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 17.sp)),
              const SizedBox(height: 25),

              // Text Question
              Text('Souhaitez-vous, un jour, voir cette fonctionnalité dans $appName ?',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 15.sp)),
              const SizedBox(height: 25),

              // Answer Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => kSecondColor)),
                    onPressed: () {
                      sendAnswer(true);
                    },
                    child: const Text(
                      'Oui, biensûr !',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      sendAnswer(false);
                    },
                    child: const Text('Non, ce n\'est pas important !', style: TextStyle(color: Colors.black54)),
                  ),
                ],
              )
            ],
          ),
          secondChild:
              // "THANK FOR ANSWER" OR HANDLE NULL RESULT

              Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 50,
                  color: kSecondColor,
                ),
                const SizedBox(height: 10),
                Text(
                  'Merci pour votre réponse !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87, fontSize: 15.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

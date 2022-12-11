import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import '../../models/question.dart';
import '../../providers/user.provider.dart';
import '../../services/firestore.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/textformfield.dart';
import '../../models/user.dart' as UserModel;

class AskUsQuestionPage extends StatefulWidget {
  const AskUsQuestionPage({super.key});

  @override
  State<AskUsQuestionPage> createState() => _AskUsQuestionPageState();
}

class _AskUsQuestionPageState extends State<AskUsQuestionPage> {
  TextEditingController textController = TextEditingController();
  bool isLoading = false;
  ValueNotifier<UserModel.User?> currentUser = ValueNotifier<UserModel.User?>(null);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textController.dispose();
  }

  sendQuestion() async {
    bool result = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    // Modeling a question model
    Map<String, Object?> questionToSend = Question(
      questionId: '',
      uid: currentUser.value!.id,
      name: currentUser.value!.name,
      content: textController.text,
      createdAt: DateTime.now(),
    ).toJson();

    // ignore: use_build_context_synchronously
    result = await FirestoreMethods().sendQuestion(context, questionToSend);
    debugPrint('Question sent : $questionToSend');

    // ignore: use_build_context_synchronously
    Navigator.pop(
      context,
    );
    // Pop the Screen once profile updated
    if (result) {
      Navigator.pop(context);

      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Votre question à bien été envoyée !', kSuccessColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
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
          'Posez-nous votre question',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          isLoading
              ? LinearProgressIndicator(
                  backgroundColor: kSecondColor.withOpacity(0.2),
                  color: kSecondColor,
                )
              : Container(),
          StreamBuilder<UserModel.User?>(
              stream: Provider.of<UserProvider>(context).getCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  // Update current user
                  currentUser.value = snapshot.data;

                  return Column(
                    children: [
                      // Bug report add content field
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: buildTextFormField(
                          controller: textController,
                          hintText: 'Comment pouvons-nous vous aider ? (moins de 500 caractères)',
                          icon: const Icon(Icons.person_pin_rounded),
                          maxLines: 10,
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

                      // NB section
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            'N.B',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Nous allons vous répondre dans votre messagerie $appName avec notre compte officiel',
                            style: TextStyle(
                              fontSize: 12.sp,
                            ),
                          ),
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
        ],
      ),
      floatingActionButton:
          // [ACTION BUTTON] Add Event Button
          FloatingActionButton.extended(
        foregroundColor: Colors.white,
        backgroundColor: kSecondColor,
        label: const Text(
          'Envoyer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          // VIBRATE
          triggerVibration();

          // Send a bug report

          setState(() {
            isLoading = true;
          });
          var isConnected = await InternetConnection().isConnected(context);
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          if (isConnected) {
            debugPrint("Has connection : $isConnected");
            // CONTINUE
            if (textController.text.isNotEmpty) {
              sendQuestion();
            } else {
              // ignore: use_build_context_synchronously
              showSnackbar(context, 'Veuillez entrer votre question', null);
            }
          } else {
            debugPrint("Has connection : $isConnected");
            // ignore: use_build_context_synchronously
            showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
          }
        },
      ),
    );
  }
}

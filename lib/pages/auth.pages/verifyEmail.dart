import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wesh/pages/auth_controller_page.dart';
import 'package:wesh/pages/login.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';

class VerifyEmailPage extends StatefulWidget {
  VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late bool isEmailVerified;
  late Timer timer;

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // check if the user email is verified
    var isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendEmailVerification();

      timer =
          Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerify());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthPageController(),
        ),
      );
    }
  }

  Future checkEmailVerify() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer.cancel();
  }

  sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      return showSnackbar(context, 'Une erreur s\'est produite: $e', null);
    }
  }

  holdBackBtn() {
    // FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthPageController(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        holdBackBtn();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            splashRadius: 25,
            onPressed: () {
              // PUSH BACK STEPS OR POP SCREEN
              holdBackBtn();
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              reverse: true,
              children: [
                const Text(
                  'Vérification du code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(
                  height: 24,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Un email de confirmation a été envoyé à l\'adresse ',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: '${FirebaseAuth.instance.currentUser!.email}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Button(
                    height: 50,
                    width: double.infinity,
                    text: 'Renvoyer le code',
                    fontColor: Colors.black87,
                    color: Colors.white,
                    isBordered: true,
                    onTap: () {
                      // Check Sign Up Method --> Continue
                      sendEmailVerification();
                    },
                  ),
                ),
              ].reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textfieldcontainer.dart';
import '../services/auth.methods.dart';
import '../services/internet_connection_checker.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  bool isPageLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
  }

  sendPasswordResetEmail(context) async {
    setState(() {
      isPageLoading = true;
    });
    var isConnected = await InternetConnection().isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // Validate Form & Login
      var email = emailController.text.trim();
      if (email != null && !EmailValidator.validate(email)) {
        return showSnackbar(
            context, 'Veuillez entrer une adresse email valide', null);
      }

      var result = await AuthMethods().resetPassword(
        context,
        email,
      );

      if (result) {
        setState(() {
          emailController.text = '';
        });
        showSnackbar(context, 'vérifiez $email', kSuccessColor);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            splashRadius: 25,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'Récupérer le mot de passe',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            isPageLoading
                ? LinearProgressIndicator(
                    backgroundColor: kSecondColor.withOpacity(0.2),
                    color: kSecondColor,
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: const [
                      Text(
                        'Entrez votre adresse email',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                          'Pour recevoir un email de récupération de votre mot de passe',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),

                  // Username Field Input
                  TextformContainer(
                    child: TextField(
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.allow(RegExp("[a-z]")),
                      // ],
                      controller: emailController,
                      decoration: const InputDecoration(
                          hintText: 'Email',
                          contentPadding: EdgeInsets.all(20),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    height: 27,
                  ),

                  // Button Action : Reset Password
                  Button(
                    height: 50,
                    width: double.infinity,
                    text: 'Récupérer le mot de passe',
                    color: kSecondColor,
                    onTap: () {
                      // Sent Reset_Password_Email
                      sendPasswordResetEmail(context);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/services/firestore.methods.dart';

import '../../services/auth.methods.dart';
import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';
import 'createpassword_and_confirm.dart';

class OTPverificationPage extends StatefulWidget {
  String authType = 'login';
  OTPverificationPage({
    Key? key,
    required this.authType,
  }) : super(key: key);

  @override
  State<OTPverificationPage> createState() => _OTPverificationPageState();
}

class _OTPverificationPageState extends State<OTPverificationPage> {
  String phoneNumber = '';
  late String _verificationCode;

  final TextEditingController _pinPutController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    phoneNumber = UserSimplePreferences.getPhone()!;
    _verifyPhone(phoneNumber);
  }

  _verifyPhone(kphoneNumber) async {
    try {
      await AuthMethods().sendPhoneVerificationCode(phoneNumber);
    } catch (e) {
      showSnackbar(context, 'Une erreur s\'est produite', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          splashRadius: 25,
          onPressed: () {
            // PUSH BACK STEPS OR POP SCREEN
            Navigator.pop(context);
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
                  text: 'Un code de vérification a été envoyé au numéro ',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: '$phoneNumber',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
              ),
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.scale,
                pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: kGreyColor,
                    activeColor: Colors.black,
                    inactiveColor: Colors.black,
                    selectedFillColor: kGreyColor,
                    disabledColor: Colors.white,
                    inactiveFillColor: kGreyColor,
                    selectedColor: kSecondColor),
                animationDuration: Duration(milliseconds: 180),
                enableActiveFill: true,
                // errorAnimationController: errorController,
                // controller: textEditingController,
                onCompleted: (pin) async {
                  print("Completed, the final code is: $pin");
                  print("Auth type: ${widget.authType}");
                  bool isAllowedToContinue = await AuthMethods()
                      .continueWithPhone(
                          context, widget.authType, phoneNumber, pin);

                  print("isAllowedToContinue: $isAllowedToContinue");

                  if (isAllowedToContinue) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    // Redirect to StartPage
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StartPage(),
                        ),
                        (route) => false);
                  } else {
                    showSnackbar(context, 'Une erreur s\'est produite ', null);
                  }
                },
                onChanged: (value) {
                  // NONE
                },
                beforeTextPaste: (text) {
                  print("Allowing to paste $text");
                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                  return false;
                },
              ),
            ].reversed.toList(),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/startPage.dart';
import '../../utils/functions.dart';
import '../../services/auth.methods.dart';
import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';

class OTPverificationPage extends StatefulWidget {
  final String authType;

  const OTPverificationPage({super.key, required this.authType});

  @override
  State<OTPverificationPage> createState() => _OTPverificationPageState();
}

class _OTPverificationPageState extends State<OTPverificationPage> {
  String phoneNumber = '';
  bool canRefresh = false;
  bool isLoading = true;
  Timer? checker;
  // late String _verificationCode;
  final TextEditingController pinPutController = TextEditingController();

  @override
  void initState() {
    //
    super.initState();

    phoneNumber = UserSimplePreferences.getPhone()!;
    _verifyPhone(phoneNumber);
    //
  }

  checkVerificationCode() {
    String verifCode = UserSimplePreferences.getPhoneCodeVerification() ?? '';
    log('Waiting for verifcode...$verifCode');
    if (verifCode.isNotEmpty) {
      log('Verifcode: $verifCode');

      setState(
        () {
          isLoading = false;
          canRefresh = true;
        },
      );
      checker?.cancel();
    }
  }

  _verifyPhone(kphoneNumber) async {
    try {
      log('Sending phone verification to: $kphoneNumber');
      //
      await AuthMethods.sendPhoneVerificationCode(kphoneNumber);

      log('Can continue with $kphoneNumber');

      // START TIMER
      checker = Timer.periodic(const Duration(seconds: 3), (_) {
        checkVerificationCode();
      });
    } catch (e) {
      log('Error while sending phone verification code: $e');
      showSnackbar(context, 'An error occured! lors de la vérification', null);
    }
  }

  @override
  void dispose() {
    super.dispose();
    checker?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 0.08.sh),
        child: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'OtpPageAppBar',
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            splashRadius: 0.06.sw,
            onPressed: () {
              // PUSH BACK STEPS OR POP SCREEN
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              splashRadius: 0.06.sw,
              onPressed: !canRefresh && isLoading
                  ? null
                  : () {
                      //
                      setState(() {
                        canRefresh = false;
                        isLoading = true;
                      });

                      pinPutController.clear();
                      phoneNumber = UserSimplePreferences.getPhone()!;
                      _verifyPhone(phoneNumber);

                      log('isLoading: $isLoading\ncanRefresh: $canRefresh');
                    },
              icon: Icon(
                Icons.refresh_rounded,
                color: canRefresh && !isLoading ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Center(
          child: !isLoading
              ? ListView(
                  padding: EdgeInsets.fromLTRB(0.1.sw, 0.1.sw, 0.1.sw, 0.1.sw),
                  shrinkWrap: true,
                  reverse: true,
                  children: [
                    Text(
                      'Vérification du code',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
                    ),
                    SizedBox(height: 0.12.sw),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Un code de vérification a été envoyé au numéro ',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14.sp,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: phoneNumber, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 0.12.sw),
                    PinCodeTextField(
                      // controller: pinPutController,
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
                      animationDuration: const Duration(milliseconds: 180),
                      enableActiveFill: true,
                      // errorAnimationController: errorController,
                      // controller: textEditingController,
                      onCompleted: (pin) async {
                        debugPrint("Completed, the final code is: $pin");
                        debugPrint("Auth type: ${widget.authType}");
                        //
                        if (widget.authType == 'updatePhoneNumber') {
                          bool isAllowedToContinue = await AuthMethods.linkCredentialsbyPhoneNumber(
                              context, widget.authType, phoneNumber, pin);

                          debugPrint("Update phone number [isAllowedToContinue]: $isAllowedToContinue");

                          if (isAllowedToContinue) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();

                            // Redirect to AccountSecuritySettingsPage

                            Navigator.of(context).pop();

                            Navigator.of(context).pop();

                            Navigator.of(context).pop();

                            showSnackbar(context, 'Votre numéro de téléphone s\'est bien ajouté', kSuccessColor);
                          } else {
                            Navigator.of(context).pop();

                            showSnackbar(context, 'An error occured! ', null);
                          }
                        }

                        //
                        else if (widget.authType == 'login') {
                          bool isAllowedToContinue =
                              await AuthMethods.continueWithPhone(context, widget.authType, phoneNumber, pin);

                          log("Login with phone number [isAllowedToContinue]: $isAllowedToContinue");

                          if (isAllowedToContinue) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();

                            // Redirect to StartPage
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                                context,
                                SwipeablePageRoute(
                                  builder: (context) => StartPage(context: context),
                                ),
                                (route) => false);
                          } else {
                            if (!mounted) return;
                            showSnackbar(context, 'An error occured!', null);
                          }
                        } else if (widget.authType == 'signup') {
                          //
                          bool isAllowedToContinue =
                              await AuthMethods.continueWithPhone(context, widget.authType, phoneNumber, pin);

                          log("Sign up with phone number [isAllowedToContinue]: $isAllowedToContinue");

                          if (isAllowedToContinue) {
                            // IF [redirectToAddEmailandPasswordPage == true]

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();

                            // Redirect to StartPage
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              SwipeablePageRoute(
                                builder: (context) => StartPage(context: context),
                              ),
                            );
                          } else {
                            log('Can\'t signup with PIN: $pin');
                            if (!mounted) return;
                            // showSnackbar(context, 'Votre code est incorrect ou n\'est plus valide. Veuillez réessayer !', null);
                            pinPutController.clear();
                          }
                        }
                      },
                      onChanged: (value) {
                        // NONE
                      },
                      beforeTextPaste: (text) {
                        debugPrint("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return false;
                      },
                    ),
                  ].reversed.toList(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Envoi du code...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 22,
                      width: 22,
                      child: RepaintBoundary(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                )),
    );
  }
}

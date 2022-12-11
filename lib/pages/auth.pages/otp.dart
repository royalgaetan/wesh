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
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 0.08.sh),
        child: MorphingAppBar(
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
        ),
      ),
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Center(
        child: ListView(
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
                  bool isAllowedToContinue =
                      await AuthMethods().linkCredentialsbyPhoneNumber(context, widget.authType, phoneNumber, pin);

                  debugPrint("Update phone number [isAllowedToContinue]: $isAllowedToContinue");

                  if (isAllowedToContinue) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    // Redirect to AccountSecuritySettingsPage
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    showSnackbar(context, 'Votre numéro de téléphone s\'est bien ajouté', kSuccessColor);
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    showSnackbar(context, 'Une erreur s\'est produite ', null);
                  }
                }

                //
                else if (widget.authType == 'login') {
                  bool isAllowedToContinue =
                      await AuthMethods().continueWithPhone(context, widget.authType, phoneNumber, pin);

                  debugPrint("Login with phone number [isAllowedToContinue]: $isAllowedToContinue");

                  if (isAllowedToContinue) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    // Redirect to StartPage
                    // ignore: use_build_context_synchronously
                    Navigator.pushAndRemoveUntil(
                        context,
                        SwipeablePageRoute(
                          builder: (context) => StartPage(context: context),
                        ),
                        (route) => false);
                  } else {
                    // ignore: use_build_context_synchronously
                    showSnackbar(context, 'Une erreur s\'est produite', null);
                  }
                } else if (widget.authType == 'signup') {
                  //
                  bool isAllowedToContinue =
                      await AuthMethods().continueWithPhone(context, widget.authType, phoneNumber, pin);

                  debugPrint("Sign up with phone number [isAllowedToContinue]: $isAllowedToContinue");

                  if (isAllowedToContinue) {
                    // IF [redirectToAddEmailandPasswordPage == true]

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    // Redirect to StartPage
                    // ignore: use_build_context_synchronously
                    Navigator.pushAndRemoveUntil(
                        context,
                        SwipeablePageRoute(
                          builder: (context) => StartPage(context: context),
                        ),
                        (route) => false);
                  } else {
                    // ignore: use_build_context_synchronously
                    showSnackbar(context, 'Une erreur s\'est produite avec votre code', null);
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
        ),
      ),
    );
  }
}

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textfieldcontainer.dart';
import '../services/auth.methods.dart';
import '../services/internet_connection_checker.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  bool isPageLoading = false;

  @override
  void dispose() {
    //
    super.dispose();
    emailController.dispose();
  }

  sendPasswordResetEmail(context) async {
    setState(() {
      isPageLoading = true;
    });
    var isConnected = await InternetConnection.isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // Validate Form & Login
      var email = emailController.text.trim();
      if (!EmailValidator.validate(email)) {
        return showSnackbar(context, 'Please enter a valid email address', null);
      }

      var result = await AuthMethods.resetPassword(
        context,
        email,
      );

      if (result) {
        setState(() {
          emailController.text = '';
        });
        showSnackbar(context, 'Recovery email sent! Verify $email', kSuccessColor);
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
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 0.08.sh),
          child: MorphingAppBar(
            toolbarHeight: 46,
            scrolledUnderElevation: 0.0,
            heroTag: 'forgotPasswordPageAppBar',
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
              'Recover Password',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            // isPageLoading
            //     ? LinearProgressIndicator(
            //         backgroundColor: kSecondColor.withOpacity(0.2),
            //         color: kSecondColor,
            //       )
            //     : Container(),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.1.sw, vertical: 0.4.sw),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Enter your email address',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.04.sw),
                        Text(
                          'To receive an email to reset your password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.12.sw),

                    // Username Field Input
                    TextformContainer(
                      child: TextField(
                        // inputFormatters: [
                        //   FilteringTextInputFormatter.allow(RegExp("[a-z]")),
                        // ],
                        controller: emailController,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                          hintText: 'Email',
                          contentPadding: EdgeInsets.all(0.04.sw),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.07.sw),

                    // Button Action : Reset Password
                    Button(
                      height: 0.12.sw,
                      width: double.infinity,
                      text: 'Recover Password',
                      color: kSecondColor,
                      onTap: () {
                        // Sent Reset_Password_Email
                        sendPasswordResetEmail(context);
                      },
                    ),
                    SizedBox(height: 0.07.sw),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

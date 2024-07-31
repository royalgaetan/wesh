import 'dart:developer';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/auth.pages/add_username.dart';
import 'package:wesh/pages/forgotpassword.dart';
import 'package:wesh/services/auth.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textfieldcontainer.dart';
import '../services/internet_connection_checker.dart';
import '../services/sharedpreferences.service.dart';
import 'startPage.dart';

class LoginPage extends StatefulWidget {
  final bool redirectToAddEmailandPasswordPage;
  final bool redirectToAddEmailPage;
  final bool redirectToUpdatePasswordPage;

  const LoginPage(
      {super.key,
      required this.redirectToAddEmailandPasswordPage,
      required this.redirectToUpdatePasswordPage,
      required this.redirectToAddEmailPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  bool showVisibilityIcon = false;
  bool isPswVisible = true;
  bool isPageLoading = false;

  final formKey = GlobalKey<FormState>();
  FocusNode emailTextfieldFocus = FocusNode();
  FocusNode passwordTextfieldFocus = FocusNode();

  @override
  void dispose() {
    //
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  continueWithEmailAndPassword(context) async {
    setState(() {
      isPageLoading = true;
    });

    emailTextfieldFocus.unfocus();
    passwordTextfieldFocus.unfocus();

    // IF [redirectToAddEmailandPasswordPage == true]
    if (widget.redirectToAddEmailandPasswordPage) {
      debugPrint("Redirect to Setting Page from : ${widget.redirectToAddEmailandPasswordPage}");
      await UserSimplePreferences.setRedirectToAddEmailandPasswordPageValue(true);
    }

    // IF [redirectToAddEmailPage == true]
    if (widget.redirectToAddEmailPage) {
      debugPrint("Redirect to Add Email Page from : ${widget.redirectToAddEmailPage}");
      await UserSimplePreferences.setRedirectToAddEmailPageValue(true);
    }

    // IF [redirectToUpdatePasswordPage == true]
    if (widget.redirectToUpdatePasswordPage) {
      debugPrint("Redirect to Update Password Page from : ${widget.redirectToUpdatePasswordPage}");
      await UserSimplePreferences.setRedirectToUpdatePasswordPageValue(true);
    }

    // Validate Form & Login
    var email = emailController.text.trim();
    var psw = passwordController.text.trim();

    if (!EmailValidator.validate(email)) {
      setState(() {
        isPageLoading = false;
      });
      return showSnackbar(context, 'Please enter a valid email address', null);
    }

    // if (psw.length < 6) {
    // setState(() {
    // isPageLoading = false;
    // });
    // return showSnackbar(context, 'Please enter a password with more than 6 characters', null);
    // }

    if (psw.isEmpty) {
      setState(() {
        isPageLoading = false;
      });
      return showSnackbar(context, 'Please enter a password', null);
    }

    var isConnected = await InternetConnection.isConnected(context);

    if (isConnected) {
      debugPrint("Has connection : $isConnected");
      bool isUserExisting = await AuthMethods.checkUserWithEmailExistenceInDb(email);
      log('isUserExisting: $isUserExisting');
      if (isUserExisting == false) {
        // ignore: use_build_context_synchronously
        setState(() {
          isPageLoading = false;
        });
        return showSnackbar(context, 'No account exists with this email...', null);
      }
      // USER EXIST : CONTINUE
      else {
        try {
          var result = await AuthMethods.loginWithEmailAndPassword(context, email, psw);

          if (result) {
            // Return to Start Page
            Navigator.of(context).pop();
            Navigator.pushAndRemoveUntil(
                context,
                SwipeablePageRoute(
                  builder: (context) => StartPage(context: context),
                ),
                (route) => false);
          }
        } catch (e) {
          setState(() {
            isPageLoading = false;
          });
          return showSnackbar(context, e, null);
        }
      }
    } else {
      debugPrint("Has connection : $isConnected");
      setState(() {
        isPageLoading = false;
      });
      return showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  continueWithGoogle() async {
    // IF [redirectToAddEmailandPasswordPage == true]
    if (widget.redirectToAddEmailandPasswordPage) {
      debugPrint("Redirect to Setting Page from : ${widget.redirectToAddEmailandPasswordPage}");
      await UserSimplePreferences.setRedirectToAddEmailandPasswordPageValue(true);
    }

    // IF [redirectToAddEmailPage == true]
    if (widget.redirectToAddEmailPage) {
      debugPrint("Redirect to Add Email Page from : ${widget.redirectToAddEmailPage}");
      await UserSimplePreferences.setRedirectToAddEmailPageValue(true);
    }

    // IF [redirectToUpdatePasswordPage == true]
    if (widget.redirectToUpdatePasswordPage) {
      debugPrint("Redirect to Update Password Page from : ${widget.redirectToUpdatePasswordPage}");
      await UserSimplePreferences.setRedirectToUpdatePasswordPageValue(true);
    }

    setState(() {
      isPageLoading = true;
    });
    // ignore: use_build_context_synchronously
    var isConnected = await InternetConnection.isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      // Continue with Google

      debugPrint("Has connection : $isConnected");

      List isAllowedToContinue =
          // ignore: use_build_context_synchronously
          await AuthMethods.continueWithGoogle(context, 'login');

      debugPrint("isAllowedToContinue: $isAllowedToContinue");

      if (isAllowedToContinue[0]) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        // Redirect to StartPage
        Navigator.pushAndRemoveUntil(
            context,
            SwipeablePageRoute(
              builder: (context) => StartPage(context: context),
            ),
            (route) => false);
      } else {
        if (!mounted) return;
        showSnackbar(context, isAllowedToContinue[1], null);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      if (!mounted) return;
      showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  continueWithFacebook() async {
    // IF [redirectToAddEmailandPasswordPage == true]
    if (widget.redirectToAddEmailandPasswordPage) {
      debugPrint("Redirect to Setting Page from : ${widget.redirectToAddEmailandPasswordPage}");
      await UserSimplePreferences.setRedirectToAddEmailandPasswordPageValue(true);
    }

    // IF [redirectToAddEmailPage == true]
    if (widget.redirectToAddEmailPage) {
      debugPrint("Redirect to Add Email Page from : ${widget.redirectToAddEmailPage}");
      await UserSimplePreferences.setRedirectToAddEmailPageValue(true);
    }

    // IF [redirectToUpdatePasswordPage == true]
    if (widget.redirectToUpdatePasswordPage) {
      debugPrint("Redirect to Update Password Page from : ${widget.redirectToUpdatePasswordPage}");
      await UserSimplePreferences.setRedirectToUpdatePasswordPageValue(true);
    }

    setState(() {
      isPageLoading = true;
    });
    if (!mounted) return;
    var isConnected = await InternetConnection.isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      // Continue with Google

      debugPrint("Has connection : $isConnected");

      if (!mounted) return;
      List isAllowedToContinue = await AuthMethods.continueWithFacebook(context, 'login');

      debugPrint("isAllowedToContinue: $isAllowedToContinue");

      if (isAllowedToContinue[0]) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        // Redirect to StartPage
        Navigator.pushAndRemoveUntil(
            context,
            SwipeablePageRoute(
              builder: (context) => StartPage(context: context),
            ),
            (route) => false);
      } else {
        // ignore: use_build_context_synchronously
        showSnackbar(context, isAllowedToContinue[1], null);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          isPageLoading
              ? LinearProgressIndicator(
                  backgroundColor: kSecondColor.withOpacity(0.2),
                  color: kSecondColor,
                )
              : Container(),
          Center(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              reverse: true,
              children: [
                // App Title
                SizedBox(height: 0.15.sw),
                const Buildlogo(),

                // Form Fields
                SizedBox(height: 0.14.sw),
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      // Email
                      TextformContainer(
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          focusNode: emailTextfieldFocus,
                          decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                              hintText: 'Email',
                              contentPadding: EdgeInsets.all(0.04.sw),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 0.04.sw),

                      // Password Field
                      TextformContainer(
                        child: TextFormField(
                          focusNode: passwordTextfieldFocus,
                          controller: passwordController,
                          onChanged: ((value) => {
                                if (value != '')
                                  {
                                    setState(() {
                                      showVisibilityIcon = true;
                                    })
                                  }
                                else
                                  {
                                    setState(() {
                                      showVisibilityIcon = false;
                                    })
                                  }
                              }),
                          obscureText: isPswVisible,
                          decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                              hintText: 'Password',
                              contentPadding: EdgeInsets.all(0.04.sw),
                              border: InputBorder.none,
                              suffixIcon: showVisibilityIcon
                                  ? IconButton(
                                      splashRadius: 0.06.sw,
                                      onPressed: () {
                                        setState(() {
                                          isPswVisible = !isPswVisible;
                                        });
                                      },
                                      icon: isPswVisible
                                          ? const Icon(Icons.visibility_rounded)
                                          : const Icon(Icons.visibility_off_rounded))
                                  : SizedBox(
                                      width: 0.04.sw,
                                      height: 0.04.sw,
                                    )),
                        ),
                      ),
                      SizedBox(height: 0.04.sw),
                    ],
                  ),
                ),

                // Forgot Password BUTTON
                const BuildforgotpswBTN(),

                // Action Buttons
                SizedBox(height: 0.04.sw),
                // Login Button
                Button(
                  height: 0.12.sw,
                  width: double.infinity,
                  text: 'Log in',
                  color: isPageLoading ? kSecondColor.withOpacity(.5) : kSecondColor,
                  onTap: isPageLoading
                      ? () {}
                      : () async {
                          // Login with Email and Password
                          continueWithEmailAndPassword(context);
                        },
                ),
                SizedBox(height: 0.08.sw),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.03.sw, horizontal: 0.02.sw),
                  child: const BuildDividerWithLabel(label: 'or continue with'),
                ),

                // Other login Methods : Phone, Google, Facebook
                BuildOtherSignupMethods(
                  continueWithGoogleOnTap: continueWithGoogle,
                  continueWithFacebookOnTap: continueWithFacebook,
                  redirectToAddEmailPage: widget.redirectToAddEmailPage,
                  redirectToAddEmailandPasswordPage: widget.redirectToAddEmailandPasswordPage,
                  redirectToUpdatePasswordPage: widget.redirectToUpdatePasswordPage,
                ),

                SizedBox(height: 0.09.sw),

                // Sign Up Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 0.04, bottom: 0.07.sw),
                      child: InkWell(
                        onTap: () {
                          // Redirect to Sign Up Page : CheckUsernanePage
                          Navigator.push(
                              context,
                              SwipeablePageRoute(
                                builder: (context) => const AddUsernamePage(),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            'Create an account',
                            style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ].reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildforgotpswBTN extends StatelessWidget {
  const BuildforgotpswBTN({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            // Redirect to Forgot Password Page
            Navigator.push(
                context,
                SwipeablePageRoute(
                  builder: (context) => const ForgotPasswordPage(),
                ));
          },
          child: Padding(
            padding: EdgeInsets.all(0.04.sw),
            child: Text(
              'Forgot password?',
              style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }
}

class BuildOtherSignupMethods extends StatefulWidget {
  final VoidCallback continueWithGoogleOnTap;
  final VoidCallback continueWithFacebookOnTap;

  final bool redirectToAddEmailandPasswordPage;
  final bool redirectToAddEmailPage;
  final bool redirectToUpdatePasswordPage;

  const BuildOtherSignupMethods({
    super.key,
    required this.continueWithGoogleOnTap,
    required this.continueWithFacebookOnTap,
    required this.redirectToAddEmailandPasswordPage,
    required this.redirectToAddEmailPage,
    required this.redirectToUpdatePasswordPage,
  });

  @override
  State<BuildOtherSignupMethods> createState() => BuildOtherSignupMethodsState();
}

class BuildOtherSignupMethodsState extends State<BuildOtherSignupMethods> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // InkWell(
        //   onTap: () async {
        //     //  Phone Auth
        //     if (widget.redirectToAddEmailandPasswordPage) {
        //       debugPrint("Redirect to Setting Page from : ${widget.redirectToAddEmailandPasswordPage}");
        //       await UserSimplePreferences.setRedirectToAddEmailandPasswordPageValue(true);
        //     }

        //     // IF [redirectToAddEmailPage == true]
        //     if (widget.redirectToAddEmailPage) {
        //       debugPrint("Redirect to Add Email Page from : ${widget.redirectToAddEmailPage}");
        //       await UserSimplePreferences.setRedirectToAddEmailPageValue(true);
        //     }

        //     // IF [redirectToUpdatePasswordPage == true]
        //     if (widget.redirectToUpdatePasswordPage) {
        //       debugPrint("Redirect to Update Password Page from : ${widget.redirectToUpdatePasswordPage}");
        //       await UserSimplePreferences.setRedirectToUpdatePasswordPageValue(true);
        //     }

        //     debugPrint('From login {redirectToAddEmailandPasswordPage}: ${widget.redirectToAddEmailandPasswordPage}');
        //     debugPrint('From login {redirectToAddEmailPage}: ${widget.redirectToAddEmailPage}');
        //     debugPrint('From login {redirectToUpdatePasswordPage}: ${widget.redirectToUpdatePasswordPage}');

        //     // ignore: use_build_context_synchronously
        //     Navigator.push(
        //         context,
        //         SwipeablePageRoute(
        //           builder: (context) => const AddPhonePage(
        //             isUpdatingPhoneNumber: false,
        //           ),
        //         ));
        //   },
        //   child: Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: SvgPicture.asset(
        //       phoneLogo,
        //       height: 32,
        //     ),
        //   ),
        // ),

        InkWell(
          onTap: widget.continueWithGoogleOnTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              googleLogo,
              height: 28,
            ),
          ),
        ),
        const SizedBox(width: 30),
        InkWell(
          onTap: widget.continueWithFacebookOnTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              colorFilter: const ColorFilter.mode(Color(0xFF1977F3), BlendMode.srcIn),
              facebookLogo,
              height: 34,
            ),
          ),
        ),
      ],
    );
  }
}

class Buildlogo extends StatelessWidget {
  const Buildlogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      weshLogoColored,
      height: 0.11.sh,
      colorFilter: const ColorFilter.mode(kSecondColor, BlendMode.srcIn),
    );
  }
}

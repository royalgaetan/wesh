import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/auth.pages/add_phone.dart';
import 'package:wesh/pages/auth.pages/add_username.dart';
import 'package:wesh/pages/forgotpassword.dart';
import 'package:wesh/services/auth.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textfieldcontainer.dart';
import '../services/internet_connection_checker.dart';
import '../services/sharedpreferences.service.dart';
import '../widgets/buildWidgets.dart';
import 'startPage.dart';

class LoginPage extends StatefulWidget {
  final bool redirectToAddEmailandPasswordPage;
  final bool redirectToAddEmailPage;
  final bool redirectToUpdatePasswordPage;

  const LoginPage(
      {Key? key,
      required this.redirectToAddEmailandPasswordPage,
      required this.redirectToUpdatePasswordPage,
      required this.redirectToAddEmailPage})
      : super(key: key);

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

  @override
  void dispose() {
    //
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  continueWithEmailAndPassword(context) async {
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
    var isConnected = await InternetConnection.isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // Validate Form & Login
      var email = emailController.text.trim();
      var psw = passwordController.text.trim();

      if (email != null && !EmailValidator.validate(email)) {
        return showSnackbar(context, 'Veuillez entrer une adresse email valide', null);
      }

      if (psw != null && psw.length < 6) {
        return showSnackbar(context, 'Veuillez entrer un mot de passe de plus de 6 caractères', null);
      }

      var result = await AuthMethods().loginWithEmailAndPassword(context, email, psw);

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
    } else {
      debugPrint("Has connection : $isConnected");
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
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
          await AuthMethods().continueWithGoogle(context, 'login');

      debugPrint("isAllowedToContinue: $isAllowedToContinue");

      if (isAllowedToContinue[0]) {
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
        showSnackbar(context, isAllowedToContinue[1], null);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
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
          await AuthMethods().continueWithFacebook(context, 'login');

      debugPrint("isAllowedToContinue: $isAllowedToContinue");

      if (isAllowedToContinue[0]) {
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
        showSnackbar(context, isAllowedToContinue[1], null);
      }
    } else {
      debugPrint("Has connection : $isConnected");
      // ignore: use_build_context_synchronously
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
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
                SizedBox(height: 0.12.sw),
                const buildlogo(),

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
                              hintText: 'Mot de passe',
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

                const buildforgotpswBTN(),

                // Action Buttons
                SizedBox(height: 0.04.sw),
                // Login Button
                Button(
                  height: 0.12.sw,
                  width: double.infinity,
                  text: 'Se connecter',
                  color: kSecondColor,
                  onTap: () async {
                    // Login with Email and Password
                    continueWithEmailAndPassword(context);
                  },
                ),
                SizedBox(height: 0.08.sw),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.03.sw, horizontal: 0.02.sw),
                  child: const buildDividerWithLabel(label: 'ou continuer avec'),
                ),

                // Other login Methods : Phone, Google, Facebook
                buildOtherSignupMethods(
                  continueWithGoogleOnTap: continueWithGoogle,
                  continueWithFacebookOnTap: continueWithFacebook,
                  redirectToAddEmailPage: widget.redirectToAddEmailPage,
                  redirectToAddEmailandPasswordPage: widget.redirectToAddEmailandPasswordPage,
                  redirectToUpdatePasswordPage: widget.redirectToUpdatePasswordPage,
                ),

                SizedBox(height: 0.1.sw),

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
                            'Créer un compte',
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

class buildforgotpswBTN extends StatelessWidget {
  const buildforgotpswBTN({
    Key? key,
  }) : super(key: key);

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
              'Mot de passe oublié ?',
              style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }
}

class buildOtherSignupMethods extends StatefulWidget {
  final VoidCallback continueWithGoogleOnTap;
  final VoidCallback continueWithFacebookOnTap;

  final bool redirectToAddEmailandPasswordPage;
  final bool redirectToAddEmailPage;
  final bool redirectToUpdatePasswordPage;

  const buildOtherSignupMethods({
    Key? key,
    required this.continueWithGoogleOnTap,
    required this.continueWithFacebookOnTap,
    required this.redirectToAddEmailandPasswordPage,
    required this.redirectToAddEmailPage,
    required this.redirectToUpdatePasswordPage,
  }) : super(key: key);

  @override
  State<buildOtherSignupMethods> createState() => _buildOtherSignupMethodsState();
}

class _buildOtherSignupMethodsState extends State<buildOtherSignupMethods> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () async {
            //  Phone Auth
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

            debugPrint('From login {redirectToAddEmailandPasswordPage}: ${widget.redirectToAddEmailandPasswordPage}');
            debugPrint('From login {redirectToAddEmailPage}: ${widget.redirectToAddEmailPage}');
            debugPrint('From login {redirectToUpdatePasswordPage}: ${widget.redirectToUpdatePasswordPage}');

            // ignore: use_build_context_synchronously
            Navigator.push(
                context,
                SwipeablePageRoute(
                  builder: (context) => const AddPhonePage(
                    isUpdatingPhoneNumber: false,
                  ),
                ));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              phoneLogo,
              height: 32,
            ),
          ),
        ),
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
        InkWell(
          onTap: widget.continueWithFacebookOnTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              facebookLogo,
              height: 34,
              color: const Color(0xFF1977F3),
            ),
          ),
        ),
      ],
    );
  }
}

class buildlogo extends StatelessWidget {
  const buildlogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      weshLogoColored,
      height: 0.11.sh,
      color: kSecondColor,
    );
  }
}

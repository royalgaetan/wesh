import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import '../../services/auth.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';
import '../../widgets/textfieldcontainer.dart';

class AddEmailandPasswordPage extends StatefulWidget {
  const AddEmailandPasswordPage({super.key});

  @override
  State<AddEmailandPasswordPage> createState() => _AddEmailandPasswordPageState();
}

class _AddEmailandPasswordPageState extends State<AddEmailandPasswordPage> {
  User? user;
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController passwordConfirmationController = TextEditingController();
  bool showVisibilityIcon = false;
  bool showPasswordConfirmationVisibilityIcon = false;
  bool isPswVisible = true;
  bool isPswConfirmationVisible = true;

  @override
  void initState() {
    //
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });

    // Toogle to FALSE [RedirectToAddEmailandPasswordPageValue]
    toogleRedirectToAddEmailandPasswordPage();
  }

  Future toogleRedirectToAddEmailandPasswordPage() async {
    await UserSimplePreferences.setRedirectToAddEmailandPasswordPageValue(false);
    debugPrint(
        "New value Redirect to Setting Page [AddEmailandPswPage]: ${UserSimplePreferences.getRedirectToAddEmailandPasswordPageValue()} ");
  }

  @override
  void dispose() {
    //
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
  }

  checkEmailandPasswordandLinkProvider(context) async {
    showFullPageLoader(context: context);

    var isConnected = await InternetConnection.isConnected(context);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // Checkers : email
      String email = emailController.text.trim();
      String psw = passwordController.text.trim();
      String confirmPsw = passwordConfirmationController.text.trim();

      if (!EmailValidator.validate(email)) {
        if (!mounted) return;
        return showSnackbar(context, 'Please enter a valid email address', null);
      }

      bool isEmailUsed = await AuthMethods.checkIfEmailInUse(context, emailController.text);

      if (isEmailUsed == true) {
        if (!mounted) return;
        return showSnackbar(context, 'This email address is already in use', null);
      }

// Checkers: password
      if (psw.isEmpty) {
        if (!mounted) return;
        return showSnackbar(context, 'Please enter a password', null);
      } else if (psw.length < 6) {
        if (!mounted) return;
        return showSnackbar(context, 'Your password must be more than 6 characters', null);
      } else if (confirmPsw.isEmpty) {
        if (!mounted) return;
        return showSnackbar(context, 'Please confirm your password', null);
      } else if (confirmPsw != psw) {
        if (!mounted) return;
        return showSnackbar(context, 'Passwords do not match', null);
      }

      // IF ALL CHECKERS VALIDATED : [CONTINUE]
      // Link Password Provider
      List result = await AuthMethods.linkCredentialsbyEmailAccount(context, email, psw);
      if (result[0]) {
        // Redirect to Settings Security Page
        Navigator.of(context).pop();
      }
    } else {
      debugPrint("Has connection : $isConnected");
      if (!mounted) return;
      showSnackbar(context, 'Please check your internet connection', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
        heroTag: 'addEmailAndPasswordPageAppBar',
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 0.06.sw,
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Email and Password',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            reverse: true,
            children: [
              Text(
                'Link your Email and Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(height: 0.12.sw),

              // Email
              TextformContainer(
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                    contentPadding: EdgeInsets.all(0.04.sw),
                    hintText: 'Email',
                    border: InputBorder.none,
                  ),
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
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                    contentPadding: EdgeInsets.all(0.04.sw),
                    border: InputBorder.none,
                    suffixIcon: showVisibilityIcon
                        ? IconButton(
                            splashRadius: 22,
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
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // Password Confirmation Field
              showVisibilityIcon
                  ? Column(
                      children: [
                        TextformContainer(
                          child: TextFormField(
                            controller: passwordConfirmationController,
                            onChanged: ((value) => {
                                  if (value != '')
                                    {
                                      setState(() {
                                        showPasswordConfirmationVisibilityIcon = true;
                                      })
                                    }
                                  else
                                    {
                                      setState(() {
                                        showPasswordConfirmationVisibilityIcon = false;
                                      })
                                    }
                                }),
                            obscureText: isPswConfirmationVisible,
                            decoration: InputDecoration(
                              hintText: 'Confirm your password',
                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                              contentPadding: EdgeInsets.all(0.04.sw),
                              border: InputBorder.none,
                              suffixIcon: showVisibilityIcon
                                  ? IconButton(
                                      splashRadius: 22,
                                      onPressed: () {
                                        setState(() {
                                          isPswConfirmationVisible = !isPswConfirmationVisible;
                                        });
                                      },
                                      icon: isPswConfirmationVisible
                                          ? const Icon(Icons.visibility_rounded)
                                          : const Icon(Icons.visibility_off_rounded))
                                  : SizedBox(
                                      width: 0.04.sw,
                                      height: 0.04.sw,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                      ],
                    )
                  : Container(),

              // END Button
              Button(
                height: 0.12.sw,
                width: double.infinity,
                text: 'Add',
                color: kSecondColor,
                onTap: () {
                  // Check Email and Passwords --> Continue to Setings Security Page
                  checkEmailandPasswordandLinkProvider(context);
                },
              ),
            ].reversed.toList(),
          ),
        ),
      ),
    );
  }
}

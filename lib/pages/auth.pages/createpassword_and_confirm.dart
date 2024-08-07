import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/services/auth.methods.dart';
import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';
import '../../widgets/textfieldcontainer.dart';

class CreatePassword extends StatefulWidget {
  final bool isUpdatingEmail;
  const CreatePassword({super.key, required this.isUpdatingEmail});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController passwordConfirmationController = TextEditingController();
  bool showVisibilityIcon = false;
  bool showPasswordConfirmationVisibilityIcon = false;
  bool isPswVisible = true;
  bool isPswConfirmationVisible = true;

  @override
  void dispose() {
    //
    super.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
  }

  @override
  void initState() {
    super.initState();
    toggleRedirectToUpdatePasswordPageValue();
  }

  Future toggleRedirectToUpdatePasswordPageValue() async {
    await UserSimplePreferences.setRedirectToUpdatePasswordPageValue(false);
    debugPrint(
        "New value Redirect to UpdatePassword Page [UpdatePasswordPage]: ${UserSimplePreferences.getRedirectToUpdatePasswordPageValue()}");
  }

  checkPasswords(context, password, confirmPassword) async {
    String psw = password.toString();
    String confirmPsw = confirmPassword.toString();

    if (psw.isEmpty) {
      return showSnackbar(context, 'Please enter a password', null);
    } else if (psw.length < 6) {
      return showSnackbar(context, 'Your password must be more than 6 characters', null);
    } else if (confirmPsw.isEmpty) {
      return showSnackbar(context, 'Please confirm your password', null);
    } else if (confirmPsw != psw) {
      return showSnackbar(context, 'Passwords do not match', null);
    }

    // IF PASSWORD CHECKED

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    // UPDATING PASSWORD
    if (widget.isUpdatingEmail) {
      // Link Password Provider
      List result = await AuthMethods.updateCurrentUserPassword(context, psw);
      if (result[0]) {
        // Redirect to Settings Security Page
        Navigator.of(context).pop();
      }
    }
    // CREATE NEW USER
    else {
      try {
        showFullPageLoader(context: context);
        String? emailCached = UserSimplePreferences.getEmail() ?? '';
        var result = await AuthMethods.createUserWithEmailAndPassword(context, emailCached, password);

        passwordController.clear();
        passwordConfirmationController.clear();

        if (result) {
          Navigator.pushAndRemoveUntil(
              context,
              SwipeablePageRoute(
                builder: (context) => StartPage(context: context),
              ),
              (route) => false);
        }
      } catch (e) {
        debugPrint('Error with passwords: $e');
        // Dismiss Full Loader
        Navigator.pop(context);
        showSnackbar(context, 'Oops! An error occured. Try again', null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 0.08.sh),
        child: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'createPasswordAndConfirmPageAppBar',
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
              'Add a password',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
            ),
            SizedBox(height: 0.12.sw),

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
                        ),
                ),
              ),
            ),
            SizedBox(height: 0.07.sw),

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
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                              contentPadding: EdgeInsets.all(0.04.sw),
                              border: InputBorder.none,
                              suffixIcon: showVisibilityIcon
                                  ? IconButton(
                                      splashRadius: 0.06.sw,
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
                                    )),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  )
                : Container(),

            // END Button
            Padding(
              padding: EdgeInsets.all(0.01.sw),
              child: Button(
                height: 0.12.sw,
                width: double.infinity,
                text: 'Add',
                color: kSecondColor,
                onTap: () {
                  // Check Passwords --> Continue to IntroductionScreensPage
                  checkPasswords(context, passwordController.text, passwordConfirmationController.text);
                },
              ),
            ),
          ].reversed.toList(),
        ),
      ),
    );
  }
}

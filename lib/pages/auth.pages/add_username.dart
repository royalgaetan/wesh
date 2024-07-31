import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wesh/pages/auth.pages/add_name_and_birthday.dart';
import 'package:wesh/services/auth.methods.dart';
import 'package:wesh/services/sharedpreferences.service.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';
import '../../widgets/textfieldcontainer.dart';

class AddUsernamePage extends StatefulWidget {
  const AddUsernamePage({super.key});

  @override
  State<AddUsernamePage> createState() => _CheckUsernameState();
}

class _CheckUsernameState extends State<AddUsernamePage> {
  TextEditingController usernameController = TextEditingController();
  bool isUsernameUsed = false;
  bool isPageLoading = false;

  @override
  void dispose() {
    //
    super.dispose();

    usernameController.dispose();
  }

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 0.08.sh),
        child: MorphingAppBar(
          toolbarHeight: 46,
          scrolledUnderElevation: 0.0,
          heroTag: 'addUsernamePageAppBar',
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
              padding: EdgeInsets.fromLTRB(0.1.sw, 0.1.sw, 0.1.sw, 0.1.sw),
              shrinkWrap: true,
              reverse: true,
              children: [
                Column(
                  children: [
                    Text(
                      'Add a username',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 0.04.sw),
                    Text(
                      'Ex: john_doe23, sarah_bell,...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.12.sw),

                // Username Field Input
                TextformContainer(
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]')),
                    ],
                    onChanged: (value) async {
                      usernameController.text = value.toLowerCase();
                      bool isUsed = await AuthMethods.checkIfUsernameInUse(context, value);
                      if (mounted) {
                        setState(() {
                          isUsernameUsed = isUsed;
                        });
                      }
                    },
                    keyboardType: TextInputType.text,
                    controller: usernameController,
                    decoration: InputDecoration(
                        suffixIcon: usernameController.text.isNotEmpty
                            ? isUsernameUsed
                                ? const Icon(Icons.close, color: kSecondColor)
                                : const Icon(Icons.done, color: Colors.green)
                            : const Icon(null),
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                        contentPadding: EdgeInsets.all(0.04.sw),
                        border: InputBorder.none),
                  ),
                ),
                SizedBox(height: 0.07.sw),
                // Button Action : Username checked
                Button(
                  height: 0.12.sw,
                  width: 0.9.sw,
                  text: 'Next',
                  color: isPageLoading ? kSecondColor.withOpacity(.5) : kSecondColor,
                  onTap: isPageLoading
                      ? () {}
                      : () async {
                          // Check Username
                          setState(() {
                            isPageLoading = true;
                          });
                          var isConnected = await InternetConnection.isConnected(context);

                          if (isConnected) {
                            debugPrint("Has connection : $isConnected");
                            // ignore: use_build_context_synchronously
                            await checkUsername(context, usernameController.text);
                          } else {
                            debugPrint("Has connection : $isConnected");
                            // ignore: use_build_context_synchronously
                            showSnackbar(context, 'Please check your internet connection', null);
                          }
                          if (mounted) {
                            setState(() {
                              isPageLoading = false;
                            });
                          }
                        },
                ),

                Wrap(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top: 0.19.sw, bottom: 0.07.sw),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'By creating an account, you agree to ',
                            style: TextStyle(color: Colors.black87, fontSize: 11.sp),
                            children: <TextSpan>[
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    //
                                    // Go to Privacy Policy Link [ONLINE]
                                    Uri urlToLaunch = Uri.parse(privacyPolicyUrl);

                                    if (!await launchUrl(urlToLaunch)) {
                                      // ignore: use_build_context_synchronously
                                      showSnackbar(context, 'Impossible de lancer cette url', null);
                                      throw 'Could not launch $urlToLaunch';
                                    }
                                  },
                                text: 'our Terms of Service and Privacy Policy',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kSecondColor,
                                ),
                              )
                            ],
                          ),
                        )),
                  ],
                )
              ].reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }
}

Future checkUsername(context, String username) async {
  if (username.isNotEmpty && username.length > 4) {
    bool isUsed = await AuthMethods.checkIfUsernameInUse(context, username);

    debugPrint('Username isUsed: $isUsed');
    if (!isUsed) {
      // Check Username
      await UserSimplePreferences.setUsername(username);

      // Go to Sign Up Methods Page
      Navigator.push(
        context,
        SwipeablePageRoute(builder: (_) => const AddNameAndBirthdayPage()),
      );
    } else {
      showSnackbar(context, 'This username is already taken', null);
    }
  } else {
    showSnackbar(context, 'Please enter a username with more than 4 characters', null);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textfieldcontainer.dart';
import 'in.pages/introductionpages.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<SignUpPage> {
  late int stepIndex;
  final PageController stepController = PageController(initialPage: 0);

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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
  }

  void gotoNextStep() {
    stepController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void gotoPreviousStep() {
    stepController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  void dispose() {
    //
    super.dispose();

    stepController.dispose();

    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
  }

  backButtonPressed() {
    var currentStepIndex = stepController.page;

    if (currentStepIndex == 0) {
      Navigator.pop(context);
      Navigator.pop(context);
    } else if (currentStepIndex == 1 || currentStepIndex == 2 || currentStepIndex == 3) {
      stepController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      return false;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        backButtonPressed();
      },
      child: Scaffold(
          appBar: MorphingAppBar(
            toolbarHeight: 46,
            scrolledUnderElevation: 0.0,
            heroTag: 'signUpPageAppBar',
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              splashRadius: 0.06.sw,
              onPressed: () {
                // PUSH BACK STEPS OR POP SCREEN
                backButtonPressed();
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          body: PageView(
            // physics: const NeverScrollableScrollPhysics(),
            controller: stepController,
            children: [
              UsernameChecker(
                usernameController: usernameController,
                stepController: stepController,
              ),
              AddEmailOrPhoneOrGoogleOrFacebook(
                emailController: emailController,
                phoneController: phoneController,
                stepController: stepController,
              ),
              CodeConfirmation(
                methodSelected: 'phone',
                phone: '+242 06 910 82 81',
                email: '',
                stepController: stepController,
              ),
              PasswordAndPasswordConfirmation(
                  passwordController: passwordController,
                  passwordConfirmationController: passwordConfirmationController,
                  showVisibilityIcon: showVisibilityIcon,
                  showPasswordConfirmationVisibilityIcon: showPasswordConfirmationVisibilityIcon,
                  isPswVisible: isPswVisible,
                  isPswConfirmationVisible: isPswConfirmationVisible)
            ],
          )),
    );
  }
}

// Step 1 : Username checker
// ignore: must_be_immutable
class UsernameChecker extends StatelessWidget {
  TextEditingController usernameController = TextEditingController();
  PageController stepController = PageController();

  UsernameChecker({super.key, required this.usernameController, required this.stepController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            children: [
              Text(
                'Add a username',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(
                height: 12,
              ),
              Text('Ex: claude33, emiliana,...', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(
            height: 40,
          ),

          // Username Field Input
          TextformContainer(
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-z]")),
              ],
              controller: usernameController,
              decoration: const InputDecoration(
                  hintText: 'Username', contentPadding: EdgeInsets.all(20), border: InputBorder.none),
            ),
          ),
          const SizedBox(
            height: 27,
          ),

          // Button Action : Username checked
          Button(
            height: 50,
            width: double.infinity,
            text: 'Next',
            color: kSecondColor,
            onTap: () {
              stepController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
            },
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

// Step 2 : Email or Phone | Google or Facebook
// ignore: must_be_immutable
class AddEmailOrPhoneOrGoogleOrFacebook extends StatefulWidget {
  PageController stepController;
  TextEditingController emailController;
  TextEditingController phoneController;

  AddEmailOrPhoneOrGoogleOrFacebook(
      {super.key, required this.emailController, required this.phoneController, required this.stepController});

  @override
  State<AddEmailOrPhoneOrGoogleOrFacebook> createState() => AddEmailOrPhoneOrGoogleOrFacebookState();
}

class AddEmailOrPhoneOrGoogleOrFacebookState extends State<AddEmailOrPhoneOrGoogleOrFacebook>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Continuer avec...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(
              height: 30,
            ),

            // Tab Bar
            TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              controller: _tabController,
              tabs: const [
                Tab(
                  text: 'Numéro de téléphone',
                ),
                Tab(
                  text: 'Email',
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // Tab Bar View
            Container(
              padding: const EdgeInsets.all(10.0),
              height: 80,
              child: TabBarView(
                controller: _tabController,
                children: [
                  //  Phone Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextformContainer(
                      child: TextFormField(
                        controller: widget.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            hintText: 'Numéro de téléphone',
                            contentPadding: EdgeInsets.all(20),
                            border: InputBorder.none),
                      ),
                    ),
                  ),

                  // Email Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextformContainer(
                      child: TextFormField(
                        controller: widget.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: 'Email', contentPadding: EdgeInsets.all(20), border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
              child: BuildDividerWithLabel(label: 'ou'),
            ),

            // Other Sign Up Methods : Google, Facebook
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    // Sign Up with Google
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      googleLogo,
                      height: 29,
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                InkWell(
                  onTap: () {
                    // Sign Up with Facebook
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(facebookLogo,
                        height: 34, colorFilter: const ColorFilter.mode(Color(0xFF1977F3), BlendMode.srcIn)),
                  ),
                ),
              ],
            ),

            // Action Button : SIGN UP BUTTON or Login
            const SizedBox(
              height: 40,
            ),
            Column(
              children: [
                // Login Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Button(
                    height: 50,
                    width: double.infinity,
                    text: 'Continuer',
                    color: kSecondColor,
                    onTap: () {
                      // Check Sign Up Method --> Continue
                      widget.stepController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Step 3 : Code sent Confirmation
// ignore: must_be_immutable
class CodeConfirmation extends StatefulWidget {
  PageController stepController;
  final String methodSelected;
  final String phone;
  final String email;

  CodeConfirmation(
      {super.key,
      required this.stepController,
      required this.methodSelected,
      required this.phone,
      required this.email});

  @override
  State<CodeConfirmation> createState() => _CodeConfirmationState();
}

class _CodeConfirmationState extends State<CodeConfirmation> {
  late String methodData;

  @override
  void initState() {
    //
    super.initState();

    if (widget.methodSelected == 'phone') {
      setState(() {
        methodData = widget.phone;
      });
    } else {
      setState(() {
        methodData = widget.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Vérification du code',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(
            height: 24,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  'Un code de vérification a été envoyé ${widget.methodSelected == 'phone' ? 'au numéro' : 'à l\'adresse'} ',
              style: const TextStyle(
                color: Colors.black54,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: ' ${widget.methodSelected == 'phone' ? widget.phone : widget.email} ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(
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
            animationDuration: const Duration(milliseconds: 180),
            enableActiveFill: true,
            // errorAnimationController: errorController,
            // controller: textEditingController,
            onCompleted: (code) {
              debugPrint("Completed, the final code is: $code");

              // Check code availability and redirect to Password Page
              widget.stepController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            onChanged: (value) {
              // NONE
            },
            beforeTextPaste: (text) {
              debugPrint("Allowing to paste $text");
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return true;
            },
          )
        ],
      ),
    );
  }
}

// Step 4 : Password + Password Confirmation
// ignore: must_be_immutable
class PasswordAndPasswordConfirmation extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;

  bool showVisibilityIcon;
  bool showPasswordConfirmationVisibilityIcon;
  bool isPswVisible;
  bool isPswConfirmationVisible;

  PasswordAndPasswordConfirmation(
      {super.key,
      required this.passwordController,
      required this.passwordConfirmationController,
      required this.showVisibilityIcon,
      required this.showPasswordConfirmationVisibilityIcon,
      required this.isPswVisible,
      required this.isPswConfirmationVisible});

  @override
  State<PasswordAndPasswordConfirmation> createState() => _PasswordAndPasswordConfirmationState();
}

class _PasswordAndPasswordConfirmationState extends State<PasswordAndPasswordConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Ajouter un mot de passe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(
            height: 30,
          ),

          // Password Field
          TextformContainer(
            child: TextFormField(
              controller: widget.passwordController,
              onChanged: ((value) => {
                    if (value != '')
                      {
                        setState(() {
                          widget.showVisibilityIcon = true;
                        })
                      }
                    else
                      {
                        setState(() {
                          widget.showVisibilityIcon = false;
                        })
                      }
                  }),
              obscureText: widget.isPswVisible,
              decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  contentPadding: const EdgeInsets.all(20),
                  border: InputBorder.none,
                  suffixIcon: widget.showVisibilityIcon
                      ? IconButton(
                          splashRadius: 0.06.sw,
                          onPressed: () {
                            setState(() {
                              widget.isPswVisible = !widget.isPswVisible;
                            });
                          },
                          icon: widget.isPswVisible
                              ? const Icon(Icons.visibility_rounded)
                              : const Icon(Icons.visibility_off_rounded))
                      : const SizedBox(
                          width: 2,
                          height: 2,
                        )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          // Password Confirmation Field
          widget.showVisibilityIcon
              ? Column(
                  children: [
                    TextformContainer(
                      child: TextFormField(
                        controller: widget.passwordConfirmationController,
                        onChanged: ((value) => {
                              if (value != '')
                                {
                                  setState(() {
                                    widget.showPasswordConfirmationVisibilityIcon = true;
                                  })
                                }
                              else
                                {
                                  setState(() {
                                    widget.showPasswordConfirmationVisibilityIcon = false;
                                  })
                                }
                            }),
                        obscureText: widget.isPswConfirmationVisible,
                        decoration: InputDecoration(
                            hintText: 'Confirmer le mot de passe',
                            contentPadding: const EdgeInsets.all(20),
                            border: InputBorder.none,
                            suffixIcon: widget.showVisibilityIcon
                                ? IconButton(
                                    splashRadius: 0.06.sw,
                                    onPressed: () {
                                      setState(() {
                                        widget.isPswConfirmationVisible = !widget.isPswConfirmationVisible;
                                      });
                                    },
                                    icon: widget.isPswConfirmationVisible
                                        ? const Icon(Icons.visibility_rounded)
                                        : const Icon(Icons.visibility_off_rounded))
                                : const SizedBox(
                                    width: 2,
                                    height: 2,
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Button(
              height: 50,
              width: double.infinity,
              text: 'Terminer',
              color: kSecondColor,
              onTap: () {
                // Check Sign Up Method --> Continue
                Navigator.push(
                  context,
                  SwipeablePageRoute(
                    builder: (context) => const IntroductionScreensPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

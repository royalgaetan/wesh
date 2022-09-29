import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wesh/google_provider.dart';
import 'package:wesh/pages/auth.pages/add_phone.dart';
import 'package:wesh/pages/auth.pages/add_username.dart';
import 'package:wesh/pages/forgotpassword.dart';
import 'package:wesh/services/auth.methods.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/functions.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/textfieldcontainer.dart';
import '../services/internet_connection_checher.dart';
import '../widgets/buildWidgets.dart';
import 'startPage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

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
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  continueWithEmailAndPassword(context) async {
    setState(() {
      isPageLoading = true;
    });
    var isConnected = await InternetConnection().isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      print("Has connection : $isConnected");

      // Validate Form & Login
      var email = emailController.text.trim();
      var psw = passwordController.text.trim();

      if (email != null && !EmailValidator.validate(email)) {
        return showSnackbar(
            context, 'Veuillez entrer une adresse email valide', null);
      }

      if (psw != null && psw.length < 6) {
        return showSnackbar(context,
            'Veuillez entrer un mot de passe de plus de 6 caractères', null);
      }

      var result =
          await AuthMethods().loginWithEmailAndPassword(context, email, psw);

      if (result) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StartPage(),
            ),
            (route) => false);
      }
    } else {
      print("Has connection : $isConnected");
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
    }
  }

  continueWithGoogle() async {
    setState(() {
      isPageLoading = true;
    });
    var isConnected = await InternetConnection().isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      // Continue with Google

      print("Has connection : $isConnected");

      List isAllowedToContinue =
          await AuthMethods().continueWithGoogle(context, 'login');

      print("isAllowedToContinue: $isAllowedToContinue");

      if (isAllowedToContinue[0]) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        // Redirect to StartPage
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StartPage(),
            ),
            (route) => false);
      } else {
        showSnackbar(context, isAllowedToContinue[1], null);
      }
    } else {
      print("Has connection : $isConnected");
      showSnackbar(context, 'Veuillez vérifier votre connexion internet', null);
    }
  }

  continueWithFacebook() async {
    setState(() {
      isPageLoading = true;
    });
    var isConnected = await InternetConnection().isConnected(context);
    setState(() {
      isPageLoading = false;
    });
    if (isConnected) {
      // Continue with Google

      print("Has connection : $isConnected");

      List isAllowedToContinue =
          await AuthMethods().continueWithFacebook(context, 'login');

      print("isAllowedToContinue: $isAllowedToContinue");

      if (isAllowedToContinue[0]) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        // Redirect to StartPage
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StartPage(),
            ),
            (route) => false);
      } else {
        showSnackbar(context, isAllowedToContinue[1], null);
      }
    } else {
      print("Has connection : $isConnected");
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                reverse: true,
                children: [
                  // App Title
                  buildlogo(),

                  // Form Fields
                  const SizedBox(height: 70),

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
                            decoration: const InputDecoration(
                                hintText: 'Email',
                                contentPadding: EdgeInsets.all(20),
                                border: InputBorder.none),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),

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
                                hintText: 'Mot de passe',
                                contentPadding: const EdgeInsets.all(20),
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
                                            ? Icon(Icons.visibility_rounded)
                                            : Icon(
                                                Icons.visibility_off_rounded))
                                    : Container(
                                        width: 2,
                                        height: 2,
                                      )),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),

                  // Forgot Password BUTTON

                  buildforgotpswBTN(),

                  // Action Buttons
                  const SizedBox(height: 20),
                  // Login Button
                  Button(
                    height: 50,
                    width: double.infinity,
                    text: 'Se connecter',
                    color: kSecondColor,
                    onTap: () async {
                      // Login with Email and Password
                      continueWithEmailAndPassword(context);
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  // Divider
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
                    child: buildDividerWithLabel(label: 'ou continuer avec'),
                  ),

                  // Other login Methods : Phone, Google, Facebook
                  buildOtherSignupMethods(
                    continueWithGoogleOnTap: continueWithGoogle,
                    continueWithFacebookOnTap: continueWithFacebook,
                  ),

                  const SizedBox(height: 50),

                  // Sign Up Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          // Redirect to Sign Up Page : CheckUsernanePage
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddUsernamePage(),
                              ));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Créer un compte',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ].reversed.toList(),
              ),
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
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordPage(),
                ));
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Mot de passe oublié ?',
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }
}

class buildOtherSignupMethods extends StatelessWidget {
  final VoidCallback continueWithGoogleOnTap;
  final VoidCallback continueWithFacebookOnTap;

  const buildOtherSignupMethods({
    Key? key,
    required this.continueWithGoogleOnTap,
    required this.continueWithFacebookOnTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () {
            //  Phone Auth
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPhonePage(),
                ));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              phoneLogo,
              height: 34,
            ),
          ),
        ),
        InkWell(
          onTap: continueWithGoogleOnTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              googleLogo,
              height: 29,
            ),
          ),
        ),
        InkWell(
          onTap: continueWithFacebookOnTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              facebookLogo,
              height: 34,
              color: Color(0xFF1977F3),
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
    return Container(
      child: SvgPicture.asset(
        weehLogo,
        height: 70,
        color: kSecondColor,
      ),
    );
  }
}

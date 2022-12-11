import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/settings.pages/account_security_settings.dart';
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
  bool showPasswordConfirmation_VisibilityIcon = false;
  bool isPswVisible = true;
  bool isPswConfirmationVisible = true;

  @override
  void initState() {
    // TODO: implement initState
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
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
  }

  checkEmailandPasswordandLinkProvider(context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CupertinoActivityIndicator(radius: 12.sp, color: Colors.white),
      ),
    );

    var isConnected = await InternetConnection().isConnected(context);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // Checkers : email
      String email = emailController.text.trim();
      String psw = passwordController.text.trim();
      String confirmPsw = passwordConfirmationController.text.trim();

      if (email != null && !EmailValidator.validate(email)) {
        // ignore: use_build_context_synchronously
        return showSnackbar(context, 'Veuillez entrer une adresse email valide', null);
      }

      bool isEmailUsed = await checkIfEmailInUse(context, emailController.text);

      if (isEmailUsed == true) {
        // ignore: use_build_context_synchronously
        return showSnackbar(context, 'Cette adresse email est déjà utilisée', null);
      }

      // Checkers : password
      if (psw.isEmpty) {
        // ignore: use_build_context_synchronously
        return showSnackbar(context, 'Veuillez entrer un mot de passe', null);
      } else if (psw.length < 6) {
        // ignore: use_build_context_synchronously
        return showSnackbar(context, 'Votre mot de passe doit contenir plus de 6 caractères', null);
      } else if (confirmPsw.isEmpty) {
        // ignore: use_build_context_synchronously
        return showSnackbar(context, 'Veuillez confirmer votre mot de passe', null);
      } else if (confirmPsw != psw) {
        // ignore: use_build_context_synchronously
        return showSnackbar(context, 'Vos mots de passe ne correspondent pas', null);
      }

      // IF ALL CHECKERS VALIDATED : [CONTINUE]
      // Link Password Provider
      List result = await AuthMethods().linkCredentialsbyEmailAccount(context, email, psw);
      if (result[0]) {
        // Redirect to Settings Security Page
        Navigator.of(context).pop();
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
      appBar: MorphingAppBar(
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
          'Email et mot de passe',
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
              Column(children: const [
                Text(
                  'Attacher votre email et un mot de passe',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                SizedBox(
                  height: 30,
                ),
              ]),

              // Email
              TextformContainer(
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(
                      hintText: 'Email', contentPadding: EdgeInsets.all(20), border: InputBorder.none),
                ),
              ),
              const SizedBox(
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
                                        showPasswordConfirmation_VisibilityIcon = true;
                                      })
                                    }
                                  else
                                    {
                                      setState(() {
                                        showPasswordConfirmation_VisibilityIcon = false;
                                      })
                                    }
                                }),
                            obscureText: isPswConfirmationVisible,
                            decoration: InputDecoration(
                                hintText: 'Confirmer le mot de passe',
                                contentPadding: const EdgeInsets.all(20),
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
                  text: 'Ajouter',
                  color: kSecondColor,
                  onTap: () {
                    // Check Email and Passwords --> Continue to Setings Security Page
                    checkEmailandPasswordandLinkProvider(context);
                  },
                ),
              ),
            ].reversed.toList(),
          ),
        ),
      ),
    );
  }
}

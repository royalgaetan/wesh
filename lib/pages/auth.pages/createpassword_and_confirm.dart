import 'package:flutter/material.dart';
import 'package:wesh/pages/auth_controller_page.dart';
import 'package:wesh/pages/in.pages/introductionpages.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/services/auth.methods.dart';

import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';
import '../../widgets/textfieldcontainer.dart';

class CreatePassword extends StatefulWidget {
  CreatePassword({Key? key}) : super(key: key);

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController passwordConfirmationController =
      TextEditingController();
  bool showVisibilityIcon = false;
  bool showPasswordConfirmation_VisibilityIcon = false;
  bool isPswVisible = true;
  bool isPswConfirmationVisible = true;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
  }

  checkPasswords(context, password, confirmPassword) async {
    String psw = password.toString();
    String confirmPsw = confirmPassword.toString();

    if (psw.isEmpty) {
      return showSnackbar(context, 'Veuillez entrer un mot de passe', null);
    } else if (psw.length < 6) {
      return showSnackbar(context,
          'Votre mot de passe doit contenir plus de 6 caractères', null);
    } else if (confirmPsw.isEmpty) {
      return showSnackbar(
          context, 'Veuillez confirmer votre mot de passe', null);
    } else if (confirmPsw != psw) {
      return showSnackbar(
          context, 'Vos mots de passe ne correspondent pas', null);
    }

    // IF PASSWORD CHECKED

    passwordController.clear();
    passwordConfirmationController.clear();

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    String? emailCached = UserSimplePreferences.getEmail() ?? '';
    var result = await AuthMethods()
        .createUserWithEmailAndPassword(context, emailCached, password);

    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => StartPage(),
          ),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          splashRadius: 25,
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
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            reverse: true,
            children: [
              const Text(
                'Ajouter un mot de passe',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const SizedBox(
                height: 30,
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
                                  : Icon(Icons.visibility_off_rounded))
                          : Container(
                              width: 2,
                              height: 2,
                            )),
                ),
              ),
              SizedBox(
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
                                        showPasswordConfirmation_VisibilityIcon =
                                            true;
                                      })
                                    }
                                  else
                                    {
                                      setState(() {
                                        showPasswordConfirmation_VisibilityIcon =
                                            false;
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
                                            isPswConfirmationVisible =
                                                !isPswConfirmationVisible;
                                          });
                                        },
                                        icon: isPswConfirmationVisible
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
                    // Check Passwords --> Continue to IntroductionScreensPage
                    checkPasswords(context, passwordController.text,
                        passwordConfirmationController.text);
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

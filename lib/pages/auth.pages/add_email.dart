import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/auth.methods.dart';
import '../../services/internet_connection_checker.dart';
import '../../services/sharedpreferences.service.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';
import '../../widgets/textfieldcontainer.dart';

class AddEmailPage extends StatefulWidget {
  const AddEmailPage({Key? key}) : super(key: key);

  @override
  State<AddEmailPage> createState() => _AddEmailPageState();
}

class _AddEmailPageState extends State<AddEmailPage> {
  TextEditingController emailController = TextEditingController();
  bool isPageLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    toggleRedirectToAddEmailPageValue();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
  }

  Future toggleRedirectToAddEmailPageValue() async {
    await UserSimplePreferences.setRedirectToAddEmailPageValue(false);
    debugPrint(
        "New value Redirect to Setting Page [AddEmailPage]: ${UserSimplePreferences.getRedirectToAddEmailPageValue()}");
  }

  checkEmailandUpdateProvider(context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CupertinoActivityIndicator(radius: 16, color: Colors.white),
      ),
    );

    var isConnected = await InternetConnection().isConnected(context);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // Checkers : email
      String email = emailController.text.trim();

      if (email != null && !EmailValidator.validate(email)) {
        // ignore: use_build_context_synchronously
        return showSnackbar(
            context, 'Veuillez entrer une adresse email valide', null);
      }

      bool isEmailUsed = await checkIfEmailInUse(context, emailController.text);

      if (isEmailUsed == true) {
        // ignore: use_build_context_synchronously
        return showSnackbar(
            context, 'Cette adresse email est déjà utilisée', null);
      }

      // IF ALL CHECKERS VALIDATED : [CONTINUE]
      // Link Password Provider
      List result = await AuthMethods().updateCurrentUserEmail(context, email);
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
                  const Text(
                    'Ajoutez votre email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 40,
                  ),

                  // Email Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextformContainer(
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            hintText: 'Email',
                            contentPadding: EdgeInsets.all(20),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  // Button Action : Add email
                  Button(
                    height: 50,
                    width: double.infinity,
                    text: 'Ajouter',
                    color: kSecondColor,
                    onTap: () async {
                      checkEmailandUpdateProvider(context);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ].reversed.toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:email_validator/email_validator.dart';
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
    //
    super.initState();
    toggleRedirectToAddEmailPageValue();
  }

  @override
  void dispose() {
    //
    super.dispose();
    emailController.dispose();
  }

  Future toggleRedirectToAddEmailPageValue() async {
    await UserSimplePreferences.setRedirectToAddEmailPageValue(false);
    debugPrint(
        "New value Redirect to Setting Page [AddEmailPage]: ${UserSimplePreferences.getRedirectToAddEmailPageValue()}");
  }

  checkEmailandUpdateProvider(context) async {
    showFullPageLoader(context: context);

    var isConnected = await InternetConnection.isConnected(context);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    if (isConnected) {
      debugPrint("Has connection : $isConnected");

      // Checkers : email
      String email = emailController.text.trim();

      if (email != null && !EmailValidator.validate(email)) {
        // ignore: use_build_context_synchronously
        return showSnackbar(context, 'Veuillez entrer une adresse email valide', null);
      }

      bool isEmailUsed = await AuthMethods.checkIfEmailInUse(context, emailController.text);

      if (isEmailUsed == true) {
        // ignore: use_build_context_synchronously
        return showSnackbar(context, 'Cette adresse email est déjà utilisée', null);
      }

      // IF ALL CHECKERS VALIDATED : [CONTINUE]
      // Link Password Provider
      List result = await AuthMethods.updateCurrentUserEmail(context, email);
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
      appBar: MorphingAppBar(
        heroTag: 'addEmailPageAppBar',
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
                Text(
                  'Ajoutez votre email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.sp,
                  ),
                ),

                SizedBox(height: 0.12.sw),

                // Email Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextformContainer(
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                        contentPadding: EdgeInsets.all(0.04.sw),
                        hintText: 'Email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),

                // Button Action : Add email
                Button(
                  height: 0.12.sw,
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
        ],
      ),
    );
  }
}

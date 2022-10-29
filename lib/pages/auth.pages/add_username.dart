import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wesh/pages/auth.pages/add_name_and_birthday.dart';
import 'package:wesh/services/sharedpreferences.service.dart';
import '../../services/internet_connection_checker.dart';
import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../../widgets/button.dart';
import '../../widgets/textfieldcontainer.dart';

class AddUsernamePage extends StatefulWidget {
  AddUsernamePage({Key? key}) : super(key: key);

  @override
  State<AddUsernamePage> createState() => _CheckUsernameState();
}

class _CheckUsernameState extends State<AddUsernamePage> {
  TextEditingController usernameController = TextEditingController();
  bool isUsernameUsed = false;
  bool isPageLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    usernameController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                  Column(
                    children: const [
                      Text(
                        'Ajouter un nom d\'utilisateur',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text('Ex: claude33, emiliana,...',
                          style: TextStyle(color: Colors.black54)),
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
                      onChanged: (value) async {
                        bool isUsed =
                            await checkIfUsernameInUse(context, value);
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
                          hintText: 'Nom d\'utilisateur',
                          contentPadding: EdgeInsets.all(20),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    height: 27,
                  ),

                  // Button Action : Username checked
                  Button(
                    height: 50,
                    width: double.infinity,
                    text: 'Suivant',
                    color: kSecondColor,
                    onTap: () async {
                      // Check Username
                      setState(() {
                        isPageLoading = true;
                      });
                      var isConnected =
                          await InternetConnection().isConnected(context);
                      if (mounted) {
                        setState(() {
                          isPageLoading = false;
                        });
                      }
                      if (isConnected) {
                        debugPrint("Has connection : $isConnected");
                        checkUsername(context, usernameController.text);
                      } else {
                        debugPrint("Has connection : $isConnected");
                        showSnackbar(context,
                            'Veuillez vérifier votre connexion internet', null);
                      }
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

checkUsername(context, String username) async {
  if (username.isNotEmpty && username.length > 4) {
    bool isUsed = await checkIfUsernameInUse(context, username);

    debugPrint('Username isUsed: $isUsed');
    if (!isUsed) {
      // Check Username
      await UserSimplePreferences.setUsername(username);

      // Go to Sign Up Methods Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddNameAndBirthdayPage()),
      );
    } else {
      showSnackbar(context, 'Ce nom d\'utilisateur est déjà pris', null);
    }
  } else {
    showSnackbar(context,
        'Veuillez entrer un nom d\'utilisateur de plus de 4 caractères', null);
  }
}

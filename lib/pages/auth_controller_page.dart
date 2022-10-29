import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wesh/providers/user.provider.dart';
import '../services/auth.methods.dart';
import '../widgets/button.dart';
import 'auth.pages/add_name_and_birthday.dart';
import 'startPage.dart';

class AuthPageController extends StatefulWidget {
  AuthPageController({Key? key}) : super(key: key);

  @override
  State<AuthPageController> createState() => _AuthPageControllerState();
}

class _AuthPageControllerState extends State<AuthPageController> {
  late StreamSubscription subscription;
  bool hasConnection = false;

  @override
  initState() {
    super.initState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!

      if (result != ConnectivityResult.none) {
        // HAS CONNECTION
        debugPrint("HAS CONNECTION");
        setState(() {
          hasConnection = true;
        });

        // check if the user email is verified
        // var hasEmail = FirebaseAuth.instance.currentUser!.email!;
        // var isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
        // if (!isVerified && hasEmail.isNotEmpty) {
        //   Navigator.pushAndRemoveUntil(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => VerifyEmailPage(),
        //       ),
        //       (route) => false);
        // }

        // check if the user has a name and birthday
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StartPage(),
            ),
            (route) => false);
      } else {
        // NO CONNECTION
        debugPrint("NO CONNECTION");
        setState(() {
          hasConnection = false;
        });
      }
    });
  }

  @override
  dispose() {
    super.dispose();

    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    hasConnection
                        ? Column(
                            children: const [
                              CupertinoActivityIndicator(
                                  radius: 16, color: Colors.grey),
                              SizedBox(
                                height: 25,
                              ),
                              Text('Veuillez patienter...')
                            ],
                          )
                        : const Text(
                            'Veuillez vérifier votre connexion internet pour continuer'),
                  ],
                ),
              ),
            ),
            Button(
              height: 50,
              width: double.infinity,
              text: 'Se deconnecter',
              fontColor: Colors.black87,
              color: Colors.white,
              isBordered: true,
              onTap: () {
                // Sign out
                AuthMethods().signout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

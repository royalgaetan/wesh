import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class LoginActivityPage extends StatefulWidget {
  const LoginActivityPage({super.key});

  @override
  State<LoginActivityPage> createState() => _LoginActivityPageState();
}

class _LoginActivityPageState extends State<LoginActivityPage> {
  User? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 25,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Votre activité de connexion',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Last connexion
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.userClock,
                    size: 24,
                  ),
                  title: const Text('Dernière connexion'),
                  subtitle: user != null
                      ? Text(
                          '${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(user!.metadata.lastSignInTime!)} à ${DateFormat('HH:mm', 'fr_Fr').format(user!.metadata.lastSignInTime!)}')
                      : const CupertinoActivityIndicator(
                          radius: 16, color: Colors.black54),
                ),

                const SizedBox(height: 20),

                // Account createdAt
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.userCheck,
                    size: 24,
                  ),
                  title: const Text('Date de création du compte'),
                  subtitle: user != null
                      ? Text(
                          '${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(user!.metadata.creationTime!)} à ${DateFormat('HH:mm', 'fr_Fr').format(user!.metadata.creationTime!)}')
                      : const CupertinoActivityIndicator(
                          radius: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class LoginActivityPage extends StatefulWidget {
  const LoginActivityPage({super.key});

  @override
  State<LoginActivityPage> createState() => _LoginActivityPageState();
}

class _LoginActivityPageState extends State<LoginActivityPage> {
  User? user;
  @override
  void initState() {
    //
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MorphingAppBar(
        heroTag: 'loginActivityPageAppBar',
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          splashRadius: 0.06.sw,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Last connexion
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.userClock,
                  size: 20.sp,
                ),
                horizontalTitleGap: 10,
                title: const Text('Dernière connexion'),
                subtitle: user != null
                    ? Text(
                        '${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(user!.metadata.lastSignInTime!)} à ${DateFormat('HH:mm', 'fr_Fr').format(user!.metadata.lastSignInTime!)}')
                    : CupertinoActivityIndicator(radius: 12.sp, color: Colors.black54),
              ),

              const SizedBox(height: 10),

              // Account createdAt
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.userCheck,
                  size: 20.sp,
                ),
                horizontalTitleGap: 10,
                title: const Text('Date de création du compte'),
                subtitle: user != null
                    ? Text(
                        '${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(user!.metadata.creationTime!)} à ${DateFormat('HH:mm', 'fr_Fr').format(user!.metadata.creationTime!)}')
                    : CupertinoActivityIndicator(radius: 12.sp, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

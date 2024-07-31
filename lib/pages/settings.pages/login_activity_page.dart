import 'package:firebase_auth/firebase_auth.dart';
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
        toolbarHeight: 46,
        scrolledUnderElevation: 0.0,
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
          'Your activity',
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
                  color: Colors.black87,
                ),
                horizontalTitleGap: 20,
                title: Text(
                  'Last Login',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Container(
                  padding: const EdgeInsets.only(top: 1),
                  alignment: Alignment.centerLeft,
                  child: user != null
                      ? Text(
                          '${DateFormat('EEE, d MMM yyyy', 'en_En').format(user!.metadata.lastSignInTime!)}\nat ${DateFormat('HH:mm', 'en_En').format(user!.metadata.lastSignInTime!)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade700,
                          ),
                        )
                      : Container(
                          width: 13,
                          height: 13,
                          margin: const EdgeInsets.only(top: 1),
                          child: const RepaintBoundary(
                            child: CircularProgressIndicator(strokeWidth: 1.4, color: Colors.black87),
                          )),
                ),
              ),

              const SizedBox(height: 10),

              // Account createdAt
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.userCheck,
                  size: 20.sp,
                  color: Colors.black87,
                ),
                horizontalTitleGap: 20,
                title: Text(
                  'Account Creation Date',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Container(
                  padding: const EdgeInsets.only(top: 1),
                  alignment: Alignment.centerLeft,
                  child: user != null
                      ? Text(
                          '${DateFormat('EEE, d MMM yyyy', 'en_En').format(user!.metadata.creationTime!)}\nat ${DateFormat('HH:mm', 'en_En').format(user!.metadata.creationTime!)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade700,
                          ),
                        )
                      : Container(
                          width: 13,
                          height: 13,
                          margin: const EdgeInsets.only(top: 1),
                          child: const RepaintBoundary(
                            child: CircularProgressIndicator(strokeWidth: 1.4, color: Colors.black87),
                          )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

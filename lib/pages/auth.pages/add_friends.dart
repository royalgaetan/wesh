import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import '../../models/user.dart' as usermodel;
import '../../services/firestore.methods.dart';
import '../../widgets/usercard.dart';

class AddFriends extends StatefulWidget {
  const AddFriends({Key? key}) : super(key: key);

  @override
  State<AddFriends> createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 20, left: 15, right: 15),
              child: Text(
                'Suivez une personne qui vous interesse',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
              ),
            ),

            // ACCOUNT SUGGESTIONS
            Expanded(
              child: FutureBuilder<List<usermodel.User>>(
                future: FirestoreMethods.getAllUsersAsFuture(),
                builder: (context, snapshot) {
                  // Handle Errors
                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(50),
                      height: 300,
                      child: const Text(
                        'Une erreur s\'est produite',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    );
                  }

                  // Handle Data and perform search
                  if (snapshot.hasData) {
                    List<usermodel.User> accountSuggestions =
                        (snapshot.data!).where((user) => user.id != FirebaseAuth.instance.currentUser!.uid).toList();
                    // Shuffle the suggestions result --> to get Random suggestions
                    accountSuggestions.shuffle();

                    // DATA FOUND
                    if (accountSuggestions.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: accountSuggestions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                            child: UserCard(
                              user: accountSuggestions[index],
                              status: 'followUnfollow',
                              onTap: () {},
                            ),
                          );
                        },
                      );
                    }

                    // NO DATA FOUND
                    else {
                      return Container(
                        padding: const EdgeInsets.all(50),
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              height: 150,
                              empty,
                              width: double.infinity,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Aucune suggestion pour l\'instant !',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }

                  // Display Loading while waiting
                  return Container(
                    padding: const EdgeInsets.all(50),
                    height: 100,
                    child: const Center(child: CupertinoActivityIndicator()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Button(
          height: 0.12.sw,
          width: double.infinity,
          text: 'Commencer',
          color: kSecondColor,
          onTap: () {
            // Redirect to Start Page
            Navigator.pushAndRemoveUntil(
                context,
                SwipeablePageRoute(
                  builder: (context) => StartPage(context: context),
                ),
                (route) => false);
          },
        ),
      ),
    );
  }
}

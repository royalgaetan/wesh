import 'package:flutter/material.dart';
import 'package:wesh/pages/auth_controller_page.dart';
import 'package:wesh/pages/in.pages/create_or_update_contactpage.dart';
import 'package:wesh/pages/startPage.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/utils/db.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/button.dart';
import 'package:wesh/widgets/usercard.dart';

class AddFriends extends StatefulWidget {
  AddFriends({Key? key}) : super(key: key);

  @override
  State<AddFriends> createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 40, bottom: 0, left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: const [
                  Text(
                    'Suivez une personne qui vous interesse',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),

              // Suggestions Header

              // const Padding(
              //   padding: EdgeInsets.only(top: 13, bottom: 20),
              //   child: Text(
              //     'Suggestions',
              //     textAlign: TextAlign.left,
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              //   ),
              // ),

              // Suggestions List
              // Expanded(
              //   child:
              //   ListView.builder(
              //     itemCount: 3,
              //     itemBuilder: ((context, index) => UserCard(
              //           status: 'isfollowing',
              //           id: '${usersList[index].id}',
              //           name: usersList[index].name,
              //           username: usersList[index].username,
              //           profilePicture: usersList[index].profilePicture,
              //           onTap: () {
              //             // Follow Unfollow Status
              //             // setState(() {
              //             //   if (status == 'notfollowing') {
              //             //     status = 'isfollowing';
              //             //   } else if (status == 'isfollowing') {
              //             //     status = 'notfollowing';
              //             //   }
              //             // });
              //           },
              //         )),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Button(
          height: 50,
          width: double.infinity,
          text: 'Commencer',
          color: kSecondColor,
          onTap: () {
            // Redirect to Start Page
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => StartPage(),
                ),
                (route) => false);
          },
        ),
      ),
    );
  }
}

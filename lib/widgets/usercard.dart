import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import '../models/user.dart' as UserModel;

class UserCard extends StatefulWidget {
  final UserModel.User user;
  final String status;
  final VoidCallback onTap;

  const UserCard({
    required this.user,
    required this.status,
    required this.onTap,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  // Redirect to Profile Page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                            uid: widget.user.id, showBackButton: true),
                      ));
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(widget.user.profilePicture),
                ),
              ),
              const SizedBox(
                width: 10,
              ),

              // USER INFO
              GestureDetector(
                onTap: () {
                  // Redirect to Profile Page
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                            uid: widget.user.id, showBackButton: true),
                      ));
                },
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact name
                      Text(
                        widget.user.id == FirebaseAuth.instance.currentUser!.uid
                            ? 'Vous'
                            : widget.user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 17),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      // Contact username
                      Text(
                        '@${widget.user.username}',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
          Row(
            children: [
              // IF THE USER IS A FOLLOWER
              widget.status == 'follower'
                  ? Button(
                      text: 'Retirer',
                      height: 40,
                      width: 90,
                      fontsize: 14,
                      fontColor: Colors.black,
                      color: Colors.white,
                      isBordered: true,
                      onTap: widget.onTap)
                  : Container(),

              // IF CURRENT_USER IS ALREADY FOLLOWING
              widget.status == 'isfollowing'
                  ? Button(
                      text: 'Se désabonner',
                      height: 40,
                      width: 133,
                      fontsize: 14,
                      fontColor: Colors.black,
                      color: Color(0xFFF0F0F0),
                      isBordered: false,
                      onTap: widget.onTap)
                  : Container(),

              // IF CURRENT_USER ISN'T FOLLOW
              widget.status == 'notfollowing'
                  ? Button(
                      text: 'S\'abonner',
                      height: 40,
                      width: 90,
                      fontsize: 14,
                      fontColor: Colors.white,
                      color: kSecondColor,
                      onTap: widget.onTap)
                  : Container(),
            ],
          )
        ],
      ),
    );
  }
}

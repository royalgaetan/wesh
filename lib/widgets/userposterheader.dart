import 'package:flutter/material.dart';
import 'package:wesh/pages/profile.dart';

class userposterheader extends StatelessWidget {
  final String uid;
  final String profilepic;
  final double radius;
  final String username;
  final Color? usernameColor;
  final double? spacebetween;

  const userposterheader({
    required this.uid,
    required this.profilepic,
    required this.radius,
    required this.username,
    this.spacebetween,
    this.usernameColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => profilePage(
              uid: uid,
            ),
          ),
        );
      },
      child: Row(
        children: [
          profilepic.isNotEmpty
              ? CircleAvatar(
                  radius: radius,
                  backgroundImage: AssetImage(profilepic),
                )
              : CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.grey.shade600,
                ),
          SizedBox(
            width: spacebetween ?? 15,
          ),
          Text(
            '$username',
            style: TextStyle(
                fontSize: 15,
                color: usernameColor != null ? usernameColor : Colors.black,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

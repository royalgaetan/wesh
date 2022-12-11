import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/button.dart';
import '../models/user.dart' as UserModel;
import '../services/firestore.methods.dart';

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
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              // Redirect to Profile Page
              Navigator.push(
                  context,
                  SwipeablePageRoute(
                    builder: (context) => ProfilePage(uid: widget.user.id, showBackButton: true),
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
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // Redirect to Profile Page
                Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => ProfilePage(uid: widget.user.id, showBackButton: true),
                    ));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Contact name
                  Wrap(
                    children: [
                      Text(
                        widget.user.id == FirebaseAuth.instance.currentUser!.uid ? 'Moi' : widget.user.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),

                  // Contact username
                  Wrap(
                    children: [
                      Text(
                        '@${widget.user.username}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              // IF THE USER IS WAITING FORWARDING
              widget.status == 'forward'
                  ? Button(
                      text: 'Envoyer',
                      height: 0.12.sw,
                      width: 0.27.sw,
                      fontsize: 14.sp,
                      fontColor: Colors.black,
                      color: Colors.white,
                      isBordered: true,
                      onTap: widget.onTap)
                  : Container(),

              // HANDLE FOLLOW/UNFOLLOW/REMOVE
              widget.status == 'followUnfollow' && widget.user.id != FirebaseAuth.instance.currentUser!.uid
                  ? StreamBuilder<UserModel.User>(
                      stream: FirestoreMethods().getUserById(FirebaseAuth.instance.currentUser!.uid),
                      builder: (context, snapshot) {
                        // Handle error
                        if (snapshot.hasError) {
                          debugPrint('error: ${snapshot.error}');
                          return Button(
                            text: 'Erreur...',
                            height: 0.12.sw,
                            width: 0.27.sw,
                            fontsize: 14.sp,
                            fontColor: Colors.black,
                            color: const Color(0xFFF0F0F0),
                            isBordered: false,
                            onTap: widget.onTap,
                          );
                        }

                        // handle data
                        if (snapshot.hasData && snapshot.data != null) {
                          UserModel.User? userGet = snapshot.data;

                          if (userGet != null && userGet.followers != null && userGet.following != null) {
                            List<String> getUserFollowers =
                                userGet.followers!.map((followerId) => followerId.toString()).toList();
                            List<String> getUserFollowings =
                                userGet.following!.map((followingId) => followingId.toString()).toList();

                            // Case 1: Follow

                            // Case 2: Unfollow

                            // Case 3: Remove

                          }

                          return Button(
                            text: '...',
                            height: 0.12.sw,
                            width: 0.27.sw,
                            fontsize: 14.sp,
                            fontColor: Colors.black,
                            color: const Color(0xFFF0F0F0),
                            isBordered: false,
                            onTap: widget.onTap,
                          );
                        }

                        // Diplay Loader

                        return Button(
                          text: '',
                          height: 0.122.sw,
                          width: 0.4.sw,
                          fontsize: 14.sp,
                          fontColor: Colors.white,
                          prefixIsLoading: true,
                          color: kSecondColor,
                          prefixIcon: Icons.timer_outlined,
                          prefixIconColor: Colors.white,
                          prefixIconSize: 15.sp,
                          onTap: () async {
                            //
                          },
                        );
                      },
                    )
                  : Container(),

              // IF CURRENT_USER IS ALREADY FOLLOWING
              widget.status == 'isfollowing'
                  ? Button(
                      text: 'Se désabonner',
                      height: 0.12.sw,
                      width: 0.27.sw,
                      fontsize: 14.sp,
                      fontColor: Colors.black,
                      color: const Color(0xFFF0F0F0),
                      isBordered: false,
                      onTap: widget.onTap)
                  : Container(),

              // IF CURRENT_USER ISN'T FOLLOW
              widget.status == 'notfollowing'
                  ? Button(
                      text: 'S\'abonner',
                      height: 0.12.sw,
                      width: 0.27.sw,
                      fontsize: 14.sp,
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

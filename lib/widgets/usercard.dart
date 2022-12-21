import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/pages/profile.dart';
import 'package:wesh/utils/constants.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import 'package:wesh/widgets/button.dart';
import '../models/user.dart' as usermodel;

class UserCard extends StatefulWidget {
  final usermodel.User user;
  final String status;
  final VoidCallback onTap;

  const UserCard({
    Key? key,
    required this.user,
    required this.status,
    required this.onTap,
  }) : super(key: key);

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
            child: buildCachedNetworkImage(
              url: widget.user.profilePicture,
              radius: 0.07.sw,
              backgroundColor: kGreyColor,
              paddingOfProgressIndicator: 12,
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
                  // currentUser name
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

                  // currentUser username
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

              // FOLLOW/UNFOLLOW OR REMOVE
              buildFollowUnfollowOrRemoveButton(user: widget.user, status: widget.status)
            ],
          )
        ],
      ),
    );
  }
}

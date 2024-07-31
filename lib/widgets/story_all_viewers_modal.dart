import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import '../models/user.dart' as usermodel;
import '../models/story.dart';
import '../utils/functions.dart';
import 'usercard.dart';

class StoryAllViewerModal extends StatefulWidget {
  final Story story;

  const StoryAllViewerModal({super.key, required this.story});

  @override
  State<StoryAllViewerModal> createState() => _StoryAllViewerModalState();
}

class _StoryAllViewerModalState extends State<StoryAllViewerModal> {
  @override
  Widget build(BuildContext context) {
    return (() {
      // No one has seen your story yet
      if (widget.story.viewers.isEmpty) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'No one has seen this story yet',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        );
      } else if (widget.story.viewers.isNotEmpty) {
        return StreamBuilder(
          stream: FirestoreMethods.getUserByIdInList(widget.story.viewers.map((userId) => userId.toString()).toList()),
          builder: (context, snapshot) {
            // on Error
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: BuildErrorWidget(onWhiteBackground: true),
                ),
              );
            }

            // has data
            if (snapshot.hasData) {
              List<usermodel.User> users = snapshot.data as List<usermodel.User>;

              // At least one user has seen your story
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Text(
                      '${users.length} ${getSatTheEnd(users.length, 'view')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17.sp,
                      ),
                    ),
                    // BODY
                    const SizedBox(
                      height: 12,
                    ),

                    ...users.map((user) => UserCard(
                          user: user,
                          status: '',
                          onTap: () {
                            // None
                          },
                        )),
                  ],
                ),
              );
            }

            // return ProgressBar
            return const SizedBox(
              height: 200,
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          },
        );
      }

      return Container();
    }());
  }
}

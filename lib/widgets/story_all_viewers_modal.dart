import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wesh/providers/user.provider.dart';
import '../models/user.dart' as UserModel;
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
      if (widget.story.viewers.length == 0) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Aucune personne n\'a encore vu cette story',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        );
      } else if (widget.story.viewers.length > 0) {
        return StreamBuilder(
          stream: Provider.of<UserProvider>(context)
              .getUsersInTheGivenList(widget.story.viewers),
          builder: (context, snapshot) {
            // on Error
            if (snapshot.hasError) {
              const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Une erreur s\'est produite lors du chargement',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ),
              );
            }

            // has data
            if (snapshot.hasData) {
              List<UserModel.User> users =
                  snapshot.data as List<UserModel.User>;

              // At least one user has seen your story
              return Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Text(
                      '${users.length} ${getSatTheEnd(users.length, 'vue')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 19,
                      ),
                    ),
                    // BODY
                    const SizedBox(
                      height: 25,
                    ),
                  ]..addAll(
                      users
                          .map((user) => UserCard(
                                user: user,
                                status: '',
                                onTap: () {
                                  // None
                                },
                              ))
                          .toList(),
                    ),
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

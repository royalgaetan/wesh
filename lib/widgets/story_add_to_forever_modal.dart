import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wesh/models/forever.dart';
import 'package:wesh/pages/in.pages/create_or_update_forever.dart';
import 'package:wesh/utils/constants.dart';

import '../models/story.dart';
import '../providers/user.provider.dart';
import '../services/firestore.methods.dart';
import 'buildWidgets.dart';
import 'button.dart';

class AddtoForeverModal extends StatefulWidget {
  final Story story;

  const AddtoForeverModal({super.key, required this.story});

  @override
  State<AddtoForeverModal> createState() => _AddtoForeverModalState();
}

class _AddtoForeverModalState extends State<AddtoForeverModal> {
  @override
  Widget build(BuildContext context) {
    return (() {
      // No one has seen your story yet
      return StreamBuilder(
        stream:
            Provider.of<UserProvider>(context).getForevers(widget.story.uid),
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
            List<Forever> forevers = snapshot.data as List<Forever>;

            // Sort forevers List
            forevers.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));

            // No forever found
            if (forevers.length == 0) {
              return Container(
                padding: EdgeInsets.all(30),
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      height: 120,
                      'assets/animations/112136-empty-red.json',
                      width: double.infinity,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Aucun forever trouvé !',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Edit or create forever !
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => (const CreateOrUpdateForeverPage()),
                          ),
                        );
                      },
                      child: const Text('+ Créer un forever'),
                    )
                  ],
                ),
              );
            }

            // Forevers found
            else if (forevers.length > 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10, left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ajouter aux Forevers',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 19,
                          ),
                        ),
                        Button(
                          text: 'Créer',
                          height: 45,
                          width: 150,
                          fontsize: 16,
                          fontColor: Colors.black,
                          color: Colors.white,
                          isBordered: true,
                          prefixIcon: Icons.add,
                          prefixIconColor: Colors.black,
                          prefixIconSize: 22,
                          onTap: () {
                            // Edit or create forever !
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    (const CreateOrUpdateForeverPage()),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // BODY
                    const SizedBox(
                      height: 25,
                    ),
                  ]..addAll(forevers
                      .map((forever) {
                        ValueNotifier<bool> isLoading =
                            ValueNotifier<bool>(false);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: InkWell(
                            onTap: !isLoading.value
                                ? () async {
                                    isLoading.value = true;
                                    debugPrint(
                                        'Is loading : ${isLoading.value}');

                                    // Add/Delete Story in Forever
                                    await FirestoreMethods()
                                        .AddOrDeleteStoryInsideForever(
                                            context,
                                            widget.story.storyId,
                                            forever.foreverId);
                                    isLoading.value = false;
                                    debugPrint(
                                        'Is loading : ${isLoading.value}');
                                  }
                                : null,
                            child: Row(
                              children: [
                                // Forever Cover
                                buildForeverCover(
                                  forever: forever,
                                ),

                                // Forever Title
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10),
                                    child: Text(
                                      forever.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17),
                                    ),
                                  ),
                                ),

                                // Forever : IsChecked(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 16, left: 10),
                                  child: ValueListenableBuilder(
                                    valueListenable: isLoading,
                                    builder: (context, value, child) {
                                      return isLoading.value
                                          ? const CupertinoActivityIndicator(
                                              color: Colors.black54,
                                            )
                                          : forever.stories.contains(
                                                  widget.story.storyId)
                                              ? const Icon(Icons.done,
                                                  color: kSecondColor)
                                              : Container();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      })
                      .toList()
                      .reversed),
                ),
              );
            }
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
    }());
  }
}

import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:wesh/models/forever.dart';
import 'package:wesh/pages/in.pages/create_or_update_forever.dart';
import 'package:wesh/utils/constants.dart';
import '../models/story.dart';
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
        stream: FirestoreMethods.getForevers(widget.story.uid),
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
            List<Forever> forevers = snapshot.data as List<Forever>;

            // Sort forevers List
            forevers.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));

            // No forever found
            if (forevers.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(30),
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      height: 100,
                      empty,
                      width: double.infinity,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'You have no forever!',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black45,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Redirect to Create a Forever Page
                        Navigator.push(
                            context,
                            SwipeablePageRoute(
                              builder: (context) => const CreateOrUpdateForeverPage(),
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          "+ Create one here",
                          style: TextStyle(fontSize: 14, color: kSecondColor),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Forevers found
            else if (forevers.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 20, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add to Forevers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 17.sp,
                            ),
                          ),
                          Button(
                            text: 'Create',
                            height: 0.12.sw,
                            width: 0.3.sw,
                            fontsize: 13.sp,
                            fontColor: Colors.black,
                            color: Colors.white,
                            isBordered: true,
                            prefixIcon: Icons.add,
                            prefixIconColor: Colors.black,
                            prefixIconSize: 19.sp,
                            onTap: () {
                              // Create forever !
                              Navigator.push(
                                context,
                                SwipeablePageRoute(
                                  builder: (_) => (const CreateOrUpdateForeverPage()),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ...forevers
                        .map((forever) {
                          ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            child: InkWell(
                              onTap: !isLoading.value
                                  ? () async {
                                      isLoading.value = true;
                                      log('Is loading : ${isLoading.value}');

                                      // Add/Delete Story in Forever
                                      await FirestoreMethods.AddOrDeleteStoryInsideForever(
                                          context, widget.story.storyId, forever.foreverId);
                                      isLoading.value = false;
                                      log('Is loading : ${isLoading.value}');
                                    }
                                  : null,
                              child: Row(
                                children: [
                                  // Forever Cover
                                  BuildForeverCover(
                                    foreverId: forever.foreverId,
                                    radius: 0.06.sw,
                                    contentPadding: 5,
                                  ),

                                  // Forever Title
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 10, left: 10),
                                      child: Text(
                                        forever.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14.sp),
                                      ),
                                    ),
                                  ),

                                  // Forever : IsChecked(),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16, left: 10),
                                    child: ValueListenableBuilder(
                                      valueListenable: isLoading,
                                      builder: (context, value, child) {
                                        return isLoading.value
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child: RepaintBoundary(
                                                  child: CircularProgressIndicator(
                                                      strokeWidth: 1.6, color: Colors.black87),
                                                ),
                                              )
                                            : forever.stories.contains(widget.story.storyId)
                                                ? const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: kSecondColor,
                                                    size: 25,
                                                  )
                                                : const Icon(
                                                    Icons.circle_outlined,
                                                    color: Colors.black87,
                                                    size: 25,
                                                  );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        })
                        .toList()
                        .reversed,

                    // BODY
                  ],
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

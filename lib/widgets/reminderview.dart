import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wesh/pages/in.pages/create_or_update_reminder.dart';
import 'package:wesh/services/firestore.methods.dart';
import 'package:wesh/widgets/buildWidgets.dart';
import '../models/reminder.dart';
import '../utils/constants.dart';
import 'button.dart';

class ReminderView extends StatefulWidget {
  final String reminderId;
  const ReminderView({super.key, required this.reminderId});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Reminder>(
      stream: FirestoreMethods().getReminderById(widget.reminderId),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          debugPrint('error: ${snapshot.error}');
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 100),
            child: Center(
              child: buildErrorWidget(onWhiteBackground: true),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          Reminder reminder = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rappel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 19.sp,
                      ),
                    ),
                    Button(
                      text: 'Modifier',
                      height: 0.12.sw,
                      width: double.infinity,
                      fontsize: 13.sp,
                      fontColor: Colors.black,
                      color: Colors.white,
                      isBordered: true,
                      prefixIcon: Icons.edit,
                      prefixIconColor: Colors.black,
                      prefixIconSize: 19,
                      onTap: () {
                        // Edit Event here !
                        Navigator.push(
                          context,
                          SwipeablePageRoute(
                            builder: (_) => (CreateOrUpdateReminderPage(reminder: reminder)),
                          ),
                        );
                        ;
                      },
                    ),
                  ],
                ),
                // BODY
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              reminder.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 17.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      // ReminderFrom
                      reminder.eventId.isNotEmpty
                          ? Row(
                              children: [
                                buildEventNameToDisplay(
                                  eventId: reminder.eventId,
                                  appendText: 'sur ',
                                )
                              ],
                            )
                          : Text(
                              'du ${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(reminder.remindFrom)} à ${DateFormat('HH:mm', 'fr_Fr').format(reminder.remindFrom)}',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 15,
                              ),
                            ),

                      const SizedBox(
                        height: 20,
                      ),

                      // Reminder
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Me rappeler ',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 15,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: reminder.reminderDelay,
                                style: const TextStyle(color: kSecondColor, fontWeight: FontWeight.bold)),
                            reminder.recurrence.isNotEmpty && reminder.recurrence != 'Aucune récurrence'
                                ? TextSpan(
                                    text: ', ${reminder.recurrence.toLowerCase()}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ))
                                : const TextSpan(),
                          ],
                        ),
                      )

                      //
                    ],
                  ),
                )
              ],
            ),
          );
        }

        // Diplay Loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30, top: 20),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade400,
                  child: CircleAvatar(
                    radius: 0.1.sw,
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade400,
                child: Container(
                    margin: const EdgeInsets.only(bottom: 2), width: 200, height: 19, color: Colors.grey.shade400),
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade400,
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 2), width: 250, height: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade400,
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 2), width: 250, height: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade400,
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 2), width: 250, height: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}

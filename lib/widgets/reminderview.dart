// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
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
      stream: FirestoreMethods.getReminderById(widget.reminderId),
      builder: (context, snapshot) {
        // Handle error
        if (snapshot.hasError) {
          debugPrint('error: ${snapshot.error}');
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Center(
              child: BuildErrorWidget(onWhiteBackground: true),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          Reminder reminder = snapshot.data!;

          //
          // setCurrentActivePageFromIndex(index: 7, userId: reminder.reminderId);

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reminder',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17.sp,
                      ),
                    ),
                    Button(
                      text: 'Edit',
                      height: 0.1.sw,
                      width: 0.25.sw,
                      fontsize: 12.sp,
                      fontColor: Colors.black,
                      color: Colors.white,
                      isBordered: true,
                      prefixIcon: Icons.edit,
                      prefixIconColor: Colors.black,
                      prefixIconSize: 13.sp,
                      onTap: () {
                        // Edit Event here !
                        Navigator.push(
                          context,
                          SwipeablePageRoute(
                            builder: (_) => (CreateOrUpdateReminderPage(reminder: reminder)),
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
                        height: 10,
                      ),

                      // ReminderFrom
                      reminder.eventId.isNotEmpty
                          ? Row(
                              children: [
                                BuildEventNameToDisplay(
                                  eventId: reminder.eventId,
                                  appendText: 'of ',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.black.withOpacity(0.7),
                                )
                              ],
                            )
                          : Text(
                              'of ${DateFormat('EEE, d MMM yyyy', 'en_En').format(reminder.remindFrom)} \nat ${DateFormat('HH:mm', 'en_En').format(reminder.remindFrom)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 12.sp,
                              ),
                            ),

                      const SizedBox(
                        height: 20,
                      ),

                      // Reminder
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Remind me ',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 12.sp,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: reminder.reminderDelay.toLowerCase(),
                                style: const TextStyle(color: kSecondColor, fontWeight: FontWeight.bold)),
                            reminder.recurrence.isNotEmpty && reminder.recurrence != 'No recurrence'
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
              Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade300,
                child: Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 2),
                  width: 190,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: List.generate(
                  3,
                  (index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade300,
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 7,
                          top: index == 2 ? 15 : 0,
                        ),
                        width: 150,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade300,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wesh/widgets/reminderView.dart';
import '../models/reminder.dart';
import 'modal.dart';

class ReminderCard extends StatefulWidget {
  final Reminder reminder;

  ReminderCard({required this.reminder});

  @override
  State<ReminderCard> createState() => _EventCardState();
}

class _EventCardState extends State<ReminderCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show ReminderView Modal
        showModalBottomSheet(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          backgroundColor: Colors.transparent,
          builder: ((context) => Scaffold(
                backgroundColor: Colors.transparent,
                body: Modal(
                  child: ReminderView(reminderId: widget.reminder.reminderId),
                ),
              )),
        );
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Trailing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                    radius: 22,
                    child: widget.reminder.eventId.isEmpty
                        ? const Icon(
                            FontAwesomeIcons.calendar,
                          )
                        : const Icon(
                            FontAwesomeIcons.splotch,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),

                // Reminder content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reminder.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14.sp),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.stopwatch, size: 12.sp, color: Colors.black.withOpacity(0.4)),
                          const SizedBox(width: 6),
                          Text(
                            widget.reminder.reminderDelay,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis, fontSize: 12.sp, color: Colors.black.withOpacity(0.7)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

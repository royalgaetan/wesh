import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wesh/widgets/reminderView.dart';
import '../models/reminder.dart';
import 'modal.dart';

class ReminderCard extends StatefulWidget {
  final Reminder reminder;

  const ReminderCard({super.key, required this.reminder});

  @override
  State<ReminderCard> createState() => _EventCardState();
}

class _EventCardState extends State<ReminderCard> {
  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Trailing
            CircleAvatar(
              radius: 0.07.sw,
              child: widget.reminder.eventId.isEmpty
                  ? Icon(
                      Icons.calendar_month_rounded,
                      size: 25.sp,
                    )
                  : Icon(
                      FontAwesomeIcons.splotch,
                      size: 19.sp,
                    ),
            ),
            const SizedBox(width: 15),

            // Reminder content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.reminder.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13.sp),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.stopwatch, size: 11.sp, color: Colors.black.withOpacity(0.4)),
                      const SizedBox(width: 6),
                      Text(
                        widget.reminder.reminderDelay,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis, fontSize: 11.sp, color: Colors.black.withOpacity(0.7)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

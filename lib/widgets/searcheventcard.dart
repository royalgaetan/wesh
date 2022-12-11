import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wesh/models/event.dart';

import '../utils/constants.dart';
import 'buildWidgets.dart';

class SearchEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const SearchEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Row(
          children: [
            Hero(
              tag: event.eventId,
              child: event.trailing.isNotEmpty
                  ? CircleAvatar(backgroundColor: kGreyColor, radius: 22, backgroundImage: NetworkImage(event.trailing))
                  : CircleAvatar(
                      radius: 22,
                      backgroundColor: kGreyColor,
                      backgroundImage: AssetImage('assets/images/eventtype.icons/${event.type}.png'),
                    ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact name
                  Wrap(
                    children: [
                      Text(
                        event.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14.sp),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),

                  // Contact username
                  Row(
                    children: [
                      buildAvatarAndUsername(
                        uidPoster: event.uid,
                        radius: 0.02.sw,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            event.type == 'birthday' ? Icons.cake_rounded : Icons.calendar_today,
                            size: 14.sp,
                            color: Colors.black54,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Wrap(
                            children: [
                              Text(
                                DateFormat(event.type == 'birthday' ? 'dd MMMM' : 'EEE, d MMM yyyy', 'fr_Fr').format(
                                  event.eventDurations.isNotEmpty
                                      ? (event.eventDurations[0]['date'] as Timestamp).toDate()
                                      : DateTime.now(),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wesh/models/event.dart';
import '../utils/constants.dart';
import '../utils/functions.dart';
import 'buildWidgets.dart';

class SearchEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const SearchEventCard({Key? key, required this.event, required this.onTap}) : super(key: key);

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
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Main Trailing
                  event.trailing.isEmpty
                      ? Container(
                          width: 0.14.sw,
                          height: 0.14.sw,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: kGreyColor,
                            image: DecorationImage(
                              image: AssetImage('assets/images/eventtype.icons/${event.type}.png'),
                              colorFilter: isOutdatedEvent(event)
                                  ? ColorFilter.mode(Colors.grey.shade200, BlendMode.saturation)
                                  : null,
                            ),
                          ),
                        )
                      : buildCachedNetworkImage(
                          url: event.trailing,
                          radius: 0.075.sw,
                          backgroundColor: kGreyColor,
                          paddingOfProgressIndicator: 10,
                          blendMode: isOutdatedEvent(event) ? BlendMode.saturation : null,
                        ),

                  // Outdate || isHappening Indicator
                  isOutdatedEvent(event) || isHappeningEvent(event)
                      ? CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 0.024.sw,
                          child: Padding(
                            padding: EdgeInsets.all(0.009.sw),
                            child: CircleAvatar(
                              backgroundColor: isOutdatedEvent(event) == true ? kWarningColor : kSecondColor,
                              radius: 0.024.sw,
                            ),
                          ),
                        )
                      : Container()
                ],
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
                            isEventWithRecurrence(event) ? Icons.cake_rounded : Icons.calendar_today,
                            size: 14.sp,
                            color: Colors.black54,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Wrap(
                            children: [
                              Text(
                                DateFormat(isEventWithRecurrence(event) ? 'dd MMMM' : 'EEE, d MMM yyyy', 'fr_Fr')
                                    .format(
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

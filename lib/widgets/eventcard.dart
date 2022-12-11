import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import '../models/event.dart';
import '../pages/profile.dart';
import '../utils/constants.dart';
import 'buildWidgets.dart';
import 'eventview.dart';
import 'modal.dart';

class EventCard extends StatefulWidget {
  final Event event;

  EventCard({required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show EventView Modal
        showModalBottomSheet(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          backgroundColor: Colors.transparent,
          builder: ((context) => Modal(
                minHeightSize: MediaQuery.of(context).size.height / 1.4,
                maxHeightSize: MediaQuery.of(context).size.height,
                child: EventView(eventId: widget.event.eventId),
              )),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.only(top: 5, bottom: 5, right: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trailing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Hero(
                    tag: widget.event.eventId,
                    child: widget.event.trailing.isNotEmpty
                        ? CircleAvatar(
                            backgroundColor: kGreyColor,
                            radius: 22,
                            backgroundImage: NetworkImage(widget.event.trailing))
                        : CircleAvatar(
                            radius: 22,
                            backgroundColor: kGreyColor,
                            backgroundImage: AssetImage('assets/images/eventtype.icons/${widget.event.type}.png'),
                          ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event name
                      Wrap(
                        children: [
                          Text(
                            widget.event.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14.sp),
                          ),
                        ],
                      ),

                      //  Event Decription
                      widget.event.caption.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                widget.event.caption,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 14.sp,
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            )
                          : Container(),

                      const SizedBox(
                        height: 10,
                      ),

                      // Event Poster Name

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildAvatarAndUsername(
                            uidPoster: widget.event.uid,
                            radius: 0.02.sw,
                          ),
                          Row(
                            children: [
                              Icon(
                                widget.event.type == 'birthday' ? Icons.cake_rounded : Icons.calendar_today,
                                size: 14.sp,
                                color: Colors.black54,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(DateFormat(widget.event.type == 'birthday' ? 'dd MMMM' : 'EEE, d MMM yyyy', 'fr_Fr')
                                  .format((widget.event.eventDurations[0]['date'] as Timestamp).toDate()))
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Divider
            const SizedBox(height: 10),

            const SizedBox(
              width: double.infinity,
              child: Divider(
                height: 1,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

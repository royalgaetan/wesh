import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wesh/utils/functions.dart';
import '../models/event.dart';
import '../utils/constants.dart';
import 'buildWidgets.dart';
import 'eventview.dart';
import 'modal.dart';

class EventCard extends StatefulWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
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
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Main Trailing
                        widget.event.trailing.isEmpty
                            ? Container(
                                width: 0.14.sw,
                                height: 0.14.sw,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: kGreyColor,
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/eventtype.icons/${widget.event.type}.png'),
                                    colorFilter: isOutdatedEvent(widget.event)
                                        ? ColorFilter.mode(Colors.grey.shade200, BlendMode.saturation)
                                        : null,
                                  ),
                                ),
                              )
                            : buildCachedNetworkImage(
                                url: widget.event.trailing,
                                radius: 0.075.sw,
                                backgroundColor: kGreyColor,
                                paddingOfProgressIndicator: 10,
                                blendMode: isOutdatedEvent(widget.event) ? BlendMode.saturation : null,
                              ),

                        // Outdate || isHappening Indicator
                        isOutdatedEvent(widget.event) || isHappeningEvent(widget.event)
                            ? CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 0.024.sw,
                                child: Padding(
                                  padding: EdgeInsets.all(0.009.sw),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        isOutdatedEvent(widget.event) == true ? kWarningColor : kSecondColor,
                                    radius: 0.024.sw,
                                  ),
                                ),
                              )
                            : Container()
                      ],
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildAvatarAndUsername(
                            uidPoster: widget.event.uid,
                            fontSize: 12.sp,
                            radius: 0.02.sw,
                          ),
                          Row(
                            children: [
                              Icon(
                                isEventWithRecurrence(widget.event) ? Icons.cake_rounded : Icons.calendar_today,
                                size: 14.sp,
                                color: Colors.black54,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                DateFormat(isEventWithRecurrence(widget.event) ? 'dd MMMM' : 'EEE, d MMM yyyy', 'fr_Fr')
                                    .format((widget.event.eventDurations[0]['date'] as Timestamp).toDate().toLocal()),
                                style: TextStyle(fontSize: 12.sp),
                              )
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

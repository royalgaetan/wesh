import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../models/event.dart';
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
                maxChildSize: 1,
                initialChildSize: .8,
                minChildSize: .8,
                child: EventView(event: widget.event),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.event.trailing.isNotEmpty
                          ? CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage(widget.event.trailing))
                          : CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(
                                  'assets/images/eventtype.icons/${widget.event.type}.png'),
                            ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),

                // Event content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),

                      widget.event.caption.isNotEmpty
                          ? Column(
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  widget.event.caption,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(0.6)),
                                )
                              ],
                            )
                          : Container(),
                      SizedBox(height: 10),

                      // Event Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Avatar + Username
                          buildAvatarAndUsername(uidPoster: widget.event.uid),

                          // Time and Date info
                          Expanded(
                            child: Column(
                              children: [
                                // Date Info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(FontAwesomeIcons.calendar,
                                        size: 15, color: Colors.black54),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      DateFormat('EEE, d MMM yyyy', 'fr_Fr')
                                          .format(widget.event.startDateTime),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),

                                // Time Info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(FontAwesomeIcons.clock,
                                        size: 15, color: Colors.black54),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      '${DateFormat('HH:mm', 'fr_Fr').format(widget.event.startDateTime)} à ${DateFormat('HH:mm', 'fr_Fr').format(widget.event.endDateTime)}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

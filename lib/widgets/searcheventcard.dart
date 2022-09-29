import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wesh/models/event.dart';

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
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(event.trailing),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact name
                  Text(
                    '${event.title} : ${event.eventId}',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  SizedBox(
                    height: 5,
                  ),

                  // Contact username
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.calendar, size: 14),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        '${DateFormat('EEE, d MMM yyyy', 'fr_Fr').format(event.startDateTime)}',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '|',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      Icon(FontAwesomeIcons.clock, size: 14),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        '${DateFormat('hh:mm', 'fr_Fr').format(event.endDateTime)} à ${DateFormat('hh:mm', 'fr_Fr').format(event.endDateTime)}',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }
}

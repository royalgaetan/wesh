import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wesh/models/event.dart';

import '../utils/constants.dart';

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
                  ? CircleAvatar(
                      backgroundColor: kGreyColor,
                      radius: 30,
                      backgroundImage: NetworkImage(event.trailing))
                  : CircleAvatar(
                      radius: 30,
                      backgroundColor: kGreyColor,
                      backgroundImage: AssetImage(
                          'assets/images/eventtype.icons/${event.type}.png'),
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
                  Text(
                    '${event.title}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  const SizedBox(
                    height: 5,
                  ),

                  // Contact username
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.calendar, size: 14),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        DateFormat('EEE, d MMM yyyy', 'fr_Fr')
                            .format(event.startDateTime),
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: const Text(
                          '|',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Icon(FontAwesomeIcons.clock, size: 14),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        '${DateFormat('HH:mm', 'fr_Fr').format(event.startDateTime)} à ${DateFormat('HH:mm', 'fr_Fr').format(event.endDateTime)}',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
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

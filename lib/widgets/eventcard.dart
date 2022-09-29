import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class EventCard extends StatefulWidget {
  final String trailing;
  final String title;
  final String caption;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  EventCard(
      {required this.trailing,
      required this.title,
      required this.caption,
      required this.date,
      required this.startTime,
      required this.endTime});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trailing
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.purple.shade300,
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.black.withOpacity(0.4),
                  //       offset: Offset(1, 4),
                  //       blurRadius: 3,
                  //       spreadRadius: 3),
                  // ],
                ),
                child: Image.asset(widget.trailing),
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),

          // Event content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  widget.caption,
                  style: TextStyle(
                      fontSize: 14, color: Colors.black.withOpacity(0.6)),
                ),
                SizedBox(height: 10),

                // Event Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar + Username
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 13,
                          backgroundImage:
                              AssetImage('assets/images/avatar 6.jpg'),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Username',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // Time info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.clock,
                          size: 19,
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Text(
                          '${DateFormat('hh:mm', 'fr_Fr').format(widget.startTime)} à ${DateFormat('hh:mm', 'fr_Fr').format(widget.endTime)}',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  child: Divider(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  ListTile(
//         leading: Container(
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: Colors.grey.shade200),
//             child: Icon(event.icon)),
//         title: Text(event.title),
//         subtitle: Text(event.subTitle),
//       );
